from fastapi import APIRouter, HTTPException, Depends
from firebase_admin import firestore
from auth.middleware import verify_firebase_token
from api.schemas import RoutineCreate, RoutineUpdate, RoutineResponse
import logging
from datetime import datetime
from typing import List

router = APIRouter(prefix="/routines", tags=["Routines"])

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Firebase 초기화 확인
import auth.firebase_init


def get_db():
    """Firestore 클라이언트를 가져옵니다 (lazy initialization)"""
    return firestore.client(database_id="uphilldb")


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
    logger.info("=" * 60)
    logger.info("📝 루틴 생성 요청 수신")
    logger.info(f"   - UID: {uid}")
    logger.info(f"   - 제목: {routine.title}")
    logger.info(f"   - 시간: {routine.time}")
    logger.info(f"   - 카테고리: {routine.category}")
    logger.info("=" * 60)
    
    try:
        # 시간 형식 검증 (HH:MM)
        time_parts = routine.time.split(":")
        if len(time_parts) != 2:
            raise HTTPException(
                status_code=400,
                detail="Invalid time format. Expected HH:MM"
            )
        hour, minute = int(time_parts[0]), int(time_parts[1])
        if not (0 <= hour < 24 and 0 <= minute < 60):
            raise HTTPException(
                status_code=400,
                detail="Invalid time values. Hour must be 0-23, minute must be 0-59"
            )
        
        # 현재 시간
        now = datetime.utcnow()
        now_str = now.isoformat()
        
        # Firestore에 루틴 저장
        routine_data = {
            "uid": uid,
            "title": routine.title,
            "time": routine.time,
            "category": routine.category,
            "color": routine.color,
            "created_at": now_str,
            "updated_at": now_str,
        }
        
        # 사용자별 루틴 컬렉션에 저장
        db = get_db()
        doc_ref = db.collection("users").document(uid).collection("routines").document()
        doc_ref.set(routine_data)
        
        routine_id = doc_ref.id
        
        logger.info(f"✅ 루틴 생성 성공: {routine_id}")
        
        return RoutineResponse(
            id=routine_id,
            uid=uid,
            title=routine.title,
            time=routine.time,
            category=routine.category,
            color=routine.color,
            created_at=now_str,
            updated_at=now_str,
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ 루틴 생성 실패: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to create routine: {str(e)}"
        )


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
    logger.info("=" * 60)
    logger.info("📋 루틴 조회 요청 수신")
    logger.info(f"   - UID: {uid}")
    logger.info("=" * 60)
    
    try:
        # 사용자의 루틴 컬렉션에서 모든 루틴 조회
        db = get_db()
        routines_ref = db.collection("users").document(uid).collection("routines")
        docs = routines_ref.stream()
        
        routines = []
        for doc in docs:
            data = doc.to_dict()
            routines.append(
                RoutineResponse(
                    id=doc.id,
                    uid=data.get("uid", uid),
                    title=data.get("title", ""),
                    time=data.get("time", ""),
                    category=data.get("category", ""),
                    color=data.get("color"),
                    created_at=data.get("created_at", ""),
                    updated_at=data.get("updated_at", ""),
                )
            )
        
        # 시간순으로 정렬
        routines.sort(key=lambda x: x.time)
        
        logger.info(f"✅ 루틴 조회 성공: {len(routines)}개")
        
        return routines
        
    except Exception as e:
        logger.error(f"❌ 루틴 조회 실패: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch routines: {str(e)}"
        )


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
    logger.info(f"📋 루틴 상세 조회 요청: {routine_id}")
    
    try:
        db = get_db()
        doc_ref = db.collection("users").document(uid).collection("routines").document(routine_id)
        doc = doc_ref.get()
        
        if not doc.exists:
            raise HTTPException(
                status_code=404,
                detail="Routine not found"
            )
        
        data = doc.to_dict()
        
        return RoutineResponse(
            id=doc.id,
            uid=data.get("uid", uid),
            title=data.get("title", ""),
            time=data.get("time", ""),
            category=data.get("category", ""),
            color=data.get("color"),
            created_at=data.get("created_at", ""),
            updated_at=data.get("updated_at", ""),
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ 루틴 조회 실패: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch routine: {str(e)}"
        )


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
    logger.info(f"✏️ 루틴 수정 요청: {routine_id}")
    
    try:
        db = get_db()
        doc_ref = db.collection("users").document(uid).collection("routines").document(routine_id)
        doc = doc_ref.get()
        
        if not doc.exists:
            raise HTTPException(
                status_code=404,
                detail="Routine not found"
            )
        
        # 시간 형식 검증 (제공된 경우)
        if routine_update.time:
            time_parts = routine_update.time.split(":")
            if len(time_parts) != 2:
                raise HTTPException(
                    status_code=400,
                    detail="Invalid time format. Expected HH:MM"
                )
            hour, minute = int(time_parts[0]), int(time_parts[1])
            if not (0 <= hour < 24 and 0 <= minute < 60):
                raise HTTPException(
                    status_code=400,
                    detail="Invalid time values. Hour must be 0-23, minute must be 0-59"
                )
        
        # 업데이트할 데이터 준비
        update_data = {
            "updated_at": datetime.utcnow().isoformat()
        }
        
        if routine_update.title is not None:
            update_data["title"] = routine_update.title
        if routine_update.time is not None:
            update_data["time"] = routine_update.time
        if routine_update.category is not None:
            update_data["category"] = routine_update.category
        if routine_update.color is not None:
            update_data["color"] = routine_update.color
        
        # Firestore 업데이트
        doc_ref.update(update_data)
        
        # 업데이트된 문서 가져오기
        updated_doc = doc_ref.get()
        data = updated_doc.to_dict()
        
        logger.info(f"✅ 루틴 수정 성공: {routine_id}")
        
        return RoutineResponse(
            id=updated_doc.id,
            uid=data.get("uid", uid),
            title=data.get("title", ""),
            time=data.get("time", ""),
            category=data.get("category", ""),
            color=data.get("color"),
            created_at=data.get("created_at", ""),
            updated_at=data.get("updated_at", ""),
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ 루틴 수정 실패: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to update routine: {str(e)}"
        )


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
    logger.info(f"🗑️ 루틴 삭제 요청: {routine_id}")
    
    try:
        db = get_db()
        doc_ref = db.collection("users").document(uid).collection("routines").document(routine_id)
        doc = doc_ref.get()
        
        if not doc.exists:
            raise HTTPException(
                status_code=404,
                detail="Routine not found"
            )
        
        doc_ref.delete()
        
        logger.info(f"✅ 루틴 삭제 성공: {routine_id}")
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ 루틴 삭제 실패: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to delete routine: {str(e)}"
        )

