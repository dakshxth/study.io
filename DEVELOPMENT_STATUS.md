# Development Status

## Completed modules

- Local study dashboard and responsive macOS-inspired app shell
- Subject, chapter, and flashcard management
- Document upload and OCR-ready extraction pipeline
- Chat-based AI professor with offline fallback
- Light/dark theme support and premium desktop-style layout
- SQLite-backed local persistence with backup and export support
- Security/privacy dashboard for local document storage and AI provider state
- Mastery, dependency graph, and revision queue endpoints
- Automated backend validation tests for core workflows
- Private online deployment scaffold using Render Docker and Supabase Auth/Postgres/Storage
- Owner-only server-side session validation, HttpOnly cookie sessions, protected API routes, and cache/security headers
- Cloud-backed study state, backups, private uploaded-file storage, authenticated JSON export, and local-to-cloud migration utility
- Spotlight-style page navigation, responsive Dock, cloud-synced theme/sidebar/emoji preferences, categorized emoji picker, and private sign-in screen

## Partially completed modules

- Render/Supabase deployment requires the owner to provision the cloud project, create one Auth account, run `SUPABASE_SETUP.sql`, and add server secrets
- The included Render free tier sleeps when idle; an always-on plan can be selected in Render if desired
- Full Tauri desktop shell scaffolding is in place but still requires local Rust toolchain installation for packaging
- Advanced external AI provider integration remains optional and disabled by default
- OCR and semantic retrieval require local environment dependencies; they gracefully degrade offline when unavailable

## Pending modules

- Full multi-agent academic orchestration with separate agent implementations
- Edge-case document verification and manual correction workflows
- End-to-end front-end testing coverage for every navigation and workflow path
- Live deployment and cloud account configuration cannot be completed without the owner's Supabase/Render access and credentials
- End-to-end browser coverage and cloud-provider integration tests

## Known bugs

- Public registration is intentionally not implemented; deploy only one owner account and disable Supabase public sign-ups
- Tauri packaging is not yet verified in this environment without Rust tooling
- External AI providers remain optional and are never required for app functionality

## Required API keys

- Any external OpenAI-compatible endpoint: `STUDY_LLM_BASE_URL`, `STUDY_LLM_API_KEY`, `STUDY_LLM_MODEL`
- Optional Tesseract binary path: `TESSERACT_CMD`

## Testing status

- Backend workflow/auth tests: 21 passing
- Frontend production build: successful; Vite reports a non-blocking large JavaScript chunk warning

## Remaining development tasks

- Expand the professor and assessment agent logic into dedicated service objects
- Add richer semantic retrieval and local vector indexing
- Add advanced exam engine, homework solver, and spaced-repetition workflows to the UI
- Complete optional desktop packaging and real productization
