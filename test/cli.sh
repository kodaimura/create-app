#!/usr/bin/env bash

set -euo pipefail

TEST_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$TEST_DIR/.." && pwd)
MKSCAF="$ROOT_DIR/bin/mkscaf"
TEMP_DIR=$(mktemp -d)

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT INT TERM

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file() {
  [ -f "$1" ] || fail "missing file: $1"
}

assert_script_project() {
  project_dir=$1
  language=$2
  entrypoint=$3
  assert_file "$project_dir/.mkscaf"
  assert_file "$project_dir/.vscode/settings.json"
  assert_file "$project_dir/Dockerfile"
  assert_file "$project_dir/Makefile"
  assert_file "$project_dir/docker-compose.yml"
  assert_file "$project_dir/$entrypoint"
  grep -q "^language=$language$" "$project_dir/.mkscaf"
  if command -v docker >/dev/null 2>&1; then
    docker compose -f "$project_dir/docker-compose.yml" config --quiet
  fi
}

create_component_repo() {
  repo_dir=$1
  service=$2
  mkdir -p "$repo_dir/bin"
  git -C "$repo_dir" init --quiet
  cat > "$repo_dir/docker-compose.yml" <<EOF
services:
  $service:
    image: busybox:1.37
EOF
  cat > "$repo_dir/bin/scaf-init" <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

root_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
printf '%s\n' "$1" > "$root_dir/.initialized"
EOF
  chmod +x "$repo_dir/bin/scaf-init"
  cp "$repo_dir/docker-compose.yml" "$repo_dir/docker-compose.prod.yml"
  printf 'EXAMPLE=value\n' > "$repo_dir/.env.example"
  git -C "$repo_dir" add .
  git -C "$repo_dir" \
    -c user.name='mkscaf test' \
    -c user.email='mkscaf@example.com' \
    commit --quiet -m 'test fixture'
  git -C "$repo_dir" tag v2.1.0
}

assert_web_project() {
  project_dir=$1
  assert_file "$project_dir/.webscaf"
  project_name=$(sed -n 's/^project=//p' "$project_dir/.webscaf")
  grep -qxF 'version=2' "$project_dir/.webscaf"
  grep -qxF 'backend_ref=v2.1.0' "$project_dir/.webscaf"
  grep -qxF 'frontend_ref=v2.1.0' "$project_dir/.webscaf"
  assert_file "$project_dir/docker-compose.yml"
  assert_file "$project_dir/api/docker-compose.yml"
  assert_file "$project_dir/web/docker-compose.yml"
  assert_file "$project_dir/api/.initialized"
  assert_file "$project_dir/web/.initialized"
  grep -qxF "$project_name" "$project_dir/api/.initialized"
  grep -qxF "$project_name" "$project_dir/web/.initialized"
  [ ! -d "$project_dir/api/.git" ] || fail "backend git metadata remains"
  [ ! -d "$project_dir/web/.git" ] || fail "frontend git metadata remains"
  if command -v docker >/dev/null 2>&1; then
    docker compose -f "$project_dir/docker-compose.yml" config --quiet
  fi
}

"$MKSCAF" script go Go_App "$TEMP_DIR/go-app" >/dev/null
assert_script_project "$TEMP_DIR/go-app" go main.go
assert_file "$TEMP_DIR/go-app/main_test.go"
assert_file "$TEMP_DIR/go-app/go.mod"
grep -q '^module go-app$' "$TEMP_DIR/go-app/go.mod"

"$MKSCAF" script julia julia-app "$TEMP_DIR/julia-app" >/dev/null
assert_script_project "$TEMP_DIR/julia-app" julia main.jl
assert_file "$TEMP_DIR/julia-app/Project.toml"
assert_file "$TEMP_DIR/julia-app/test/runtests.jl"

"$MKSCAF" script python python-app "$TEMP_DIR/python-app" >/dev/null
assert_script_project "$TEMP_DIR/python-app" python main.py
assert_file "$TEMP_DIR/python-app/test_main.py"

"$MKSCAF" script racket racket-app "$TEMP_DIR/racket-app" >/dev/null
assert_script_project "$TEMP_DIR/racket-app" racket main.rkt
assert_file "$TEMP_DIR/racket-app/test.rkt"

"$MKSCAF" script typescript TypeScript_App "$TEMP_DIR/typescript-app" >/dev/null
assert_script_project "$TEMP_DIR/typescript-app" typescript src/index.ts
assert_file "$TEMP_DIR/typescript-app/src/index.test.ts"
assert_file "$TEMP_DIR/typescript-app/package-lock.json"
grep -q '^  "name": "typescript-app",$' "$TEMP_DIR/typescript-app/package.json"

"$MKSCAF" script patterns | grep -q 'typescript'

(
  cd "$TEMP_DIR"
  printf '1\n1\ninteractive-go\n\n' | "$MKSCAF" >/dev/null
)
assert_script_project "$TEMP_DIR/interactive-go" go main.go

mkdir "$TEMP_DIR/existing"
if "$MKSCAF" script racket existing "$TEMP_DIR/existing" >/dev/null 2>&1; then
  fail "existing output directory was overwritten"
fi

if "$MKSCAF" script unknown invalid "$TEMP_DIR/invalid" >/dev/null 2>&1; then
  fail "unknown script language was accepted"
fi

BACKEND_REPO="$TEMP_DIR/backend-repo"
FRONTEND_REPO="$TEMP_DIR/frontend-repo"
create_component_repo "$BACKEND_REPO" api
create_component_repo "$FRONTEND_REPO" web

export WEBSCAF_BACKEND_REPO="file://$BACKEND_REPO"
export WEBSCAF_FRONTEND_REPO="file://$FRONTEND_REPO"

"$MKSCAF" web fast-react web-app "$TEMP_DIR/from-mkscaf" >/dev/null
assert_web_project "$TEMP_DIR/from-mkscaf"

(
  cd "$TEMP_DIR"
  printf '1\ninteractive-web\n' | "$MKSCAF" web >/dev/null
)
assert_web_project "$TEMP_DIR/interactive-web"

(
  cd "$TEMP_DIR"
  printf '2\n1\nnested-web\n' | "$MKSCAF" >/dev/null
)
assert_web_project "$TEMP_DIR/nested-web"

echo "mkscaf CLI checks passed"
