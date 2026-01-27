# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Uphill은 홍익대학교 IT 소모임 Recru-IT 스크럼 3팀 프로젝트로, 루틴 관리 및 최적화 애플리케이션입니다. IoT 연동(Samsung SmartThings), AR 공간 스캔, AI 기반 공간 기반 루틴 추천 기능을 제공합니다.
공간기반 루틴 추천 : AR 공간 스캔을 통한 공간 내 가구를 분석하여 루틴에 최적화한 가구 배치를 함께 추천합니다.

## 지침

- 사용자 요청이 없는 한 ./backend 디렉토리 내 코드는 수정하지 마세요.
- 만약 ./backend 내 함수, 클래스, 모듈 작성을 요청받으면 함수/클래스 시그니처(스켈레톤)와 한국어 docstring만 작성하세요.
- 내부 로직은 절대 구현하지 말고, 실제 구현은 명시적으로 요청한 경우에만 작성하세요.

## Code Guidelines

- **가독성과 유지보수성을 최우선으로 합니다.**
- 명확한 변수명과 함수명 사용
- 각 함수/클래스에 한국어 docstring 작성
- 복잡한 로직은 작은 단위로 분리
- 가독성과 유지보수성을 1순위로 최적화는 2순위

- **Flutter 주석 원칙**
- 각 Flutte UI 요소마다 어떤 UI를 나타내는지 주석을 작성
- backend 요청을 보내는 부분에 주석 작성

-**Naming Convention**

- 변수명: camelCase (예: userName)
- 클래스명: PascalCase (예: UserService)
- 파일명: snake_case.py
- 모든 함수에 docstring 필수
- 새 파일 생성 전 기존 구조 확인 필수

-**Backend Convention**

- Router코드와 서비스 로직 코드는 명확히 분리되어야 함

## Repository Structure

```
uphill/
├── uphill/                      # Flutter Frontend
│   └── lib/
│       ├── main.dart            # 앱 진입점 (Firebase 초기화)
│       ├── main_scaffold.dart   # 루트 네비게이션 (하단 네비게이션 바)
│       ├── screens/             # 페이지 컴포넌트
│       ├── services/            # API/Auth 서비스 레이어
│       ├── widgets/             # 재사용 UI 컴포넌트
│       └── theme/               # 테마 설정 (UphillColors)
│
├── backend/                     # FastAPI Backend (Layered Architecture)
│   ├── main.py                  # FastAPI 앱 (CORS, 라우터 등록)
│   ├── auth/                    # 인증 모듈
│   │   ├── firebase_init.py     # Firebase Admin SDK 초기화
│   │   ├── middleware.py        # Firebase 토큰 검증 미들웨어
│   │   ├── google_router.py     # Google OAuth 엔드포인트
│   │   └── schemas.py           # 인증 관련 Pydantic 모델
│   ├── api/                     # API Layer: HTTP 요청/응답 처리만
│   │   ├── routines.py          # 루틴 라우터 (요청 받고 서비스 호출)
│   │   ├── executions.py        # 수행 기록 라우터
│   │   ├── user.py              # 사용자 라우터
│   │   └── schemas.py           # Pydantic 요청/응답 모델
│   ├── services/                # Service Layer: 비즈니스 로직
│   │   ├── routine_service.py   # 루틴 비즈니스 로직
│   │   ├── execution_service.py # 수행 기록 비즈니스 로직
│   │   └── ai_feedback.py       # AI 피드백 생성 로직
│   └── repositories/            # Repository Layer: DB 접근만
│       ├── routine_repository.py    # 루틴 Firestore 접근
│       └── execution_repository.py  # 수행 기록 Firestore 접근
│
└── icon/                        # 에셋 리소스
```

## Tech Stack

| 구분     | 기술                                        |
| -------- | ------------------------------------------- |
| Frontend | Flutter (Dart SDK ^3.9.2)                   |
| Backend  | FastAPI (Python 3.13)                       |
| Database | Firebase Firestore (`uphilldb`)             |
| Auth     | Firebase Auth + Google OAuth 2.0            |
| AI       | OpenAI API (gpt-4o-mini), LangChain, YOLO11 |
| Deploy   | Docker, Docker Compose                      |

## Development Commands

### Frontend (Flutter)

```bash
cd uphill
flutter pub get          # 의존성 설치
flutter analyze          # Lint 검사
flutter test             # 테스트 실행
flutter run              # 앱 실행 (디버그)
flutter run -d chrome    # 웹 버전 실행
```

### Backend (FastAPI)

```bash
cd backend
pipenv install                                    # 의존성 설치
pipenv run uvicorn main:app --reload              # 개발 서버 (hot reload)
uvicorn main:app --host 0.0.0.0 --port 8000      # 프로덕션 서버
```

### Docker

```bash
cd backend
docker-compose up --build    # 백엔드 컨테이너 빌드 및 실행
```

## Environment Variables

백엔드 `/backend/.env` 파일에 다음 변수 필요:

```
GOOGLE_CLIENT_ID=<Google OAuth 클라이언트 ID>
OPENAI_API_KEY=<OpenAI API 키>
FIREBASE_SERVICE_ACCOUNT_KEY=<Firebase 서비스 계정 JSON 문자열>
FIREBASE_SERVICE_ACCOUNT_PATH=serviceAccountKey.json
```

## Architecture

