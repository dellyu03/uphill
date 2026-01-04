from pydantic import BaseModel
from typing import Optional
from datetime import time


class RoutineCreate(BaseModel):
    """루틴 생성 요청 스키마"""
    title: str
    time: str  # "HH:MM" 형식
    category: str
    color: Optional[str] = None  # 색상 코드 (예: "#FF5722")


class RoutineUpdate(BaseModel):
    """루틴 수정 요청 스키마"""
    title: Optional[str] = None
    time: Optional[str] = None
    category: Optional[str] = None
    color: Optional[str] = None


class RoutineResponse(BaseModel):
    """루틴 응답 스키마"""
    id: str
    uid: str
    title: str
    time: str
    category: str
    color: Optional[str] = None
    created_at: str
    updated_at: str

