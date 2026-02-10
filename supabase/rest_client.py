"""
KBJ2 Supabase REST API 클라이언트
PostgreSQL Functions를 직접 호출하는 간단한 클라이언트
"""
import requests
from typing import Optional, Dict, Any, List

class KBJ2RestClient:
    """Supabase REST API 기반 KBJ2 클라이언트"""

    def __init__(self, supabase_url: str, supabase_key: str):
        self.base_url = supabase_url.rstrip('/')
        self.key = supabase_key
        self.session = requests.Session()

    def _headers(self) -> Dict[str, str]:
        return {
            'Content-Type': 'application/json',
            'apikey': self.key,
            'Authorization': f'Bearer {self.key}'
        }

    def strat(self, query: str, context: str = "") -> Dict[str, Any]:
        """
        간단 전략 분석

        Args:
            query: 분석할 주제
            context: 추가 배경 정보
        """
        response = self.session.post(
            f"{self.base_url}/rest/v1/rpc/kbj2_strat",
            headers=self._headers(),
            json={"query": query, "context": context},
            timeout=60
        )
        response.raise_for_status()
        return response.json()

    def agents_analysis(
        self,
        query: str,
        context: str = "",
        agent_count: int = 5
    ) -> Dict[str, Any]:
        """
        멀티 에이전트 분석 (1~5개 에이전트)

        Args:
            query: 분석할 주제
            context: 추가 배경 정보
            agent_count: 에이전트 수 (1~5)
        """
        response = self.session.post(
            f"{self.base_url}/rest/v1/rpc/kbj2_agents_analysis",
            headers=self._headers(),
            json={
                "query": query,
                "context": context,
                "agent_count": min(agent_count, 5)
            },
            timeout=180  # 3분 (여러 에이전트 실행)
        )
        response.raise_for_status()
        return response.json()

    def health(self) -> Dict[str, Any]:
        """서버 상태 확인"""
        response = self.session.get(
            f"{self.base_url}/rest/v1/",
            headers={'apikey': self.key}
        )
        response.raise_for_status()
        return {"status": "ok" if response.status_code == 200 else "error"}


# ===== 사용 예시 =====
if __name__ == "__main__":
    import os

    # 환경변수 또는 직접 입력
    SUPABASE_URL = os.environ.get("SUPABASE_URL", "https://your-project-ref.supabase.co")
    SUPABASE_KEY = os.environ.get("SUPABASE_ANON_KEY", "your-anon-key")

    # 클라이언트 초기화
    client = KBJ2RestClient(SUPABASE_URL, SUPABASE_KEY)

    # 1. 간단 전략 분석
    print("=== 간단 전략 분석 ===")
    result = client.strat(
        query="신규 카페 오픈 전략 수립",
        context="서울 강남구, 타겟 2030"
    )
    print(f"성공: {result.get('success')}")
    print(f"요청 ID: {result.get('request_id')}")

    # 2. 멀티 에이전트 분석
    print("\n=== 멀티 에이전트 분석 ===")
    multi_result = client.agents_analysis(
        query="다음 모임 일정 정해줘",
        context="회비 관리 앱",
        agent_count=3
    )
    print(f"성공: {multi_result.get('success')}")
    print(f"에이전트 수: {multi_result.get('agents')}")

    # 각 에이전트 응답 확인
    responses = multi_result.get('responses', {})
    for key, value in responses.items():
        print(f"\n[{key}]")
        print(value)
