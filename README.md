# webscaf

Webアプリケーションのバックエンドとフロントエンドを組み合わせて、認証機能付きのプロジェクトを生成するスキャフォルドツールです。

## 対応パターン

| パターン | バックエンド | フロントエンド |
| --- | --- | --- |
| `fast-react` | [FastAPI](https://github.com/kodaimura/scaf-fast) | [React](https://github.com/kodaimura/scaf-react) |
| `fast-next` | [FastAPI](https://github.com/kodaimura/scaf-fast) | [Next.js](https://github.com/kodaimura/scaf-next) |
| `gin-react` | [Gin](https://github.com/kodaimura/scaf-gin) | [React](https://github.com/kodaimura/scaf-react) |
| `gin-next` | [Gin](https://github.com/kodaimura/scaf-gin) | [Next.js](https://github.com/kodaimura/scaf-next) |
| `genie-react` | [Genie](https://github.com/kodaimura/scaf-genie) | [React](https://github.com/kodaimura/scaf-react) |
| `genie-next` | [Genie](https://github.com/kodaimura/scaf-genie) | [Next.js](https://github.com/kodaimura/scaf-next) |
| `nest-react` | [NestJS](https://github.com/kodaimura/scaf-nest) | [React](https://github.com/kodaimura/scaf-react) |
| `nest-next` | [NestJS](https://github.com/kodaimura/scaf-nest) | [Next.js](https://github.com/kodaimura/scaf-next) |

パターンは `patterns/*.conf` として独立しています。今後、別のバックエンドやフロントエンドを既存の生成処理を変更せずに追加できます。

## 必要要件

- Bash
- Git
- Docker Compose
- Make

## インストール

最初に一度だけcloneし、`bin` ディレクトリをPATHへ追加します。

```sh
mkdir -p ~/bin
# ~/bin/webscaf は任意のclone先に変更できます。変更する場合は、次のPATHも同じ場所に合わせてください。
git clone https://github.com/kodaimura/webscaf.git ~/bin/webscaf
echo 'export PATH="$HOME/bin/webscaf/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

別の場所へclone済みの場合は、その絶対パスの `bin` を追加してください。

```sh
export PATH="/absolute/path/to/webscaf/bin:$PATH"
```

登録を確認します。

```sh
webscaf --help
webscaf patterns
```

以後、プロジェクトを作成するたびに `webscaf` をcloneする必要はありません。ツールを更新するときは、最初にcloneしたリポジトリで `git pull --ff-only` を実行します。

## 使い方

対話形式で生成する場合：

```sh
webscaf
```

パターンとプロジェクト名を指定する場合：

```sh
webscaf fast-react my-app
```

NestJSとReactを組み合わせる場合：

```sh
webscaf nest-react my-app
```

Next.jsを使用する場合：

```sh
webscaf fast-next my-next-app
webscaf nest-next my-next-app
```

デフォルトでは、現在のディレクトリに `my-app` が作成されます。出力先を明示することもできます。

```sh
webscaf fast-react my-app ../my-app
```

生成後：

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

## 生成される構成

```text
my-app/
  api/                  # 選択したバックエンド
  web/                  # 選択したフロントエンド
  .env                  # Compose共通設定
  .webscaf              # 生成元パターンのメタデータ
  docker-compose.yml
  docker-compose.prod.yml
  Makefile
```

各コンポーネントのDocker Composeをルートから合成しているため、バックエンドやフロントエンド固有の開発コマンドもそれぞれのディレクトリで利用できます。

## ローカルリポジトリからの生成

テンプレート開発時は、環境変数でクローン元を上書きできます。

```sh
WEBSCAF_BACKEND_REPO=/path/to/scaf-fast \
WEBSCAF_FRONTEND_REPO=/path/to/scaf-next \
webscaf fast-next my-app
```
