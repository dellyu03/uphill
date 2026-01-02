from fastapi import APIRouter, HTTPException
import logging
from firebase_admin import auth

router = APIRouter(prefix="/user", tags=["User"])

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@router.get("/info")
def get_user_info(uid: str):
    """
    Google 로그인 이후 전달받은 Firebase UID로
    Firebase Auth 사용자 정보를 조회하여 반환합니다.

    TODO:
        - Firestore / RDB 와 연동해서 실제 비즈니스 도메인 유저 정보로 확장
        - 인증 미들웨어를 붙여서 Authorization 헤더의 ID 토큰에서 uid 추출
    """

    logger.info("=" * 60)
    logger.info("📊 사용자 정보 조회 요청 수신")
    logger.info(f"   - UID: {uid}")
    logger.info("=" * 60)

    try:
        firebase_user = auth.get_user(uid)
    except auth.UserNotFoundError:
        logger.warning(f"⚠️ Firebase에 존재하지 않는 UID 요청: {uid}")
        raise HTTPException(status_code=404, detail="User not found")
    except Exception as e:
        logger.error(f"❌ Firebase 사용자 정보 조회 실패: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch user info")

    user_info = {
        "uid": firebase_user.uid,
        "email": firebase_user.email,
        "name": firebase_user.display_name,
        "picture": firebase_user.photo_url,
        # 필요 시 추가 필드 확장
    }

    logger.info(f"📤 반환 데이터: {user_info}")

    return user_info