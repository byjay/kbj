FROM python:3.11-slim

WORKDIR /app

# 시스템 패키지
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 패키지 복사 및 설치
COPY kbj2/requirements-api.txt .
RUN pip install --no-cache-dir -r requirements-api.txt

# 소스 코드 복사
COPY kbj2/ ./kbj2/

# 환경변수
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

# 서버 실행
CMD ["uvicorn", "kbj2.server:app", "--host", "0.0.0.0", "--port", "8000"]
