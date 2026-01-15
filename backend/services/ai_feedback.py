import os
import json
import logging
from dotenv import load_dotenv
from openai import OpenAI
from api.schemas import DailySummaryResponse

# 환경 변수 로드
load_dotenv()

logger = logging.getLogger(__name__)

# OpenAI 클라이언트 초기화
_openai_client = None


def get_openai_client() -> OpenAI:
    """OpenAI 클라이언트를 반환합니다 (lazy initialization)"""
    global _openai_client
    if _openai_client is None:
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OPENAI_API_KEY 환경 변수가 설정되지 않았습니다")
        _openai_client = OpenAI(api_key=api_key)
    return _openai_client


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

        prompt = f"""당신은 사용자의 일간 루틴 수행을 분석하고 따뜻하고 격려하는 피드백을 제공하는 AI 코치입니다.

오늘 날짜: {summary.date}
완료한 루틴 수: {count}개
총 수행 시간: {total_mins}분

수행한 루틴 상세:
{json.dumps(executions_detail, ensure_ascii=False, indent=2) if executions_detail else "없음"}

위 정보를 바탕으로 다음 JSON 형식으로 피드백을 작성해주세요:
{{
    "short": "한 줄 요약 피드백 (20자 이내, 핵심 메시지)",
    "full": "상세 피드백 (2-3문장, 격려와 구체적인 조언 포함)",
    "recommendations": ["추천 루틴 1", "추천 루틴 2", "추천 루틴 3"]
}}

규칙:
1. short는 감정을 담아 짧고 임팩트 있게 작성
2. full은 오늘 수행한 루틴을 언급하며 구체적으로 격려
3. recommendations는 수행한 루틴의 카테고리나 시간대를 고려하여 보완할 수 있는 루틴 추천
4. 루틴이 없으면 시작하기 쉬운 간단한 루틴을 추천
5. 반드시 유효한 JSON만 출력하세요."""

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "당신은 친근하고 따뜻한 루틴 코치입니다. 항상 긍정적이고 격려하는 톤으로 말합니다. JSON 형식으로만 응답하세요."},
                {"role": "user", "content": prompt}
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
