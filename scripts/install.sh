#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH=""
FORCE="${FORCE:-0}"
NON_INTERACTIVE="${NON_INTERACTIVE:-0}"
RUNTIME_PROFILE="${OH_MY_OPENCODE_SLIM_PRESET:-}"
PROFILE=""
PROVIDER="${OPENCODE_MODEL_PROVIDER:-opencode-go}"
OPENCODE_BIN="${OPENCODE_BIN:-opencode}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--force)
      FORCE="1"
      ;;
    --non-interactive)
      NON_INTERACTIVE="1"
      ;;
    --provider)
      shift
      if [[ $# -eq 0 ]]; then
        echo "--provider requires a value" >&2
        exit 1
      fi
      PROVIDER="$1"
      ;;
    --profile)
      shift
      if [[ $# -eq 0 ]]; then
        echo "--profile requires balanced or quality" >&2
        exit 1
      fi
      PROFILE="$1"
      ;;
    -h|--help)
      echo "Usage: bash ./scripts/install.sh [project-path] [--force] [--non-interactive] [--profile balanced|quality] [--provider opencode-go]"
      exit 0
      ;;
    *)
      if [[ -n "$PROJECT_PATH" ]]; then
        echo "Unexpected argument: $1" >&2
        exit 1
      fi
      PROJECT_PATH="$1"
      ;;
  esac
  shift
done

PROJECT_PATH="${PROJECT_PATH:-$PWD}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_DIR="$REPO_ROOT/template/.opencode"
DEST_DIR="$PROJECT_PATH/.opencode"

MODEL_KEYS=(primary balanced)
MODEL_TITLES=(
  "Primary and deep reasoning"
  "Fast and balanced work"
)
MODEL_DESCRIPTIONS=(
  "Planning, fixing, Oracle, architecture, and high-stakes specialist work."
  "Routine orchestration, general work, exploration, docs, design, titles, summaries, and compaction."
)
MODEL_DEFAULTS=(
  "opencode-go/glm-5.3-flash"
  "opencode-go/qwen3.8-flash"
)

JSON_RUNTIME=""
JSON_RUNTIME_BIN=""

MODELS=()

select_json_runtime() {
  if [[ -n "$JSON_RUNTIME" ]]; then
    return 0
  fi

  if command -v node >/dev/null 2>&1; then
    JSON_RUNTIME="node"
    JSON_RUNTIME_BIN="$(command -v node)"
  elif command -v python3 >/dev/null 2>&1 && python3 -c 'import sys; sys.exit(0 if sys.version_info.major == 3 else 1)' >/dev/null 2>&1; then
    JSON_RUNTIME="python3"
    JSON_RUNTIME_BIN="$(command -v python3)"
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info.major == 3 else 1)' >/dev/null 2>&1; then
    JSON_RUNTIME="python3"
    JSON_RUNTIME_BIN="$(command -v python)"
  else
    echo "The quality profile and custom routing require Node.js or Python 3; no supported runtime was found." >&2
    exit 1
  fi
}

