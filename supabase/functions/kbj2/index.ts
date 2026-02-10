/**
 * KBJ2 API for Supabase Edge Functions
 * 21-Agent Super Intelligence System (TypeScript/Deno 버전)
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

// ===== 타입 정의 =====
interface StratRequest {
  query: string
  context?: string
}

interface StratResponse {
  success: boolean
  request_id: string
  data?: any
  error?: string
}

interface AgentPersona {
  name: string
  role: string
  personality: string
  expertise: string[]
  decision_style: string
}

// ===== 에이전트 페르소나 =====
const DIRECTOR: AgentPersona = {
  name: "전략디렉터_최총괄",
  role: "전략 기획 총괄 및 의사결정",
  personality: "거시적 관점에서 전략을 수립하고, 팀원들의 의견을 종합하여 최종 결정",
  expertise: ["전략 기획", "조직 관리", "의사결정"],
  decision_style: "balanced"
}

const RESEARCH_TEAM: AgentPersona[] = [
  { name: "시장조사원_김데이터", role: "시장 동향 분석", personality: "데이터 중심적 사고", expertise: ["시장 분석", "경쟁사 조사"], decision_style: "analytical" },
  { name: "기술조사원_박테크", role: "기술 트렌드 조사", personality: "최신 기술에 관심", expertise: ["기술 동향", "특허 분석"], decision_style: "innovative" },
  { name: "규제분석가_이법률", role: "법적 규제 검토", personality: "보수적이고 꼼꼼함", expertise: ["해사법", "환경 규제"], decision_style: "conservative" },
  { name: "재무분석원_정비용", role: "비용 및 수익성 분석", personality: "수치에 민감하고 실리적", expertise: ["원가 회계", "ROI 분석"], decision_style: "financial" },
  { name: "공급망조사_한소싱", role: "공급망 현황 조사", personality: "발로 뛰는 현장형", expertise: ["물류", "협력사 네트워크"], decision_style: "field-oriented" }
]

// ===== GLM API 호출 =====
async function callGLMApi(prompt: string, apiKey: string): Promise<any> {
  const response = await fetch("https://api.z.ai/api/coding/paas/v4/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      model: "GLM-4.7",
      messages: [
        { role: "system", content: "You are a highly intelligent AI agent. Output JSON only." },
        { role: "user", content: prompt }
      ],
      temperature: 0.7,
      stream: false
    })
  })

  if (!response.ok) {
    throw new Error(`GLM API error: ${response.status}`)
  }

  const result = await response.json()
  const content = result.choices[0].message.content
    .replace(/```json/g, "")
    .replace(/```/g, "")
    .trim()

  try {
    return JSON.parse(content)
  } catch {
    return { analysis: content, recommendation: "Parse error" }
  }
}

// ===== 프롬프트 생성 =====
function createPrompt(persona: AgentPersona, context: string, task: string): string {
  return `당신은 ${persona.name}입니다.

[역할과 성격]
- 역할: ${persona.role}
- 성격: ${persona.personality}
- 전문분야: ${persona.expertise.join(", ")}
- 의사결정 스타일: ${persona.decision_style}

[현재 상황]
${context}

[수행할 작업]
${task}

JSON 형식으로 응답하세요:
{
  "agent_name": "${persona.name}",
  "analysis": "상세 분석 내용",
  "recommendation": "구체적 제안사항",
  "concerns": "우려사항",
  "next_action": "다음 단계"
}`
}

// ===== 핸들러 =====
serve(async (req) => {
  // CORS 처리
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization"
      }
    })
  }

  const url = new URL(req.url)
  const path = url.pathname

  // 루트 엔드포인트
  if (path === "/" || path === "/kbj2") {
    return new Response(JSON.stringify({
      service: "KBJ2 API (Supabase Edge Functions)",
      version: "2.0.0",
      endpoints: {
        "POST /kbj2/strat": "전략 분석 (21 에이전트)",
        "GET /kbj2/health": "상태 확인"
      }
    }), {
      headers: { "Content-Type": "application/json" }
    })
  }

  // 헬스체크
  if (path === "/kbj2/health") {
    return new Response(JSON.stringify({
      status: "healthy",
      version: "2.0.0",
      platform: "supabase-edge"
    }), {
      headers: { "Content-Type": "application/json" }
    })
  }

  // 전략 분석 API
  if (path === "/kbj2/strat" && req.method === "POST") {
    try {
      const { query, context = "" }: StratRequest = await req.json()

      if (!query) {
        throw new Error("query is required")
      }

      const requestId = crypto.randomUUID().slice(0, 8)
      const apiKey = Deno.env.get("ZAI_API_KEY")

      if (!apiKey) {
        throw new Error("ZAI_API_KEY not configured")
      }

      // 디렉터 계획 수립
      const directorPrompt = createPrompt(
        DIRECTOR,
        `전략적 의사결정이 필요한 상황: ${query}\n배경정보: ${context}`,
        "이 안건에 대한 분석 방향과 각 팀별 역할을 정의하고, 리서치팀에게 조사할 핵심 질문 3가지를 도출하세요."
      )

      const directorPlan = await callGLMApi(directorPrompt, apiKey)

      // 리서치 팀 병렬 실행
      const researchPromises = RESEARCH_TEAM.map(agent => {
        const prompt = createPrompt(
          agent,
          `디렉터 지시사항: ${JSON.stringify(directorPlan)}`,
          `'${query}' 관련하여 당신의 전문분야로 심층 조사하고 구체적인 데이터를 제시하세요.`
        )
        return callGLMApi(prompt, apiKey)
      })

      const researchResults = await Promise.all(researchPromises)

      // 결과 통합
      const response: StratResponse = {
        success: true,
        request_id: requestId,
        data: {
          director_planning: directorPlan,
          research_findings: researchResults,
          summary: {
            total_agents: 1 + RESEARCH_TEAM.length,
            query: query,
            timestamp: new Date().toISOString()
          }
        }
      }

      return new Response(JSON.stringify(response), {
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        }
      })

    } catch (error) {
      const errorResponse: StratResponse = {
        success: false,
        request_id: crypto.randomUUID().slice(0, 8),
        error: error.message
      }

      return new Response(JSON.stringify(errorResponse), {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        }
      })
    }
  }

  // 404
  return new Response(JSON.stringify({ error: "Not found" }), {
    status: 404,
    headers: { "Content-Type": "application/json" }
  }
})