### Backend: Layered Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  API Layer (api/)                       │
│           HTTP 요청/응답 처리, 입력 검증                  │
│     "요청이 들어오면 여기서 받는다"                        │
├─────────────────────────────────────────────────────────┤
│               Service Layer (services/)                 │
│           비즈니스 로직, 데이터 가공, 외부 API            │
│     "핵심 로직은 여기서 처리한다"                         │
├─────────────────────────────────────────────────────────┤
│            Repository Layer (repositories/)             │
│              Firestore CRUD 작업만 수행                  │
│     "DB 접근은 여기서만 한다"                             │
├─────────────────────────────────────────────────────────┤
│                 Firebase Firestore                      │
└─────────────────────────────────────────────────────────┘
```

**각 레이어의 역할:**

| Layer      | 파일                                 | 역할                 | 예시                        |
| ---------- | ------------------------------------ | -------------------- | --------------------------- |
| API        | `api/routines.py`                    | 요청 받기, 응답 반환 | `@router.post("/routines")` |
| Service    | `services/routine_service.py`        | 비즈니스 로직        | 시간 검증, 데이터 변환      |
| Repository | `repositories/routine_repository.py` | DB 접근              | Firestore 읽기/쓰기         |

**코드 흐름 예시 (루틴 생성):**

```
1. api/routines.py         → POST /routines 요청 수신
2. services/routine_service.py → 시간 형식 검증, 데이터 준비
3. repositories/routine_repository.py → Firestore에 저장
4. 역순으로 응답 반환
```

**디버깅 가이드:**

- 400 에러 → API Layer (입력 검증 실패)
- 비즈니스 로직 오류 → Service Layer
- DB 에러 → Repository Layer

### Frontend Service Pattern

```
┌──────────────────────────────────────┐
│           Screens (UI)               │
│  home_screen, routine_detail 등      │
├──────────────────────────────────────┤
│         Services (Singleton)         │
│  AuthService, RoutineService         │
│  - HTTP 통신, 상태 관리               │
├──────────────────────────────────────┤
│           Widgets                    │
│  재사용 가능한 UI 컴포넌트             │
└──────────────────────────────────────┘
```

- **Singleton Pattern**: `AuthService`, `RoutineService`는 싱글톤으로 구현
- **BaseURL**: Android 에뮬레이터: `http://10.0.2.2:8000`, 실제 기기: 서버 IP

### Data Flow

```
Flutter App
    │
    ├─(1) Google Sign-In → Firebase Auth → ID Token 획득
    │
    └─(2) API 요청 (Authorization: Bearer <Firebase ID Token>)
              │
              ▼
        ┌─────────────────────────────────────────┐
        │           FastAPI Backend               │
        ├─────────────────────────────────────────┤
        │  auth/middleware.py                     │
        │  └─ Firebase 토큰 검증 → uid 추출        │
        ├─────────────────────────────────────────┤
        │  api/routines.py (API Layer)            │
        │  └─ 요청 파싱, 응답 포맷                  │
        ├─────────────────────────────────────────┤
        │  services/routine_service.py (Service)  │
        │  └─ 비즈니스 로직 처리                    │
        ├─────────────────────────────────────────┤
        │  repositories/routine_repository.py     │
        │  └─ Firestore CRUD                      │
        └─────────────────────────────────────────┘
              │
              ▼
        Firebase Firestore (users/{uid}/routines)
```

### Firestore Data Model

```
uphilldb/
└── users/
    └── {uid}/
        ├── routines/
        │   └── {routineId}/
        │       ├── title: string
        │       ├── time: string (HH:MM)
        │       ├── category: string
        │       ├── color: string?
        │       ├── days: array<int>? (0=월~6=일)
        │       ├── created_at: string (ISO8601)
        │       └── updated_at: string (ISO8601)
        │
        └── executions/
            └── {executionId}/
                ├── routine_id: string
                ├── routine_title: string
                ├── started_at: string (ISO8601)
                ├── ended_at: string (ISO8601)
                └── duration_seconds: int
```

## API Endpoints

| Method | Endpoint                            | 설명                   |
| ------ | ----------------------------------- | ---------------------- |
| POST   | `/auth/google`                      | Google OAuth 토큰 검증 |
| GET    | `/routines`                         | 사용자 루틴 목록 조회  |
| POST   | `/routines`                         | 루틴 생성              |
| GET    | `/routines/{id}`                    | 루틴 상세 조회         |
| PUT    | `/routines/{id}`                    | 루틴 수정              |
| DELETE | `/routines/{id}`                    | 루틴 삭제              |
| POST   | `/executions/{routineId}`           | 수행 기록 저장         |
| GET    | `/executions/daily?date=YYYY-MM-DD` | 일간 수행 기록         |
| GET    | `/executions/daily/{date}/feedback` | AI 피드백 조회         |

## Firebase Configuration

- **Project ID**: `uphil-9fc91`
- **Database ID**: `uphilldb`
- Flutter 앱은 `firebase_options.dart` (FlutterFire CLI 자동 생성) 사용
- Backend는 `serviceAccountKey.json` 또는 환경변수로 인증

# Flutter 코딩 규칙

### 명명 규칙

- 위젯/클래스: PascalCase (UserProfileScreen)
- 변수/함수: camelCase (userName, fetchData)
- 파일명: snake_case.dart (user_profile_screen.dart)
- private: \_접두사 (\_internalState)

### 위젯 작성 순서

1. const 생성자 + super.key
2. final 필드 선언
3. build 메서드
4. private 헬퍼 메서드

### 필수 규칙

- 한 파일 = 하나의 public 위젯
- build 메서드 50줄 이하 유지
- 비동기 후 mounted 체크 필수
- const 생성자 적극 활용
- 하드코딩 금지 → constants 파일 사용

### 금지 사항

- build 안에서 Future/Stream 생성
- 5단계 이상 위젯 중첩
- 축약 변수명 (btn, usr, tmp)
- context를 비동기 콜백에서 직접 사용
