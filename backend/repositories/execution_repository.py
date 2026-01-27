"""
수행 기록 Repository Layer
Firestore 수행 기록 컬렉션에 대한 CRUD 작업만 수행합니다.
"""
from typing import List, Optional
from firebase_admin import firestore
import logging

logger = logging.getLogger(__name__)


class ExecutionRepository:
    """
    수행 기록 Firestore 저장소
    DB 접근 로직만 담당합니다.
    """

    def __init__(self, database_id: str = "uphilldb"):
        """
        ExecutionRepository 초기화

        Args:
            database_id: Firestore 데이터베이스 ID
        """
        self.database_id = database_id
        self._db = None

    def _get_db(self):
        """Firestore 클라이언트를 가져옵니다 (lazy initialization)"""
        if self._db is None:
            self._db = firestore.client(database_id=self.database_id)
        return self._db

    def create(self, uid: str, execution_data: dict) -> str:
        """
        새로운 수행 기록을 생성합니다.

        Args:
            uid: 사용자 ID
            execution_data: 수행 기록 데이터

        Returns:
            str: 생성된 문서 ID
        """
        db = self._get_db()
        doc_ref = db.collection("users").document(uid).collection("executions").document()
        doc_ref.set(execution_data)
        logger.info(f"✅ 수행 기록 생성 성공: {doc_ref.id}")
        return doc_ref.id

    def get_by_date(self, uid: str, date: str) -> List[dict]:
        """
        특정 날짜의 수행 기록을 조회합니다.

        Args:
            uid: 사용자 ID
            date: 조회할 날짜 (YYYY-MM-DD)

        Returns:
            List[dict]: 수행 기록 목록
        """
        db = self._get_db()
        executions_ref = db.collection("users").document(uid).collection("executions")
        query = executions_ref.where("date", "==", date)
        docs = query.stream()

        executions = []
        for doc in docs:
            data = doc.to_dict()
            data['id'] = doc.id
            executions.append(data)

        logger.info(f"✅ 수행 기록 조회 성공: {len(executions)}개")
        return executions

    def get_by_id(self, uid: str, execution_id: str) -> Optional[dict]:
        """
        특정 수행 기록을 조회합니다.

        Args:
            uid: 사용자 ID
            execution_id: 수행 기록 ID

        Returns:
            Optional[dict]: 수행 기록 데이터 (없으면 None)
        """
        db = self._get_db()
        doc_ref = db.collection("users").document(uid).collection("executions").document(execution_id)
        doc = doc_ref.get()

        if not doc.exists:
            return None

        data = doc.to_dict()
        data['id'] = doc.id
        return data

    def routine_exists(self, uid: str, routine_id: str) -> bool:
        """
        루틴이 존재하는지 확인합니다.

        Args:
            uid: 사용자 ID
            routine_id: 루틴 ID

        Returns:
            bool: 루틴 존재 여부
        """
        db = self._get_db()
        doc_ref = db.collection("users").document(uid).collection("routines").document(routine_id)
        doc = doc_ref.get()
        return doc.exists
