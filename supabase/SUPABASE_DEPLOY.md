# KBJ2 Supabase 배포 가이드

## 🚀 Supabase 배포 (완전 무료)

### 1단계: Supabase 프로젝트 생성
```
1. https://supabase.com/dashboard 접속
2. [New Project] 클릭
3. 조직: qrchejbxffozzqmsbvxb
4. 프로젝트명: kbj2-api
5. 데이터베이스 비밀번호: (기억하기 쉬운 것)
6. 리전: Northeast Asia (Seoul)
7. [Create new project] 클릭
```

### 2단계: Edge Functions 배포
```bash
# Supabase CLI 설치 (이미 설치되어 있으면 생략)
# Windows: winget install Supabase.CLI

# kbj2 폴더로 이동
cd F:\kbj_repo

# Supabase 로그인
supabase login

# 프로젝트 링크
supabase link --project-ref your-project-ref

# Edge Functions 배포
supabase functions deploy kbj2
```

### 3단계: 환경변수 설정
Supabase Dashboard → Edge Functions → kbj2 → 설정:
```
ZAI_API_KEY = your_api_key_here
```

---

## 📍 배포된 URL
```
https://your-project-ref.supabase.co/functions/v1/kbj2
```

---

## 📝 호출 예시

### JavaScript/TypeScript
```javascript
const response = await fetch(
  'https://your-project-ref.supabase.co/functions/v1/kbj2/strat',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' // Supabase Anon Key
    },
    body: JSON.stringify({
      query: '신규 카페 오픈 전략',
      context: '서울 강남구'
    })
  }
)
const result = await response.json()
console.log(result)
```

### Python
```python
import requests

url = 'https://your-project-ref.supabase.co/functions/v1/kbj2/strat'
headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
}

response = requests.post(url, json={
    'query': '신규 카페 오픈 전략',
    'context': '서울 강남구'
}, headers=headers)

print(response.json())
```

### cURL
```bash
curl -X POST https://your-project-ref.supabase.co/functions/v1/kbj2/strat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{"query":"신규 카페 오픈 전략","context":"서울 강남구"}'
```

---

## 🔑 API Key 가져오기
```
1. Supabase Dashboard → Settings → API
2. project_url (anon public) 확인
3. anon/public 키 복사
```
