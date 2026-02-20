# Volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"


# zsh のふるまいを明示
set -o pipefail
setopt PROMPT_SUBST

# 履歴（安全・扱いやすさ）
setopt EXTENDED_HISTORY        # 時刻なども保存
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY      # 実行ごとに履歴へ追記
setopt SHARE_HISTORY           # 複数シェル間で共有

# 操作性
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_SILENT
setopt INTERACTIVE_COMMENTS
setopt COMPLETE_IN_WORD
setopt MENU_COMPLETE
setopt AUTO_MENU
setopt NUMERIC_GLOB_SORT
setopt NO_CLOBBER
setopt TRANSIENT_RPROMPT
setopt LIST_TYPES              # 補完一覧にファイル種別記号
setopt RM_STAR_WAIT            # rm * 実行時に確認待ち

PROMPT_EOL_MARK=''

# ロケール（文字化け対策）
export LANG=ja_JP.UTF-8
export LC_CTYPE=ja_JP.UTF-8

# 履歴ファイル
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

# less の既定（色・スクロール安定）
export LESS='-R -F -X'
export LESSHISTFILE=-

# エディタ（存在するものを優先）
if command -v nvim >/dev/null; then
  export EDITOR=nvim
elif command -v vim >/dev/null; then
  export EDITOR=vim
else
  export EDITOR=nano
fi

# PATH/FPATH を重複なく保つ
typeset -U path fpath

##### Homebrew / PATH / 補完 ##############################################

# Apple Silicon / Intel どちらでもOK
if command -v /opt/homebrew/bin/brew >/dev/null; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif command -v /usr/local/bin/brew >/dev/null; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# brew の zsh 補完を読み込めるように FPATH を追加（存在時のみ）
if command -v brew >/dev/null; then
  _brew_prefix="$(brew --prefix 2>/dev/null)"
  if [[ -d "$_brew_prefix/share/zsh/site-functions" ]]; then
    fpath=("$._brew_prefix"/share/zsh/site-functions $fpath)
  fi
  unset _brew_prefix
fi

# PATH の重複排除を確実に
path=($path)

##### 色 / vcs_info / フック ##############################################

autoload -Uz colors vcs_info add-zsh-hook compinit
colors

##### 補完初期化（キャッシュ有効化＆安全） ###############################

# 補完のダンプはZshバージョンごとに分ける
ZSH_COMPCACHE=${ZSH_COMPCACHE:-~/.zcompcache}
[[ -d "$ZSH_COMPCACHE" ]] || mkdir -p "$ZSH_COMPCACHE"
ZSH_COMPDUMP="$ZSH_COMPCACHE/zcompdump-$ZSH_VERSION"

# compinit（-i: insecure警告を無視, -d: ダンプファイル指定）
compinit -i -d "$ZSH_COMPDUMP"

# 補完の表示・一致ルール（見やすく）
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=*'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_COMPCACHE"
zstyle ':completion:*' rehash true
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':completion:*:messages'     format '%F{blue}%d%f'
zstyle ':completion:*:warnings'     format '%F{red}%d%f'
# 隠しファイルも補完対象に
_comp_options+=(globdots)

##### キーバインド ########################################################

# 端末に依存しない安全な矢印キー検出
zmodload zsh/terminfo
bindkey -e
[[ -n ${terminfo[kcuu1]} ]] && bindkey "${terminfo[kcuu1]}" history-beginning-search-backward
[[ -n ${terminfo[kcud1]} ]] && bindkey "${terminfo[kcud1]}" history-beginning-search-forward
# 単語境界：./- を「単語中」扱いしない（編集しやすく）
WORDCHARS='*?_[]~=&;!#$%^(){}<>'

##### macOS らしさ / コマンドの見た目 ####################################

# LSCOLORS（macOSのBSD ls用配色：好みで調整可）
export LSCOLORS=Gxfxcxdxbxegedabagacad

# ls / less
if command -v eza >/dev/null; then
  alias ls='eza -F --group-directories-first --icons=auto'
else
  alias ls='ls -GFh'
fi
alias less='less -R'

# grep（GNU grep があれば色付き）
if command -v ggrep >/dev/null; then
  alias grep='ggrep --color=auto'
else
  alias grep='grep'
fi

# cat（bat があれば自動）
if command -v bat >/dev/null; then
  alias cat='bat'
fi

# sudo 経由でもエイリアス展開
alias sudo='sudo '

# rm の簡易セーフガード（ゴミ箱へ）
trash() { command mv -f "$@" ~/.Trash/; }
alias rm='trash'  # 不要ならコメントアウト