select_model() {
  local key="$1"
  local title="$2"
  local description="$3"
  local default_model="$4"
  local answer=""
  local index=0
  local selected_index=0

  if [[ "$NON_INTERACTIVE" == "1" ]]; then
    printf '%s\n' "$default_model"
    return 0
  fi

  while true; do
    echo "" >&2
    echo "== $title ==" >&2
    echo "$description" >&2
    echo "Default: $default_model" >&2

    if [[ ${#MODELS[@]} -gt 0 ]]; then
      echo "" >&2
      echo "Available models:" >&2
      for index in "${!MODELS[@]}"; do
        if [[ "${MODELS[$index]}" == "$default_model" ]]; then
          echo "  $((index + 1)). ${MODELS[$index]} (default)" >&2
        else
          echo "  $((index + 1)). ${MODELS[$index]}" >&2
        fi
      done
    else
      echo "" >&2
      echo "No models were returned by opencode. You can still type a full provider/model id." >&2
    fi

    if ! read -r -p "Choose model number or provider/model for '$key' [Enter = default]: " answer; then
      answer=""
    fi
    answer="${answer//[$'\t\r\n ']}"

    if [[ -z "$answer" ]]; then
      printf '%s\n' "$default_model"
      return 0
    fi

    if [[ "$answer" =~ ^[0-9]+$ ]]; then
      selected_index=$((answer - 1))
      if [[ $selected_index -ge 0 && $selected_index -lt ${#MODELS[@]} ]]; then
        printf '%s\n' "${MODELS[$selected_index]}"
        return 0
      fi
    fi

    if [[ "$answer" == */* ]]; then
      printf '%s\n' "$answer"
      return 0
    fi

    echo "Invalid selection. Use a listed number, press Enter for default, or type provider/model." >&2
  done
}

apply_curated_profile() {
  local opencode_config="$DEST_DIR/opencode.jsonc"
  local slim_config="$DEST_DIR/oh-my-opencode-slim.jsonc"

  if [[ "$PROFILE" == "balanced" ]]; then
    return 0
  fi

  if [[ "$JSON_RUNTIME" == "node" ]]; then
    "$JSON_RUNTIME_BIN" - "$opencode_config" "$slim_config" <<'NODE'
const fs = require('fs');
const [opencodePath, slimPath] = process.argv.slice(2);

function readJson(path) {
  return JSON.parse(fs.readFileSync(path, 'utf8'));
}

function writeJson(path, value) {
  fs.writeFileSync(path, JSON.stringify(value, null, 2) + '\n');
}

const opencode = readJson(opencodePath);
opencode.model = 'opencode-go/qwen3.8-max';
opencode.small_model = 'opencode-go/qwen3.8-flash';
opencode.agent.build.model = 'opencode-go/kimi-k2.7-code';
delete opencode.agent.build.variant;
opencode.agent.plan.model = 'opencode-go/glm-5.3';
opencode.agent.plan.variant = 'max';
opencode.agent.general.model = 'opencode-go/qwen3.8-max';
opencode.agent.general.variant = 'medium';
opencode.agent.explore.model = 'opencode-go/qwen3.8-flash';
opencode.agent.explore.variant = 'medium';
for (const agentName of ['title', 'summary', 'compaction']) {
  opencode.agent[agentName].model = 'opencode-go/qwen3.8-flash';
  opencode.agent[agentName].variant = 'low';
}
writeJson(opencodePath, opencode);

const slim = readJson(slimPath);
slim.preset = 'quality';
writeJson(slimPath, slim);
NODE
    return 0
  fi

  if [[ "$JSON_RUNTIME" == "python3" ]]; then
    "$JSON_RUNTIME_BIN" - "$opencode_config" "$slim_config" <<'PY'
import json
import sys

opencode_path, slim_path = sys.argv[1:]

def read_json(path):
    with open(path, "r", encoding="utf-8") as handle:
        return json.load(handle)

def write_json(path, value):
    with open(path, "w", encoding="utf-8") as handle:
        json.dump(value, handle, indent=2)
        handle.write("\n")

opencode = read_json(opencode_path)
opencode["model"] = "opencode-go/qwen3.8-max"
opencode["small_model"] = "opencode-go/qwen3.8-flash"
opencode["agent"]["build"]["model"] = "opencode-go/kimi-k2.7-code"
opencode["agent"]["build"].pop("variant", None)
for agent_name, model, variant in (
    ("plan", "opencode-go/glm-5.3", "max"),
    ("general", "opencode-go/qwen3.8-max", "medium"),
    ("explore", "opencode-go/qwen3.8-flash", "medium"),
    ("title", "opencode-go/qwen3.8-flash", "low"),
    ("summary", "opencode-go/qwen3.8-flash", "low"),
    ("compaction", "opencode-go/qwen3.8-flash", "low"),
):
    opencode["agent"][agent_name]["model"] = model
    opencode["agent"][agent_name]["variant"] = variant
write_json(opencode_path, opencode)

slim = read_json(slim_path)
slim["preset"] = "quality"
write_json(slim_path, slim)
PY
    return 0
  fi

  echo "Internal error: unsupported JSON runtime '$JSON_RUNTIME'." >&2
  return 1
}

apply_model_choices() {
  local opencode_config="$DEST_DIR/opencode.jsonc"
  local slim_config="$DEST_DIR/oh-my-opencode-slim.jsonc"

  if [[ "$JSON_RUNTIME" == "node" ]]; then
    "$JSON_RUNTIME_BIN" - "$opencode_config" "$slim_config" "$PRIMARY_MODEL" "$BALANCED_MODEL" "$PROFILE" <<'NODE'
const fs = require('fs');
const [
  opencodePath,
  slimPath,
  primary,
  balanced,
  profile,
] = process.argv.slice(2);

function readJson(path) {
  return JSON.parse(fs.readFileSync(path, 'utf8'));
}

function writeJson(path, value) {
  fs.writeFileSync(path, JSON.stringify(value, null, 2) + '\n');
}

const opencode = readJson(opencodePath);
opencode.enabled_providers = [...new Set([
  'opencode-go',
  primary.slice(0, primary.indexOf('/')),
  balanced.slice(0, balanced.indexOf('/')),
])];
opencode.model = balanced;
opencode.small_model = balanced;
opencode.agent.build.model = primary;
delete opencode.agent.build.variant;
opencode.agent.plan.model = primary;
delete opencode.agent.plan.variant;
opencode.agent.general.model = balanced;
delete opencode.agent.general.variant;
opencode.agent.explore.model = balanced;
delete opencode.agent.explore.variant;
opencode.agent.title.model = balanced;
delete opencode.agent.title.variant;
opencode.agent.summary.model = balanced;
delete opencode.agent.summary.variant;
opencode.agent.compaction.model = balanced;
delete opencode.agent.compaction.variant;
writeJson(opencodePath, opencode);

const slim = readJson(slimPath);
slim.preset = profile;
for (const preset of [slim.presets.balanced, slim.presets.quality]) {
  preset.orchestrator.model = [
    { id: balanced },
    { id: primary },
  ];
  preset.oracle.model = [
    { id: primary },
    { id: balanced },
  ];
  preset.council.model = [
    { id: primary },
    { id: balanced },
  ];
  preset.explorer.model = [
    { id: balanced },
    { id: primary },
  ];
  preset.librarian.model = [
    { id: balanced },
    { id: primary },
  ];
  preset.fixer.model = [
    { id: primary },
    { id: balanced },
  ];
  preset.designer.model = [
    { id: balanced },
    { id: primary },
  ];
}
slim.agents['code-reviewer'].model = primary;
delete slim.agents['code-reviewer'].variant;
slim.agents['repo-architect'].model = primary;
delete slim.agents['repo-architect'].variant;
slim.agents['test-writer'].model = balanced;
delete slim.agents['test-writer'].variant;
slim.agents['security-reviewer'].model = primary;
delete slim.agents['security-reviewer'].variant;
const councilPreset = slim.council.presets['generic-review-board'];
councilPreset['correctness-review'].model = primary;
delete councilPreset['correctness-review'].variant;
councilPreset['architecture-review'].model = primary;
delete councilPreset['architecture-review'].variant;
councilPreset['security-review'].model = balanced;
delete councilPreset['security-review'].variant;
writeJson(slimPath, slim);
NODE
    return 0
  fi

  if [[ "$JSON_RUNTIME" == "python3" ]]; then
    "$JSON_RUNTIME_BIN" - "$opencode_config" "$slim_config" "$PRIMARY_MODEL" "$BALANCED_MODEL" "$PROFILE" <<'PY'
import json
import sys

(
    opencode_path,
    slim_path,
    primary,
    balanced,
    profile,
) = sys.argv[1:]

def read_json(path):
    with open(path, "r", encoding="utf-8") as handle:
        return json.load(handle)

def write_json(path, value):
    with open(path, "w", encoding="utf-8") as handle:
        json.dump(value, handle, indent=2)
        handle.write("\n")

opencode = read_json(opencode_path)
opencode["enabled_providers"] = list(dict.fromkeys((
    "opencode-go",
    primary.split("/", 1)[0],
    balanced.split("/", 1)[0],
)))
opencode["model"] = balanced
opencode["small_model"] = balanced
for agent_name, model in {
    "build": primary,
    "plan": primary,
    "general": balanced,
    "explore": balanced,
    "title": balanced,
    "summary": balanced,
    "compaction": balanced,
}.items():
    opencode["agent"][agent_name]["model"] = model
    opencode["agent"][agent_name].pop("variant", None)
write_json(opencode_path, opencode)

slim = read_json(slim_path)
slim["preset"] = profile
for preset_name in ("balanced", "quality"):
    preset = slim["presets"][preset_name]
    preset["orchestrator"]["model"] = [
        {"id": balanced},
        {"id": primary},
    ]
    preset["oracle"]["model"] = [
        {"id": primary},
        {"id": balanced},
    ]
    preset["council"]["model"] = [
        {"id": primary},
        {"id": balanced},
    ]
    preset["explorer"]["model"] = [
        {"id": balanced},
        {"id": primary},
    ]
    preset["librarian"]["model"] = [
        {"id": balanced},
        {"id": primary},
    ]
    preset["fixer"]["model"] = [
        {"id": primary},
        {"id": balanced},
    ]
    preset["designer"]["model"] = [
        {"id": balanced},
        {"id": primary},
    ]
for agent_name, model in {
    "code-reviewer": primary,
    "repo-architect": primary,
    "test-writer": balanced,
    "security-reviewer": primary,
}.items():
    slim["agents"][agent_name]["model"] = model
    slim["agents"][agent_name].pop("variant", None)
council_preset = slim["council"]["presets"]["generic-review-board"]
for councillor_name, model in {
    "correctness-review": primary,
    "architecture-review": primary,
    "security-review": balanced,
}.items():
    council_preset[councillor_name]["model"] = model
    council_preset[councillor_name].pop("variant", None)
write_json(slim_path, slim)
PY
    return 0
  fi

  echo "Internal error: unsupported JSON runtime '$JSON_RUNTIME'." >&2
  return 1
}

PROFILE="$(printf '%s' "$PROFILE" | tr '[:upper:]' '[:lower:]')"
case "$PROFILE" in
  ""|balanced|quality)
    ;;
  *)
    echo "Profile must be 'balanced' or 'quality'." >&2
    exit 1
    ;;
esac

if [[ -z "$PROFILE" ]]; then
  if [[ "$NON_INTERACTIVE" == "1" ]]; then
    PROFILE="balanced"
  else
    while true; do
      if ! read -r -p "Choose curated profile: 1 = balanced, 2 = quality [Enter = balanced]: " profile_answer; then
        profile_answer=""
      fi
      case "$(printf '%s' "$profile_answer" | tr '[:upper:]' '[:lower:]')" in
        ""|1|balanced)
          PROFILE="balanced"
          break
          ;;
        2|quality)
          PROFILE="quality"
          break
          ;;
        *)
          echo "Invalid profile. Choose 1/balanced or 2/quality." >&2
          ;;
      esac
    done
  fi
fi

if [[ -n "$RUNTIME_PROFILE" && "$(printf '%s' "$RUNTIME_PROFILE" | tr '[:upper:]' '[:lower:]')" != "$PROFILE" ]]; then
  echo "Warning: OH_MY_OPENCODE_SLIM_PRESET overrides Slim at runtime. Set it to '$PROFILE' or unset it to use the installed profile." >&2
fi

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "Project path does not exist or is not a directory: $PROJECT_PATH" >&2
  exit 1
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Template source not found: $SOURCE_DIR" >&2
  exit 1
fi

if [[ "$PROFILE" == "quality" ]]; then
  select_json_runtime
fi

if [[ -e "$DEST_DIR" && "$FORCE" != "1" ]]; then
  echo "Target already has .opencode. Re-run with FORCE=1 to merge and overwrite matching template files." >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
cp -R "$SOURCE_DIR"/. "$DEST_DIR"/

if [[ "$PROFILE" == "quality" ]]; then
  apply_curated_profile
fi

CUSTOMIZE_ROUTING="0"
if [[ "$NON_INTERACTIVE" != "1" ]]; then
  echo ""
  echo "Interactive model routing"
  echo "Provider queried: $PROVIDER"
  if ! read -r -p "Replace the '$PROFILE' profile with two selected models? [y/N]: " customize_answer; then
    customize_answer=""
  fi
  case "$customize_answer" in
    y|Y|yes|YES|Yes)
      CUSTOMIZE_ROUTING="1"
      ;;
  esac
fi

PRIMARY_MODEL=""
BALANCED_MODEL=""
SELECTED_MODELS=()
if [[ "$CUSTOMIZE_ROUTING" == "1" ]]; then
  if command -v "$OPENCODE_BIN" >/dev/null 2>&1; then
    while IFS= read -r model; do
      if [[ -n "$model" && "$model" == */* ]]; then
        MODELS+=("$model")
      fi
    done < <("$OPENCODE_BIN" models "$PROVIDER" </dev/null 2>/dev/null || true)
  fi

  select_json_runtime

  if [[ ${#MODELS[@]} -gt 0 ]]; then
    echo "Found ${#MODELS[@]} model(s) via opencode models $PROVIDER."
  else
    echo "No model list was available from opencode models $PROVIDER. You can still type full provider/model IDs."
  fi

  for index in "${!MODEL_KEYS[@]}"; do
    selected="$(select_model "${MODEL_KEYS[$index]}" "${MODEL_TITLES[$index]}" "${MODEL_DESCRIPTIONS[$index]}" "${MODEL_DEFAULTS[$index]}")"
    SELECTED_MODELS+=("$selected")
  done

  PRIMARY_MODEL="${SELECTED_MODELS[0]}"
  BALANCED_MODEL="${SELECTED_MODELS[1]}"
  apply_model_choices
fi

echo "Installed OpenCode Go generic project config to $DEST_DIR"
echo ""
echo "Selected model routing:"
if [[ "$CUSTOMIZE_ROUTING" == "1" ]]; then
  for index in "${!MODEL_KEYS[@]}"; do
    echo "  ${MODEL_KEYS[$index]}: ${SELECTED_MODELS[$index]}"
  done
else
  echo "  $PROFILE curated profile"
fi
echo ""
echo "Restart OpenCode in the target project so it loads the new config."
