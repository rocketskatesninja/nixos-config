# User configuration

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

export PATH="$PATH:/home/nope/.local/bin"

# Prompt colors — read from noctalia-shell's live color scheme so the
# terminal follows whatever desktop theme is active, instead of a hardcoded
# palette. Falls back to the original Catppuccin Mocha values if noctalia
# hasn't run yet (e.g. a bare TTY) or the file is missing/unreadable.
_noctalia_color() {
    grep "\"$1\"" ~/.config/noctalia/colors.json 2>/dev/null | sed -E 's/.*: *"(#[0-9a-fA-F]+)".*/\1/'
}
if [[ -f ~/.config/noctalia/colors.json ]]; then
    C_BG=$(_noctalia_color mSurfaceVariant)
    C_ACCENT=$(_noctalia_color mPrimary)
    C_GIT_TEXT=$(_noctalia_color mSecondary)
    C_OK=$(_noctalia_color mSecondary)
    C_ERR=$(_noctalia_color mError)
    C_DIM=$(_noctalia_color mOnSurfaceVariant)
    C_CURSOR=$(_noctalia_color mOnSurface)
    C_MUTED=$(_noctalia_color mOutline)
fi
: ${C_BG:=#313244}
: ${C_ACCENT:=#89b4fa}
: ${C_GIT_TEXT:=#cba6f7}
: ${C_OK:=#cba6f7}
: ${C_ERR:=#f38ba8}
: ${C_DIM:=#7f849c}
: ${C_CURSOR:=#ffffff}
: ${C_MUTED:=#585b70}

# History
HISTSIZE=10000
SAVEHIST=10000

# Autosuggestions — use history + completion, more visible color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=$C_MUTED"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Terminal screensaver (matches Omarchy's — TTE random effects) after 2.5 min idle, any key exits
TMOUT=150
TRAPALRM() { /home/nope/nixos-config/screensaver; printf "\e]12;${C_CURSOR}\a"; zle reset-prompt; }

# Catppuccin Mocha LS_COLORS
export LS_COLORS="di=1;34:ln=36:so=35:pi=33:ex=32:bd=1;33:cd=1;33:su=31:sg=31:tw=1;34:ow=1;34"

# fzf — cache init so it doesn't re-evaluate on every shell open
_fzf_bin=$(command -v fzf)
if [[ ! -f ~/.cache/fzf-init.zsh || "$_fzf_bin" -nt ~/.cache/fzf-init.zsh ]]; then
    mkdir -p ~/.cache && fzf --zsh > ~/.cache/fzf-init.zsh
fi
source ~/.cache/fzf-init.zsh

# zoxide — cache init so it doesn't re-evaluate on every shell open
_zoxide_bin=$(command -v zoxide)
if [[ ! -f ~/.cache/zoxide-init.zsh || "$_zoxide_bin" -nt ~/.cache/zoxide-init.zsh ]]; then
    mkdir -p ~/.cache && zoxide init zsh > ~/.cache/zoxide-init.zsh
fi
source ~/.cache/zoxide-init.zsh

# history-substring-search — type partial command then use ↑/↓
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Aliases
alias fman='compgen -c | fzf | xargs man'
alias proxychains='proxychains4 -f ~/.config/proxychains/proxychains.conf'

# SecLists wordlists — cache nix store path (glob is slow to expand every time)
if [[ ! -f ~/.cache/seclists-path || ! -d "$(cat ~/.cache/seclists-path 2>/dev/null)" ]]; then
    mkdir -p ~/.cache && echo /nix/store/*seclists*/share/wordlists/seclists > ~/.cache/seclists-path
fi
export SECLISTS=$(cat ~/.cache/seclists-path)

# Custom prompt — colored pills + right-side clock
setopt PROMPT_SUBST

_git_segment() {
    _git_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    _git_markers=""
    _git_pill=""
    if [[ -n $_git_branch ]]; then
        git diff --quiet 2>/dev/null || _git_markers+="*"
        git diff --cached --quiet 2>/dev/null || _git_markers+="+"
        _git_pill=" %K{$C_MUTED}%F{$C_GIT_TEXT} $_git_branch${_git_markers:+ $_git_markers} %f%k"
    fi
}

_build_prompt() {
    printf "\e]12;${C_CURSOR}\a"
    _git_segment
    local git=$_git_pill
    local branch=$_git_branch
    local markers=$_git_markers

    local user_host=$(print -Pn "%n@%m")
    local dir=$(print -Pn "%(4~|.../%3~|%~)")

    # Precise visible length: each pill is " content ", separator between pills is 1 space
    # user pill(2+len) + sep(1) + dir pill(2+len) + optional: git sep(1) + git pill(2+len+markers)
    local left_len=$(( 2 + ${#user_host} + 1 + 2 + ${#dir} ))
    if [[ -n $branch ]]; then
        local m_len=0
        [[ -n $markers ]] && m_len=$(( 1 + ${#markers} ))
        left_len=$(( left_len + 1 + 2 + ${#branch} + m_len ))
    fi

    local clock_time=$(date +'%I:%M %p')
    local clock_len=$(( 2 + ${#clock_time} ))
    local pad=$(( COLUMNS - left_len - clock_len ))
    (( pad < 1 )) && pad=1
    local padding=${(l:$pad:: :):-}

    local clock="%K{$C_BG}%F{$C_DIM} %D{%I:%M %p} %f%k"

    PROMPT="%K{$C_BG}%F{$C_ACCENT} %n@%m %f%k %K{$C_BG}%F{$C_ACCENT} %(4~|.../%3~|%~) %f%k${git}${padding}${clock}
%(?:%F{$C_OK}:%F{$C_ERR}) ❯%f "
    RPROMPT=""
}

precmd_functions+=(_build_prompt)
