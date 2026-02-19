import os
import json
import logging
from pathlib import Path
from typing import List
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
) -> str:
    """
    루틴 정보와 YOLO11로 감지된 가구 목록을 기반으로 OpenAI API를 사용해
    공간 배치 최적화 솔루션을 생성합니다.

    Args:
        routine_title: 루틴 이름
        purpose: 루틴 목적 (예: 운동, 독서, 명상)
        description: 추구하는 환경과 활동 설명
        detected_furniture: YOLO11로 감지된 가구 목록 (예: ["침대", "책상", "의자"])

    Returns:
        str: AI가 생성한 공간 변경 솔루션 텍스트 (2-3문장)
    """
    system_prompt = (
        "당신은 공간 최적화 전문가입니다. "
        "사용자의 루틴 정보와 현재 공간의 가구 배치를 분석하여, "
        "루틴을 더 효율적으로 수행할 수 있는 구체적인 공간 변경 솔루션을 제안합니다. "
        "실용적이고 실행 가능한 제안을 2-3문장으로 간결하게 작성하세요."
    )

    furniture_text = ", ".join(detected_furniture) if detected_furniture else "감지된 가구 없음"

    user_prompt = (
        f"루틴 이름: {routine_title}\n"
        f"루틴 목적: {purpose}\n"
        f"추구하는 환경/활동: {description}\n"
        f"현재 공간의 가구: {furniture_text}\n\n"
        "위 정보를 바탕으로 이 루틴을 위한 최적의 공간 변경 솔루션을 한국어로 작성해주세요."
    )

    try:
        client = get_openai_client()

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0.7,
            max_tokens=300,
        )

        solution = response.choices[0].message.content.strip()
        logger.info(f"✅ 공간 솔루션 생성 성공: {solution[:50]}...")
        return solution

    except Exception as e:
        logger.error(f"❌ 공간 솔루션 OpenAI 호출 실패: {e}")
        # 폴백: 가구 정보 기반 기본 솔루션 반환
        if detected_furniture:
            return (
                f"{furniture_text} 중 루틴에 필요한 동선을 확보해주세요. "
                f"{purpose} 활동에 적합하도록 공간을 정리하고, "
                "방해 요소가 되는 물건은 한쪽으로 치워두세요."
            )
        return (
            f"{purpose} 루틴을 위해 충분한 활동 공간을 확보해주세요. "
            "불필요한 물건을 정리하고 루틴에 집중할 수 있는 환경을 만들어보세요."
        )


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
