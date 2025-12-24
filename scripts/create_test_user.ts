
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.21.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables");
    Deno.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

async function createTestUser() {
    const email = "demo@tradertutor.com";
    const password = "demo12345";

    console.log(`Checking if user ${email} exists...`);

    // Try to sign in first to see if it exists
    const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password
    });

    if (!signInError && signInData.user) {
        console.log("User already exists and login works.");
        return;
    }

    console.log("Creating user...");
    // Create user directly (admin auto-confirms email with service role usually, or we use admin.createUser)
    const { data, error } = await supabase.auth.admin.createUser({
        email,
        password,
        email_confirm: true
    });

    if (error) {
        console.error("Error creating user:", error);
    } else {
        console.log("User created successfully:", data.user.id);
    }
}

createTestUser();
