# mkscaf

An interactive CLI for generating small script projects in multiple languages
and authentication-ready web applications.

mkscaf includes [webscaf](https://github.com/kodaimura/webscaf), so installing
mkscaf provides both `mkscaf web` and the standalone `webscaf` command.

## Requirements

- Bash
- Docker / Docker Compose
- Make
- Git for web application generation

## Installation

```sh
mkdir -p ~/bin
# Change ~/bin/mkscaf if you prefer another clone location, and update PATH to match.
git clone https://github.com/kodaimura/mkscaf.git ~/bin/mkscaf
echo 'export PATH="$HOME/bin/mkscaf/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
make -C ~/bin/mkscaf grant
```

## Interactive usage

Select a project type first:

```sh
mkscaf
```

Start with the script language prompt:

```sh
mkscaf script
```

Start with the web pattern prompt. Both commands use the same bundled webscaf:

```sh
mkscaf web
webscaf
```

## Direct usage

```sh
mkscaf script python my-script
mkscaf script go my-tool ../my-tool
mkscaf script typescript my-tool

mkscaf web fast-react my-app
mkscaf web nest-next my-next-app ../my-next-app
webscaf fast-react my-app
```

List the available choices:

```sh
mkscaf script patterns
mkscaf web patterns
webscaf patterns
```

### Script templates

| Language | Runtime | Entry point | Tests |
| --- | --- | --- | --- |
| Go | Go 1.26 | `main.go` | `go test` |
| Julia | Julia 1.12.6 | `main.jl` | `Test` standard library |
| Python | Python 3.14 | `main.py` | `unittest` |
| Racket | Racket 9.2 | `main.rkt` | Racket standard library |
| TypeScript | Node.js 24 / TypeScript 7 | `src/index.ts` | `node:test` |

Every script template provides the same development commands:

```sh
make run
make test
make build
make shell
make clean
```

Generated projects include executable code, focused tests, a Docker Compose
environment, a Makefile, VS Code settings, and `.mkscaf` generation metadata.

## Managing webscaf

webscaf remains available as a standalone repository. mkscaf vendors it under
`vendor/webscaf` using Git subtree, so no additional clone or submodule setup is
required.

Develop and verify web generation changes in the webscaf repository first,
then update the bundled copy and run the mkscaf checks:

```sh
make update_webscaf
make check
```

## Verification

```sh
make check
```

The checks cover every script language, interactive and direct usage,
equivalent output from `mkscaf web` and `webscaf`, scaffold component
initialization, and protection against overwriting existing paths.
