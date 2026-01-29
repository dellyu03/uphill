import os
import json
import logging
from pathlib import Path
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
