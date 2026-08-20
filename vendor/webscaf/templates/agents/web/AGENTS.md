# Web Instructions

## Project Context

- Read the web `README.md`, `Makefile`, and package scripts before changing development workflows.
- Preserve the existing frontend structure, component boundaries, and styling conventions unless the task requires an architectural change.
- When `docs/ARCHITECTURE.md` exists, read it before changing application code and treat it as the web application's local architecture contract.

## Working Agreements

- Keep page-specific behavior and reusable components in their existing responsibilities.
- Keep API request and response types close to the feature that owns them.
- Add or update tests when user-visible behavior changes.

## Verification

- Run `make check` after web changes.
- Run the framework's production build when production dependencies or build configuration changes.

## Operations

- Read `../docs/RUNBOOK.md` before changing production behavior or assisting with a deployment, release, rollback, recovery, or production incident.
