"""
루틴 API Layer
HTTP 요청/응답 처리만 담당합니다.
비즈니스 로직은 Service Layer에서 처리합니다.
"""
from fastapi import APIRouter, HTTPException, Depends
from auth.middleware import verify_firebase_token
from api.schemas import RoutineCreate, RoutineUpdate, RoutineResponse, SpaceSolutionRequest, SpaceSolutionResponse
from services.routine_service import RoutineService
from typing import List
import logging

router = APIRouter(prefix="/routines", tags=["Routines"])

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Service 인스턴스 (Singleton)
routine_service = RoutineService()


@router.post("", response_model=RoutineResponse, status_code=201)
async def create_routine(
    routine: RoutineCreate,
    uid: str = Depends(verify_firebase_token)
):
    """
    새로운 루틴을 생성합니다.

    Args:
        routine: 루틴 생성 정보
        uid: 인증된 사용자의 uid (미들웨어에서 자동 추출)

    Returns:
        RoutineResponse: 생성된 루틴 정보
    """
    try:
        # Service Layer 호출
        return routine_service.create_routine(uid, routine)

    except ValueError as e:
        # 비즈니스 로직 검증 실패 (400 Bad Request)
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        # 예상치 못한 에러 (500 Internal Server Error)
        logger.error(f"❌ 루틴 생성 실패: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to create routine: {str(e)}")


@router.get("", response_model=List[RoutineResponse])
async def get_routines(
    uid: str = Depends(verify_firebase_token)
):
    """
    현재 로그인한 사용자의 모든 루틴을 조회합니다.

    Args:
        uid: 인증된 사용자의 uid (미들웨어에서 자동 추출)

    Returns:
        List[RoutineResponse]: 사용자의 루틴 목록
    """
    try:
        # Service Layer 호출
        return routine_service.get_all_routines(uid)

    except Exception as e:
        logger.error(f"❌ 루틴 조회 실패: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch routines: {str(e)}")


@router.post("/space-solution", response_model=SpaceSolutionResponse)
async def generate_space_solution(
    request: SpaceSolutionRequest,
    uid: str = Depends(verify_firebase_token)
):
    """
    루틴 정보와 YOLO11로 감지된 가구 목록을 기반으로 AI 공간 배치 솔루션을 생성합니다.

    Args:
        request: 루틴 제목, 목적, 추구하는 환경/활동, 감지된 가구 목록
        uid: 인증된 사용자의 uid (미들웨어에서 자동 추출)

    Returns:
        SpaceSolutionResponse: AI가 생성한 공간 변경 솔루션 텍스트
    """
    try:
        result = routine_service.get_space_solution(
            routine_title=request.routine_title,
            purpose=request.purpose,
            description=request.description,
            detected_furniture=request.detected_furniture,
        )
        return SpaceSolutionResponse(
            solution=result["solution"],
            floor_plan_image_url=result.get("floor_plan_image_url"),
        )

    except Exception as e:
        logger.error(f"❌ 공간 솔루션 생성 실패: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to generate space solution: {str(e)}")


@router.get("/{routine_id}", response_model=RoutineResponse)
async def get_routine(
    routine_id: str,
    uid: str = Depends(verify_firebase_token)
):
    """
    특정 루틴의 상세 정보를 조회합니다.

    Args:
        routine_id: 루틴 ID
        uid: 인증된 사용자의 uid (미들웨어에서 자동 추출)

    Returns:
        RoutineResponse: 루틴 상세 정보
    """
    try:
        # Service Layer 호출
        routine = routine_service.get_routine_by_id(uid, routine_id)

        # 루틴이 없으면 404
        if routine is None:
            raise HTTPException(status_code=404, detail="Routine not found")

        return routine

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ 루틴 조회 실패: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch routine: {str(e)}")


@router.put("/{routine_id}", response_model=RoutineResponse)
async def update_routine(
    routine_id: str,
    routine_update: RoutineUpdate,
    uid: str = Depends(verify_firebase_token)
):
    """
    루틴을 수정합니다.

    Args:
        routine_id: 루틴 ID
        routine_update: 수정할 루틴 정보
        uid: 인증된 사용자의 uid (미들웨어에서 자동 추출)

    Returns:
        RoutineResponse: 수정된 루틴 정보
    """
    try:
        # Service Layer 호출
        routine = routine_service.update_routine(uid, routine_id, routine_update)

        # 루틴이 없으면 404
        if routine is None:
            raise HTTPException(status_code=404, detail="Routine not found")

        return routine

    except ValueError as e:
        # 비즈니스 로직 검증 실패 (400 Bad Request)
        raise HTTPException(status_code=400, detail=str(e))
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ 루틴 수정 실패: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to update routine: {str(e)}")


@router.delete("/{routine_id}", status_code=204)
async def delete_routine(
    routine_id: str,
    uid: str = Depends(verify_firebase_token)
):
    """
    루틴을 삭제합니다.

    Args:
        routine_id: 루틴 ID
        uid: 인증된 사용자의 uid (미들웨어에서 자동 추출)
    """
    try:
        # Service Layer 호출
        deleted = routine_service.delete_routine(uid, routine_id)

        # 루틴이 없으면 404
        if not deleted:
            raise HTTPException(status_code=404, detail="Routine not found")

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ 루틴 삭제 실패: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to delete routine: {str(e)}")
