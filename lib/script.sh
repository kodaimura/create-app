#!/usr/bin/env bash

set -euo pipefail

LIB_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$LIB_DIR/.." && pwd)
TEMPLATE_DIR="$ROOT_DIR/template"
COMMAND_NAME=${MKSCAF_SCRIPT_COMMAND_NAME:-mkscaf script}

usage() {
  cat <<EOF
Usage:
  $COMMAND_NAME
  $COMMAND_NAME patterns
  $COMMAND_NAME <language> <project-name> [output-directory]

Languages:
  go, julia, python, racket, typescript
EOF
}

print_patterns() {
  cat <<'EOF'
Available script languages:
  go          Go
  julia       Julia
  python      Python
  racket      Racket
  typescript  TypeScript
EOF
}

choose_language() {
  echo "Select a script language:"
  echo "  1) Go"
  echo "  2) Julia"
  echo "  3) Python"
  echo "  4) Racket"
  echo "  5) TypeScript"
  printf "Enter number [1-5]: "
  read -r choice

  case "$choice" in
    1) language=go ;;
    2) language=julia ;;
    3) language=python ;;
    4) language=racket ;;
    5) language=typescript ;;
    *)
      echo "Error: enter a number between 1 and 5." >&2
      exit 1
      ;;
  esac
}

validate_language() {
  case "$1" in
    go|julia|python|racket|typescript) ;;
    *)
      echo "Error: unknown script language '$1'." >&2
      echo >&2
      print_patterns >&2
      exit 1
      ;;
  esac
}

validate_project_name() {
  project_name=$1
  case "$project_name" in
    ''|*[!A-Za-z0-9_-]*|[-_]*)
      echo "Error: project name must start with a letter or number and use only A-Z, a-z, 0-9, '-' or '_'." >&2
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

write_metadata() {
  destination=$1
  cat > "$destination/.mkscaf" <<EOF
version=1
kind=script
project=$project_name
language=$language
EOF
}

generate_template_project() {
  source_dir="$TEMPLATE_DIR/script-$language"
  if [ ! -d "$source_dir" ]; then
    echo "Error: template is missing: $source_dir" >&2
    exit 1
  fi

  cp -R "$source_dir/." "$staging_dir/project/"

  case "$language" in
    go|typescript)
      project_slug=$(printf '%s' "$project_name" | tr '[:upper:]_' '[:lower:]-')
      ;;
  esac

  if [ "$language" = "go" ]; then
    sed "s/__PROJECT_NAME__/$project_slug/g" \
      "$staging_dir/project/go.mod" > "$staging_dir/project/go.mod.tmp"
    mv "$staging_dir/project/go.mod.tmp" "$staging_dir/project/go.mod"
  elif [ "$language" = "typescript" ]; then
    for package_file in package.json package-lock.json; do
      sed "s/__PROJECT_NAME__/$project_slug/g" \
        "$staging_dir/project/$package_file" > "$staging_dir/project/$package_file.tmp"
      mv "$staging_dir/project/$package_file.tmp" "$staging_dir/project/$package_file"
    done
  fi
}

generate_project() {
  validate_language "$language"
  validate_project_name "$project_name"
  output_dir=$(absolute_path "$output_dir")

  if [ -e "$output_dir" ]; then
    echo "Error: output path already exists: $output_dir" >&2
    exit 1
  fi

  output_parent=$(dirname -- "$output_dir")
  staging_dir=$(mktemp -d "$output_parent/.mkscaf.XXXXXX")
  cleanup() {
    if [ -n "${staging_dir:-}" ] && [ -d "$staging_dir" ]; then
      rm -rf "$staging_dir"
    fi
  }
  trap cleanup EXIT INT TERM

  mkdir "$staging_dir/project"
  generate_template_project

  cp -R "$ROOT_DIR/.vscode" "$staging_dir/project/.vscode"
  write_metadata "$staging_dir/project"
  mv "$staging_dir/project" "$output_dir"
  staging_dir=''
  trap - EXIT INT TERM

  echo
  echo "Created $language script scaffold at: $output_dir"
  echo "Next steps:"
  echo "  cd $output_dir"
  echo "  make run"
  echo "  make test"
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi

if [ "${1:-}" = "patterns" ] && [ "$#" -eq 1 ]; then
  print_patterns
  exit 0
fi

if [ "$#" -eq 0 ]; then
  choose_language
  printf "Project name: "
  read -r project_name
  printf "Output directory [%s/%s]: " "$PWD" "$project_name"
  read -r output_dir
  output_dir=${output_dir:-"$PWD/$project_name"}
elif [ "$#" -eq 2 ] || [ "$#" -eq 3 ]; then
  language=$1
  project_name=$2
  output_dir=${3:-"$PWD/$project_name"}
else
  usage >&2
  exit 1
fi

generate_project
