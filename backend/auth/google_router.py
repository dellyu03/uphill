from fastapi import APIRouter, HTTPException
from auth.schemas import GoogleLogin
from google.oauth2 import id_token
from google.auth.transport import requests
from firebase_admin import auth
import os
import logging

router = APIRouter(prefix="/auth", tags=["GoogleAuth"])

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID")


@router.post("/google")
async def google_login(payload: GoogleLogin):
    id_token_str = payload.id_token

    try:
        google_user = id_token.verify_oauth2_token(
            id_token_str,
            requests.Request(),
            GOOGLE_CLIENT_ID,
        )
    except Exception as e:
        logger.error(f"Google ID Token verification failed: {e}")
        raise HTTPException(status_code=401, detail="Invalid Google ID Token")

    email = google_user.get("email")
    name = google_user.get("name")
    picture = google_user.get("picture")
    uid = google_user.get("sub")

    logger.info("=" * 60)
    logger.info("🔐 Google 로그인 성공!")
    logger.info(f"👤 사용자 정보:")
    logger.info(f"   - UID: {uid}")
    logger.info(f"   - 이름: {name}")
    logger.info(f"   - 이메일: {email}")
    logger.info(f"   - 프로필 사진: {picture}")
    logger.info("=" * 60)

    try:
        user = auth.get_user(uid)
        logger.info(f"✅ 기존 사용자 로그인: {email}")
    except auth.UserNotFoundError:
        user = auth.create_user(
            uid=uid,
            email=email,
            display_name=name,
            photo_url=picture
        )
        logger.info(f"🆕 새 사용자 생성: {email}")

    firebase_custom_token = auth.create_custom_token(uid).decode("utf-8")

    return {
        "message": "Google login success",
        "uid": uid,
        "email": email,
        "name": name,
        "picture": picture,
        "firebase_token": firebase_custom_token
    }