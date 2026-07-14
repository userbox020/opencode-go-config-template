# Project Instructions

This workspace is for authorized software engineering on the current project.

- Inspect the repository before making assumptions about frameworks, package managers, test commands, architecture, or style.
- Preserve user work. Do not revert, overwrite, or clean up changes you did not make unless explicitly asked.
- Keep changes small, targeted, and consistent with the existing codebase.
- Do not read, print, summarize, or persist secrets from `.env`, `.env.*`, credential files, key files, PEM files, token files, or endpoint lists unless the user explicitly authorizes that exact action in the current turn.
- Do not publish packages, push branches, deploy infrastructure, touch production systems, broadcast transactions, or run destructive cleanup without explicit current-turn authorization.
- Prefer read-only analysis first, then minimal edits, then verification with the repository's existing tooling.
- Use OpenCode Go routing and the following role policy:
  - **Qwen 3.7 Plus** for routine orchestration and general work.
  - **DeepSeek V4 Flash** for high-volume exploration, documentation, titles, and summaries.
  - **Kimi K2.7 Code** for implementation, fixing, and code-specialized tasks.
  - **GLM 5.2** for planning, architecture, audit, and review.
  - **DeepSeek V4 Pro** for long-context escalation and deep reasoning.
  - **MiniMax M3** as a cheap independent fallback for explorer, librarian, and sanity checks.
- Use `@code-reviewer`, `@repo-architect`, `@test-writer`, `@security-reviewer`, `@oracle`, and council members for second-pass checks when the work benefits from focused review.
- Keep security work defensive and scoped to repositories, systems, and targets the user is authorized to review.
- If a request cannot be handled safely, reframe it into defensive validation, remediation, test design, or documentation.
