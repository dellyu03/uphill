"""
수행 기록 API Layer
HTTP 요청/응답 처리만 담당합니다.
비즈니스 로직은 Service Layer에서 처리합니다.
"""
from fastapi import APIRouter, HTTPException, Depends, Query
from auth.middleware import verify_firebase_token
from api.schemas import ExecutionCreate, ExecutionResponse, DailySummaryResponse, DailyFeedbackResponse
from services.execution_service import ExecutionService
from services.ai_feedback import generate_ai_feedback
import logging

router = APIRouter(prefix="/executions", tags=["Executions"])

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Service 인스턴스 (Singleton)
execution_service = ExecutionService()


@router.post("/{routine_id}", response_model=ExecutionResponse, status_code=201)
async def create_execution(
    routine_id: str,
    execution: ExecutionCreate,
    uid: str = Depends(verify_firebase_token)
):
    """
    루틴 수행 기록을 저장합니다.

    Args:
        routine_id: 루틴 ID
        execution: 수행 기록 정보
        uid: 인증된 사용자의 uid

    Returns:
        ExecutionResponse: 생성된 수행 기록
    """
    try:
        # Service Layer 호출
        return execution_service.create_execution(uid, routine_id, execution)

    except ValueError as e:
        # 비즈니스 로직 검증 실패
        error_msg = str(e)
        if "not found" in error_msg.lower():
            raise HTTPException(status_code=404, detail=error_msg)
        raise HTTPException(status_code=400, detail=error_msg)
    except Exception as e:
        logger.error(f"❌ 수행 기록 생성 실패: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to create execution: {str(e)}")


@router.get("/daily", response_model=DailySummaryResponse)
async def get_daily_executions(
    date: str = Query(..., description="조회할 날짜 (YYYY-MM-DD 형식)"),
    uid: str = Depends(verify_firebase_token)
):
    """
    특정 날짜의 모든 수행 기록과 통계를 조회합니다.

    Args:
        date: 조회할 날짜 (YYYY-MM-DD)
        uid: 인증된 사용자의 uid

    Returns:
        DailySummaryResponse: 일간 수행 통계
    """
    try:
        # Service Layer 호출
        return execution_service.get_daily_summary(uid, date)

    except ValueError as e:
        # 날짜 형식 검증 실패 (400 Bad Request)
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"❌ 일간 기록 조회 실패: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch daily executions: {str(e)}")


@router.get("/daily/{date}/feedback", response_model=DailyFeedbackResponse)
async def get_daily_feedback(
    date: str,
    uid: str = Depends(verify_firebase_token)
):
    """
    특정 날짜의 AI 피드백을 생성합니다.

    Args:
        date: 조회할 날짜 (YYYY-MM-DD)
        uid: 인증된 사용자의 uid

    Returns:
        DailyFeedbackResponse: 일간 AI 피드백
    """
    try:
        # Service Layer에서 일간 통계 조회
        summary = execution_service.get_daily_summary(uid, date)

        # AI 피드백 생성 (별도 Service)
        ai_feedback = generate_ai_feedback(summary)

        logger.info(f"✅ AI 피드백 생성 성공")

        return DailyFeedbackResponse(
            date=date,
            summary=summary,
            ai_feedback_short=ai_feedback["short"],
            ai_feedback_full=ai_feedback["full"],
            recommended_routines=ai_feedback["recommendations"]
        )

    except ValueError as e:
        # 날짜 형식 검증 실패 (400 Bad Request)
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"❌ AI 피드백 생성 실패: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to generate feedback: {str(e)}")
