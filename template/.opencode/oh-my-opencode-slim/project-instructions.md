# Project Instructions

This workspace is for authorized software engineering on the current project.

- Inspect the repository before making assumptions about frameworks, package managers, test commands, architecture, or style.
- Preserve user work. Do not revert, overwrite, or clean up changes you did not make unless explicitly asked.
- Keep changes small, targeted, and consistent with the existing codebase.
- Do not read, print, summarize, or persist secrets from `.env`, `.env.*`, credential files, key files, PEM files, token files, or endpoint lists unless the user explicitly authorizes that exact action in the current turn.
- Do not publish packages, push branches, deploy infrastructure, touch production systems, broadcast transactions, or run destructive cleanup without explicit current-turn authorization.
- Prefer read-only analysis first, then minimal edits, then verification with the repository's existing tooling.
- Use the selected OpenCode Go profile. The balanced profile is the default; the quality profile deliberately spends more of the premium-model allowances.
- Treat the configured agent models as authoritative. If two-model customization was selected during installation, use those custom routes instead of the curated mappings described below.
- In the balanced profile, use **MiniMax M3** (`thinking`) for orchestration, **Qwen3.8 Flash** for balanced general work, **LongCat 2.0** for high-volume exploration and summaries, **GLM-5.3 Flash** (`max`) for planning, and **Kimi K2.7 Code** for implementation.
- In the quality profile, use **Qwen3.8 Max** for orchestration and difficult reasoning, **GLM-5.3** (`max`) for planning and architecture, **Qwen3.8 Flash** for exploration and summaries, and **Kimi K2.7 Code** for implementation.
- Balanced observation uses **MiMo V2.5** first and Qwen3.8 Flash as fallback. Quality observation uses **Qwen3.8 Max** first and MiMo V2.5 as fallback.
- Use **DeepSeek V4 Pro** (`max`) for defensive security review and **DeepSeek V4 Flash** (`high`) as an economical exploration fallback.
- Use only variants exposed by the selected model. Kimi K2.7 Code, MiMo V2.5, and Qwen3.7 Max do not have configurable variants in the current Go catalog.
- Reserve Qwen3.8 Max, full GLM-5.3, and DeepSeek V4 Pro for Oracle, architecture, council, security, and high-stakes review in the balanced profile.
- Use `@code-reviewer`, `@repo-architect`, `@test-writer`, `@security-reviewer`, `@oracle`, and council members for second-pass checks when the work benefits from focused review.
- Keep security work defensive and scoped to repositories, systems, and targets the user is authorized to review.
- If a request cannot be handled safely, reframe it into defensive validation, remediation, test design, or documentation.
