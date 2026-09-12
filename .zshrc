# User configuration

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

export PATH="$PATH:/home/nope/.local/bin"

# History
HISTSIZE=10000
SAVEHIST=10000

# Autosuggestions — use history + completion, more visible color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#585b70'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Terminal screensaver — cmatrix after 5 min idle, any key exits
TMOUT=150
TRAPALRM() { PYTHONWARNINGS=ignore unimatrix -a -f -b -c blue -s 90 -l km -o; printf '\033c'; zle reset-prompt; }

# Catppuccin Mocha LS_COLORS
export LS_COLORS="di=1;34:ln=36:so=35:pi=33:ex=32:bd=1;33:cd=1;33:su=31:sg=31:tw=1;34:ow=1;34"

# fzf — Ctrl+R for fuzzy history, Ctrl+T for fuzzy file find
source <(fzf --zsh)

# zoxide — smarter cd, use 'z <partial-name>' to jump to visited dirs
eval "$(zoxide init zsh)"

# history-substring-search — type partial command then use ↑/↓
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Aliases
alias fman='compgen -c | fzf | xargs man'

# Custom prompt — colored pills + right-side clock
setopt PROMPT_SUBST

_git_segment() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    local markers=""
    git diff --quiet 2>/dev/null || markers+="*"
    git diff --cached --quiet 2>/dev/null || markers+="+"
    echo -n " %K{#45475a}%F{#cba6f7} $branch${markers:+ $markers} %f%k"
}

_build_prompt() {
    printf '\e]12;#ffffff\a'
    local git=$(_git_segment)

    local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    local markers=""
    git diff --quiet 2>/dev/null || markers+="*"
    git diff --cached --quiet 2>/dev/null || markers+="+"

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

    local clock="%K{#313244}%F{#7f849c} %D{%I:%M %p} %f%k"

    PROMPT="%K{#313244}%F{#89b4fa} %n@%m %f%k %K{#313244}%F{#89b4fa} %(4~|.../%3~|%~) %f%k${git}${padding}${clock}
%(?:%F{#cba6f7}:%F{#f38ba8}) ❯%f "
    RPROMPT=""
}

precmd_functions+=(_build_prompt)
