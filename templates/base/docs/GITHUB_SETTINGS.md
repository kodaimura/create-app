# GitHub Repository Settings

GitHub repository settings are not copied from a template repository. A
repository owner or administrator should complete this checklist once after the
initial push and the first successful CI run.

## Pull request settings

Open **Settings > General > Pull Requests** and configure the repository to:

- Enable squash merging.
- Disable merge commits.
- Disable rebase merging.
- Automatically delete head branches after merging.

## Main branch ruleset

Open **Settings > Rules > Rulesets**, create a branch ruleset targeting `main`,
and enable these rules:

- Require a pull request before merging.
- Require the `Quality`, `E2E`, and `Build` checks from the `CI` workflow to
  pass.
- Require conversation resolution before merging.
- Restrict branch deletion.
- Block force pushes.

Use zero required approvals for solo development. Require at least one approval
when other developers can merge changes. Set the ruleset to **Active** after
reviewing its target and bypass permissions.

## Dependency alerts

Enable **Dependabot alerts** under the personal account's **Settings > Advanced
Security**. Enable them for existing repositories and automatically for new
repositories when the same policy should apply across the account.

Use alerts to review and prioritize vulnerable dependencies without failing
unrelated pull requests. Leave automatic Dependabot security updates disabled
unless the project has decided to accept automatically generated update pull
requests.
