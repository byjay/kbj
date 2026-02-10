/**
 * KBJ2 Supabase REST API 클라이언트
 * PostgreSQL Functions를 직접 호출
 */

class KBJ2RestClient {
  constructor(supabaseUrl, supabaseKey) {
    this.baseUrl = supabaseUrl.replace(/\/$/, '');
    this.key = supabaseKey;
  }

  /**
   * 간단 전략 분석
   */
  async strat(query, context = '') {
    const response = await fetch(`${this.baseUrl}/rest/v1/rpc/kbj2_strat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': this.key,
        'Authorization': `Bearer ${this.key}`
      },
      body: JSON.stringify({ query, context })
    });
    return await response.json();
  }

  /**
   * 멀티 에이전트 분석 (1~5개 에이전트)
   */
  async agentsAnalysis(query, context = '', agentCount = 5) {
    const response = await fetch(`${this.baseUrl}/rest/v1/rpc/kbj2_agents_analysis`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': this.key,
        'Authorization': `Bearer ${this.key}`
      },
      body: JSON.stringify({
        query,
        context,
        agent_count: Math.min(agentCount, 5)
      })
    });
    return await response.json();
  }

  /**
   * 헬스체크
   */
  async health() {
    const response = await fetch(`${this.baseUrl}/rest/v1/`, {
      headers: { 'apikey': this.key }
    });
    return { status: response.ok ? 'ok' : 'error' };
  }
}

// ===== 사용 예시 =====
/*
const client = new KBJ2RestClient(
  'https://your-project-ref.supabase.co',
  'your-anon-key'
);

// 간단 전략 분석
const result = await client.strat('신규 카페 오픈 전략', '서울 강남구');
console.log(result);

// 멀티 에이전트 분석
const multiResult = await client.agentsAnalysis(
  '다음 모임 일정 정해줘',
  '회비 관리 앱',
  3
);
console.log(multiResult.responses);
*/

export default KBJ2RestClient;
