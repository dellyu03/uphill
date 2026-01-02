# Python 3.13 베이스 이미지 사용
FROM python:3.13-slim

# 작업 디렉토리 설정
WORKDIR /app

# 시스템 패키지 업데이트 및 pipenv 설치에 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# pipenv 설치
RUN pip install --no-cache-dir pipenv

# Pipfile과 Pipfile.lock 복사
COPY Pipfile Pipfile.lock ./

# 의존성 설치
RUN pipenv install --deploy --system

# 애플리케이션 코드 복사
COPY . .

# 포트 노출 (FastAPI 기본 포트)
EXPOSE 8000

# 환경 변수 설정
ENV PYTHONUNBUFFERED=1

# 헬스체크용 스크립트 생성
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# uvicorn으로 FastAPI 애플리케이션 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

