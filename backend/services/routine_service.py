"""
루틴 Service Layer
루틴 관련 비즈니스 로직을 담당합니다.
"""
from typing import List, Optional
from datetime import datetime
from repositories.routine_repository import FirestoreRoutineRepository
from api.schemas import RoutineCreate, RoutineUpdate, RoutineResponse
from services.ai_feedback import generate_space_solution
import logging

logger = logging.getLogger(__name__)


class RoutineService:
    """
    루틴 비즈니스 로직 서비스
    데이터 검증, 변환 등의 비즈니스 로직을 담당합니다.
    """

    def __init__(self):
        """RoutineService 초기화"""
        self.repository = FirestoreRoutineRepository()

    def validate_time_format(self, time_str: str) -> bool:
        """
        시간 형식을 검증합니다. (HH:MM)

        Args:
            time_str: 검증할 시간 문자열

        Returns:
            bool: 유효한 형식이면 True

        Raises:
            ValueError: 잘못된 형식일 경우
        """
        time_parts = time_str.split(":")
        if len(time_parts) != 2:
            raise ValueError("Invalid time format. Expected HH:MM")

        try:
            hour, minute = int(time_parts[0]), int(time_parts[1])
        except ValueError:
            raise ValueError("Invalid time format. Expected HH:MM")

        if not (0 <= hour < 24 and 0 <= minute < 60):
            raise ValueError("Invalid time values. Hour must be 0-23, minute must be 0-59")

        return True

    def create_routine(self, uid: str, routine: RoutineCreate) -> RoutineResponse:
        """
        새로운 루틴을 생성합니다.

        Args:
            uid: 사용자 ID
            routine: 루틴 생성 데이터

        Returns:
            RoutineResponse: 생성된 루틴 정보
        """
        logger.info(f"📝 루틴 생성 요청 - UID: {uid}, 제목: {routine.title}")

        # 시간 형식 검증
        self.validate_time_format(routine.time)

        # 현재 시간
        now_str = datetime.utcnow().isoformat()

        # 저장할 데이터 준비
        routine_data = {
            "uid": uid,
            "title": routine.title,
            "time": routine.time,
            "category": routine.category,
            "color": routine.color,
            "days": routine.days,
            # 프리미엄 UI 추가 필드
            "purpose": routine.purpose,
            "space": routine.space,
            "description": routine.description,
            "is_flexible": routine.is_flexible,
            "notification_time": routine.notification_time,
            "end_time": routine.end_time,
            "iot_devices": routine.iot_devices,
            # AI 공간 솔루션 및 평면도
            "space_solution": routine.space_solution,
            "floor_plan_image_url": routine.floor_plan_image_url,
            "created_at": now_str,
            "updated_at": now_str,
        }

        # Repository를 통해 저장
        routine_id = self.repository.create(uid, routine_data)

        return RoutineResponse(
            id=routine_id,
            uid=uid,
            title=routine.title,
            time=routine.time,
            category=routine.category,
            color=routine.color,
            days=routine.days,
            purpose=routine.purpose,
            space=routine.space,
            description=routine.description,
            is_flexible=routine.is_flexible,
            notification_time=routine.notification_time,
            end_time=routine.end_time,
            iot_devices=routine.iot_devices,
            space_solution=routine.space_solution,
            floor_plan_image_url=routine.floor_plan_image_url,
            created_at=now_str,
            updated_at=now_str,
        )

    def get_all_routines(self, uid: str) -> List[RoutineResponse]:
        """
        사용자의 모든 루틴을 조회합니다.

        Args:
            uid: 사용자 ID

        Returns:
            List[RoutineResponse]: 루틴 목록 (시간순 정렬)
        """
        logger.info(f"📋 루틴 조회 요청 - UID: {uid}")

        # Repository에서 데이터 조회
        routines_data = self.repository.get_all_by_user(uid)

        # Response 모델로 변환
        routines = [
            RoutineResponse(
                id=data.get("id", ""),
                uid=data.get("uid", uid),
                title=data.get("title", ""),
                time=data.get("time", ""),
                category=data.get("category", ""),
                color=data.get("color"),
                days=data.get("days"),
                purpose=data.get("purpose"),
                space=data.get("space"),
                description=data.get("description"),
                is_flexible=data.get("is_flexible"),
                notification_time=data.get("notification_time"),
                end_time=data.get("end_time"),
                iot_devices=data.get("iot_devices"),
                space_solution=data.get("space_solution"),
                floor_plan_image_url=data.get("floor_plan_image_url"),
                created_at=data.get("created_at", ""),
                updated_at=data.get("updated_at", ""),
            )
            for data in routines_data
        ]

        # 시간순 정렬
        routines.sort(key=lambda x: x.time)

        logger.info(f"✅ 루틴 조회 성공: {len(routines)}개")
        return routines

    def get_routine_by_id(self, uid: str, routine_id: str) -> Optional[RoutineResponse]:
        """
        특정 루틴을 조회합니다.

        Args:
            uid: 사용자 ID
            routine_id: 루틴 ID

        Returns:
            Optional[RoutineResponse]: 루틴 정보 (없으면 None)
        """
        logger.info(f"📋 루틴 상세 조회 - ID: {routine_id}")

        data = self.repository.get_by_id(uid, routine_id)
        if data is None:
            return None

        return RoutineResponse(
            id=data.get("id", ""),
            uid=data.get("uid", uid),
            title=data.get("title", ""),
            time=data.get("time", ""),
            category=data.get("category", ""),
            color=data.get("color"),
            days=data.get("days"),
            purpose=data.get("purpose"),
            space=data.get("space"),
            description=data.get("description"),
            is_flexible=data.get("is_flexible"),
            notification_time=data.get("notification_time"),
            end_time=data.get("end_time"),
            iot_devices=data.get("iot_devices"),
            space_solution=data.get("space_solution"),
            floor_plan_image_url=data.get("floor_plan_image_url"),
            created_at=data.get("created_at", ""),
            updated_at=data.get("updated_at", ""),
        )

    def update_routine(self, uid: str, routine_id: str, routine_update: RoutineUpdate) -> Optional[RoutineResponse]:
        """
        루틴을 수정합니다.

        Args:
            uid: 사용자 ID
            routine_id: 루틴 ID
            routine_update: 수정할 데이터

        Returns:
            Optional[RoutineResponse]: 수정된 루틴 정보 (없으면 None)
        """
        logger.info(f"✏️ 루틴 수정 요청 - ID: {routine_id}")

        # 루틴 존재 확인
        existing = self.repository.get_by_id(uid, routine_id)
        if existing is None:
            return None

        # 시간 형식 검증 (제공된 경우)
        if routine_update.time:
            self.validate_time_format(routine_update.time)

        # 업데이트 데이터 준비
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
        if routine_update.days is not None:
            update_data["days"] = routine_update.days
        # 프리미엄 UI 추가 필드
        if routine_update.purpose is not None:
            update_data["purpose"] = routine_update.purpose
        if routine_update.space is not None:
            update_data["space"] = routine_update.space
        if routine_update.description is not None:
            update_data["description"] = routine_update.description
        if routine_update.is_flexible is not None:
            update_data["is_flexible"] = routine_update.is_flexible
        if routine_update.notification_time is not None:
            update_data["notification_time"] = routine_update.notification_time
        if routine_update.end_time is not None:
            update_data["end_time"] = routine_update.end_time
        if routine_update.iot_devices is not None:
            update_data["iot_devices"] = routine_update.iot_devices

        # Repository를 통해 업데이트
        updated_data = self.repository.update(uid, routine_id, update_data)

        if updated_data is None:
            return None

        return RoutineResponse(
            id=updated_data.get("id", ""),
            uid=updated_data.get("uid", uid),
            title=updated_data.get("title", ""),
            time=updated_data.get("time", ""),
            category=updated_data.get("category", ""),
            color=updated_data.get("color"),
            days=updated_data.get("days"),
            purpose=updated_data.get("purpose"),
            space=updated_data.get("space"),
            description=updated_data.get("description"),
            is_flexible=updated_data.get("is_flexible"),
            notification_time=updated_data.get("notification_time"),
            end_time=updated_data.get("end_time"),
            iot_devices=updated_data.get("iot_devices"),
            space_solution=updated_data.get("space_solution"),
            floor_plan_image_url=updated_data.get("floor_plan_image_url"),
            created_at=updated_data.get("created_at", ""),
            updated_at=updated_data.get("updated_at", ""),
        )

    def get_space_solution(
        self,
        routine_title: str,
        purpose: str,
        description: str,
        detected_furniture: List[str],
    ) -> dict:
        """
        루틴 정보와 감지된 가구 목록을 기반으로 AI 공간 배치 솔루션 텍스트와
        DALL-E 3 평면도 이미지 URL을 생성합니다.

        Args:
            routine_title: 루틴 이름
            purpose: 루틴 목적 (예: 운동, 독서, 명상)
            description: 추구하는 환경과 활동 설명
            detected_furniture: YOLO11로 감지된 가구 목록

        Returns:
            dict: {"solution": 솔루션 텍스트, "floor_plan_image_url": 이미지 URL or None}
        """
        logger.info(f"🏠 공간 솔루션 생성 요청 - 루틴: {routine_title}, 가구: {detected_furniture}")
        return generate_space_solution(
            routine_title=routine_title,
            purpose=purpose,
            description=description,
            detected_furniture=detected_furniture,
        )

    def delete_routine(self, uid: str, routine_id: str) -> bool:
        """
        루틴을 삭제합니다.

        Args:
            uid: 사용자 ID
            routine_id: 루틴 ID

        Returns:
            bool: 삭제 성공 여부
        """
        logger.info(f"🗑️ 루틴 삭제 요청 - ID: {routine_id}")
        return self.repository.delete(uid, routine_id)
