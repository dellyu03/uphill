# Uphill - 백엔드 & AI 아키텍처 발표 자료

## 1. 기술 스택 (Tech Stack)

| 구분 | 기술 | 용도 |
|------|------|------|
| **Backend Framework** | FastAPI (Python 3.13) | REST API 서버 |
| **ASGI Server** | Uvicorn | 비동기 서버 구동 |
| **Database** | Firebase Firestore (`uphilldb`) | NoSQL 문서형 DB |
| **Authentication** | Firebase Auth + Google OAuth 2.0 | 사용자 인증 |
| **AI - LLM** | OpenAI API (gpt-4o-mini) | 루틴 피드백 생성 |
| **AI - Orchestration** | LangChain (core, community) | AI 파이프라인 관리 (예정) |
| **AI - Vision** | Ultralytics YOLO11 | AR 공간 스캔 & 가구 탐지 |
| **Validation** | Pydantic | 요청/응답 데이터 검증 |
| **Deploy** | Docker + Docker Compose | 컨테이너 기반 배포 |

---

## 2. 시스템 아키텍처 (System Architecture)

```
┌────────────────────────────────────────────────────────────────┐
│                    Flutter Frontend (Dart)                      │
│  Google Sign-In → Firebase Auth → ID Token 획득                 │
└──────────────────────────┬─────────────────────────────────────┘
                           │ HTTP (Authorization: Bearer <token>)
                           ▼
┌────────────────────────────────────────────────────────────────┐
│                   FastAPI Backend (Python 3.13)                 │
│                                                                │
│  ┌──────────────┐  ┌─────────────┐  ┌───────────────────────┐ │
│  │  Auth Module  │  │  API Layer  │  │   AI Services         │ │
│  │  (Firebase    │  │  (Routines, │  │  (OpenAI gpt-4o-mini) │ │
│  │   토큰 검증)  │  │ Executions) │  │  (YOLO11 공간 스캔)   │ │
│  └──────────────┘  └──────┬──────┘  └───────────┬───────────┘ │
│                           │                      │             │
│                    ┌──────▼──────────────────────▼───────┐     │
│                    │        Service Layer                │     │
│                    │   비즈니스 로직 + AI 피드백 생성      │     │
│                    └──────────────┬──────────────────────┘     │
│                                  │                             │
│                    ┌─────────────▼──────────────────────┐     │
│                    │       Repository Layer              │     │
│                    │       Firestore CRUD Only           │     │
│                    └─────────────┬──────────────────────┘     │
└──────────────────────────────────┼─────────────────────────────┘
                                   │
                           ┌───────▼───────┐
                           │   Firestore   │
                           │  (uphilldb)   │
                           └───────────────┘
```

---

## 3. 서비스 아키텍처 (Layered Architecture)

### 3-Layer 구조

| Layer | 역할 | 주요 파일 |
|-------|------|-----------|
| **API Layer** | HTTP 요청/응답 처리, 입력 검증 | `api/routines.py`, `api/executions.py`, `api/user.py` |
| **Service Layer** | 비즈니스 로직, 데이터 가공, AI 연동 | `services/routine_service.py`, `services/execution_service.py`, `services/ai_feedback.py` |
| **Repository Layer** | Firestore CRUD만 수행 | `repositories/routine_repository.py`, `repositories/execution_repository.py` |

### 핵심 설계 원칙

- **관심사 분리**: 각 레이어는 단일 책임만 가짐
- **의존성 역전**: Repository는 인터페이스(ABC) 기반으로 설계 → DB 교체 용이
- **Singleton 패턴**: Service 인스턴스 한 번 생성 후 재사용
- **Lazy Initialization**: DB 클라이언트는 최초 접근 시에만 초기화
- **프롬프트 외부 관리**: AI 프롬프트를 `.txt` 파일로 분리 (하드코딩 금지)

### 코드 흐름 예시 (루틴 생성)

```
POST /routines
    → api/routines.py (Pydantic으로 입력 검증)
    → services/routine_service.py (시간 형식 HH:MM 검증, 타임스탬프 생성)
    → repositories/routine_repository.py (Firestore에 저장)
    → 역순으로 응답 반환
```

---

## 4. AI 피드백 시스템 (현재 구현 완료)

```
GET /executions/daily/{date}/feedback
         │
         ▼
┌──────────────────────────────────┐
│  ExecutionService                │
│  .get_daily_summary(uid, date)   │
│  → 일간 통계 계산                 │
│    (완료 수, 총 수행시간, 상세내역) │
└──────────┬───────────────────────┘
           ▼
┌──────────────────────────────────┐
│  ai_feedback.py                  │
│  generate_ai_feedback(summary)   │
│                                  │
│  1. 시스템 프롬프트 로드           │
│     (prompts/feedback_system_    │
│      prompt.txt)                 │
│  2. 유저 프롬프트 템플릿 포맷팅    │
│  3. OpenAI gpt-4o-mini 호출      │
│     (temp=0.7, max_tokens=500)   │
│  4. JSON 응답 파싱               │
│  5. 실패 시 Fallback 응답        │
└──────────┬───────────────────────┘
           ▼
┌──────────────────────────────────┐
│  응답 구조                        │
│  ├ ai_feedback_short: 한 줄 격려  │
│  ├ ai_feedback_full: 2-3문장 피드백│
│  └ recommended_routines: 추천 루틴│
└──────────────────────────────────┘
```

### Fallback 전략

OpenAI API 실패 시에도 완료 루틴 수에 따라 적절한 기본 피드백 제공:

