-- KBJ2 API for Supabase using PostgreSQL Functions
-- Supabase Database Functions를 통한 GLM API 호출

-- ===== 1. GLM API 호출 함수 =====
CREATE OR REPLACE FUNCTION call_glm_api(
  prompt TEXT,
  api_key TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  response TEXT;
  result JSONB;
BEGIN
  -- Supabase에서 외부 API 호출 (pg_net 확장 사용)
  SELECT content INTO response
  FROM http(
    'https://api.z.ai/api/coding/paas/v4/chat/completions',
    'POST',
    jsonb_build_object(
      'model', 'GLM-4.7',
      'messages', jsonb_build_array(
        jsonb_build_object('role', 'system', 'content', 'You are a helpful AI assistant.'),
        jsonb_build_object('role', 'user', 'content', prompt)
      ),
      'temperature', 0.7,
      'stream', false
    ),
    jsonb_build_object(
      'Authorization', 'Bearer ' || api_key,
      'Content-Type', 'application/json'
    ),
    30000  -- 30초 타임아웃
  );

  -- 응답 파싱
  result := jsonb_extract_path_text(response, 'choices', '0', 'message', 'content')::jsonb;

  RETURN result;
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('error', SQLERRM);
END;
$$;

-- ===== 2. 간단한 전략 분석 함수 =====
CREATE OR REPLACE FUNCTION kbj2_strat(
  query TEXT,
  context TEXT DEFAULT ''
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  api_key TEXT;
  full_prompt TEXT;
  result JSONB;
  request_id TEXT;
BEGIN
  -- 환경변수에서 API 키 가져오기 (또는 secrets 테이블)
  -- 실제 사용시: https://supabase.com/dashboard/project/_/settings/secrets
  api_key := current_setting('app.zai_api_key', true);

  IF api_key IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'ZAI_API_KEY not configured'
    );
  END IF;

  -- 요청 ID 생성
  request_id := substr(md5(random()::text), 1, 8);

  -- 프롬프트 구성
  full_prompt := format('당신은 전략 분석가입니다.

[분석 주제]
%s

[추가 배경]
%s

다음을 분석하고 JSON 형식으로 응답하세요:
1. 핵심 이슈 3가지
2. 추천 전략
3. 리스크 사항
4. 다음 단계

응답 형식:
{
  "issues": ["이슈1", "이슈2", "이슈3"],
  "strategy": "추천 전략",
  "risks": ["리스크1", "리스크2"],
  "next_steps": ["단계1", "단계2"]
}', query, context);

  -- GLM API 호출
  result := call_glm_api(full_prompt, api_key);

  -- 응답 반환
  RETURN jsonb_build_object(
    'success', true,
    'request_id', request_id,
    'query', query,
    'response', result,
    'timestamp', now()
  );
END;
$$;

-- ===== 3. REST API 엔드포인트를 위한 래퍼 함수 =====
-- Supabase Auto-generated REST API로 호출 가능

-- RPC 호출 예시: POST /rest/v1/rpc/kbj2_strat
-- Body: { "query": "...", "context": "..." }

-- ===== 4. 간단한 에이전트 시뮬레이션 =====
CREATE OR REPLACE FUNCTION kbj2_agents_analysis(
  query TEXT,
  context TEXT DEFAULT '',
  agent_count INT DEFAULT 5
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  agent RECORD;
  agent_prompts TEXT[];
  full_prompt TEXT;
  api_key TEXT;
  responses JSONB := jsonb_build_object();
  i INT := 1;
BEGIN
  api_key := current_setting('app.zai_api_key', true);

  IF api_key IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'API Key missing');
  END IF;

  -- 에이전트 프롬프트 정의
  agent_prompts := ARRAY[
    '당신은 낙관론자입니다. 긍정적인 관점에서 기회를 찾아주세요.',
    '당신은 비관론자입니다. 리스크와 위험요소를 분석해주세요.',
    '당신은 현실주의자입니다. 실현 가능한 중립적 분석을 해주세요.',
    '당신은 혁신가입니다. 창의적이고 파괴적 아이디어를 제시해주세요.',
    '당신은 실용주의자입니다. 실행 가능한 구체적 방안을 제시해주세요.'
  ];

  -- 각 에이전트 순차 호출
  FOR agent IN SELECT * FROM unnest(agent_prompts) AS prompt LOOP
    full_prompt := format('[주제] %s\n\n[배경] %s\n\n%s', query, context, agent.prompt);

    BEGIN
      responses := responses || jsonb_build_object(
        'agent_' || i,
        call_glm_api(full_prompt, api_key)
      );
      i := i + 1;
    EXCEPTION WHEN OTHERS THEN
      responses := responses || jsonb_build_object(
        'agent_' || i,
        jsonb_build_object('error', SQLERRM)
      );
      i := i + 1;
    END;
  END LOOP;

  RETURN jsonb_build_object(
    'success', true,
    'query', query,
    'agents', agent_count,
    'responses', responses,
    'timestamp', now()
  );
END;
$$;

-- ===== 5. secrets 테이블 (선택사항 - API 키 저장용) =====
CREATE TABLE IF NOT EXISTS kbj2_secrets (
  id INT PRIMARY KEY,
  zai_api_key TEXT
);

INSERT INTO kbj2_secrets (id, zai_api_key) VALUES (1, 'your-api-key-here')
ON CONFLICT (id) DO NOTHING;

-- ===== 6. 보안: RLS 정책 =====
ALTER TABLE kbj2_secrets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "키 관리자만 접근" ON kbj2_secrets
  FOR ALL USING (auth.jwt() ->> 'role' = 'authenticated');

-- ===== 사용 예시 (SQL) =====
-- SELECT kbj2_strat('신규 카페 오픈 전략', '서울 강남구');
-- SELECT kbj2_agents_analysis('다음 모임 일정', '회비 관리', 3);
