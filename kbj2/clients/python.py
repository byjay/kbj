"""
KBJ2 API 클라이언트 - Python
모든 프로젝트에서 사용 가능한 간단한 인터페이스
"""
import requests
from typing import Optional, Dict, Any, List

class KBJ2Client:
    """KBJ2 API 클라이언트"""

    def __init__(self, base_url: str = "https://your-kbj2-domain.com"):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()

    def strat(self, query: str, context: str = "") -> Dict[str, Any]:
        """
        전략 분석 (21 에이전트)

        Args:
            query: 분석할 주제
            context: 추가 배경 정보

        Returns:
            분석 결과 딕셔너리
        """
        response = self.session.post(
            f"{self.base_url}/api/strat",
            json={"query": query, "context": context},
            timeout=300  # 5분 (21 에이전트가 모두 작동할 시간)
        )
        response.raise_for_status()
        return response.json()

    def edms(self, filepath: str) -> Dict[str, Any]:
        """EDMS 도면 분석"""
        response = self.session.post(
            f"{self.base_url}/api/edms",
            json={"filepath": filepath},
            timeout=180
        )
        response.raise_for_status()
        return response.json()

    def enterprise(self, projects: List[str]) -> Dict[str, Any]:
        """대규모 병렬 분석"""
        response = self.session.post(
            f"{self.base_url}/api/enterprise",
            json={"projects": projects},
            timeout=600
        )
        response.raise_for_status()
        return response.json()

    def health(self) -> Dict[str, Any]:
        """서버 상태 확인"""
        response = self.session.get(f"{self.base_url}/health")
        response.raise_for_status()
        return response.json()


# ===== 사용 예시 =====
if __name__ == "__main__":
    # 클라이언트 초기화
    client = KBJ2Client("https://your-kbj2-domain.com")

    # 전략 분석
    result = client.strat(
        query="신규 카페 오픈 전략 수립",
        context="서울 강남구, 타겟 2030"
    )

    if result["success"]:
        print("✅ 분석 완료!")
        print(f"요청 ID: {result['request_id']}")
        print(f"데이터: {result['data']}")
    else:
        print(f"❌ 오류: {result['error']}")
