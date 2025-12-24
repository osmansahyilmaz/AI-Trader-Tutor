import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.21.0";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req) => {
    // Handle CORS preflight request
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    const traceId = crypto.randomUUID();
    console.log(`[${traceId}] analyzeRequest started`);

    try {
        // 1. Verify Auth
        const authHeader = req.headers.get("Authorization");
        if (!authHeader) {
            console.error(`[${traceId}] Missing Authorization header`);
            return new Response(JSON.stringify({ error: "Unauthorized" }), {
                status: 401,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Initialize Supabase client
        const supabaseClient = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_ANON_KEY") ?? "",
            { global: { headers: { Authorization: authHeader } } }
        );

        // Get user from token
        const {
            data: { user },
            error: userError,
        } = await supabaseClient.auth.getUser();

        if (userError || !user) {
            console.error(`[${traceId}] Invalid token: ${userError?.message}`);
            return new Response(JSON.stringify({ error: "Unauthorized" }), {
                status: 401,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        console.log(`[${traceId}] User authenticated: ${user.id}`);

        // 2. Parse & Validate Input
        const { symbol, timeframe, requestId, assetClass } = await req.json();

        if (!symbol || !timeframe || !requestId) {
            console.error(`[${traceId}] Invalid input: missing fields`);
            return new Response(
                JSON.stringify({ error: "Missing symbol, timeframe, or requestId" }),
                {
                    status: 400,
                    headers: { ...corsHeaders, "Content-Type": "application/json" },
                }
            );
        }

        // 3. Transaction Block (Credits + Idempotency)
        const { data: txResult, error: txError } = await supabaseClient.rpc(
            "process_request_transaction",
            {
                p_user_id: user.id,
                p_request_id: requestId,
            }
        );

        if (txError) {
            console.error(`[${traceId}] Transaction error:`, txError);
            return new Response(JSON.stringify({ error: "Transaction failed" }), {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        const status = txResult.status;

        if (status === "limit_exceeded") {
            console.warn(`[${traceId}] Rate limit exceeded for user ${user.id}`);
            return new Response(
                JSON.stringify({ error: "insufficient-funds" }),
                {
                    status: 402,
                    headers: { ...corsHeaders, "Content-Type": "application/json" },
                }
            );
        }

        if (status === "in_progress") {
            console.warn(`[${traceId}] Request ${requestId} already in progress`);
            return new Response(
                JSON.stringify({ error: "Request in progress" }),
                {
                    status: 409,
                    headers: { ...corsHeaders, "Content-Type": "application/json" },
                }
            );
        }

        if (status === "completed") {
            console.log(`[${traceId}] Returning cached analysis ${txResult.analysis_id}`);
            return new Response(JSON.stringify(txResult.analysis), {
                status: 200,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // 4. Fetch Market Data
        let candles;
        try {
            // Import from shared module
            const { fetchCandles } = await import("../_shared/marketData.ts");

            // Determine asset class if not provided
            let effectiveAssetClass = assetClass;
            if (!effectiveAssetClass) {
                if (symbol.includes("/")) effectiveAssetClass = "fx";
                else effectiveAssetClass = "crypto";
            }

            candles = await fetchCandles(symbol, timeframe, effectiveAssetClass);

            if (candles.length < 50) {
                throw new Error("Insufficient candle data");
            }

            console.log(`[${traceId}] Fetched ${candles.length} candles`);

        } catch (err) {
            console.error(`[${traceId}] Market Data Error:`, err);
            // Return 503 Service Unavailable if provider fails
            return new Response(JSON.stringify({ error: "Market data unavailable" }), {
                status: 503,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }
        // 5. Compute Indicators & Structure
        let indicators, structureData;
        try {
            const { computeIndicators } = await import("../_shared/indicators.ts");
            const { computeStructureAndLevels } = await import("../_shared/structure.ts");

            indicators = computeIndicators(candles);
            structureData = computeStructureAndLevels(candles);

            console.log(`[${traceId}] Computed: Trend=${indicators.trend_state}, Structure=${structureData.structure.state}, Levels=${structureData.levels.length}`);
        } catch (err) {
            console.error(`[${traceId}] Computation Error:`, err);
            return new Response(JSON.stringify({ error: "Analysis computation failed" }), {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // 6. Generate AI Explanation
        let explanation;
        try {
            const { generateExplanation } = await import("../_shared/openai.ts");

            const payloadForAI = {
                symbol,
                timeframe,
                current_price: candles[candles.length - 1].c,
                ...indicators,
                structure: structureData.structure,
                levels: structureData.levels
            };

            explanation = await generateExplanation(payloadForAI);
            console.log(`[${traceId}] AI Explanation generated`);

        } catch (err) {
            console.error(`[${traceId}] AI Error:`, err);
            // Fallback is handled inside generateExplanation, but double check
            explanation = {
                summary: "Explanation generation failed.",
                indicators: "",
                scenarios: "",
                risk_note: "Educational only."
            };
        }

        // 7. Save to DB
        const analysisPayload = {
            symbol,
            timeframe,
            current_price: candles[candles.length - 1].c,
            ...indicators,
            structure: structureData.structure,
            levels: structureData.levels
        };

        // Insert into analyses
        const { data: analysisData, error: analysisError } = await supabaseClient
            .from("analyses")
            .insert({
                user_id: user.id,
                symbol,
                timeframe,
                payload_version: "1.0",
                analysis_payload: analysisPayload,
                explanation: explanation,
            })
            .select("id, created_at")
            .single();

        if (analysisError) {
            console.error(`[${traceId}] Failed to save analysis:`, analysisError);
            // We should probably mark request as failed, but let's try to return 500
            await supabaseClient
                .from("requests")
                .update({ status: "failed", error_code: "SAVE_ERROR" })
                .eq("user_id", user.id)
                .eq("request_id", requestId);

            return new Response(JSON.stringify({ error: "Failed to save analysis" }), {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Update request status
        const { error: updateError } = await supabaseClient
            .from("requests")
            .update({
                status: "completed",
                analysis_id: analysisData.id,
            })
            .eq("user_id", user.id)
            .eq("request_id", requestId);

        if (updateError) {
            console.error(`[${traceId}] Failed to update request status:`, updateError);
            // Analysis is saved but request status is wrong. This is an edge case.
            // For MVP, we log and return success because the user gets the data.
        }

        // Fetch updated credits to return
        // We can do a quick check on profiles
        const { data: profile } = await supabaseClient
            .from("profiles")
            .select("daily_limit, used_today")
            .eq("user_id", user.id)
            .single();

        const creditsLeft = profile ? (profile.daily_limit - profile.used_today) : 0;

        const finalResponse = {
            result: typeof explanation === 'string' ? explanation : explanation.summary, // Flatten for simple UI consumption if needed, or keep full object
            // User requested JSON: { result: string, credits_left: number }
            // But our UI might expect the full analysis object "analysis_payload" etc.
            // Let's return a hybrid or stick to the existing "finalResponse" structure but add credits_left
            // The prompt asks for { result: string, credits_left: number } specifically for the new requirement.
            // However, the Flutter app `AnalysisResponse.fromJson` expects `analysisId`, `createdAt`, etc.
            // I will ADD credits_left to the existing response to not break UI deserialization.
            analysisId: analysisData.id,
            createdAt: analysisData.created_at,
            payload_version: "1.0",
            analysis_payload: analysisPayload,
            explanation: explanation,
            credits_left: creditsLeft
        };

        // Also ensure "result" field exists if simple string is expected by new logic
        // finalResponse.result = ... (not overriding complexity)

        console.log(`[${traceId}] analyzeRequest completed successfully`);

        return new Response(JSON.stringify(finalResponse), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
            status: 200,
        });
    } catch (error) {
        console.error(`[${traceId}] Internal Error:`, error);
        return new Response(JSON.stringify({ error: "Internal Server Error" }), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
            status: 500,
        });
    }
});
