# API Instructions

## Project Context

- Read the API `README.md` and `Makefile` before changing setup or development workflows.
- Preserve the existing backend structure and naming unless the task requires an architectural change.
- When `docs/ARCHITECTURE.md` exists, read it before changing application code and treat it as the API's local architecture contract.
- Do not assume that another backend pattern's architecture applies to this API.

## Working Agreements

- Keep request and response handling, business logic, and persistence concerns in their existing responsibilities.
- Use migrations for database schema changes.
- Add or update tests when API behavior changes.

## Verification

- Run `make check` after API changes.
- Run `make test_e2e` when API behavior or database integration changes.
- Run `make build_prod` when production dependencies or container configuration changes.

## Operations

- Read `../docs/RUNBOOK.md` before changing production behavior or assisting with a deployment, release, rollback, recovery, or production incident.
