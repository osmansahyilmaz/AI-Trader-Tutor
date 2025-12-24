export interface AnalysisPayload {
    symbol: string;
    timeframe: string;
    current_price: number;
    ema: {
        ema20: number;
        ema50: number;
        ema200: number;
    };
    trend_state: string;
    rsi: {
        value: number;
        state: string;
    };
    atr: {
        value: number;
        percent: number;
    };
    structure: {
        state: string;
        recent_pivots: any[];
    };
    levels: {
        type: string;
        price: number;
        touches: number;
    }[];
}

export interface Explanation {
    summary: string;
    indicators: string;
    scenarios: string;
    risk_note: string;
}

export async function generateExplanation(payload: AnalysisPayload): Promise<Explanation> {
    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
        console.warn("OPENAI_API_KEY not set. Returning stub explanation.");
        return getStubExplanation();
    }

    const prompt = `
You are an AI Trading Tutor. Your goal is to explain the market situation for ${payload.symbol} (${payload.timeframe}) based ONLY on the provided data.
You must write in TURKISH.
You must NOT give financial advice.
You must NOT invent numbers. Use only the numbers provided below.

DATA:
Current Price: ${payload.current_price}
Trend: ${payload.trend_state} (EMA20=${payload.ema.ema20.toFixed(2)}, EMA50=${payload.ema.ema50.toFixed(2)}, EMA200=${payload.ema.ema200.toFixed(2)})
RSI: ${payload.rsi.value.toFixed(2)} (${payload.rsi.state})
ATR: ${payload.atr.value.toFixed(2)} (${payload.atr.percent.toFixed(2)}%)
Structure: ${payload.structure.state}
Levels: ${JSON.stringify(payload.levels.map(l => `${l.type} at ${l.price.toFixed(2)}`))}

INSTRUCTIONS:
Output a JSON object with exactly these 4 fields:
1. "summary": A brief overview of the trend and structure.
2. "indicators": Explain what the EMAs and RSI are suggesting.
3. "scenarios": Describe "If price breaks above X..." or "If price holds Y..." scenarios using the provided levels.
4. "risk_note": A standard disclaimer that this is educational only.

FORMAT:
{
  "summary": "...",
  "indicators": "...",
  "scenarios": "...",
  "risk_note": "..."
}
`;

    try {
        const res = await fetch("https://api.openai.com/v1/chat/completions", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${apiKey}`,
            },
            body: JSON.stringify({
                model: "gpt-4o", // or gpt-3.5-turbo
                messages: [
                    { role: "system", content: "You are a helpful trading tutor. Output valid JSON." },
                    { role: "user", content: prompt }
                ],
                temperature: 0.7,
            }),
        });

        if (!res.ok) {
            const errText = await res.text();
            console.error("OpenAI API error:", res.status, errText);
            return getStubExplanation();
        }

        const data = await res.json();
        const content = data.choices[0].message.content;

        // Parse JSON from content (handle potential markdown code blocks)
        const jsonStr = content.replace(/```json\n|\n```/g, "").trim();
        const explanation = JSON.parse(jsonStr);

        return {
            summary: explanation.summary || "Summary unavailable.",
            indicators: explanation.indicators || "Indicators unavailable.",
            scenarios: explanation.scenarios || "Scenarios unavailable.",
            risk_note: explanation.risk_note || "Bu analiz eğitim amaçlıdır, yatırım tavsiyesi değildir.",
        };

    } catch (err) {
        console.error("OpenAI generation failed:", err);
        return getStubExplanation();
    }
}

function getStubExplanation(): Explanation {
    return {
        summary: "AI Tutor şu anda kullanılamıyor (API Key eksik veya hata oluştu).",
        indicators: "Lütfen aşağıdaki teknik verileri kendiniz inceleyiniz.",
        scenarios: "Destek ve direnç seviyelerine göre işlem planı yapabilirsiniz.",
        risk_note: "Bu analiz sadece eğitim amaçlıdır. Yatırım tavsiyesi içermez.",
    };
}
