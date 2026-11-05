# STUDY.IO — Private Personal Study Platform

A private engineering study platform built as a React + Vite frontend and FastAPI backend. It supports a single-owner online deployment backed by Supabase Auth, Postgres, and a private Storage bucket, as well as local development. Features include:

- subject and chapter management
- private document upload and processing for PDF, DOCX, PPTX, TXT, images, and scanned PDFs with optional Tesseract OCR
- adaptive study dashboard
- AI professor chat with local fallback or an optional OpenAI-compatible LLM grounded in extracted study notes
- chapter/concept relationship graph, flashcards, memory lab, timed exam simulator, and study planner
- persistent light/dark appearance toggle
- SQLite-backed local or Supabase-backed online data persistence with backup, export, and deletion controls
- owner-only privacy dashboard and server-side secret configuration
- Tauri desktop shell scaffolding for private app-style desktop use
- progress analytics and gamified XP system
- editable academic profile and dashboard layout preferences
- persisted subject/chapter/concept/semester management and examination calendar
- session and assessment records that drive study-hour, streak, mastery, and countdown statistics
- browser-native optional voice dictation and speech output in AI Professor
- cinematic local welcome screen with live clock and real saved academic context

## Deploy the private online application

The production image serves both the built React application and FastAPI from one HTTPS origin. Supabase provides the single owner's authentication, cloud database, and private uploaded-file bucket. API access is checked on the server for every request; only the configured Supabase Auth UUID is accepted. Public registration must remain disabled and only your own account should exist in the Supabase project.

1. Create a private Supabase project. In **Authentication → Users**, create your personal account; copy its user UUID. Disable public sign-ups and enable MFA if available for your plan.
2. Run the updated [SUPABASE_SETUP.sql](SUPABASE_SETUP.sql) in the Supabase SQL Editor. It creates private study-state/backup/API-settings tables with RLS enabled and a non-public `study-files` bucket. Do not add browser-facing table or bucket access policies.
3. Push this repository to a private GitHub repository. In Render, create a Blueprint from that repository and use [render.yaml](render.yaml), or create a Docker web service with this repository's Dockerfile. The included free-tier service may sleep when idle; upgrade it in Render if an always-warm service is desired.
4. Set `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `STUDY_OWNER_ID`, and a unique long random `STUDY_APP_SECRET` in Render's service settings. The service-role key and encryption secret are server-only and must never be copied into the frontend or committed to git. Keep `STUDY_AUTH_REQUIRED=true` and `STUDY_COOKIE_SECURE=true`.
5. Deploy and open the Render HTTPS URL. The login page accepts the single account created in step 1; requests without its valid server-checked session are rejected. The database, backups, and uploaded originals persist in Supabase when the web process restarts.

Add AI provider and Brave Search credentials in **Settings → API configuration** after signing in. The backend encrypts those credentials with `STUDY_APP_SECRET` and persists the encrypted configuration in the owner-only Supabase API-settings table, so credentials survive service restarts. The UI can fetch model IDs currently available to each provider; select a listed model before saving/testing. Do not use a localhost provider URL in the online deployment. AI providers receive the user's prompt and relevant note excerpts; only enable providers you trust.

### Migrate the current local study data

Before enabling online use, create the Supabase tables/bucket and set the Supabase environment variables in a trusted local shell. From the backend directory, run `..\\.venv\\Scripts\\python.exe migrate_local_to_cloud.py`. The script refuses to overwrite a cloud account that already contains records, migrates existing state and matching uploaded originals, and leaves local files untouched. Do not put service-role credentials in source control or send them in chat. Verify the migrated subjects and files after signing in online.

Online backups are stored in the private database. The legacy local-only launch scripts and SQLite database remain available for development, but data entered locally is not automatically synchronized until the one-time migration is performed.

## Run the private local website (Windows)

Double-click [START.bat](START.bat). It checks the Python and Node dependencies, chooses available ports, starts FastAPI and Vite bound only to `127.0.0.1`, waits for both health checks, and opens the site in the default browser. It then creates [STOP.bat](STOP.bat) for this launch; use that file to stop only the app processes. Keep the two minimized PowerShell service windows open while using the app.

The local launcher is not published or publicly hosted: its backend and frontend listen on loopback only. Local development data and uploads remain under `backend/data`; automatic local backups are created at startup and hourly when data has changed. Use `STOP.bat` to stop the recorded instance without deleting academic data. For the online deployment, follow the cloud setup above.

### First-time setup

The workspace already contains `.venv` and `frontend/node_modules`. If setting up this checkout on another computer, install Python 3.11+ and Node.js LTS, then run in PowerShell from the project folder:

```powershell
py -3 -m venv .venv
.venv\Scripts\python.exe -m pip install -r backend\requirements.txt
npm --prefix frontend install
```

Then double-click [START.bat](START.bat). If it reports missing packages, follow the exact install step it prints.

## Optional online AI and academic research

For local development, keys can be added in **Settings → API configuration** or supplied in `backend/.env`; never put API keys in frontend code. The settings page supports Gemini, OpenAI, OpenAI-compatible custom endpoints, and Brave Search. It fetches provider model IDs instead of silently choosing a hard-coded model. Search results link to original pages, and search history is persisted locally. Providers transmit the query (and for tutoring, relevant excerpts from local notes) to the configured external service; use providers you trust. Without credentials or internet, local records, uploads, and progress remain available and research displays a clear configuration/connection error rather than simulated results.

## Manual local run

### 1) Start the backend

```powershell
cd backend
..\.venv\Scripts\python.exe run_local.py
```

### 2) Start the frontend

```powershell
npm --prefix frontend run dev -- --host 127.0.0.1
```

Then open:

- http://localhost:5173/
- API health: http://localhost:8000/health

### 3) Optional desktop shell

```powershell
npm --prefix "c:\Users\prabh\Downloads\STUDY\frontend" run dev:desktop
```

This runs the app in a local Tauri shell that keeps data and processing on the personal computer.

## Notes

- This project is intended for one private owner. Online mode requires Supabase Auth and uses cloud storage; local development remains available separately.
- Uploaded documents are saved under the backend data directory, with SQLite-backed persistence and backup history in the local app folder.
- Dashboard totals are computed from persisted records. Study time and streak require logged study sessions; assessment mastery requires recorded assessment scores; examination countdowns require saved examination records. Empty values are intentional until you enter data.
- Academic profile, exam calendar, dashboard preferences, study sessions, and assessment attempts are saved in the local SQLite-backed state and included in local backups/exports.
- AI integrations are optional and require internet access; local academic records and uploaded documents continue to be available offline.
- Optional OCR requires the Python packages in `backend/requirements.txt` and the Tesseract executable. Set `TESSERACT_CMD` when Tesseract is not on PATH.
- Provider credentials belong only in backend `.env` for local development or the hosting provider's server-side secret settings online. Never expose them in browser JavaScript. The local launcher binds to loopback; do not expose its development ports publicly.
- Optional voice dictation and speech use browser speech APIs if available. The microphone is requested only after activating dictation; speech recognition may use the browser vendor's recognition service.
- Local backups are plain JSON files under `backend/data/backups`; keep this folder private. Online backups are stored in the private Supabase database.
