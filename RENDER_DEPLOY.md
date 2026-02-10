# KBJ2 Render 배포 가이드

## 🚀 5분 만에 Render 배포하기

### 1단계: GitHub에 코드 푸시
```
이미 완료됨: https://github.com/byjay/kbj
```

### 2단계: Render 배포
```
1. https://dashboard.render.com/ 접속
2. [New+] → [New Web Service]
3. GitHub 연동 → byjay/kbj 선택
4. 설정:
   - Name: kbj2-api
   - Environment: Python 3
   - Build Command: pip install fastapi uvicorn requests aiohttp
   - Start Command: uvicorn kbj2.simple_server:app --host 0.0.0.0 --port $PORT
5. [Advanced] → [Environment Variables]:
   - ZAI_API_KEY = (당신의 키)
6. [Create Web Service]
```

### 3단계: UptimeRobot 설정 (슬립 방지)
```
1. https://uptimerobot.com/ 접속 (무료)
2. [Add New Monitor]
3. 설정:
   - Type: HTTPS
   - URL: (Render에서 배포된 URL)
   - Monitoring Interval: 5 minutes
4. [Create Monitor]
```

---

## ✅ 완료 후

### 배포된 URL
```
https://kbj2-api.onrender.com
```

### 호출 예시
```bash
curl -X POST https://kbj2-api.onrender.com/strat \
  -H "Content-Type: application/json" \
  -d '{"query":"다음 모임 일정 정해줘"}'
```

---

## 🔄 슬립 방지 원리
- UptimeRobot이 5분마다 핑 보내면
- Render가 계속 깨어있음
- 무료로 24/7 실행 가능!

---

## 📝 JOT 앱에서 호출 예시
```javascript
// JOT 앱에서 KBJ2 API 호출
const response = await fetch('https://kbj2-api.onrender.com/strat', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    query: '다음 모임 일정 정해줘',
    context: '회비 관리 앱'
  })
})
const result = await response.json()
```
