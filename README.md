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
- The checked-in template and normal installs use the balanced profile. Its default `model` is `opencode-go/qwen3.8-flash` and `small_model` is `opencode-go/longcat-2.0`.
- Balanced core routing uses Kimi K2.7 Code for `build`, GLM-5.3 Flash (`max`) for `plan`, Qwen3.8 Flash (`medium`) for `general`, and LongCat 2.0 (`medium`) for `explore`. Title, summary, and compaction use LongCat 2.0 (`low`); compaction retains 6 tail turns.
- A quality profile is available through both installers. It uses Qwen3.8 Max for general work and orchestration, full GLM-5.3 (`max`) for planning, and Qwen3.8 Flash for high-volume support work while retaining Kimi K2.7 Code for implementation.
- `oh-my-opencode-slim` is pinned to `2.2.17` with plugin-managed auto-updates disabled. Periodic orchestrator wake-ups are explicitly disabled to keep usage predictable.
- Balanced plugin routing uses MiniMax M3 (`thinking`) for orchestration, premium Qwen3.8 Max only for Oracle and correctness review, GLM-5.3 Flash for council synthesis, LongCat 2.0 for exploration and research, Kimi K2.7 Code for implementation and UI work, and MiMo V2.5 for visual observation.
- Quality plugin routing uses Qwen3.8 Max for orchestration, Oracle, review, and visual fallback; full GLM-5.3 for architecture and council synthesis; Qwen3.8 Flash for exploration and research; and Kimi K2.7 Code for implementation.
- Observer is enabled with automatic image routing. Balanced uses MiMo V2.5 with Qwen3.8 Flash fallback; quality uses Qwen3.8 Max with MiMo V2.5 fallback.
- Custom reviewers use Qwen3.8 Max, GLM-5.3, and DeepSeek V4 Pro with model-family fallbacks. The review council uses those three families for correctness, architecture, and security perspectives.
- Model fallback retries once before moving through a configured chain. Unsupported generic variants are intentionally omitted instead of being silently ignored by OpenCode.
- Normal and non-interactive installs preserve balanced defaults unless quality is explicitly selected. Two-model customization replaces text-agent routing but leaves the vision-capable Observer route intact.
- Secret-like files are read-gated and edit-denied by default.
- Risky shell operations such as `git push`, package publish, production deploy, `kubectl`, `terraform apply`, `pulumi up`, live transaction broadcasts, and destructive cleanup ask first.

## Role Policy

- **MiniMax M3** for orchestration, coordination, and workflow judgment.
- **Qwen3.8 Flash** for balanced general work, exploration fallback, tests, and visual fallback.
- **Qwen3.8 Max** for quality orchestration, Oracle work, difficult reasoning, and correctness review.
- **GLM-5.3 Flash** for balanced planning and council synthesis.
- **GLM-5.3** for quality planning, architecture, council synthesis, and migration review.
- **LongCat 2.0** for high-volume exploration, documentation, titles, summaries, and compaction.
- **DeepSeek V4 Flash** for economical exploration fallback.
- **Kimi K2.7 Code** for code-specialized implementation and UI work.
- **MiMo V2.5** for screenshots, images, video, and visual analysis.
- **DeepSeek V4 Pro** for defensive security review and deep escalation.

## Requirements

- OpenCode installed and available as `opencode` or `opencode.cmd`. Version `1.18.25` or newer is recommended.
- npm package access so OpenCode can load the pinned `oh-my-opencode-slim@2.2.17` plugin.
- An active OpenCode Go subscription.
- Node.js or Python 3 is required by the macOS/Linux installer for the quality profile or explicit two-model customization.

OpenCode Go costs **$10/month**. Its included usage limits are **$12 per rolling 5 hours**, **$30 per week**, and **$60 per month**. Some premium models receive a lower monthly allowance. The provider does not publish RPM, TPM, concurrency, or latency SLA limits.

## Current Go Catalog

As of August 30, 2026, `opencode models opencode-go` returns these 25 active IDs:

- `deepseek-v4-flash`, `deepseek-v4-flash-vision-exp`, `deepseek-v4-pro`
- `glm-5.1`, `glm-5.2`, `glm-5.3`, `glm-5.3-flash`
- `gpt-5.6-luna`, `grok-4.6`
- `hy3`, `hy4-preview`
- `kimi-k2.6`, `kimi-k2.7-code`, `kimi-k3`
- `longcat-2.0`
- `mimo-v2.5`, `mimo-v2.5-pro`
- `minimax-m2.7`, `minimax-m3`
- `muse-spark-1.2-contributor`
- `qwen3.6-plus`, `qwen3.7-max`, `qwen3.7-plus`, `qwen3.8-flash`, `qwen3.8-max`

