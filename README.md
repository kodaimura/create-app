# mkscaf

複数言語の小さなスクリプト環境と、認証機能付きWebアプリケーションを生成する対話式CLIです。
[webscaf](https://github.com/kodaimura/webscaf)を内包しているため、mkscafをインストールすると
`mkscaf web`と`webscaf`の両方を利用できます。

## 必要要件

- Bash
- Git
- Docker / Docker Compose
- Make

Juliaパッケージ生成時のみ、グローバルGitユーザー設定を使用します。

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

対話式・引数式のScript生成、`mkscaf web`と`webscaf`の生成結果一致、既存パスの
上書き防止を一時ディレクトリ内で検証します。
