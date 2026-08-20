#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PATTERNS_DIR="$ROOT_DIR/patterns"
TEMPLATES_DIR="$ROOT_DIR/templates/base"
AGENT_TEMPLATES_DIR="$ROOT_DIR/templates/agents"
COMMAND_NAME=${WEBSCAF_COMMAND_NAME:-./setup.sh}

usage() {
  cat <<EOF
Usage:
  $COMMAND_NAME
  $COMMAND_NAME patterns
  $COMMAND_NAME <pattern> <project-name> [output-directory]

Examples:
  $COMMAND_NAME fast-react my-app
  $COMMAND_NAME fast-next my-next-app
  $COMMAND_NAME fast-react my-app ../my-app

Environment overrides for local mirrors or testing:
  WEBSCAF_BACKEND_REPO=/path/to/backend
  WEBSCAF_BACKEND_REF=v2.1.0
  WEBSCAF_FRONTEND_REPO=/path/to/frontend
  WEBSCAF_FRONTEND_REF=v2.1.0
EOF
}

pattern_files() {
  for file in "$PATTERNS_DIR"/*.conf; do
    [ -e "$file" ] || continue
    # shellcheck disable=SC1090
    source "$file"
    printf '%08d\t%s\n' "$PATTERN_ORDER" "$file"
  done | LC_ALL=C sort | cut -f2-
}

load_pattern() {
  selected_pattern=$1
  pattern_file="$PATTERNS_DIR/$selected_pattern.conf"

  if [ ! -f "$pattern_file" ]; then
    echo "Error: unknown pattern '$selected_pattern'." >&2
    echo >&2
    print_patterns >&2
    exit 1
  fi

  # Pattern files are maintained as part of webscaf and contain declarations only.
  # shellcheck disable=SC1090
  source "$pattern_file"

  : "${PATTERN_ID:?PATTERN_ID is required}"
  : "${PATTERN_ORDER:?PATTERN_ORDER is required}"
  : "${PATTERN_LABEL:?PATTERN_LABEL is required}"
  : "${BACKEND_REPO:?BACKEND_REPO is required}"
  : "${BACKEND_REF:?BACKEND_REF is required}"
  : "${FRONTEND_REPO:?FRONTEND_REPO is required}"
  : "${FRONTEND_REF:?FRONTEND_REF is required}"
}

print_patterns() {
  echo "Available patterns:"
  while IFS= read -r file; do
    # shellcheck disable=SC1090
    source "$file"
    printf '  %-16s %s\n' "$PATTERN_ID" "$PATTERN_LABEL"
  done < <(pattern_files)
}

choose_pattern() {
  files=()
  while IFS= read -r file; do
    files+=("$file")
  done < <(pattern_files)

  if [ "${#files[@]}" -eq 0 ]; then
    echo "Error: no scaffold patterns are installed." >&2
    exit 1
  fi

  echo "Select a scaffold pattern:"
  index=1
  for file in "${files[@]}"; do
    # shellcheck disable=SC1090
    source "$file"
    printf '  %d) %s\n' "$index" "$PATTERN_LABEL"
    index=$((index + 1))
  done

  printf 'Enter number [1-%d]: ' "${#files[@]}"
  read -r choice

  case "$choice" in
    ''|*[!0-9]*)
      echo "Error: enter a number between 1 and ${#files[@]}." >&2
      exit 1
      ;;
  esac

  if [ "$choice" -lt 1 ] || [ "$choice" -gt "${#files[@]}" ]; then
    echo "Error: enter a number between 1 and ${#files[@]}." >&2
    exit 1
  fi

  selected_file=${files[$((choice - 1))]}
  selected_pattern=$(basename "$selected_file" .conf)
}

validate_project_name() {
  case "$1" in
    ''|*[!a-z0-9_-]*|[-_]* )
      echo "Error: project name must start with a lowercase letter or number and use only a-z, 0-9, '-' or '_'." >&2
      exit 1
      ;;
  esac
}

absolute_path() {
  path=$1
  parent=$(dirname -- "$path")
  name=$(basename -- "$path")
  mkdir -p "$parent"
  parent=$(CDPATH= cd -- "$parent" && pwd)
  printf '%s/%s\n' "$parent" "$name"
}

copy_example_env() {
  component_dir=$1

  if [ -f "$component_dir/.env.example" ] && [ ! -e "$component_dir/.env" ]; then
    cp "$component_dir/.env.example" "$component_dir/.env"
  fi

  if [ -f "$component_dir/api/.env.example" ] && [ ! -e "$component_dir/api/.env" ]; then
    cp "$component_dir/api/.env.example" "$component_dir/api/.env"
  fi
}

initialize_component() {
  component_dir=$1
  project_name=$2
  init_command="$component_dir/bin/scaf-init"

  if [ ! -e "$init_command" ]; then
    return
  fi

  if [ ! -x "$init_command" ]; then
    echo "Error: component initializer is not executable: $init_command" >&2
    exit 1
  fi

  "$init_command" "$project_name"
}

remove_component_github_files() {
  component_dir=$1

  rm -rf "$component_dir/.github"
  rm -f \
    "$component_dir/docs/CONTRIBUTING.md" \
    "$component_dir/docs/GITHUB_SETTINGS.md" \
    "$component_dir/docs/RUNBOOK.md" \
    "$component_dir/docs/SECURITY.md"
  rmdir "$component_dir/docs" 2>/dev/null || true
}

rewrite_component_project_doc_references() {
  component_dir=$1

  for file in "$component_dir/README.md" "$component_dir/AGENTS.md"; do
    if [ ! -f "$file" ]; then
      continue
    fi

    sed \
      -e 's|docs/CONTRIBUTING\.md|../docs/CONTRIBUTING.md|g' \
      -e 's|docs/GITHUB_SETTINGS\.md|../docs/GITHUB_SETTINGS.md|g' \
      -e 's|docs/RUNBOOK\.md|../docs/RUNBOOK.md|g' \
      -e 's|docs/SECURITY\.md|../docs/SECURITY.md|g' \
      "$file" > "$file.webscaf"
    mv "$file.webscaf" "$file"
  done
}

ensure_component_agent_files() {
  component_dir=$1
  component_type=$2
  agent_template_dir="$AGENT_TEMPLATES_DIR/$component_type"

  if [ ! -f "$component_dir/AGENTS.md" ]; then
    cp "$agent_template_dir/AGENTS.md" "$component_dir/AGENTS.md"
  fi

  if [ ! -f "$component_dir/CLAUDE.md" ]; then
    cp "$agent_template_dir/CLAUDE.md" "$component_dir/CLAUDE.md"
  fi
}

render_file() {
  file=$1
  project_name=$2
  pattern_id=$3
  pattern_label=$4
  backend_repo=$5
  backend_ref=$6
  frontend_repo=$7
  frontend_ref=$8

  sed \
    -e "s|{{PROJECT_NAME}}|$project_name|g" \
    -e "s|{{PATTERN_ID}}|$pattern_id|g" \
    -e "s|{{PATTERN_LABEL}}|$pattern_label|g" \
    -e "s|{{BACKEND_REPO}}|$backend_repo|g" \
    -e "s|{{BACKEND_REF}}|$backend_ref|g" \
    -e "s|{{FRONTEND_REPO}}|$frontend_repo|g" \
    -e "s|{{FRONTEND_REF}}|$frontend_ref|g" \
    "$file" > "$file.rendered"
  mv "$file.rendered" "$file"
}

generate_project() {
  project_name=$1
  output_dir=$2

  validate_project_name "$project_name"
  output_dir=$(absolute_path "$output_dir")

  if [ -e "$output_dir" ]; then
    echo "Error: output path already exists: $output_dir" >&2
    exit 1
  fi

  output_parent=$(dirname -- "$output_dir")
  staging_dir=$(mktemp -d "$output_parent/.webscaf.XXXXXX")
  cleanup() {
    if [ -n "${staging_dir:-}" ] && [ -d "$staging_dir" ]; then
      rm -rf "$staging_dir"
    fi
  }
  trap cleanup EXIT INT TERM

  backend_repo=${WEBSCAF_BACKEND_REPO:-$BACKEND_REPO}
  backend_ref=${WEBSCAF_BACKEND_REF:-$BACKEND_REF}
  frontend_repo=${WEBSCAF_FRONTEND_REPO:-$FRONTEND_REPO}
  frontend_ref=${WEBSCAF_FRONTEND_REF:-$FRONTEND_REF}

  echo "Cloning backend: $backend_repo ($backend_ref)"
  git -c advice.detachedHead=false clone \
    --quiet --depth 1 --branch "$backend_ref" "$backend_repo" "$staging_dir/api"

  echo "Cloning frontend: $frontend_repo ($frontend_ref)"
  git -c advice.detachedHead=false clone \
    --quiet --depth 1 --branch "$frontend_ref" "$frontend_repo" "$staging_dir/web"

  initialize_component "$staging_dir/api" "$project_name"
  initialize_component "$staging_dir/web" "$project_name"

  remove_component_github_files "$staging_dir/api"
  remove_component_github_files "$staging_dir/web"
  ensure_component_agent_files "$staging_dir/api" api
  ensure_component_agent_files "$staging_dir/web" web
  rewrite_component_project_doc_references "$staging_dir/api"
  rewrite_component_project_doc_references "$staging_dir/web"

  rm -rf "$staging_dir/api/.git" "$staging_dir/web/.git"
  cp -R "$TEMPLATES_DIR/." "$staging_dir/"
  mv "$staging_dir/env.template" "$staging_dir/.env.example"

  render_file \
    "$staging_dir/.env.example" \
    "$project_name" "$PATTERN_ID" "$PATTERN_LABEL" \
    "$backend_repo" "$backend_ref" "$frontend_repo" "$frontend_ref"
  render_file \
    "$staging_dir/README.md" \
    "$project_name" "$PATTERN_ID" "$PATTERN_LABEL" \
    "$backend_repo" "$backend_ref" "$frontend_repo" "$frontend_ref"
  render_file \
    "$staging_dir/.webscaf" \
    "$project_name" "$PATTERN_ID" "$PATTERN_LABEL" \
    "$backend_repo" "$backend_ref" "$frontend_repo" "$frontend_ref"

  cp "$staging_dir/.env.example" "$staging_dir/.env"
  copy_example_env "$staging_dir/api"
  copy_example_env "$staging_dir/web"

  mv "$staging_dir" "$output_dir"
  staging_dir=''
  trap - EXIT INT TERM

  echo
  echo "Created $PATTERN_LABEL scaffold at: $output_dir"
  echo "Next steps:"
  echo "  cd $output_dir"
  echo "  make build"
  echo "  make up"
  echo "  make migrate"
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  echo
  print_patterns
  exit 0
fi

if [ "${1:-}" = "patterns" ] && [ "$#" -eq 1 ]; then
  print_patterns
  exit 0
fi

if [ "$#" -eq 0 ]; then
  choose_pattern
  printf 'Project name: '
  read -r project_name
  output_dir="$PWD/$project_name"
elif [ "$#" -eq 2 ] || [ "$#" -eq 3 ]; then
  selected_pattern=$1
  project_name=$2
  output_dir=${3:-"$PWD/$project_name"}
else
  usage >&2
  exit 1
fi

load_pattern "$selected_pattern"
generate_project "$project_name" "$output_dir"
