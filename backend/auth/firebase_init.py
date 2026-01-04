import firebase_admin
from firebase_admin import credentials, auth
import os
import json


FIREBASE_SERVICE_ACCOUNT_KEY = os.getenv("FIREBASE_SERVICE_ACCOUNT_KEY")
FIREBASE_SERVICE_ACCOUNT_PATH = os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH", "serviceAccountKey.json")

if FIREBASE_SERVICE_ACCOUNT_KEY:
    try:
        service_account_dict = json.loads(FIREBASE_SERVICE_ACCOUNT_KEY)
        cred = credentials.Certificate(service_account_dict)
    except json.JSONDecodeError:
        cred = credentials.Certificate(FIREBASE_SERVICE_ACCOUNT_KEY)
elif os.path.exists(FIREBASE_SERVICE_ACCOUNT_PATH):
    cred = credentials.Certificate(FIREBASE_SERVICE_ACCOUNT_PATH)
else:
    cred = None
    import logging
    logger = logging.getLogger(__name__)
    logger.warning("Firebase 서비스 계정 키를 찾을 수 없습니다. Firebase 기능이 비활성화됩니다.")

if not firebase_admin._apps and cred:
    firebase_admin.initialize_app(cred)