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
  go, julia, python, racket
EOF
}

print_patterns() {
  cat <<'EOF'
Available script languages:
  go       Go
  julia    Julia package
  python   Python
  racket   Racket
EOF
}

choose_language() {
  echo "Select a script language:"
  echo "  1) Go"
  echo "  2) Julia"
  echo "  3) Python"
  echo "  4) Racket"
  printf "Enter number [1-4]: "
  read -r choice

  case "$choice" in
    1) language=go ;;
    2) language=julia ;;
    3) language=python ;;
    4) language=racket ;;
    *)
      echo "Error: enter a number between 1 and 4." >&2
      exit 1
      ;;
  esac
}

validate_language() {
  case "$1" in
    go|julia|python|racket) ;;
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

  if [ "$language" = "julia" ]; then
    case "$project_name" in
      [A-Za-z]*)
        case "$project_name" in
          *[!A-Za-z0-9_]*)
            echo "Error: Julia package names must start with a letter and use only letters, numbers, or '_'." >&2
            exit 1
            ;;
        esac
        ;;
      *)
        echo "Error: Julia package names must start with a letter and use only letters, numbers, or '_'." >&2
        exit 1
        ;;
    esac
  fi
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
}

generate_julia_project() {
  docker_bin=${MKSCAF_DOCKER_BIN:-docker}
  git_user=$(git config --global user.name || true)
  git_email=$(git config --global user.email || true)
  if [ -z "$git_user" ] || [ -z "$git_email" ]; then
    echo "Error: Julia generation requires global git user.name and user.email." >&2
    exit 1
  fi

  "$docker_bin" run --rm \
    -v "$staging_dir:/workspace" \
    -e GIT_USER="$git_user" \
    -e GIT_EMAIL="$git_email" \
    -e PROJECT_NAME="$project_name" \
    julia:1.12.6 sh -c \
    'apt-get update >/dev/null && apt-get install -y git >/dev/null && julia -e '\''using Pkg; Pkg.add("PkgTemplates"); using PkgTemplates; Template(user=ENV["GIT_USER"], dir="/workspace")(ENV["PROJECT_NAME"])'\'''

  mv "$staging_dir/$project_name" "$staging_dir/project"
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

  if [ "$language" = "julia" ]; then
    generate_julia_project
  else
    mkdir "$staging_dir/project"
    generate_template_project
  fi

  cp -R "$ROOT_DIR/.vscode" "$staging_dir/project/.vscode"
  write_metadata "$staging_dir/project"
  mv "$staging_dir/project" "$output_dir"
  staging_dir=''
  trap - EXIT INT TERM

  echo
  echo "Created $language script scaffold at: $output_dir"
  echo "Next steps:"
  echo "  cd $output_dir"
  echo "  make build"
  echo "  make up"
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
