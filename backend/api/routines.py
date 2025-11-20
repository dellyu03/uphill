from __future__ import annotations

import uuid
from typing import List

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field

from models.llm import evaluate_routine_with_gptoss

router = APIRouter(prefix="/routines", tags=["routines"])


class RoutineUpload(BaseModel):
    """사용자가 업로드하는 루틴 구조."""

    name: str = Field(..., description="루틴 제목")
    goal: str = Field(..., description="루틴의 주요 목표")
    steps: List[str] = Field(default_factory=list, description="루틴을 구성하는 단계 목록")


class RoutineEvaluation(BaseModel):
    """LLM 평가 결과"""

    id: str
    name: str
    goal: str
    steps: List[str]
    score: int = Field(ge=1, le=5, description="1~5 점수")
    summary: str
    risk: str
    tip: str
    raw_feedback: str = Field(description="LLM 원본 응답")


_evaluated_routines: list[RoutineEvaluation] = []


@router.post(
    "",
    response_model=RoutineEvaluation,
    status_code=status.HTTP_201_CREATED,
    summary="루틴 업로드 및 평가",
)
def upload_routine(payload: RoutineUpload) -> RoutineEvaluation:
    evaluation = evaluate_routine_with_gptoss(
        name=payload.name,
        goal=payload.goal,
        steps=payload.steps,
    )
    try:
        score = int(evaluation.get("score", 3))
    except (TypeError, ValueError):
        score = 3

    routine = RoutineEvaluation(
        id=str(uuid.uuid4()),
        name=payload.name,
        goal=payload.goal,
        steps=payload.steps,
        score=max(1, min(5, score)),
        summary=evaluation.get("summary", "요약 없음"),
        risk=evaluation.get("risk", "주의 사항 없음"),
        tip=evaluation.get("tip", "팁 없음"),
        raw_feedback=evaluation.get("raw_feedback", ""),
    )
    _evaluated_routines.append(routine)
    return routine


@router.get(
    "",
    response_model=list[RoutineEvaluation],
    summary="평가 완료된 루틴 목록 조회",
)
def list_routines() -> list[RoutineEvaluation]:
    if not _evaluated_routines:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="평가된 루틴이 없습니다.")
    return _evaluated_routines
