from fastapi import HTTPException, Header
from firebase_admin import auth
import logging

logger = logging.getLogger(__name__)


async def verify_firebase_token(authorization: str = Header(None)) -> str:
    if not authorization:
        logger.warning("⚠️ Authorization 헤더가 없습니다")
        raise HTTPException(
            status_code=401,
            detail="Authorization header is required"
        )
    
    try:
        # "Bearer <token>" 형식에서 토큰 추출
        parts = authorization.split()
        if len(parts) != 2 or parts[0].lower() != "bearer":
            raise HTTPException(
                status_code=401,
                detail="Invalid authorization header format. Expected: Bearer <token>"
            )
        
        token = parts[1]
        
        # Firebase ID Token 검증
        decoded_token = auth.verify_id_token(token)
        uid = decoded_token.get("uid")
        
        if not uid:
            raise HTTPException(
                status_code=401,
                detail="Token does not contain uid"
            )
        
        logger.info(f"✅ 토큰 검증 성공: uid={uid}")
        return uid
        
    except auth.InvalidIdTokenError as e:
        logger.error(f"❌ 유효하지 않은 ID Token: {e}")
        raise HTTPException(
            status_code=401,
            detail="Invalid Firebase ID Token"
        )
    except auth.ExpiredIdTokenError as e:
        logger.error(f"❌ 만료된 ID Token: {e}")
        raise HTTPException(
            status_code=401,
            detail="Expired Firebase ID Token"
        )
    except Exception as e:
        logger.error(f"❌ 토큰 검증 실패: {e}")
        raise HTTPException(
            status_code=401,
            detail=f"Token verification failed: {str(e)}"
        )

