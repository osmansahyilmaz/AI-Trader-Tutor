# local_dev.md — Local development notes (Supabase + Flutter)

**Date:** 2025-12-20

## Secrets Setup
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Fill in the values in `.env` (contains BOTH public and server keys).

3. **Generate the public-only config for Flutter:**
   ```bash
   # Linux/Mac/Git Bash
   chmod +x scripts/generate_public_env.sh
   ./scripts/generate_public_env.sh
   
   # Windows PowerShell
   ./scripts/generate_public_env.ps1
   ```
   *This creates `.env.public` containing ONLY safe client variables.*

## Running Flutter
Use `--dart-define-from-file` with the **generated public file**:
```bash
flutter run --dart-define-from-file=.env.public
```

## Option A: Use deployed Supabase (simplest)
- Develop Flutter against the hosted project.
- Deploy Edge Functions to the hosted project.
- Set Edge secrets (using the master .env is fine here):
  ```bash
  supabase secrets set --env-file .env
  ```

## Option B: Local Supabase (recommended if agent supports it)
1) Install Supabase CLI
2) `supabase start`
3) Apply SQL migrations (or run `postgres_schema.sql`)
4) Serve Edge Functions (loading secrets from .env):
   - `supabase functions serve analyzeRequest --env-file .env`
   - `supabase functions serve getAnalysis --env-file .env`

Notes:
- **Auth Provider**: Use **Email + Password**. Anonymous & OTP disabled.
- **Supabase Dashboard**:
  1. Go to Authentication -> Providers -> Email -> Enable "Email provider".
  2. Go to Authentication -> Providers -> Email -> DISABLE "Confirm email".
  3. (Optional) "User Registrations" must be enabled.
- **Testing**: Register new user (instant login), or Login with existing.
