/**
 * KBJ2 API 클라이언트 - Supabase Edge Functions 버전
 */

class KBJ2SupabaseClient {
  constructor(supabaseUrl, supabaseKey) {
    this.baseUrl = supabaseUrl.replace(/\/$/, '');
    this.key = supabaseKey;
  }

  /**
   * 전략 분석 (21 에이전트)
   */
  async strat(query, context = '') {
    const response = await fetch(`${this.baseUrl}/functions/v1/kbj2/strat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.key}`
      },
      body: JSON.stringify({ query, context })
    });
    return await response.json();
  }

  /**
   * 헬스체크
   */
  async health() {
    const response = await fetch(`${this.baseUrl}/functions/v1/kbj2/health`, {
      headers: {
        'Authorization': `Bearer ${this.key}`
      }
    });
    return await response.json();
  }
}

// 사용 예시
/*
const client = new KBJ2SupabaseClient(
  'https://your-project-ref.supabase.co',
  'your-anon-key'
);

const result = await client.strat('신규 카페 오픈 전략', '서울 강남구');
console.log(result);
*/

export default KBJ2SupabaseClient;
