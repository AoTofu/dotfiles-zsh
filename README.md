# macOS 向け zsh 設定（`.zshrc`）

このリポジトリは、普段使いしやすさを重視した `zsh` 設定を共有するためのものです。  
対象は macOS の `zsh`（`/bin/zsh`）です。

## この設定でできること

- 見やすい 2 行プロンプト（色 + 絵文字アイコン）
- Git ブランチと差分状態（`vcs_info`）の表示
- コマンド実行時間（2 秒以上）と終了コードの表示
- 補完の強化（大文字小文字のゆるい一致、メニュー選択、キャッシュ）
- 履歴の扱い改善（重複抑制、複数シェル共有、実行ごと追記）
- 端末タイトルの自動更新（タブ名にカレントディレクトリや実行コマンドを反映）
- `eza` / `bat` / `ggrep` がある場合は自動で活用
- `rm` をゴミ箱移動に置き換える簡易セーフガード

## 動作環境

- macOS
- zsh 5.8 以降（macOS 標準で概ね動作）
- Homebrew（任意だがあると便利）

## あると便利なコマンド（任意）

```bash
brew install eza bat grep direnv pyenv rbenv fnm
```

以下はインストール済みの場合のみ自動で有効化されます。

- `direnv`
- `pyenv`
- `rbenv`
- `fnm`
- `volta`

## 導入手順

1. 現在の設定をバックアップ

```bash
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d-%H%M%S)
```

2. このリポジトリの `.zshrc` を反映

```bash
cp .zshrc ~/.zshrc
```

3. 設定を再読み込み

```bash
exec zsh
```

## 更新手順

```bash
git pull
cp .zshrc ~/.zshrc
exec zsh
```

## カスタマイズのポイント

- 絵文字を使わないプレーン表示にする  
  `.zshrc` の `ZSH_PROMPT_ICON_MODE` の既定値を `plain` に変更してください。
  例: `typeset -g ZSH_PROMPT_ICON_MODE=${ZSH_PROMPT_ICON_MODE:-plain}`

- `rm` を通常動作に戻す  
  `.zshrc` の `alias rm='trash'` をコメントアウトしてください。

- `cat` を `bat` に置き換えたくない場合  
  `.zshrc` の `alias cat='bat'` をコメントアウトしてください。

- プロンプト右側の日付時刻を消したい場合  
  `__build_prompt` 内の `parts+=("%F{245}${PROMPT_ICON_CLOCK}%f %F{245}%D{%Y-%m-%d %H:%M:%S}%f")` を削除してください。

## 注意点

- この設定では `rm` がゴミ箱移動になります。  
  完全削除したい場合は `command rm` を使ってください。
- 環境によってはロケールや補完設定を追加調整した方が見やすくなる場合があります。
