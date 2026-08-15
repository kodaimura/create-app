# mkscaf

複数言語の小さなスクリプト環境と、認証機能付きWebアプリケーションを生成する対話式CLIです。
[webscaf](https://github.com/kodaimura/webscaf)を内包しているため、mkscafをインストールすると
`mkscaf web`と`webscaf`の両方を利用できます。

## 必要要件

- Bash
- Docker / Docker Compose
- Make
- Git（Webアプリケーション生成時）

## インストール

```sh
mkdir -p ~/bin
# ~/bin/mkscafは任意のclone先へ変更できます。PATHも同じ場所に合わせてください。
git clone https://github.com/kodaimura/mkscaf.git ~/bin/mkscaf
echo 'export PATH="$HOME/bin/mkscaf/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
make -C ~/bin/mkscaf grant
```

## 対話形式

プロジェクト種別から選ぶ場合：

```sh
mkscaf
```

Script言語の選択から始める場合：

```sh
mkscaf script
```

Webパターンの選択から始める場合は、どちらも同じWebscafを実行します。

```sh
mkscaf web
webscaf
```

## 引数指定

```sh
mkscaf script python my-script
mkscaf script go my-tool ../my-tool
mkscaf script typescript my-tool

mkscaf web fast-react my-app
mkscaf web nest-next my-next-app ../my-next-app
webscaf fast-react my-app
```

利用可能な選択肢：

```sh
mkscaf script patterns
mkscaf web patterns
webscaf patterns
```

### Scriptテンプレート

| 言語 | 実行環境 | エントリーポイント | テスト |
| --- | --- | --- | --- |
| Go | Go 1.26 | `main.go` | `go test` |
| Julia | Julia 1.12.6 | `main.jl` | `Test`標準ライブラリ |
| Python | Python 3.14 | `main.py` | `unittest` |
| Racket | Racket 9.2 | `main.rkt` | Racket標準機能 |
| TypeScript | Node.js 24 / TypeScript 7 | `src/index.ts` | `node:test` |

どの言語も同じ操作で利用できます。

```sh
make run
make test
make build
make shell
make clean
```

生成物には、実行コード、最小限のテスト、Docker Compose環境、Makefile、
VS Code設定、生成情報を保持する`.mkscaf`が含まれます。

Laravelの旧生成処理は互換用コマンドとして残しています。

```sh
mkscaf legacy laravel
```

## Webscafの管理

`webscaf`は単体リポジトリでも従来どおり利用できます。mkscafにはGit subtreeとして
`vendor/webscaf`へ内包し、追加cloneやsubmodule初期化なしで動作させています。

Web生成機能は先にwebscafリポジトリで変更・検証し、その後mkscaf側を更新します。

```sh
make update_webscaf
make check
```

## 検証

```sh
make check
```

全言語のScript生成、対話式・引数式、`mkscaf web`と`webscaf`の生成結果一致、
既存パスの上書き防止を一時ディレクトリ内で検証します。
