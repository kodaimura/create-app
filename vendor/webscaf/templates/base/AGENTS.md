# Project Instructions

## Scope

- These instructions apply to the entire project.
- Before modifying `api/**`, read and follow `api/AGENTS.md`.
- Before modifying `web/**`, read and follow `web/AGENTS.md`.
- When a change affects both applications, follow both scoped instruction files.

## Working Agreements

- Read the relevant README and Makefile before changing development workflows.
- Keep changes focused and preserve unrelated work.
- Do not commit secrets, local environment files, or generated runtime data.
- Add or update tests when behavior changes.

## Verification

- Run `make check` for backend and frontend checks.
- Run `make test_e2e` when API behavior or database integration changes.
- Run `make build_prod` when production dependencies or container configuration changes.

## Operations

- Before changing production configuration, deployment behavior, database migration procedures, health checks, or rollback behavior, read `docs/RUNBOOK.md`.
- Read `docs/RUNBOOK.md` before assisting with a deployment, release, rollback, recovery, or production incident.
- Follow the runbook's authorization, verification, and stop conditions. Do not treat an implementation or commit request as deployment authorization.
