from fastapi import APIRouter, HTTPException, Depends, Query
from firebase_admin import firestore
from auth.middleware import verify_firebase_token
from api.schemas import ExecutionCreate, ExecutionResponse, DailySummaryResponse, DailyFeedbackResponse
from datetime import datetime, timezone
from typing import List
import logging

# Firebase 초기화 확인
import auth.firebase_init

# AI 피드백 서비스
from services.ai_feedback import generate_ai_feedback

router = APIRouter(prefix="/executions", tags=["Executions"])

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def get_db():
    """Firestore 클라이언트를 가져옵니다 (lazy initialization)"""
    return firestore.client(database_id="uphilldb")


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
    logger.info("=" * 60)
    logger.info("📝 루틴 수행 기록 생성 요청")
    logger.info(f"   - UID: {uid}")
    logger.info(f"   - Routine ID: {routine_id}")
    logger.info(f"   - Title: {execution.routine_title}")
    logger.info(f"   - Duration: {execution.duration_seconds}초")
    logger.info("=" * 60)

    try:
        db = get_db()

        # 루틴 존재 확인
        routine_ref = db.collection("users").document(uid).collection("routines").document(routine_id)
        routine_doc = routine_ref.get()
        if not routine_doc.exists:
            raise HTTPException(status_code=404, detail="Routine not found")

        # 날짜 추출 (YYYY-MM-DD)
        try:
            started_dt = datetime.fromisoformat(execution.started_at.replace('Z', '+00:00'))
            date_str = started_dt.strftime('%Y-%m-%d')
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid date format for started_at")

        now = datetime.now(timezone.utc).isoformat()

        execution_data = {
            "routine_id": routine_id,
            "routine_title": execution.routine_title,
            "started_at": execution.started_at,
            "ended_at": execution.ended_at,
            "duration_seconds": execution.duration_seconds,
            "date": date_str,
            "created_at": now,
        }

        # executions 컬렉션에 저장
        doc_ref = db.collection("users").document(uid).collection("executions").document()
        doc_ref.set(execution_data)

        logger.info(f"✅ 수행 기록 생성 성공: {doc_ref.id}")

        return ExecutionResponse(
            id=doc_ref.id,
            routine_id=routine_id,
            routine_title=execution.routine_title,
            started_at=execution.started_at,
            ended_at=execution.ended_at,
            duration_seconds=execution.duration_seconds,
            date=date_str,
            created_at=now,
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ 수행 기록 생성 실패: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to create execution: {str(e)}"
        )


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
    logger.info(f"📋 일간 수행 기록 조회: {date}")

    try:
        # 날짜 형식 검증
        try:
            datetime.strptime(date, '%Y-%m-%d')
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD")

        db = get_db()

        # 해당 날짜의 수행 기록 조회
        executions_ref = db.collection("users").document(uid).collection("executions")
        query = executions_ref.where("date", "==", date)
        docs = query.stream()

        executions = []
        total_duration = 0

        for doc in docs:
            data = doc.to_dict()
            executions.append(ExecutionResponse(
                id=doc.id,
                routine_id=data.get("routine_id", ""),
                routine_title=data.get("routine_title", ""),
                started_at=data.get("started_at", ""),
                ended_at=data.get("ended_at", ""),
                duration_seconds=data.get("duration_seconds", 0),
                date=data.get("date", ""),
                created_at=data.get("created_at", ""),
            ))
            total_duration += data.get("duration_seconds", 0)

        # 시작 시간순으로 정렬
        executions.sort(key=lambda x: x.started_at)

        logger.info(f"✅ 일간 기록 조회 성공: {len(executions)}개")

        return DailySummaryResponse(
            date=date,
            total_routines=len(executions),
            total_duration_seconds=total_duration,
            executions=executions
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ 일간 기록 조회 실패: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch daily executions: {str(e)}"
        )


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
    logger.info(f"🤖 AI 피드백 생성 요청: {date}")

    try:
        # 먼저 일간 통계 조회
        summary = await get_daily_executions(date=date, uid=uid)

        # AI 피드백 생성
        ai_feedback = generate_ai_feedback(summary)

        logger.info(f"✅ AI 피드백 생성 성공")

        return DailyFeedbackResponse(
            date=date,
            summary=summary,
            ai_feedback_short=ai_feedback["short"],
            ai_feedback_full=ai_feedback["full"],
            recommended_routines=ai_feedback["recommendations"]
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ AI 피드백 생성 실패: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to generate feedback: {str(e)}"
        )
