import firebase_admin
from firebase_admin import credentials, auth
import os
import json

# 환경 변수에서 Firebase 서비스 계정 키를 받아서 파일로 생성
FIREBASE_SERVICE_ACCOUNT_KEY = os.getenv("FIREBASE_SERVICE_ACCOUNT_KEY")
FIREBASE_SERVICE_ACCOUNT_PATH = os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH", "serviceAccountKey.json")

if FIREBASE_SERVICE_ACCOUNT_KEY:
    # 환경 변수에서 JSON 문자열로 받은 경우
    try:
        service_account_dict = json.loads(FIREBASE_SERVICE_ACCOUNT_KEY)
        cred = credentials.Certificate(service_account_dict)
    except json.JSONDecodeError:
        # 이미 파일 경로인 경우
        cred = credentials.Certificate(FIREBASE_SERVICE_ACCOUNT_KEY)
elif os.path.exists(FIREBASE_SERVICE_ACCOUNT_PATH):
    # 파일 경로로 제공된 경우
    cred = credentials.Certificate(FIREBASE_SERVICE_ACCOUNT_PATH)
else:
    # Firebase 초기화 실패 (선택적 초기화)
    cred = None
    import logging
    logger = logging.getLogger(__name__)
    logger.warning("Firebase 서비스 계정 키를 찾을 수 없습니다. Firebase 기능이 비활성화됩니다.")

if not firebase_admin._apps and cred:
    firebase_admin.initialize_app(cred)