# .zshrc for macOS

<p align="center">
  <img alt="header" src="https://capsule-render.vercel.app/api?type=waving&height=220&color=0:00C6FF,50:0072FF,100:7F5AF0&text=bluetofu%20zshrc&fontColor=ffffff&fontSize=52&fontAlignY=38&animation=fadeIn" />
</p>

<p align="center">
  <img alt="macOS" src="https://img.shields.io/badge/macOS-Ready-111827?style=for-the-badge&logo=apple&logoColor=white" />
  <img alt="zsh" src="https://img.shields.io/badge/zsh-5.8%2B-16a34a?style=for-the-badge&logo=gnu-bash&logoColor=white" />
  <img alt="homebrew" src="https://img.shields.io/badge/Homebrew-Optional-f97316?style=for-the-badge&logo=homebrew&logoColor=white" />
  <img alt="dotfiles" src="https://img.shields.io/badge/Type-Dotfiles-7c3aed?style=for-the-badge" />
</p>

普段使いで「見やすい・速い・安全寄り」を目指した `zsh` 設定です。  
`oh-my-zsh` なしで動く、シンプル構成の `.zshrc` を共有しています。

## Highlights

| 項目 | 内容 |
| --- | --- |
| Prompt | 2行プロンプト、終了コード表示、実行時間（2秒以上）表示 |
| Git | `vcs_info` でブランチ + 変更状態（`●` `✚` `?`）を表示 |
| Completion | 補完メニュー選択、あいまい一致、補完キャッシュ |
| History | 重複抑制、即時追記、複数シェル共有 |
| Safety | `rm` をゴミ箱移動に変更（必要ならすぐ無効化可） |
| UX | 端末タイトル更新、`eza/bat/ggrep` の自動利用 |

## Quick Start

```bash
# 1) バックアップ
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d-%H%M%S)

# 2) 適用
cp .zshrc ~/.zshrc

# 3) 反映
exec zsh
```

## Optional Tools

あると便利なコマンド（未導入でも `.zshrc` は動作）:

```bash
brew install eza bat grep direnv pyenv rbenv fnm
```

有効化されるもの:

- `direnv`
- `pyenv`
- `rbenv`
- `fnm`
- `volta`

## Prompt Preview

```text
~/Documents/project
$ _

# 右側: git:main ●✚ 3s ✖ 1 2026-02-20 22:30:10
```

## Customize

1. `rm` を通常動作に戻す  
`alias rm='trash'` をコメントアウト

2. `cat` を通常動作に戻す  
`alias cat='bat'` をコメントアウト

3. 右側の日時表示を消す  
`parts+=("%F{240}%D{%Y-%m-%d} %*%f")` の行を削除

## Notes

- この設定では `rm` はゴミ箱移動です。完全削除したい場合は `command rm` を使ってください。
- macOS 前提で調整しています。Linux で使う場合は `ls` まわりなどを環境に合わせて変更してください。

---

気に入ったら `Fork` / `Star` で使い回してください。
