from abc import ABC, abstractmethod
from typing import List, Optional
from firebase_admin import firestore
import logging

logger = logging.getLogger(__name__)


class IRoutineRepository(ABC):
    """루틴 저장소 인터페이스 (Dependency Inversion Principle)"""

    @abstractmethod
    def create(self, uid: str, routine_data: dict) -> str:
        pass

    @abstractmethod
    def get_all_by_user(self, uid: str) -> List[dict]:
        pass

    @abstractmethod
    def get_by_id(self, uid: str, routine_id: str) -> Optional[dict]:
        pass

    @abstractmethod
    def update(self, uid: str, routine_id: str, update_data: dict) -> dict:
        pass

    @abstractmethod
    def delete(self, uid: str, routine_id: str) -> bool:
        pass


class FirestoreRoutineRepository(IRoutineRepository):
    """Firestore 기반 루틴 저장소 구현 (Single Responsibility Principle)"""

    def __init__(self, database_id: str = "uphilldb"):
        self.database_id = database_id
        self._db = None

    def _get_db(self):
        """Firestore 클라이언트를 가져옵니다 (lazy initialization)"""
        if self._db is None:
            self._db = firestore.client(database_id=self.database_id)
        return self._db

    def create(self, uid: str, routine_data: dict) -> str:
        """새로운 루틴을 생성합니다"""
        db = self._get_db()
        doc_ref = db.collection("users").document(uid).collection("routines").document()
        doc_ref.set(routine_data)
        logger.info(f"✅ 루틴 생성 성공: {doc_ref.id}")
        return doc_ref.id

    def get_all_by_user(self, uid: str) -> List[dict]:
        """사용자의 모든 루틴을 조회합니다"""
        db = self._get_db()
        routines_ref = db.collection("users").document(uid).collection("routines")
        docs = routines_ref.stream()

        routines = []
        for doc in docs:
            data = doc.to_dict()
            data['id'] = doc.id
            routines.append(data)

        return routines

    def get_by_id(self, uid: str, routine_id: str) -> Optional[dict]:
        """특정 루틴의 상세 정보를 조회합니다"""
        db = self._get_db()
        doc_ref = db.collection("users").document(uid).collection("routines").document(routine_id)
        doc = doc_ref.get()

        if not doc.exists:
            return None

        data = doc.to_dict()
        data['id'] = doc.id
        return data

    def update(self, uid: str, routine_id: str, update_data: dict) -> dict:
        """루틴을 수정합니다"""
        db = self._get_db()
        doc_ref = db.collection("users").document(uid).collection("routines").document(routine_id)

        doc_ref.update(update_data)

        updated_doc = doc_ref.get()
        if not updated_doc.exists:
            return None

        data = updated_doc.to_dict()
        data['id'] = updated_doc.id
        logger.info(f"✅ 루틴 수정 성공: {routine_id}")
        return data

    def delete(self, uid: str, routine_id: str) -> bool:
        """루틴을 삭제합니다"""
        db = self._get_db()
        doc_ref = db.collection("users").document(uid).collection("routines").document(routine_id)

        doc = doc_ref.get()
        if not doc.exists:
            return False

        doc_ref.delete()
        logger.info(f"✅ 루틴 삭제 성공: {routine_id}")
        return True
