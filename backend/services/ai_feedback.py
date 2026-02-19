import os
import json
import logging
from pathlib import Path
from typing import List, Optional
from dotenv import load_dotenv
from openai import OpenAI
from api.schemas import DailySummaryResponse

# 환경 변수 로드
load_dotenv()

logger = logging.getLogger(__name__)

# OpenAI 클라이언트 초기화
_openai_client = None

# 프롬프트 파일 경로
PROMPTS_DIR = Path(__file__).parent.parent / "prompts"
SYSTEM_PROMPT_FILE = PROMPTS_DIR / "feedback_system_prompt.txt"
USER_PROMPT_TEMPLATE_FILE = PROMPTS_DIR / "feedback_user_prompt_template.txt"
SPACE_SOLUTION_SYSTEM_PROMPT_FILE = PROMPTS_DIR / "space_solution_system_prompt.txt"
SPACE_SOLUTION_USER_PROMPT_TEMPLATE_FILE = PROMPTS_DIR / "space_solution_user_prompt_template.txt"
FLOOR_PLAN_PROMPT_TEMPLATE_FILE = PROMPTS_DIR / "floor_plan_prompt_template.txt"


def get_openai_client() -> OpenAI:
    """OpenAI 클라이언트를 반환합니다 (lazy initialization)"""
    global _openai_client
    if _openai_client is None:
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OPENAI_API_KEY 환경 변수가 설정되지 않았습니다")
        _openai_client = OpenAI(api_key=api_key)
    return _openai_client


def load_prompt(file_path: Path) -> str:
    """프롬프트 파일을 읽어옵니다."""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return f.read().strip()
    except FileNotFoundError:
        logger.error(f"프롬프트 파일을 찾을 수 없습니다: {file_path}")
        raise
    except Exception as e:
        logger.error(f"프롬프트 파일 읽기 실패: {e}")
        raise


def generate_ai_feedback(summary: DailySummaryResponse) -> dict:
    """
    OpenAI API를 사용하여 수행 기록 기반 AI 피드백을 생성합니다.

    Args:
        summary: 일간 수행 통계

    Returns:
        dict: short, full, recommendations 키를 가진 피드백 딕셔너리
    """
    total_mins = summary.total_duration_seconds // 60
    count = summary.total_routines

    # 수행 기록 상세 정보 구성
    executions_detail = []
    for exec in summary.executions:
        exec_mins = exec.duration_seconds // 60
        executions_detail.append({
            "title": exec.routine_title,
            "started_at": exec.started_at,
            "ended_at": exec.ended_at,
            "duration_minutes": exec_mins
        })

    # OpenAI API 호출
    try:
        client = get_openai_client()

        # 외부 프롬프트 파일 로드
        system_prompt = load_prompt(SYSTEM_PROMPT_FILE)
        user_prompt_template = load_prompt(USER_PROMPT_TEMPLATE_FILE)

        # 프롬프트 템플릿에 데이터 삽입
        executions_json = json.dumps(executions_detail, ensure_ascii=False, indent=2) if executions_detail else "없음"
        user_prompt = user_prompt_template.format(
            date=summary.date,
            count=count,
            total_mins=total_mins,
            executions_detail=executions_json
        )

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            temperature=0.7,
            max_tokens=500
        )

        result_text = response.choices[0].message.content.strip()

        # JSON 파싱 (```json 블록 제거)
        if result_text.startswith("```"):
            result_text = result_text.split("```")[1]
            if result_text.startswith("json"):
                result_text = result_text[4:]
        result_text = result_text.strip()

        feedback = json.loads(result_text)

        logger.info(f"✅ OpenAI 피드백 생성 성공: {feedback['short']}")

        return {
            "short": feedback.get("short", "오늘도 수고했어요!"),
            "full": feedback.get("full", "루틴을 꾸준히 수행하고 있네요. 계속 파이팅!"),
            "recommendations": feedback.get("recommendations", ["스트레칭", "물 마시기", "명상"])
        }

    except Exception as e:
        logger.error(f"❌ OpenAI API 호출 실패: {e}")
        # 폴백: 기본 피드백 반환
        return generate_fallback_feedback(summary)


