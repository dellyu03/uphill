"""
수행 기록 Service Layer
수행 기록 관련 비즈니스 로직을 담당합니다.
"""
from typing import List
from datetime import datetime, timezone
from repositories.execution_repository import ExecutionRepository
from api.schemas import ExecutionCreate, ExecutionResponse, DailySummaryResponse
import logging

logger = logging.getLogger(__name__)


class ExecutionService:
    """
    수행 기록 비즈니스 로직 서비스
    데이터 검증, 변환, 통계 계산 등을 담당합니다.
    """

    def __init__(self):
        """ExecutionService 초기화"""
        self.repository = ExecutionRepository()

    def validate_date_format(self, date_str: str) -> bool:
        """
        날짜 형식을 검증합니다. (YYYY-MM-DD)

        Args:
            date_str: 검증할 날짜 문자열

        Returns:
            bool: 유효한 형식이면 True

        Raises:
            ValueError: 잘못된 형식일 경우
        """
        try:
            datetime.strptime(date_str, '%Y-%m-%d')
            return True
        except ValueError:
            raise ValueError("Invalid date format. Use YYYY-MM-DD")

    def parse_started_at(self, started_at: str) -> str:
        """
        시작 시간에서 날짜를 추출합니다.

        Args:
            started_at: ISO8601 형식의 시작 시간

        Returns:
            str: YYYY-MM-DD 형식의 날짜

        Raises:
            ValueError: 잘못된 형식일 경우
        """
        try:
            started_dt = datetime.fromisoformat(started_at.replace('Z', '+00:00'))
            return started_dt.strftime('%Y-%m-%d')
        except ValueError:
            raise ValueError("Invalid date format for started_at")

    def create_execution(self, uid: str, routine_id: str, execution: ExecutionCreate) -> ExecutionResponse:
        """
        수행 기록을 생성합니다.

        Args:
            uid: 사용자 ID
            routine_id: 루틴 ID
            execution: 수행 기록 생성 데이터

        Returns:
            ExecutionResponse: 생성된 수행 기록

        Raises:
            ValueError: 루틴이 존재하지 않거나 날짜 형식이 잘못된 경우
        """
        logger.info(f"📝 수행 기록 생성 - UID: {uid}, Routine: {routine_id}")

        # 루틴 존재 확인
        if not self.repository.routine_exists(uid, routine_id):
            raise ValueError("Routine not found")

        # 날짜 추출
        date_str = self.parse_started_at(execution.started_at)

        # 현재 시간
        now = datetime.now(timezone.utc).isoformat()

        # 저장할 데이터 준비
        execution_data = {
            "routine_id": routine_id,
            "routine_title": execution.routine_title,
            "started_at": execution.started_at,
            "ended_at": execution.ended_at,
            "duration_seconds": execution.duration_seconds,
            "date": date_str,
            "created_at": now,
        }

        # Repository를 통해 저장
        execution_id = self.repository.create(uid, execution_data)

        return ExecutionResponse(
            id=execution_id,
            routine_id=routine_id,
            routine_title=execution.routine_title,
            started_at=execution.started_at,
            ended_at=execution.ended_at,
            duration_seconds=execution.duration_seconds,
            date=date_str,
            created_at=now,
        )

    def get_daily_summary(self, uid: str, date: str) -> DailySummaryResponse:
        """
        특정 날짜의 수행 통계를 조회합니다.

        Args:
            uid: 사용자 ID
            date: 조회할 날짜 (YYYY-MM-DD)

        Returns:
            DailySummaryResponse: 일간 수행 통계
        """
        logger.info(f"📋 일간 수행 기록 조회 - Date: {date}")

        # 날짜 형식 검증
        self.validate_date_format(date)

        # Repository에서 데이터 조회
        executions_data = self.repository.get_by_date(uid, date)

        # Response 모델로 변환
        executions = []
        total_duration = 0

        for data in executions_data:
            executions.append(ExecutionResponse(
                id=data.get("id", ""),
                routine_id=data.get("routine_id", ""),
                routine_title=data.get("routine_title", ""),
                started_at=data.get("started_at", ""),
                ended_at=data.get("ended_at", ""),
                duration_seconds=data.get("duration_seconds", 0),
                date=data.get("date", ""),
                created_at=data.get("created_at", ""),
            ))
            total_duration += data.get("duration_seconds", 0)

        # 시작 시간순 정렬
        executions.sort(key=lambda x: x.started_at)

        logger.info(f"✅ 일간 기록 조회 성공: {len(executions)}개")

        return DailySummaryResponse(
            date=date,
            total_routines=len(executions),
            total_duration_seconds=total_duration,
            executions=executions
        )
