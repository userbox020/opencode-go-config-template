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
- Core agent variants: `build` uses `opencode-go/kimi-k2.7-code` (high); `plan` uses `opencode-go/glm-5.2` (high); `general` uses `opencode-go/qwen3.7-plus` (medium); `explore`, `title`, and `summary` use `opencode-go/deepseek-v4-flash` (low); `compaction` uses `opencode-go/deepseek-v4-flash` (medium). Compaction retains 6 tail turns.
- `oh-my-opencode-slim` routing uses the same OpenCode Go model IDs: orchestrator (`qwen3.7-plus` medium → `glm-5.2` high), oracle (`glm-5.2` high → `deepseek-v4-pro` high), council (`glm-5.2` high → `deepseek-v4-pro` high), explorer/librarian (`deepseek-v4-flash` low → `minimax-m3` low), fixer (`kimi-k2.7-code` high → `glm-5.2` high), designer (`qwen3.7-plus` medium → `kimi-k2.7-code` medium), `code-reviewer` (`qwen3.7-plus` high), `repo-architect` (`glm-5.2` high), `test-writer` (`deepseek-v4-flash` medium), `security-reviewer` (`glm-5.2` high).
- Council retries once. Deep review uses `opencode-go/glm-5.2` (high), fast sanity uses `opencode-go/deepseek-v4-flash` (low), and security sanity uses `opencode-go/deepseek-v4-pro` (high).
- Fallback chains use the OpenCode Go models above; the small model is used for low-effort and high-volume tasks.
- These are template defaults. Customized installations substitute the selected primary and balanced models while retaining the documented effort variants and fallback order.
- Secret-like files are read-gated and edit-denied by default.
- Risky shell operations such as `git push`, package publish, production deploy, `kubectl`, `terraform apply`, `pulumi up`, live transaction broadcasts, and destructive cleanup ask first.

## Role Policy

- **Qwen 3.7 Plus** for routine orchestration and general work.
- **DeepSeek V4 Flash** for high-volume exploration, documentation, titles, and summaries.
- **Kimi K2.7 Code** for implementation, fixing, and code-specialized tasks.
- **GLM 5.2** for planning, architecture, audit, and review.
- **DeepSeek V4 Pro** for long-context escalation and deep reasoning.
- **MiniMax M3** as a cheap independent fallback for explorer, librarian, and sanity checks.

## Requirements

- OpenCode installed and available as `opencode` or `opencode.cmd`.
- The `oh-my-opencode-slim` OpenCode plugin available to OpenCode.
- An active OpenCode Go subscription.
- The macOS/Linux installer requires Node.js or Python 3 and verifies the runtime before copying or overwriting destination files.

OpenCode Go subscription pricing: **$12 per rolling 5 hours**, **$30 per week**, and **$60 per month**. The provider does not publish RPM, TPM, concurrency, or latency SLA limits.

The installer queries `opencode models opencode-go` for interactive customization. Catalog presence does not guarantee runtime availability; the defaults are the runtime-verified OpenCode Go IDs above. If your setup uses different model names, select them during install or edit both:

- `template/.opencode/opencode.jsonc`
- `template/.opencode/oh-my-opencode-slim.jsonc`

## Install Into A Project

From this repo on Windows:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -ProjectPath C:\path\to\your-project
```

The installer defaults to the `opencode-go` provider and asks whether to customize model routing. If you choose yes, it shows each routing slot, a short description, the default model, and the numbered models returned by OpenCode.

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

The installer defaults to the `opencode-go` provider and prompts for two model slots while preserving all role-specific effort variants and fallback order:

- `primary`: defaults to `opencode-go/glm-5.2` for planning, fixing, Oracle, architecture, and high-stakes specialist work.
- `balanced`: defaults to `opencode-go/qwen3.7-plus` for routine orchestration, general work, exploration, docs, design, titles, summaries, and compaction.

Custom installs substitute the chosen primary and balanced models while preserving role variants and fallback order.

Use a different provider model list:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -ProjectPath C:\path\to\your-project -Provider opencode-go
```

```bash
bash ./scripts/install.sh /path/to/your-project --provider opencode-go
```

Skip prompts and keep defaults for automation:

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
opencode debug config
opencode debug agent orchestrator
opencode debug skill
```

Run a live model smoke test for each verified OpenCode Go ID if desired:

```bash
opencode run --agent build -m opencode-go/qwen3.7-plus "Respond with exactly: ROUTING_OK_QWEN"
opencode run --agent build -m opencode-go/deepseek-v4-flash "Respond with exactly: ROUTING_OK_FLASH"
opencode run --agent build -m opencode-go/glm-5.2 "Respond with exactly: ROUTING_OK_GLM"
opencode run --agent build -m opencode-go/kimi-k2.7-code "Respond with exactly: ROUTING_OK_KIMI"
opencode run --agent build -m opencode-go/deepseek-v4-pro "Respond with exactly: ROUTING_OK_PRO"
opencode run --agent build -m opencode-go/minimax-m3 "Respond with exactly: ROUTING_OK_MINIMAX"
```

Restart any already-running OpenCode session after copying or editing config files. OpenCode loads config at startup.

## Included Agents

- `orchestrator`: primary project coordinator.
- `oracle`: focused clarification and second-pass reasoning.
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
