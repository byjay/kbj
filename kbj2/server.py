"""
KBJ2 API Server
21-Agent Super Intelligence System as a Service
"""
import os
import sys
import asyncio
from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
import uvicorn

from .system import EDMSAgentSystem
from .strat_team import StrategicPlanningTeam
from .edms_team import EDMSSpecializedTeams
from .orchestrator_v2 import EnterpriseOrchestrator

# ===== Pydantic Models =====
class StratRequest(BaseModel):
    """전략 분석 요청"""
    query: str = Field(..., description="분석할 주제", min_length=1, max_length=1000)
    context: str = Field("", description="추가 배경 정보", max_length=2000)

class StratResponse(BaseModel):
    """전략 분석 응답"""
    success: bool
    request_id: str
    data: Optional[Dict[str, Any]] = None
    error: Optional[str] = None

class EDMSRequest(BaseModel):
    """EDMS 분석 요청"""
    filepath: str = Field(..., description="도면 파일 경로")

class EnterpriseRequest(BaseModel):
    """엔터프라이즈 분석 요청"""
    projects: List[str] = Field(..., description="프로젝트 목록", min_items=1)

class HealthResponse(BaseModel):
    """헬스체크 응답"""
    status: str
    version: str
    agents_ready: bool

# ===== App Setup =====
app = FastAPI(
    title="KBJ2 API",
    description="21-Agent Super Intelligence System",
    version="2.0.0"
)

# CORS (모든 도메인 허용 - 프로덕션에서는 제한 필요)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ===== Global System =====
_system: Optional[EDMSAgentSystem] = None
_strat_team: Optional[StrategicPlanningTeam] = None
_edms_team: Optional[EDMSSpecializedTeams] = None

def get_system() -> EDMSAgentSystem:
    """시스템 인스턴스 가져오기 (지연 초기화)"""
    global _system, _strat_team, _edms_team
    if _system is None:
        _system = EDMSAgentSystem()
        _strat_team = StrategicPlanningTeam(_system)
        _edms_team = EDMSSpecializedTeams(_system)
    return _system

# ===== Routes =====

@app.get("/", response_model=Dict[str, Any])
async def root():
    """루트 엔드포인트"""
    return {
        "service": "KBJ2 API",
        "version": "2.0.0",
        "endpoints": {
            "POST /api/strat": "전략 분석 (21 에이전트)",
            "POST /api/edms": "EDMS 도면 분석",
            "POST /api/enterprise": "대규모 병렬 분석",
            "GET /health": "상태 확인"
        },
        "docs": "/docs"
    }

@app.get("/health", response_model=HealthResponse)
async def health():
    """헬스체크"""
    return HealthResponse(
        status="healthy",
        version="2.0.0",
        agents_ready=True
    )

@app.post("/api/strat", response_model=StratResponse)
async def analyze_strategy(request: StratRequest, background_tasks: BackgroundTasks):
    """
    전략 분석 API (21 에이전트)

    ## 사용 예시
    ```python
    import requests
    response = requests.post("https://your-domain.com/api/strat", json={
        "query": "신규 카페 오픈 전략 수립",
        "context": "서울 강남구, 타겟 2030"
    })
    ```
    """
    import uuid
    request_id = str(uuid.uuid4())[:8]

    try:
        system = get_system()
        result = await _strat_team.run_strategic_analysis(request.query, request.context)

        return StratResponse(
            success=True,
            request_id=request_id,
            data=result
        )
    except Exception as e:
        return StratResponse(
            success=False,
            request_id=request_id,
            error=str(e)
        )

@app.post("/api/edms")
async def analyze_edms(request: EDMSRequest):
    """
    EDMS 도면 분석 API

    ## 사용 예시
    ```python
    import requests
    response = requests.post("https://your-domain.com/api/edms", json={
        "filepath": "/path/to/drawing.pdf"
    })
    ```
    """
    import uuid
    request_id = str(uuid.uuid4())[:8]

    try:
        system = get_system()
        analysis = await _edms_team.analyze_drawing(request.filepath)
        bom = await _edms_team.generate_bom(analysis)

        return {
            "success": True,
            "request_id": request_id,
            "data": {
                "analysis": analysis,
                "bom": bom
            }
        }
    except Exception as e:
        return {
            "success": False,
            "request_id": request_id,
            "error": str(e)
        }

@app.post("/api/enterprise")
async def analyze_enterprise(request: EnterpriseRequest):
    """
    엔터프라이즈 병렬 분석 API

    ## 사용 예시
    ```python
    import requests
    response = requests.post("https://your-domain.com/api/enterprise", json={
        "projects": ["프로젝트A", "프로젝트B", "프로젝트C"]
    })
    ```
    """
    import uuid
    request_id = str(uuid.uuid4())[:8]

    try:
        system = get_system()
        orchestrator = EnterpriseOrchestrator(system)
        projects = [f"Project_{i}: {p.strip()}" for i, p in enumerate(request.projects)]
        result = await orchestrator.launch_project_cluster(projects)

        return {
            "success": True,
            "request_id": request_id,
            "data": result
        }
    except Exception as e:
        return {
            "success": False,
            "request_id": request_id,
            "error": str(e)
        }

# ===== Server Startup =====
def start_server(host: str = "0.0.0.0", port: int = 8000):
    """서버 시작"""
    if sys.platform == 'win32':
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

    print(f"""
    ╔══════════════════════════════════════════════════════════════╗
    ║           🚀 KBJ2 API Server Starting...                    ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  URL:      http://{host}:{port}                              ║
    ║  Docs:     http://{host}:{port}/docs                         ║
    ║  Version:  2.0.0                                              ║
    ║  Agents:   21-Agent System                                    ║
    ╚══════════════════════════════════════════════════════════════╝
    """)

    uvicorn.run(app, host=host, port=port)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="0.0.0.0", help="호스트 주소")
    parser.add_argument("--port", type=int, default=8000, help="포트 번호")
    args = parser.parse_args()

    start_server(args.host, args.port)
