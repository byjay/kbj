@echo off
REM KBJ2 Render 배포 가이드 런처

echo.
echo ══════════════════════════════════════════════════════════════════
echo   🚀 KBJ2 Render 배포 - 클릭만 하면 됩니다!
echo ══════════════════════════════════════════════════════════════════
echo.

echo 1단계: Render Dashboard 열기
echo    브라우저가 열립니다...
echo.
timeout /t 2 >nul

start "" "https://dashboard.render.com/"

echo.
echo ══════════════════════════════════════════════════════════════════
echo   2단계: New Web Service 생성
echo ══════════════════════════════════════════════════════════════════
echo.
echo 다음 단계를 따라하세요:
echo.
echo 1. [New+] 버튼 클릭
echo 2. [New Web Service] 클릭
echo 3. GitHub 연동 (안되어 있으면)
echo.
pause

echo.
echo ══════════════════════════════════════════════════════════════════
echo   3단계: 레포지토리 선택
echo ══════════════════════════════════════════════════════════════════
echo.
echo 1. GitHub: byjay/kbj 선택
echo 2. Branch: main 선택
echo 3. Root Directory: (비워둠)
echo 4. [Next] 클릭
echo.
pause

echo.
echo ══════════════════════════════════════════════════════════════════
echo   4단계: 설정 입력
echo ══════════════════════════════════════════════════════════════════
echo.
echo 다음을 입력하세요:
echo.
echo Name: kbj2-api
echo Region: Singapore (또는 Oregon)
echo Branch: main
echo Runtime: Python 3
echo.
echo Build Command:
echo   pip install fastapi uvicorn requests aiohttp
echo.
echo Start Command:
echo   uvicorn kbj2.simple_server:app --host 0.0.0.0 --port $PORT
echo.
pause

echo.
echo ══════════════════════════════════════════════════════════════════
echo   5단계: 환경변수 설정
echo ══════════════════════════════════════════════════════════════════
echo.
echo 1. [Advanced] 클릭
echo 2. [Environment Variables] 탭
echo 3. [Add Variable] 클릭
echo 4. Key: ZAI_API_KEY
echo 5. Value: (당신의 ZAI API 키 입력)
echo 6. [Save] 클릭
echo.
pause

echo.
echo ══════════════════════════════════════════════════════════════════
echo   6단계: 배포 시작
echo ══════════════════════════════════════════════════════════════════
echo.
echo 1. [Create Web Service] 클릭
echo 2. 배포 시작됩니다 (약 3-5분 소요)
echo 3. 완료되면 URL 생성됩니다
echo.
pause

echo.
echo ══════════════════════════════════════════════════════════════════
echo   7단계: UptimeRobot 설정 (슬립 방지)
echo ══════════════════════════════════════════════════════════════════
echo.
echo UptimeRobot을 엽니다...
start "" "https://uptimerobot.com/"

echo.
echo 1. 회원가입 또는 로그인
echo 2. [Add New Monitor]
echo 3. Type: HTTPS
echo 4. URL: (배포된 Render URL 입력)
echo 5. Monitoring Interval: 5 minutes
echo 6. [Create Monitor]
echo.
echo ══════════════════════════════════════════════════════════════════
echo.
echo ✅ 배포 완료 후 다음 URL로 접근 가능:
echo    https://kbj2-api.onrender.com/strat
echo.
echo 📝 호출 예시:
echo    curl -X POST https://kbj2-api.onrender.com/strat ^
echo      -H "Content-Type: application/json" ^
echo      -d "{\"query\":\"다음 모임 일정\"}"
echo.
echo ══════════════════════════════════════════════════════════════════
echo.

pause
