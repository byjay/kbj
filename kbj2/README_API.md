# KBJ2 API 배포 가이드

## 🚀 Railway 배포 (추천 - 가장 간단)

### 1단계: Railway 접속 및 설정
```
1. https://railway.app/ 접속
2. GitHub으로 로그인
3. "New Project" → "Deploy from GitHub repo"
4. F:\kbj_repo 선택 또는 푸시 후 선택
```

### 2단계: 환경변수 설정
Railway 대시보드에서 Variables 탭에 추가:
```
ZAI_API_KEY=your_api_key_here
PORT=8000
```

### 3단계: 배포 확인
- Railway가 자동으로 Dockerfile 감지하여 배포
- 완료 후 도메인 확인 (예: `kbj2.up.railway.app`)

---

## 🔧 Render 배포 (대안)

### 1단계: Blueprint 설정
`render.yaml` 생성 (이미 제공됨)

### 2단계: 배포
```
1. https://render.com/ 접속
2. "New" → "Blueprint" → F:\kbj_repo 선택
3. 환경변수: ZAI_API_KEY
4. Deploy
```

---

## 📦 Docker 로컬 테스트

```bash
# 이미지 빌드
docker build -t kbj2-api F:\kbj_repo

# 컨테이너 실행
docker run -d -p 8000:8000 \
  -e ZAI_API_KEY=your_key \
  --name kbj2 \
  kbj2-api

# 테스트
curl http://localhost:8000/health
```

---

## 🌐 도메인 연결

### Railway 도메인 설정
```
1. Railway 프로젝트 → Settings → Domains
2. Custom Domain 입력: kbj2.your-domain.com
3. DNS에 CNAME 레코드 추가:
   kbj2 → [railway-provided-domain]
```

---

## ✅ 배포 후 테스트

```bash
# 헬스체크
curl https://your-domain.com/health

# 전략 분석 테스트
curl -X POST https://your-domain.com/api/strat \
  -H "Content-Type: application/json" \
  -d '{"query":"테스트","context":""}'
```

---

## 📝 다른 프로젝트에서 호출 예시

### Python
```python
from kbj2.clients.python import KBJ2Client

client = KBJ2Client("https://your-domain.com")
result = client.strat("분석할 주제")
print(result)
```

### JavaScript
```javascript
import KBJ2Client from './kbj2/clients/javascript.js';

const client = new KBJ2Client("https://your-domain.com");
const result = await client.strat("분석할 주제");
console.log(result);
```

### cURL
```bash
curl -X POST https://your-domain.com/api/strat \
  -H "Content-Type: application/json" \
  -d '{"query":"분석할 주제","context":""}'
```
