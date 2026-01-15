from pydantic import BaseModel
from typing import Optional, List
from datetime import time


class RoutineCreate(BaseModel):
    """루틴 생성 요청 스키마"""
    title: str
    time: str  # "HH:MM" 형식
    category: str
    color: Optional[str] = None  # 색상 코드 (예: "#FF5722")
    days: Optional[List[int]] = None  # 반복 요일 (0=월, 1=화, ..., 6=일)


class RoutineUpdate(BaseModel):
    """루틴 수정 요청 스키마"""
    title: Optional[str] = None
    time: Optional[str] = None
    category: Optional[str] = None
    color: Optional[str] = None
    days: Optional[List[int]] = None  # 반복 요일 (0=월, 1=화, ..., 6=일)


class RoutineResponse(BaseModel):
    """루틴 응답 스키마"""
    id: str
    uid: str
    title: str
    time: str
    category: str
    color: Optional[str] = None
    days: Optional[List[int]] = None  # 반복 요일 (0=월, 1=화, ..., 6=일)
    created_at: str
    updated_at: str


# ===== 루틴 수행 기록 스키마 =====

class ExecutionCreate(BaseModel):
    """루틴 수행 기록 생성 요청 스키마"""
    routine_id: str
    routine_title: str
    started_at: str      # ISO8601 형식 (예: 2026-01-15T08:30:00Z)
    ended_at: str        # ISO8601 형식
    duration_seconds: int


class ExecutionResponse(BaseModel):
    """루틴 수행 기록 응답 스키마"""
    id: str
    routine_id: str
    routine_title: str
    started_at: str
    ended_at: str
    duration_seconds: int
    date: str            # YYYY-MM-DD (쿼리용)
    created_at: str


class DailySummaryResponse(BaseModel):
    """일간 수행 통계 응답 스키마"""
    date: str
    total_routines: int           # 완료된 루틴 수
    total_duration_seconds: int   # 총 수행 시간 (초)
    executions: List[ExecutionResponse]


class DailyFeedbackResponse(BaseModel):
    """일간 AI 피드백 응답 스키마"""
    date: str
    summary: DailySummaryResponse
    ai_feedback_short: str        # 한 줄 피드백
    ai_feedback_full: str         # 상세 피드백
    recommended_routines: List[str]  # 추천 루틴 목록

