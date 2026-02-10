#!/bin/bash
# KBJ2 API 클라이언트 - cURL

API_URL="https://your-kbj2-domain.com"

# 전략 분석 (21 에이전트)
kbj2_strat() {
    local query="$1"
    local context="${2:-}"

    curl -X POST "${API_URL}/api/strat" \
        -H "Content-Type: application/json" \
        -d "{\"query\":\"$query\",\"context\":\"$context\"}"
}

# EDMS 도면 분석
kbj2_edms() {
    local filepath="$1"

    curl -X POST "${API_URL}/api/edms" \
        -H "Content-Type: application/json" \
        -d "{\"filepath\":\"$filepath\"}"
}

# 엔터프라이즈 분석
kbj2_enterprise() {
    local projects="$1"  # 콤마로 구분된 프로젝트 목록

    curl -X POST "${API_URL}/api/enterprise" \
        -H "Content-Type: application/json" \
        -d "{\"projects\":[\"$projects\"]}"
}

# 헬스체크
kbj2_health() {
    curl "${API_URL}/health"
}

# ===== 사용 예시 =====
# kbj2_strat "신규 카페 오픈 전략" "서울 강남구"
# kbj2_health
