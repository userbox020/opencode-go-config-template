# OpenCode Go Generic Project Config

Reusable OpenCode Go subscription project template. It is project-agnostic and conservative around secrets, destructive commands, publishing, deployments, and production access.

## What This Includes

- `template/.opencode/opencode.jsonc`: OpenCode project config.
- `template/.opencode/oh-my-opencode-slim.jsonc`: generic multi-agent routing for `oh-my-opencode-slim`.
- `template/.opencode/oh-my-opencode-slim/project-instructions.md`: project-wide working rules.
- `template/.opencode/oh-my-opencode-slim/orchestrator_append.md`: generic routing guidance.
- `template/.opencode/skills/project-workflow/SKILL.md`: reusable workflow skill for any codebase.
- `scripts/install.ps1`: Windows installer with interactive model selection.
- `scripts/install.sh`: macOS/Linux installer with interactive model selection.

No API keys, RPC endpoints, private keys, or project-specific paths are included.

## Defaults

- Enabled provider is `opencode-go`.
- Default `model` is `opencode-go/qwen3.7-plus` and `small_model` is `opencode-go/deepseek-v4-flash`.
- Core routing uses Kimi K2.7 Code for `build`, GLM-5.2 (`max`) for `plan`, Qwen3.7 Plus for `general`, and DeepSeek V4 Flash (`high`) for `explore`. Title, summary, and compaction use DeepSeek V4 Flash without a reasoning variant; compaction retains 6 tail turns.
- `oh-my-opencode-slim` is pinned to `2.2.8` with plugin-managed auto-updates disabled. Updates are deliberate and reproducible.
- Plugin routing uses MiniMax M3 (`thinking`) for orchestration, Qwen3.7 Max (`max`) for Oracle, GLM-5.2 (`max`) for council synthesis, DeepSeek V4 Flash (`high`) for exploration, research, tests, and scoped implementation, Kimi K2.7 Code for UI work, and MiMo V2.5 for visual observation.
- Observer is enabled with automatic image routing. Its fallback is the multimodal Qwen3.7 Plus model.
- Custom reviewers use Qwen3.7 Max, GLM-5.2, and DeepSeek V4 Pro with model-family fallbacks. The review council uses those three families for correctness, architecture, and security perspectives.
- Model fallback retries once before moving through a configured chain. Unsupported generic variants are intentionally omitted instead of being silently ignored by OpenCode.
- Normal and non-interactive installs preserve these curated defaults. Explicit two-model customization replaces text-agent routing but leaves the vision-capable Observer route intact.
- Secret-like files are read-gated and edit-denied by default.
- Risky shell operations such as `git push`, package publish, production deploy, `kubectl`, `terraform apply`, `pulumi up`, live transaction broadcasts, and destructive cleanup ask first.

## Role Policy

- **MiniMax M3** for orchestration, coordination, and workflow judgment.
- **Qwen3.7 Max** for Oracle work, difficult reasoning, and correctness review.
- **GLM-5.2** for planning, architecture, council synthesis, and migration review.
- **DeepSeek V4 Flash** for high-volume exploration, documentation, tests, summaries, and scoped implementation.
- **Kimi K2.7 Code** for code-specialized implementation and UI work.
- **MiMo V2.5** for screenshots, images, video, and visual analysis.
- **DeepSeek V4 Pro** for defensive security review and deep escalation.
- **Qwen3.7 Plus** for balanced general work and orchestration fallback.

## Requirements

- OpenCode installed and available as `opencode` or `opencode.cmd`. Version `1.18.9` or newer is recommended.
- npm package access so OpenCode can load the pinned `oh-my-opencode-slim@2.2.8` plugin.
- An active OpenCode Go subscription.
- Node.js or Python 3 is only required by the macOS/Linux installer when explicit two-model customization is selected.

OpenCode Go costs **$5 for the first month**, then **$10/month**. Its included usage limits are **$12 per rolling 5 hours**, **$30 per week**, and **$60 per month**. Some premium models receive a lower monthly allowance. The provider does not publish RPM, TPM, concurrency, or latency SLA limits.

## Current Go Catalog

As of July 29, 2026, `opencode models opencode-go` returns these 16 active IDs:

- `deepseek-v4-flash`, `deepseek-v4-pro`
- `glm-5.1`, `glm-5.2`, `grok-4.5`, `hy3`
- `kimi-k2.6`, `kimi-k2.7-code`, `kimi-k3`
- `mimo-v2.5`, `mimo-v2.5-pro`
- `minimax-m2.7`, `minimax-m3`
- `qwen3.6-plus`, `qwen3.7-max`, `qwen3.7-plus`

Kimi K3 and Grok 4.5 are not default routes because their Go allowances are much lower than the balanced specialist models. The installer queries `opencode models opencode-go` only when interactive customization is selected. Catalog presence does not guarantee runtime availability. If your setup uses different model names, select them during install or edit both:

