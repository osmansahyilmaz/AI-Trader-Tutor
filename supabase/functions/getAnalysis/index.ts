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
    console.log(`[${traceId}] getAnalysis started`);

    try {
        // 1. Verify Auth
        const authHeader = req.headers.get("Authorization");
        if (!authHeader) {
            return new Response(JSON.stringify({ error: "Unauthorized" }), {
                status: 401,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        const supabaseClient = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_ANON_KEY") ?? "",
            { global: { headers: { Authorization: authHeader } } }
        );

        const {
            data: { user },
            error: userError,
        } = await supabaseClient.auth.getUser();

        if (userError || !user) {
            return new Response(JSON.stringify({ error: "Unauthorized" }), {
                status: 401,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // 2. Parse Input
        const url = new URL(req.url);
        const analysisId = url.searchParams.get("id");

        if (!analysisId) {
            return new Response(JSON.stringify({ error: "Missing analysisId" }), {
                status: 400,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // 3. Fetch from DB
        // We use the authenticated client, so RLS should apply if configured correctly.
        // However, Edge Functions often run with service role if not careful.
        // Here we initialized with `Authorization: authHeader`, so it acts as the user.
        // BUT, just to be safe and explicit, we also filter by user_id.

        const { data, error } = await supabaseClient
            .from("analyses")
            .select("*")
            .eq("id", analysisId)
            .eq("user_id", user.id) // Explicit ownership check
            .single();

        if (error) {
            console.error(`[${traceId}] Fetch error:`, error);
            // If row not found (or RLS hides it), error code is usually 'PGRST116' (JSON object requested, multiple (or no) rows returned)
            if (error.code === "PGRST116") {
                return new Response(JSON.stringify({ error: "Analysis not found" }), {
                    status: 404,
                    headers: { ...corsHeaders, "Content-Type": "application/json" },
                });
            }
            return new Response(JSON.stringify({ error: "Database error" }), {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // 4. Format Response
        const response = {
            analysisId: data.id,
            createdAt: data.created_at,
            payload_version: data.payload_version,
            analysis_payload: data.analysis_payload,
            explanation: data.explanation,
        };

        console.log(`[${traceId}] getAnalysis completed`);

        return new Response(JSON.stringify(response), {
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
