# Deployment Runbook

This runbook defines the checks, execution boundaries, verification, and
recovery steps shared by every deployment environment. Complete the
project-specific values before the first deployment and keep them current when
the delivery process changes.

## Project-specific values

Document references and command names, but never credentials or secret values.

| Item                         | Value                                     |
| ---------------------------- | ----------------------------------------- |
| Environments                 | `<development, staging, production, ...>` |
| Deployment command           | `<command or script>`                     |
| Authentication command       | `<command or documented login procedure>` |
| Web URL and health check     | `<URL or command>`                        |
| API URL and health check     | `<URL or command>`                        |
| Critical flows               | `<links to smoke tests or manual checks>` |
| Logs and metrics             | `<location or command>`                   |
| Database backup and recovery | `<document or procedure>`                 |
| Previous release lookup      | `<artifact, image, or revision lookup>`   |
| Incident contact             | `<team or contact method>`                |

## Authorization and scope

- Identify the target environment and exact revision before running anything.
- A request to implement, review, or commit code does not authorize deployment.
- Deploy only when the requested environment and revision are unambiguous.
- Use the approved credentials and authentication method for the target
  environment. Do not print, copy, or store credentials in this repository.
- Record the operator, target environment, revision, and start time.

## Before deployment

1. Confirm the working tree and exact revision:

   ```sh
   git status --short
   git rev-parse HEAD
   ```

2. Confirm the revision is available from the expected remote and has passed
   the required CI checks.
3. Run the project checks:

   ```sh
   make check
   make test_e2e
   make build_prod
   ```

4. Run the backend dependency audit when runtime dependencies changed or the
   deployment is a release that requires a dependency review.
5. Confirm required environment variables and secrets exist in the target
   environment without displaying their values.
6. Review pending database migrations for locking, data conversion, deletion,
   and backward-compatibility risks.
7. Confirm the database backup and recovery procedure before any migration that
   can irreversibly change data.
8. Identify the previous known-good web and API artifacts or revision.

## Deployment

1. Authenticate using the project-specific procedure.
2. Run the documented deployment command with an explicit environment and
   revision whenever the command supports them.
3. Stop when a command returns a non-zero status. Preserve the relevant output
   without exposing secrets or personal data.
4. Record the deployed web and API artifacts or revision and completion time.

Do not continue by inventing replacement commands when a documented command is
missing or fails.

## Verification

1. Confirm the running web and API applications report the requested revision
   when the platform exposes that information.
2. Confirm the configured health checks succeed.
3. Confirm database migrations reached the expected revision.
4. Verify the documented critical user flows through the web and API.
5. Review startup logs, application errors, and available service metrics.
6. Report the environment, revision, checks performed, and final result.

## Stop conditions

Stop and request a decision before continuing when:

- The environment, revision, account, or deployment target is ambiguous.
- Required CI checks have not passed.
- Authentication or required configuration is unavailable.
- A migration may delete or irreversibly transform data and recovery has not
  been confirmed.
- The deployment command fails or the deployed revision does not match the
  requested revision.
- Health checks or critical flows fail after deployment.
- Continuing would require a destructive or undocumented operation.

## Rollback and recovery

- Prefer rolling the web and API applications back to their previous known-good
  artifacts or revision.
- Confirm that the selected web and API versions are compatible before rolling
  back only one component.
- Do not automatically downgrade database migrations.
- Require an explicit decision before destructive database recovery or any
  operation that may lose data.
- When the database schema is not backward compatible, choose a reviewed
  corrective migration or documented recovery procedure.
- Repeat all verification steps after rollback or recovery.

## Incident record

Record enough information to reproduce and review the event:

- Environment and affected services
- Requested and actual web and API revisions
- Start time, detection time, and recovery time
- Commands or automation invoked
- Failed checks and relevant sanitized logs
- User impact and known data impact
- Mitigation, rollback, or recovery performed
- Follow-up changes or documentation updates