- `template/.opencode/opencode.jsonc`
- `template/.opencode/oh-my-opencode-slim.jsonc`

Primary references are the [OpenCode Go documentation](https://opencode.ai/docs/go/), the live `opencode models opencode-go` catalog, and the [`oh-my-opencode-slim` v2.2.8 release](https://github.com/alvinunreal/oh-my-opencode-slim/releases/tag/v2.2.8).

## Install Into A Project

From this repo on Windows:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -ProjectPath C:\path\to\your-project
```

The installer preserves curated specialist routing by default. If you explicitly choose two-model customization, it shows each routing slot, a short description, its default, and the numbered models returned by OpenCode.

From this repo on macOS/Linux:

```bash
bash ./scripts/install.sh /path/to/your-project
```

If the target project already has `.opencode`, the installer stops unless you pass force mode.

Windows force mode:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -ProjectPath C:\path\to\your-project -Force
```

macOS/Linux force mode:

```bash
FORCE=1 bash ./scripts/install.sh /path/to/your-project
```

Force mode merges and overwrites matching template files. It does not delete extra files in the target `.opencode` directory.

## Interactive Model Routing

Press Enter at the routing prompt to keep the recommended specialist mapping. Choose customization only when you want to replace text-agent routing with two models:

- `primary`: defaults to `opencode-go/glm-5.2` for planning, fixing, Oracle, architecture, and high-stakes specialist work.
- `balanced`: defaults to `opencode-go/qwen3.7-plus` for routine orchestration, general work, exploration, docs, design, titles, summaries, and compaction.

Custom routing omits model variants because variant names are provider-specific. The curated MiMo V2.5 Observer route is retained so arbitrary text-only choices do not break image handling.

Use a different provider model list:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -ProjectPath C:\path\to\your-project -Provider opencode-go
```

```bash
bash ./scripts/install.sh /path/to/your-project --provider opencode-go
```

Skip prompts and keep curated specialist defaults for automation:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -ProjectPath C:\path\to\your-project -NonInteractive
```

```bash
bash ./scripts/install.sh /path/to/your-project --non-interactive
```

You can also set `OPENCODE_MODEL_PROVIDER` for the Unix installer, or `OPENCODE_BIN` if your OpenCode binary has a custom name.

## Validate After Install

Run these from the target project:

```bash
opencode models --refresh
opencode debug config
opencode debug agent orchestrator
opencode debug skill
npx oh-my-opencode-slim@2.2.8 doctor
```

Run a live model smoke test for each verified OpenCode Go ID if desired:

```bash
opencode run --agent build -m opencode-go/qwen3.7-plus "Respond with exactly: ROUTING_OK_QWEN"
opencode run --agent build -m opencode-go/qwen3.7-max "Respond with exactly: ROUTING_OK_QWEN_MAX"
opencode run --agent build -m opencode-go/deepseek-v4-flash "Respond with exactly: ROUTING_OK_FLASH"
opencode run --agent build -m opencode-go/glm-5.2 "Respond with exactly: ROUTING_OK_GLM"
opencode run --agent build -m opencode-go/kimi-k2.7-code "Respond with exactly: ROUTING_OK_KIMI"
opencode run --agent build -m opencode-go/deepseek-v4-pro "Respond with exactly: ROUTING_OK_PRO"
opencode run --agent build -m opencode-go/minimax-m3 "Respond with exactly: ROUTING_OK_MINIMAX"
opencode run --agent build -m opencode-go/mimo-v2.5 "Respond with exactly: ROUTING_OK_MIMO"
```

Restart any already-running OpenCode session after copying or editing config files. OpenCode loads config at startup.

## Included Agents

- `orchestrator`: primary project coordinator.
- `oracle`: focused clarification and second-pass reasoning.
- `observer`: read-only screenshot, image, video, and visual analysis.
- `code-reviewer`: correctness, maintainability, regression, and diff review.
- `repo-architect`: architecture, module boundaries, migration planning, and tradeoffs.
- `test-writer`: test strategy, fixtures, edge cases, and regression coverage.
- `security-reviewer`: defensive review for auth, secrets, injection, unsafe IO, dependencies, and deployment risk.

## Safety Rules

The template defaults to normal coding productivity while protecting common dangerous surfaces:

- Do not read or summarize secrets unless explicitly authorized in the current turn.
- Do not edit secret-bearing files.
- Ask before publishing packages, pushing git branches, deploying infrastructure, touching Kubernetes, running production migrations, or broadcasting transactions.
- Keep security work defensive and scoped to repositories, systems, and targets you are authorized to review.

## Upload To GitHub

If this folder is not already a git repo:

```bash
git init
git add .
git commit -m "Add OpenCode Go generic project config"
```

Create and push a private GitHub repo with GitHub CLI:

```bash
gh repo create opencode-go-config-template --private --source . --remote origin --push
```

Change `--private` to `--public` only if you are sure the repo contains no private notes or project-specific details.