def generate_space_solution(
    routine_title: str,
    purpose: str,
    description: str,
    detected_furniture: List[str],
) -> dict:
    """
    루틴 정보와 YOLO11로 감지된 가구 목록을 기반으로 OpenAI API를 사용해
    공간 배치 최적화 솔루션 텍스트와 DALL-E 3 평면도 이미지 URL을 함께 생성합니다.

    Args:
        routine_title: 루틴 이름
        purpose: 루틴 목적 (예: 운동, 독서, 명상)
        description: 추구하는 환경과 활동 설명
        detected_furniture: YOLO11로 감지된 가구 목록 (예: ["침대", "책상", "의자"])

    Returns:
        dict: {
            "solution": AI가 생성한 공간 변경 솔루션 텍스트,
            "floor_plan_image_url": DALL-E 3 생성 평면도 이미지 URL (실패 시 None)
        }
    """
    # 프롬프트 파일 로드
    system_prompt = load_prompt(SPACE_SOLUTION_SYSTEM_PROMPT_FILE)
    user_prompt_template = load_prompt(SPACE_SOLUTION_USER_PROMPT_TEMPLATE_FILE)

    furniture_text = ", ".join(detected_furniture) if detected_furniture else "감지된 가구 없음"

    user_prompt = user_prompt_template.format(
        routine_title=routine_title,
        purpose=purpose,
        description=description,
        furniture_text=furniture_text,
    )

    # 폴백 솔루션 텍스트 (GPT 실패 시)
    fallback_solution = (
        f"{furniture_text} 중 루틴에 필요한 동선을 확보해주세요. "
        f"{purpose} 활동에 적합하도록 공간을 정리하고, "
        "방해 요소가 되는 물건은 한쪽으로 치워두세요."
    ) if detected_furniture else (
        f"{purpose} 루틴을 위해 충분한 활동 공간을 확보해주세요. "
        "불필요한 물건을 정리하고 루틴에 집중할 수 있는 환경을 만들어보세요."
    )

    # Step 1. GPT로 솔루션 텍스트 생성
    solution = fallback_solution
    try:
        client = get_openai_client()

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0.7,
            max_tokens=400,
        )

        solution = response.choices[0].message.content.strip()
        logger.info(f"✅ 공간 솔루션 생성 성공: {solution[:50]}...")

    except Exception as e:
        logger.error(f"❌ 공간 솔루션 GPT 호출 실패: {e}")

    # Step 2. DALL-E 3로 평면도 이미지 생성
    floor_plan_image_url = generate_floor_plan_image(
        purpose=purpose,
        furniture_text=furniture_text,
        solution_summary=solution[:200],  # 프롬프트 길이 제한을 위해 요약
    )

    return {
        "solution": solution,
        "floor_plan_image_url": floor_plan_image_url,
    }


def generate_floor_plan_image(
    purpose: str,
    furniture_text: str,
    solution_summary: str,
) -> Optional[str]:
    """
    DALL-E 3 API를 사용하여 공간 솔루션 기반 평면도 이미지를 생성합니다.

    Args:
        purpose: 루틴 목적
        furniture_text: 감지된 가구 목록 텍스트
        solution_summary: 공간 솔루션 요약 (200자 이내)

    Returns:
        Optional[str]: DALL-E 3가 생성한 이미지 URL (실패 시 None)
                       주의: 이미지 URL은 약 1시간 후 만료됩니다.
    """
    try:
        client = get_openai_client()

        prompt_template = load_prompt(FLOOR_PLAN_PROMPT_TEMPLATE_FILE)
        image_prompt = prompt_template.format(
            purpose=purpose,
            furniture_text=furniture_text,
            solution_summary=solution_summary,
        )

        response = client.images.generate(
            model="dall-e-3",
            prompt=image_prompt,
            size="1024x1024",
            quality="standard",
            n=1,
        )

        image_url = response.data[0].url
        logger.info(f"✅ 평면도 이미지 생성 성공")
        return image_url

    except Exception as e:
        logger.error(f"❌ DALL-E 3 평면도 생성 실패: {e}")
        return None


def generate_fallback_feedback(summary: DailySummaryResponse) -> dict:
    """OpenAI API 실패 시 기본 피드백을 반환합니다."""
    total_mins = summary.total_duration_seconds // 60
    count = summary.total_routines

    if count == 0:
        return {
            "short": "오늘은 아직 완료한 루틴이 없어요",
            "full": "괜찮아요, 작은 것부터 시작해보세요. 5분짜리 스트레칭이나 물 한 잔 마시기 같은 간단한 것도 좋아요!",
            "recommendations": ["5분 스트레칭", "물 마시기", "짧은 산책"]
        }
    elif count == 1:
        routine_name = summary.executions[0].routine_title if summary.executions else "루틴"
        return {
            "short": f"좋은 시작! '{routine_name}' 완료",
            "full": f"오늘 '{routine_name}'을 완료하고 {total_mins}분을 투자했네요. 내일은 하나 더 추가해볼까요?",
            "recommendations": ["독서 10분", "명상 5분", "일기 쓰기"]
        }
    elif count <= 3:
        return {
            "short": f"잘하고 있어요! {count}개 완료",
            "full": f"오늘 {count}개의 루틴을 완료하고 총 {total_mins}분을 투자했네요. 이 페이스 유지하면 큰 변화가 올 거예요!",
            "recommendations": ["새로운 루틴 도전", "루틴 시간 늘리기"]
        }
    else:
        return {
            "short": f"대단해요! {count}개 완료!",
            "full": f"오늘 {count}개 루틴을 완료하고 총 {total_mins}분을 투자했어요. 정말 대단해요!",
            "recommendations": ["충분한 휴식", "내일도 화이팅"]
        }