##### 便利ツールのフック（任意：存在時のみ） ##############################

# direnv
if command -v direnv >/dev/null; then
  eval "$(direnv hook zsh)"
fi

# pyenv / rbenv / fnm / volta など（必要なものだけ使われます）
if command -v pyenv >/dev/null; then
  eval "$(pyenv init -)"
fi
if command -v rbenv >/dev/null; then
  eval "$(rbenv init - zsh)"
fi
if command -v fnm >/dev/null; then
  eval "$(fnm env --use-on-cd)"
fi
if command -v volta >/dev/null; then
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
fi

# gpg（pinentry対策）
if command -v gpg >/dev/null; then
  export GPG_TTY=$(tty)
fi

##### ターミナルタイトル ##################################################

# 実行後（カレントディレクトリ）
__title_precmd() {
  case "$TERM_PROGRAM:$TERM" in
    Apple_Terminal:*|iTerm.app:*|WezTerm:*|*:xterm*|*:screen*|*:tmux*)
      print -Pn '\e]0;%n@%m: %~\a'
      ;;
  esac
}

# 実行直前（コマンド名）
__title_preexec() {
  local cmd="${1%%$'\n'*}"
  case "$TERM_PROGRAM:$TERM" in
    Apple_Terminal:*|iTerm.app:*|WezTerm:*|*:xterm*|*:screen*|*:tmux*)
      print -Pn -- "\e]0;${cmd:q} — %n@%m: %~\a"
      ;;
  esac
}

add-zsh-hook precmd __title_precmd
add-zsh-hook preexec __title_preexec

##### Git 連携（vcs_info） ################################################

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
# 速度重視するなら有効化（超大規模repo向け）
# zstyle ':vcs_info:git:*' use-simple true

# ステータス表示
zstyle ':vcs_info:git:*' stagedstr '●'     # ステージ済みあり
zstyle ':vcs_info:git:*' unstagedstr '✚'   # 未ステージあり
zstyle ':vcs_info:git:*' formats '%b %u%c'          # 例: main ●✚
zstyle ':vcs_info:git:*' actionformats '%b|%a %u%c'

# （任意）未追跡ファイルがあれば ? を足す軽量フック
+vi-git-untracked() {
  # git管理下で未追跡があるか確認（高速）
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    if [[ -n "$(git ls-files --others --exclude-standard 2>/dev/null | head -n1)" ]]; then
      hook_com[unstaged]+='?'
    fi
  fi
}
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

##### コマンド実行時間（2秒以上で表示） ##################################

typeset -g __cmd_timer __cmd_duration

__start_timer() {
  __cmd_timer=$SECONDS
}
add-zsh-hook preexec __start_timer

##### プロンプト構築 #######################################################

__build_prompt() {
  local exit=$?   # 直前の終了コード

  # 実行時間
  if [[ -n ${__cmd_timer:-} ]]; then
    local delta=$(( SECONDS - __cmd_timer ))
    if (( delta >= 2 )); then
      __cmd_duration="${delta}s"
    else
      __cmd_duration=""
    fi
    unset __cmd_timer   # ★計測リセット（重要）
  fi

  # 仮想環境名（Python venv / conda / poetry 等）
  local venv=""
  if   [[ -n $VIRTUAL_ENV ]];        then venv="${VIRTUAL_ENV:t}"
  elif [[ -n $CONDA_DEFAULT_ENV ]];  then venv="$CONDA_DEFAULT_ENV"
  elif [[ -n $POETRY_ACTIVE ]];      then venv="poetry"
  fi

  # 左プロンプト（2行）
  PROMPT='%F{yellow}%2~%f'
  if [[ -n $venv ]]; then
    PROMPT+=" %F{magenta}(${venv})%f"
  fi
  PROMPT+=$'\n''%(!.%F{red}#%f.%F{blue}$%f) '

  # 右プロンプト（Git / 実行時間 / 終了コード / 日時）
  local parts=()
  if [[ -n $vcs_info_msg_0_ ]]; then
    parts+=("%F{blue}git:%f%F{white}${vcs_info_msg_0_}%f")
  fi
  if [[ -n $__cmd_duration ]]; then
    parts+=("%F{cyan}$__cmd_duration%f")
  fi
  if (( exit != 0 )); then
    parts+=("%F{red}✖ $exit%f")
  fi
  parts+=("%F{240}%D{%Y-%m-%d} %*%f")  # 日付と時刻（不要なら削除）
  RPROMPT="${(j: :)parts}"
}

# ★順序重要：まず vcs_info、次に __build_prompt を実行
add-zsh-hook precmd vcs_info
add-zsh-hook precmd __build_prompt