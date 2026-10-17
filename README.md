# Liah Academy SMS

Flutter mobile/web client + Supabase backend for **Liah Academy School Management System (LA-SMS)**.

## Architecture

- **Flutter Client:** Beginner-friendly feature-first layout under `lib/features/`, **Riverpod** state management + **go_router** navigation. Each feature uses `models/`, `services/`, `providers/`, `screens/`, and `widgets/`.
- **Theme:** Liah Academy brand palette (`AppColors.navy`, `AppColors.navyDeep`, `AppColors.gold`, `AppColors.onNavy`) defined in `lib/app/theme/`.
- **Supabase Backend:** PostgreSQL with strict Row-Level Security (default deny), `auth.users` → `public.profiles` trigger mapping, RBAC (`roles`, `permissions`, `profile_roles`), and Deno **Edge Functions** for all privileged mutations.

## Repository Layout

```text
liah_app/
├── README.md                          ← Project overview + quick start
├── .env.example                       ← Environment variables (public + Edge Function secrets)
├── pubspec.yaml                       ← Flutter dependencies & assets
├── docs/
│   ├── API_CONTRACTS.md               ← Contracts for Edge Functions
│   ├── DATA_MODEL.md                  ← Domain table map & conventions
│   ├── OPEN_POLICIES.md               ← Open decision register & privileged operations
│   └── RLS_MATRIX.md                  ← Row-Level Security policy matrix
├── supabase/
│   ├── config.toml                    ← Local Supabase config (project_id = "la-sms-dev", signup disabled)
│   ├── migrations/
│   │   ├── 20241013000000_initial_schema.sql
│   │   ├── 20241013000001_roles_permissions.sql
│   │   ├── 20241013000002_rls_policies.sql
│   │   ├── 20241013000003_edge_auth_helpers.sql
│   │   └── 20241013000004_auth_profile_and_academic_rls.sql
│   ├── functions/
│   │   ├── _shared/                   ← Auth, CORS, response, & Supabase client helpers
│   │   ├── admin-create-student/      ← Creates Auth user + profile + student + matricule
│   │   ├── get-semester-access/       ← Evaluates registration window & fee clearance
│   │   ├── register-course/           ← Enrolls student in a course offering
│   │   └── drop-course/               ← Drops a registered course offering
│   └── seed.sql                       ← Roles, permissions, fee categories & academic seed data
└── lib/
    ├── main.dart
    ├── app/                           ← AppTheme, AppColors, GoRouter, bootstrap
    ├── core/                          ← Env, EdgeFunctionClient, formatters, widgets
    └── features/
        ├── README.md                  ← What each feature folder is for
        ├── academics/
        ├── administration/
        ├── admissions/
        ├── announcements/
        ├── attendance/
        ├── auth/                      ← Sign-in, sessions, profiles, and roles
        ├── dashboard/                 ← Role-based workspace shell
        ├── documents/
        ├── fees/
        ├── registration/              ← Course registration and drop screen
        ├── reports/
        ├── results/
        ├── staff/
        └── students/                  ← Student directory and create-student screen
```

## Supabase Environments

| Environment | Project ID | Purpose |
|-------------|------------|---------|
| Local / Dev | `la-sms-dev` | Development & integration testing |
| Staging | `la-sms-staging` | Pre-release UAT & payment sandbox verification |
| Production | `la-sms-prod` | Live academic & financial records |

## Quick Start

### 1. Supabase (Local)

Requires the [Supabase CLI](https://supabase.com/docs/guides/cli).

```bash
supabase start
supabase db reset          # Applies migrations + supabase/seed.sql
supabase functions serve   # Serves Edge Functions locally
```

### 2. Flutter Client

1. Copy `.env.example` → `.env` and set `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
2. Install packages and run:

```bash
flutter pub get
flutter run
```
