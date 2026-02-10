# KBJ2 Supabase 배포 (3단계)

## 1단계: 프로젝트 생성 (2분)
```
1. https://supabase.com/dashboard/org/qrchejbxffozzqmsbvxb 접속
2. [New Project] 클릭
3. 정보 입력:
   - Name: kbj2-api
   - Database Password: (기억할 것)
   - Region: Northeast Asia (Seoul) ⭐
4. [Create new project] 클릭
   (약 2분 대기)
```

## 2단계: SQL 실행 (1분)
```
1. 프로젝트 대시보드 → [SQL Editor] 클릭
2. [New query] 클릭
3. 아래 내용 복사해서 붙여넣기:
```

```sql
-- pg_net 확장 활성화 (외부 API 호출용)
CREATE EXTENSION IF NOT EXISTS pg_net;

-- ZAI API 키 설정 (당신의 키로 변경)
-- 방법 1: Secrets 사용 (Dashboard → Settings → Secrets)
-- 방법 2: 아래 테이블에 직접 입력
CREATE TABLE IF NOT EXISTS kbj2_secrets (
  id INT PRIMARY KEY,
  zai_api_key TEXT
);

INSERT INTO kbj2_secrets (id, zai_api_key) VALUES (1, '당신의_ZAI_API_KEY')
ON CONFLICT (id) DO UPDATE SET zai_api_key = EXCLUDED.zai_api_key;

-- 간단 전략 분석 함수
CREATE OR REPLACE FUNCTION kbj2_strat(
  query TEXT,
  context TEXT DEFAULT ''
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  api_key TEXT;
  response TEXT;
  result JSONB;
  request_id TEXT;
  full_prompt TEXT;
BEGIN
  -- API 키 가져오기
  SELECT zai_api_key INTO api_key FROM kbj2_secrets WHERE id = 1;

  IF api_key IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'API Key not found');
  END IF;

  request_id := substr(md5(random()::text), 1, 8);

  -- 프롬프트 생성
  full_prompt := format('당신은 전략 분석가입니다.

[주제] %s

[배경] %s

다음을 분석해주세요:
1. 핵심 이슈
2. 추천 전략
3. 리스크
4. 다음 단계

JSON 형식으로 응답하세요.', query, context);

  -- GLM API 호출
  SELECT content INTO response
  FROM http(
    'https://api.z.ai/api/coding/paas/v4/chat/completions',
    'POST',
    jsonb_build_object(
      'model', 'GLM-4.7',
      'messages', jsonb_build_array(
        jsonb_build_object('role', 'system', 'content', 'You are a helpful AI assistant.'),
        jsonb_build_object('role', 'user', 'content', full_prompt)
      ),
      'temperature', 0.7
    ),
    jsonb_build_object(
      'Authorization', 'Bearer ' || api_key,
      'Content-Type', 'application/json'
    ),
    60000
  );

  -- 결과 파싱
  result := jsonb_extract_path_text(response, 'choices', '0', 'message', 'content')::jsonb;

  RETURN jsonb_build_object(
    'success', true,
    'request_id', request_id,
    'query', query,
    'response', result,
    'timestamp', now()
  );
END;
$$;

-- 권한 설정 (모두 호출 가능)
GRANT EXECUTE ON FUNCTION kbj2_strat TO postgres, anon, authenticated;
```

```
4. [Run] 클릭
5. "Success" 메시지 확인
```

## 3단계: API 호출 (바로 사용)
```
1. Dashboard → Settings → API
2. URL과 anon 키 복사

3. 테스트:
```

```bash
curl -X POST https://your-project-ref.supabase.co/rest/v1/rpc/kbj2_strat \
  -H "Content-Type: application/json" \
  -H "apikey: 복사한_anon_키" \
  -d '{"query":"신규 카페 오픈 전략","context":"서울 강남구"}'
```

---

## ✅ 완료!

이제 어떤 프로젝트에서도 호출 가능:

```javascript
const response = await fetch('https://your-project-ref.supabase.co/rest/v1/rpc/kbj2_strat', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'apikey': 'your-anon-key'
  },
  body: JSON.stringify({
    query: '다음 모임 일정 정해줘',
    context: '회비 관리 앱'
  })
})
```
