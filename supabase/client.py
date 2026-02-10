"""
KBJ2 API 클라이언트 - Supabase Edge Functions 버전
"""
import requests
from typing import Optional, Dict, Any

class KBJ2SupabaseClient:
    """KBJ2 Supabase API 클라이언트"""

    def __init__(self, supabase_url: str, supabase_key: str):
        self.base_url = supabase_url.rstrip('/')
        self.key = supabase_key
        self.session = requests.Session()

    def strat(self, query: str, context: str = "") -> Dict[str, Any]:
        """
        전략 분석 (21 에이전트)

        Args:
            query: 분석할 주제
            context: 추가 배경 정보
        """
        response = self.session.post(
            f"{self.base_url}/functions/v1/kbj2/strat",
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {self.key}"
            },
            json={"query": query, "context": context},
            timeout=300
        )
        response.raise_for_status()
        return response.json()

    def health(self) -> Dict[str, Any]:
        """서버 상태 확인"""
        response = self.session.get(
            f"{self.base_url}/functions/v1/kbj2/health",
            headers={"Authorization": f"Bearer {self.key}"}
        )
        response.raise_for_status()
        return response.json()


# ===== 사용 예시 =====
if __name__ == "__main__":
    import os

    # 환경변수 또는 직접 입력
    SUPABASE_URL = os.environ.get("SUPABASE_URL", "https://your-project-ref.supabase.co")
    SUPABASE_KEY = os.environ.get("SUPABASE_ANON_KEY", "your-anon-key")

    client = KBJ2SupabaseClient(SUPABASE_URL, SUPABASE_KEY)

    # 전략 분석
    result = client.strat(
        query="신규 카페 오픈 전략 수립",
        context="서울 강남구, 타겟 2030"
    )

    if result.get("success"):
        print("✅ 분석 완료!")
        print(f"요청 ID: {result.get('request_id')}")
        print(f"데이터: {result.get('data')}")
    else:
        print(f"❌ 오류: {result.get('error')}")
