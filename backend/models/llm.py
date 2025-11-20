from __future__ import annotations

import json
from typing import Iterable

from langchain_community.llms import Ollama


PROMPT_TEMPLATE = """
당신은 루틴 및 시간관리 전문가 입니다. 아래 일상 루틴을 1~5 사이 정수 점수로 평가하고 JSON으로만 답하세요.
JSON 형식:
{{
  "score": 1~5 정수,
  "summary": "장점과 목적 적합도 1문단",
  "risk": "주의할 점 1문장",
  "tip": "개선 팁 1문장"
}}

루틴 정보:
- 이름: {name}
- 목표: {goal}
- 단계:
{steps}
"""


def get_ollama_gptoss_model(base_url: str = "http://localhost:11434") -> Ollama:
    """
    langchain에서 Ollama의 gpt-oss 모델을 불러오는 함수
    """
    return Ollama(
        model="gpt-oss",
        base_url=base_url,
    )


def evaluate_routine_with_gptoss(*, name: str, goal: str, steps: Iterable[str]) -> dict[str, str]:
    """
    루틴 정보를 받아 gpt-oss 모델이 평가한 JSON 응답을 반환한다.
    """
    prompt = PROMPT_TEMPLATE.format(
        name=name,
        goal=goal,
        steps="\n".join(f"  - {step}" for step in steps) or "  (단계 미입력)",
    )
    llm = get_ollama_gptoss_model()
    raw = llm.invoke(prompt).strip()
    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError:
        parsed = {
            "score": 3,
            "summary": raw,
            "risk": "LLM 응답을 해석할 수 없어 기본값을 사용했습니다.",
            "tip": "루틴의 강약 조절을 다시 확인하세요.",
        }
    parsed["raw_feedback"] = raw
    return parsed
