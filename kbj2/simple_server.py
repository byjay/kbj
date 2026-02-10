"""
KBJ2 간단 서버
Python으로 된 KBJ2를 웹에서 호출 가능하게 만듦
"""
import asyncio
import sys
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import uvicorn

# KBJ2 모듈 임포트
from kbj2.system import EDMSAgentSystem
from kbj2.strat_team import StrategicPlanningTeam

app = FastAPI(title="KBJ2 API")

# 전역 변수
_system = None
_strat_team = None

def get_system():
    global _system, _strat_team
    if _system is None:
        _system = EDMSAgentSystem()
        _strat_team = StrategicPlanningTeam(_system)
    return _system

class StratRequest(BaseModel):
    query: str
    context: str = ""

@app.get("/")
def root():
    return {"service": "KBJ2 API", "endpoints": {"/strat": "POST - 전략 분석"}}

@app.post("/strat")
async def analyze(req: StratRequest):
    """전략 분석 실행"""
    try:
        get_system()
        result = await _strat_team.run_strategic_analysis(req.query, req.context)
        return {"success": True, "data": result}
    except Exception as e:
        return {"success": False, "error": str(e)}

if __name__ == "__main__":
    if sys.platform == 'win32':
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

    print("🚀 KBJ2 서버 시작: http://localhost:8000")
    uvicorn.run(app, host="0.0.0.0", port=8000)