| 완료 수 | 기본 피드백 |
|---------|------------|
| 0개 | "오늘은 아직 완료한 루틴이 없어요" + 간단한 루틴 추천 |
| 1개 | "좋은 시작! '{루틴명}' 완료" |
| 2~3개 | "잘하고 있어요! {N}개 완료" |
| 4개+ | "대단해요! {N}개 완료!" |

---

## 5. YOLO11 공간 스캔 (예정 기능)

### 계획된 아키텍처

```
┌──────────────────────────────────────────────────────┐
│                Flutter App (AR 스캔)                   │
│           사용자 공간을 카메라로 촬영/스캔               │
└──────────────────┬───────────────────────────────────┘
                   │ 이미지/영상 데이터 전송
                   ▼
┌──────────────────────────────────────────────────────┐
│            YOLO11 Object Detection                    │
│  ┌────────────────────────────────────────────────┐  │
│  │  Ultralytics YOLO11 모델                        │  │
│  │  - 공간 내 가구 탐지 (책상, 침대, 의자 등)       │  │
│  │  - Bounding Box + Class Label 추출              │  │
│  │  - 공간 구성 데이터 생성                         │  │
│  └────────────────────────────────────────────────┘  │
└──────────────────┬───────────────────────────────────┘
                   │ 탐지된 가구 목록 + 공간 정보
                   ▼
┌──────────────────────────────────────────────────────┐
│         LangChain AI Pipeline                         │
│  ┌────────────────────────────────────────────────┐  │
│  │  1. 공간 데이터 분석                             │  │
│  │  2. 가구 배치 기반 루틴 추천                      │  │
│  │     예: 책상 감지 → "독서 루틴", "업무 루틴" 추천  │  │
│  │     예: 요가매트 감지 → "스트레칭 루틴" 추천       │  │
│  │  3. 공간 최적화 가구 배치 제안                    │  │
│  └────────────────────────────────────────────────┘  │
└──────────────────┬───────────────────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────────────────┐
│              사용자에게 제공                            │
│  ├ 공간 기반 루틴 추천                                │
│  ├ 루틴 최적화를 위한 가구 배치 제안                    │
│  └ 개인화된 공간 활용 가이드                           │
└──────────────────────────────────────────────────────┘
```

### YOLO11 선택 이유

- **실시간 탐지**: 모바일 환경에서도 빠른 추론 속도
- **높은 정확도**: YOLO 시리즈 최신 모델로 객체 탐지 성능 우수
- **다양한 클래스**: COCO 데이터셋 기반 80개+ 객체 클래스 (가구 포함)
- **경량화 옵션**: n/s/m/l/x 모델 크기 선택 가능 (모바일 최적화)

---

## 6. 인증 플로우

```
Flutter                           Backend                        Firebase
  │                                  │                              │
  ├─(1) Google Sign-In ─────────────────────────────────────────────>│
  │<── ID Token ────────────────────────────────────────────────────│
  │                                  │                              │
  ├─(2) POST /auth/google ─────────>│                              │
  │     {id_token}                   ├─ Google 토큰 검증             │
  │                                  ├─ 사용자 존재 확인 ────────────>│
  │                                  ├─ Firebase Custom Token 생성──>│
  │<── {uid, firebase_token} ───────│                              │
  │                                  │                              │
  ├─(3) API 요청 ──────────────────>│                              │
  │  Authorization: Bearer <token>   ├─ middleware.py               │
  │                                  ├─ 토큰 검증 → uid 추출 ────────>│
  │                                  ├─ 비즈니스 로직 처리           │
  │<── 응답 ────────────────────────│                              │
```

---

## 7. API 엔드포인트

| Method | Endpoint | 설명 |
|--------|----------|------|
| **POST** | `/auth/google` | Google OAuth 토큰 검증 & 로그인 |
| **GET** | `/user/info` | 사용자 프로필 조회 |
| **POST** | `/routines` | 루틴 생성 |
| **GET** | `/routines` | 사용자 루틴 목록 조회 |
| **GET** | `/routines/{id}` | 루틴 상세 조회 |
| **PUT** | `/routines/{id}` | 루틴 수정 |
| **DELETE** | `/routines/{id}` | 루틴 삭제 |
| **POST** | `/executions/{routineId}` | 수행 기록 저장 |
| **GET** | `/executions/daily?date=YYYY-MM-DD` | 일간 수행 기록 & 통계 |
| **GET** | `/executions/daily/{date}/feedback` | AI 피드백 조회 |

---

## 8. Firestore 데이터 모델

```
uphilldb/
└── users/{uid}/
    ├── routines/{routineId}/
    │   ├── title: string              (루틴 제목)
    │   ├── time: string (HH:MM)       (실행 시간)
    │   ├── category: string           (카테고리)
    │   ├── color: string? (hex code)  (UI 색상)
    │   ├── days: array<int>?          (반복 요일: 0=월~6=일)
    │   ├── created_at: string (ISO8601)
    │   └── updated_at: string (ISO8601)
    │
    └── executions/{executionId}/
        ├── routine_id: string         (연결된 루틴 ID)
        ├── routine_title: string      (루틴 이름, 비정규화)
        ├── date: string (YYYY-MM-DD)  (실행 날짜, 쿼리용)
        ├── started_at: string (ISO8601)
        ├── ended_at: string (ISO8601)
        ├── duration_seconds: int      (수행 시간)
        └── created_at: string (ISO8601)
```

---
