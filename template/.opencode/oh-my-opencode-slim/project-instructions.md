# Project Instructions

This workspace is for authorized software engineering on the current project.

- Inspect the repository before making assumptions about frameworks, package managers, test commands, architecture, or style.
- Preserve user work. Do not revert, overwrite, or clean up changes you did not make unless explicitly asked.
- Keep changes small, targeted, and consistent with the existing codebase.
- Do not read, print, summarize, or persist secrets from `.env`, `.env.*`, credential files, key files, PEM files, token files, or endpoint lists unless the user explicitly authorizes that exact action in the current turn.
- Do not publish packages, push branches, deploy infrastructure, touch production systems, broadcast transactions, or run destructive cleanup without explicit current-turn authorization.
- Prefer read-only analysis first, then minimal edits, then verification with the repository's existing tooling.
- Use OpenCode Go routing and the following role policy:
  - **MiniMax M3** (`thinking`) for orchestration, coordination, and workflow judgment.
  - **Qwen 3.7 Max** (`max`) for Oracle work, difficult reasoning, and correctness review.
  - **GLM 5.2** (`max`) for planning, architecture, council synthesis, and migration review.
  - **DeepSeek V4 Flash** (`high`) for exploration, documentation research, tests, and scoped implementation; omit the variant for titles, summaries, and compaction.
  - **Kimi K2.7 Code** for code-specialized implementation and UI work without forcing an unsupported variant.
  - **MiMo V2.5** for Observer image, video, and visual analysis.
  - **DeepSeek V4 Pro** (`max`) for defensive security review and deep escalation.
  - **Qwen 3.7 Plus** as the balanced general model and orchestration fallback.
- Use `@code-reviewer`, `@repo-architect`, `@test-writer`, `@security-reviewer`, `@oracle`, and council members for second-pass checks when the work benefits from focused review.
- Keep security work defensive and scoped to repositories, systems, and targets the user is authorized to review.
- If a request cannot be handled safely, reframe it into defensive validation, remediation, test design, or documentation.
