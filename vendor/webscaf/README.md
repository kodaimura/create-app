# webscaf

A scaffold CLI that combines a backend and frontend into an authentication-ready
web application.

## Supported patterns

| Pattern       | Backend                                           | Frontend                                          |
| ------------- | ------------------------------------------------- | ------------------------------------------------- |
| `fast-react`  | [FastAPI](https://github.com/kodaimura/scaf-fast) | [React](https://github.com/kodaimura/scaf-react)  |
| `fast-next`   | [FastAPI](https://github.com/kodaimura/scaf-fast) | [Next.js](https://github.com/kodaimura/scaf-next) |
| `gin-react`   | [Gin](https://github.com/kodaimura/scaf-gin)      | [React](https://github.com/kodaimura/scaf-react)  |
| `gin-next`    | [Gin](https://github.com/kodaimura/scaf-gin)      | [Next.js](https://github.com/kodaimura/scaf-next) |
| `genie-react` | [Genie](https://github.com/kodaimura/scaf-genie)  | [React](https://github.com/kodaimura/scaf-react)  |
| `genie-next`  | [Genie](https://github.com/kodaimura/scaf-genie)  | [Next.js](https://github.com/kodaimura/scaf-next) |
| `nest-react`  | [NestJS](https://github.com/kodaimura/scaf-nest)  | [React](https://github.com/kodaimura/scaf-react)  |
| `nest-next`   | [NestJS](https://github.com/kodaimura/scaf-nest)  | [Next.js](https://github.com/kodaimura/scaf-next) |

Patterns are defined independently in `patterns/*.conf`, so additional backend
and frontend combinations can be added without changing the generation flow.

## Requirements

- Bash
- Git
- Docker Compose
- Make

## Installation

Clone webscaf once and add its `bin` directory to `PATH`:

```sh
mkdir -p ~/bin
# Change ~/bin/webscaf if you prefer another clone location, and update PATH to match.
git clone https://github.com/kodaimura/webscaf.git ~/bin/webscaf
echo 'export PATH="$HOME/bin/webscaf/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

If the repository is already located elsewhere, add its absolute `bin` path:

```sh
export PATH="/absolute/path/to/webscaf/bin:$PATH"
```

Verify the installation:

```sh
webscaf --help
webscaf patterns
```

You do not need to clone webscaf again for each project. Update the original
clone with `git pull --ff-only` when needed.

## Usage

Start the interactive prompt:

```sh
webscaf
```

Specify a pattern and project name directly:

```sh
webscaf fast-react my-app
webscaf nest-react my-app
webscaf fast-next my-next-app
webscaf nest-next my-next-app
```

By default, the project is created under the current directory. An explicit
output directory can be provided as the third argument:

```sh
webscaf fast-react my-app ../my-app
```

Start the generated application:

```sh
cd my-app
make build
make up
make migrate
```

- Web: http://localhost:3000
- API: http://localhost:8000/api
- Health: http://localhost:8000/health
- MailHog: http://localhost:8025

## Generated structure

```text
my-app/
  .github/              # GitHub Actions and contribution templates
  docs/                 # GitHub, contribution, security, and operations guidance
  api/                  # selected backend and its architecture contract
  web/                  # selected frontend and its architecture contract
  AGENTS.md              # project-wide AI instructions and component delegation
  CLAUDE.md              # imports the project-wide instructions
  .env.example          # tracked shared Compose settings template
  .env                  # local shared Compose settings
  .webscaf              # generation metadata
  docker-compose.yml
  docker-compose.prod.yml
  Makefile
```

The root Compose files combine both components. Framework-specific commands
remain available from the `api` and `web` directories.

GitHub workflows and contribution files from the selected components are
replaced with the project-wide versions at the generated repository root.
References in component READMEs and agent instructions are updated to point to
those root documents. Framework-specific `AGENTS.md`, `CLAUDE.md`, and
`docs/ARCHITECTURE.md` files remain inside `api/` and `web/`; the root
instructions delegate changes to them.

When a component provides an executable `bin/scaf-init`, webscaf runs it with
the project name immediately after cloning. Each scaffold is responsible for
initializing its module name, package name, Compose resources, and UI title.