Muse Spark Contributor is not a default because prompts and completions may be used for training and availability is region-limited. Grok 4.6 and GPT 5.6 Luna retain data for up to 30 days. Kimi K3, Qwen3.8 Max, full GLM-5.3, and DeepSeek V4 Pro have lower monthly allowances, so the balanced profile reserves the latter three for infrequent specialist work. Hy4 remains a preview, and DeepSeek V4 Flash Vision remains experimental and lacks video input, so neither replaces the stable Observer route.

The installer queries `opencode models opencode-go` only when interactive customization is selected. Catalog presence does not guarantee runtime availability. If your setup uses different model names, select them during install or edit both:

- `template/.opencode/opencode.jsonc`
- `template/.opencode/oh-my-opencode-slim.jsonc`

Primary references are the [OpenCode Go documentation](https://opencode.ai/docs/go/), the live `opencode models opencode-go` catalog, and the [`oh-my-opencode-slim` v2.2.17 release](https://github.com/alvinunreal/oh-my-opencode-slim/releases/tag/v2.2.17).

## Install Into A Project

From this repo on Windows:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -ProjectPath C:\path\to\your-project
```

Press Enter at the profile prompt to install the balanced profile. The installer can instead generate the quality profile or replace text-agent routing with two models selected from OpenCode's catalog.

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

## Routing Profiles

Balanced is the default for interactive and non-interactive installs. Select quality explicitly when higher reasoning quality is worth using premium allowances more quickly.

Windows quality profile:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -ProjectPath C:\path\to\your-project -Profile quality
```

macOS/Linux quality profile:

```bash
bash ./scripts/install.sh /path/to/your-project --profile quality
```

The checked-in template is balanced. The quality installer changes core OpenCode routing and selects the `quality` Slim preset. Re-run the installer with force mode and the desired profile to switch an installed project. A runtime `OH_MY_OPENCODE_SLIM_PRESET` override changes only Slim agents; rerun the installer to keep core OpenCode agents aligned.

After selecting a curated profile, interactive installs offer optional two-model customization:

- `primary`: defaults to `opencode-go/glm-5.3-flash` for planning, fixing, Oracle, architecture, and high-stakes specialist work.
- `balanced`: defaults to `opencode-go/qwen3.8-flash` for routine orchestration, general work, exploration, docs, design, titles, summaries, and compaction.

Custom routing omits model variants because variant names are provider-specific. It enables the selected providers alongside `opencode-go`, applies the custom text routes to both Slim presets so runtime overrides remain consistent, and retains each preset's curated Observer route.

Use a different provider model list:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -ProjectPath C:\path\to\your-project -Provider opencode-go
```

```bash
bash ./scripts/install.sh /path/to/your-project --provider opencode-go
```

Skip prompts and install balanced for automation:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -ProjectPath C:\path\to\your-project -NonInteractive
```

```bash
bash ./scripts/install.sh /path/to/your-project --non-interactive
```

Use `-NonInteractive -Profile quality` or `--non-interactive --profile quality` for automated quality installs. `OH_MY_OPENCODE_SLIM_PRESET` overrides Slim at runtime, so the installers warn when it conflicts with the selected profile. The Unix installer also accepts `OPENCODE_MODEL_PROVIDER` and `OPENCODE_BIN`.

## Validate After Install

Run these from the target project:

```bash
opencode models --refresh
opencode debug config
opencode debug agent orchestrator
opencode debug skill
npx oh-my-opencode-slim@2.2.17 doctor
```

The published OpenCode JSON schema can lag the live Go catalog and may temporarily flag newly added model IDs as enum errors. `opencode models opencode-go` plus a successful `opencode debug config` are the authoritative runtime checks for dynamic Go IDs; the Slim 2.2.17 schema should validate without exceptions.

Live smoke tests consume Go usage. These commands cover the models used by the curated profiles:

```bash
opencode run --agent build -m opencode-go/qwen3.8-flash --variant medium "Respond with exactly: ROUTING_OK_QWEN_FLASH"
opencode run --agent build -m opencode-go/qwen3.8-max --variant xhigh "Respond with exactly: ROUTING_OK_QWEN_MAX"
opencode run --agent build -m opencode-go/longcat-2.0 --variant medium "Respond with exactly: ROUTING_OK_LONGCAT"
opencode run --agent build -m opencode-go/glm-5.3-flash --variant max "Respond with exactly: ROUTING_OK_GLM_FLASH"
opencode run --agent build -m opencode-go/glm-5.3 --variant max "Respond with exactly: ROUTING_OK_GLM"
opencode run --agent build -m opencode-go/kimi-k2.7-code "Respond with exactly: ROUTING_OK_KIMI"
opencode run --agent build -m opencode-go/deepseek-v4-flash --variant high "Respond with exactly: ROUTING_OK_DEEPSEEK_FLASH"
opencode run --agent build -m opencode-go/deepseek-v4-pro --variant max "Respond with exactly: ROUTING_OK_DEEPSEEK_PRO"
opencode run --agent build -m opencode-go/minimax-m3 --variant thinking "Respond with exactly: ROUTING_OK_MINIMAX"
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
