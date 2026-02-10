/**
 * KBJ2 API 클라이언트 - JavaScript/TypeScript
 * 모든 프로젝트에서 사용 가능한 간단한 인터페이스
 */

class KBJ2Client {
  constructor(baseUrl = 'https://your-kbj2-domain.com') {
    this.baseUrl = baseUrl.replace(/\/$/, '');
  }

  /**
   * 전략 분석 (21 에이전트)
   * @param {string} query - 분석할 주제
   * @param {string} context - 추가 배경 정보
   * @returns {Promise<object>} 분석 결과
   */
  async strat(query, context = '') {
    const response = await fetch(`${this.baseUrl}/api/strat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query, context })
    });
    return await response.json();
  }

  /**
   * EDMS 도면 분석
   */
  async edms(filepath) {
    const response = await fetch(`${this.baseUrl}/api/edms`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ filepath })
    });
    return await response.json();
  }

  /**
   * 대규모 병렬 분석
   */
  async enterprise(projects) {
    const response = await fetch(`${this.baseUrl}/api/enterprise`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ projects })
    });
    return await response.json();
  }

  /**
   * 서버 상태 확인
   */
  async health() {
    const response = await fetch(`${this.baseUrl}/health`);
    return await response.json();
  }
}

// ===== 사용 예시 =====

// Node.js/CommonJS
module.exports = KBJ2Client;

// ES Module
export default KBJ2Client;

// 브라우저 전역
if (typeof window !== 'undefined') {
  window.KBJ2Client = KBJ2Client;
}

/*
// 사용 예시
const client = new KBJ2Client('https://your-kbj2-domain.com');

const result = await client.strat(
  '신규 카페 오픈 전략 수립',
  '서울 강남구, 타겟 2030'
);

if (result.success) {
  console.log('✅ 분석 완료!', result.data);
} else {
  console.error('❌ 오류:', result.error);
}
*/
