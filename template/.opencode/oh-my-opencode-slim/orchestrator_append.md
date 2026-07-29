# Generic Project Routing

Use this routing policy for any project using this OpenCode Go-first template.

- Use OpenCode Go routing and the following role policy:
  - **MiniMax M3** (`thinking`) for orchestration, coordination, and workflow judgment.
  - **Qwen 3.7 Max** (`max`) for Oracle work, difficult reasoning, and correctness review.
  - **GLM 5.2** (`max`) for planning, architecture, council synthesis, and migration review.
  - **DeepSeek V4 Flash** (`high`) for exploration, documentation research, tests, and scoped implementation.
  - **Kimi K2.7 Code** for code-specialized implementation and UI work.
  - **MiMo V2.5** for Observer image, video, and visual analysis.
  - **DeepSeek V4 Pro** (`max`) for defensive security review and deep escalation.
  - **Qwen 3.7 Plus** as the balanced general model and orchestration fallback.
- Use only variants exposed by the selected model. Do not invent generic effort variants for Kimi K2.7 Code, MiMo V2.5, or Qwen 3.7 Plus.
- Reserve maximum reasoning for Oracle, council synthesis, architecture, security, and high-stakes review.
- Prefer DeepSeek V4 Flash for high-volume work; avoid routing routine tasks to low-allowance premium models merely because they are newer.
- Delegate focused second-pass work instead of making one agent solve every concern.
- Use `@code-reviewer` for correctness, regression, maintainability, edge-case, and test-gap review.
- Use `@repo-architect` for architecture decisions, migrations, module boundaries, API contracts, and sequencing.
- Use `@test-writer` for targeted tests, reproduction cases, fixtures, and verification commands.
- Use `@security-reviewer` for defensive review of auth, secrets, injection, unsafe IO, dependencies, deployment, logging, and data exposure.
- Use `@oracle` for narrow clarifications or independent reasoning checks.
- Use council only when parallel review is worth the extra time.
- Ask before reading secrets, modifying credential files, publishing packages, pushing branches, deploying, touching production systems, or running destructive commands.

## Review Handoff Shape

When delegating review, include the relevant code paths, summary of the intended behavior, known assumptions, files changed, tests run, tests not run, and specific concerns to check.
