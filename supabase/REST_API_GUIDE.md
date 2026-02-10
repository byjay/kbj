# KBJ2 Supabase REST API 배포 가이드

## 🚀 가장 간단한 배포 방법

### 1단계: Supabase 프로젝트 생성
```
1. https://supabase.com/dashboard/org/qrchejbxffozzqmsbvxb 접속
2. [New Project] → kbj2-api 생성
3. 리전: Northeast Asia (Seoul)
```

### 2단계: SQL 함수 실행
```
1. Dashboard → SQL Editor
2. [New query] 클릭
3. kbj2_api.sql 파일 내용 붙여넣기
4. [Run] 클릭
```

### 3단계: API 키 설정
```
방법 1: Secrets에 설정
Dashboard → Settings → Secrets
- ZAI_API_KEY = your_api_key_here

방법 2: SQL로 직접 입력
UPDATE kbj2_secrets SET zai_api_key = 'your-key' WHERE id = 1;
```

---

## 📝 Supabase REST API 호출 방법

### 기본 URL 형식
```
https://your-project-ref.supabase.co/rest/v1/rpc/함수명
```

### JavaScript/TypeScript
```javascript
const SUPABASE_URL = 'https://your-project-ref.supabase.co'
const SUPABASE_KEY = 'your-anon-key'

// 1. 간단 전략 분석
const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/kbj2_strat`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'apikey': SUPABASE_KEY,
    'Authorization': `Bearer ${SUPABASE_KEY}`
  },
  body: JSON.stringify({
    query: '신규 카페 오픈 전략',
    context: '서울 강남구'
  })
})

const result = await response.json()
console.log(result)
```

### Python
```python
import requests

SUPABASE_URL = 'https://your-project-ref.supabase.co'
SUPABASE_KEY = 'your-anon-key'

# 간단 전략 분석
response = requests.post(
    f'{SUPABASE_URL}/rest/v1/rpc/kbj2_strat',
    headers={
        'Content-Type': 'application/json',
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}'
    },
    json={
        'query': '신규 카페 오픈 전략',
        'context': '서울 강남구'
    }
)

print(response.json())
```

### cURL
```bash
curl -X POST https://your-project-ref.supabase.co/rest/v1/rpc/kbj2_strat \
  -H "Content-Type: application/json" \
  -H "apikey: your-anon-key" \
  -H "Authorization: Bearer your-anon-key" \
  -d '{
    "query": "신규 카페 오픈 전략",
    "context": "서울 강남구"
  }'
```

---

## 🤖 멀티 에이전트 분석 (5개 에이전트)

### JavaScript
```javascript
const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/kbj2_agents_analysis`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'apikey': SUPABASE_KEY,
    'Authorization': `Bearer ${SUPABASE_KEY}`
  },
  body: JSON.stringify({
    query: '다음 모임 일정 정해줘',
    context: '회비 관리 앱',
    agent_count: 5  // 1~5개 에이전트
  })
})

const result = await response.json()
// result.responses.agent_1, agent_2, ... 각 에이전트의 응답
```

---

## 🔑 API Key 확인 위치
```
Dashboard → Settings → API
- URL: your-project-ref.supabase.co
- anon public:eyJhbGc... (이 키 사용)
```

---

## ✅ 테스트 해보기

배포 후 바로 테스트:
```bash
# 헬스체크 (프로젝트 연결 확인)
curl https://your-project-ref.supabase.co/rest/v1/ \
  -H "apikey: your-anon-key"

# 전략 분석 테스트
curl -X POST https://your-project-ref.supabase.co/rest/v1/rpc/kbj2_strat \
  -H "Content-Type: application/json" \
  -H "apikey: your-anon-key" \
  -d '{"query":"테스트","context":""}'
```
