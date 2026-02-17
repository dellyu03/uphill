"""
방 스캔 API Layer
이미지 업로드 요청을 받아 YOLO11 분석을 수행하고 결과를 반환합니다.
"""
from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from auth.middleware import verify_firebase_token
from services.room_scan_service import RoomScanService
from pydantic import BaseModel
from typing import List
import logging

router = APIRouter(prefix="/room-scan", tags=["RoomScan"])

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Service 인스턴스 (Singleton)
room_scan_service = RoomScanService()


class RoomScanResponse(BaseModel):
    """
    방 스캔 분석 결과 응답 모델.

    Attributes:
        detected_furniture: 감지된 가구 이름 목록
    """

    detected_furniture: List[str]


@router.post("/analyze", response_model=RoomScanResponse)
async def analyze_room(
    image: UploadFile = File(...),
    uid: str = Depends(verify_firebase_token),
):
    """
    업로드된 방 이미지를 YOLO11로 분석하여 가구 목록을 반환합니다.

    Args:
        image: 분석할 방 사진 파일 (jpg, png 등)
        uid: 인증된 사용자의 uid (미들웨어에서 자동 추출)

    Returns:
        RoomScanResponse: 감지된 가구 이름 목록
    """
    try:
        # 이미지 바이트 데이터 읽기
        image_bytes = await image.read()

        # Service Layer 호출 - YOLO11 분석
        detected_furniture = room_scan_service.analyze_room_image(image_bytes)

        return RoomScanResponse(detected_furniture=detected_furniture)

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"❌ 방 스캔 분석 실패: {e}")
        raise HTTPException(
            status_code=500, detail=f"Failed to analyze room image: {str(e)}"
        )
