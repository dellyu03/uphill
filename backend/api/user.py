from fastapi import APIRouter
import logging

router = APIRouter(prefix="/user", tags=["User"])

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@router.get("/info")
def get_user_info(uid: str):
    # 여기서는 예시로 임의 정보 반환
    # 실제로는 Firebase Firestore에서 가져오면 됨

    logger.info("=" * 60)
    logger.info("📊 사용자 정보 조회")
    logger.info(f"   - UID: {uid}")
    logger.info("=" * 60)

    user_info = {
        "uid": uid,
        "role": "basic_user",
        "created_at": "2025-01-01",
    }

    logger.info(f"📤 반환 데이터: {user_info}")

    return user_info