# Generic Project Routing

Use this routing policy for any project using this OpenCode Go-first template.

- Use the selected OpenCode Go profile. Balanced is the default; quality deliberately uses lower-allowance premium models more often.
- Treat the configured agent models as authoritative. If two-model customization was selected during installation, use those custom routes instead of the curated mappings described below.
- Balanced routing uses **MiniMax M3** (`thinking`) for orchestration, **Qwen3.8 Flash** for balanced work, **LongCat 2.0** for high-volume exploration and research, **GLM-5.3 Flash** (`max`) for planning, and **Kimi K2.7 Code** for implementation.
- Quality routing uses **Qwen3.8 Max** for orchestration and difficult reasoning, **GLM-5.3** (`max`) for planning and architecture, **Qwen3.8 Flash** for exploration, and **Kimi K2.7 Code** for implementation.
- Balanced observation uses **MiMo V2.5** first and Qwen3.8 Flash as fallback. Quality observation uses **Qwen3.8 Max** first and MiMo V2.5 as fallback.
- Use **DeepSeek V4 Pro** (`max`) for defensive security review and **DeepSeek V4 Flash** (`high`) as an economical exploration fallback.
- Use only variants exposed by the selected model. Do not invent generic variants for Kimi K2.7 Code, MiMo V2.5, or Qwen3.7 Max.
- Reserve maximum reasoning for Oracle, council synthesis, architecture, security, and high-stakes review.
- Prefer LongCat 2.0 and Qwen3.8 Flash for high-volume work; avoid routing routine balanced-profile tasks to low-allowance premium models merely because they are newer.
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
