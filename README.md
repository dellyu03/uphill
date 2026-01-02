# 🫧 uphill

## 👥 Members

-
-

## 📋 Summary

- 공간
- 홍익대학교 IT 소모임 Recru-it 스크럼 3팀 프로젝트 활동

## 🚀 Main Features

- Samsung Smart Things API를 활용한 IOT 연동 기능
- 루틴 생성, 수정 삭제 기능
- 루틴 시간표 출력 기능
- 공간 스캔 데이터와 연동한 루틴별 공간 활용 솔루션 추천
- 내 루틴 취향 및 목표에 따른 AI 추천 루틴
- 루틴별 변동 가능성 입력을 활용한 자동 루틴 수정
- 루틴 수행 이력에 따른 피드백

## 🔧 Tech Stacks

### FrontEnd

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>

### Backend & DB

<img src="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI"/>
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white" alt="Firebase"/>

### DevOps

<img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker"/>

## 📦 Architecture

```
                         ┌─────────────────────────┐
                         │       Flutter App        │
                         │  (AR 스캔 + UI + IoT 제어) │
                         └───────────┬─────────────┘
                                     │
                  ┌──────────────────┴───────────────────┐
                  │             API Gateway              │
                  │            (FastAPI/NestJS)          │
                  └───────────┬───────────┬─────────────┘
                              │           │
                     ┌────────┘     ┌─────┴────────┐
                     ▼              ▼               ▼
        ┌────────────────┐   ┌────────────────┐  ┌────────────────┐
        │  User/Routine  │   │  Space DB      │  │   Vector DB     │
        │  (Firestore)   │   │ (Storage+FS)   │  │ (Qdrant/Pinecone)│
        └────────────────┘   └────────────────┘  └────────────────┘
                ▲                     ▲                 ▲
                │                     │                 │
                └─────────┬───────────┴───────────────┘
                          ▼
               ┌────────────────────┐
               │   AI Orchestration │
               │(OpenAI, LLM/VLM,   │
               │ Depth + AR + 추천 AI)│
               └────────────────────┘
```
