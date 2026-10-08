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

# Terminal screensaver (matches Omarchy's — TTE random effects) after 5 min idle, any key exits
TMOUT=300
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

# ==========================================================================
# Custom prompt — colored pills + right-side clock
# ==========================================================================
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

    # Pill shown only inside nix-shell / nix develop
    local nix=""
    local nix_len=0
    if [[ -n $IN_NIX_SHELL || -n $MY_NIX_SHELL ]]; then
        nix=" %K{$C_BG}%F{$C_OK} ❄ nix %f%k"
        nix_len=8   # separator(1) + " ❄ nix " (7)
    fi

    local user_host=$(print -Pn "%n@%m")
    local dir=$(print -Pn "%(4~|.../%3~|%~)")

    # Precise visible length: each pill is " content ", separator between pills is 1 space
    # user pill(2+len) + sep(1) + dir pill(2+len) + nix pill + optional: git sep(1) + git pill(2+len+markers)
    local left_len=$(( 2 + ${#user_host} + 1 + 2 + ${#dir} + nix_len ))
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

    PROMPT="%K{$C_BG}%F{$C_ACCENT} %n@%m %f%k %K{$C_BG}%F{$C_ACCENT} %(4~|.../%3~|%~) %f%k${nix}${git}${padding}${clock}
%(?:%F{$C_OK}:%F{$C_ERR}) ❯%f "
    RPROMPT=""
}

precmd_functions+=(_build_prompt)

# ==========================================================================
# Aliases & functions  (trailing "# comment" = description shown by `aliases`)
# ==========================================================================

# --- Shell ---
alias reload='source ~/.zshrc'                 # reload this config
alias zshrc='${EDITOR:-nano} ~/.zshrc'         # edit this config
alias c='clear'                                # clear the screen
alias h='history -30'                          # last 30 commands
alias please='sudo $(fc -ln -1)'               # rerun the last command with sudo
alias fman='compgen -c | fzf | xargs man'      # fuzzy-search man pages

# List every alias/function in ~/.zshrc with its description
aliases() {
    awk '
    function emit(name, desc) { printf "  \033[1m%-14s\033[0m %s\n", name, desc }
    /^# --- / { h = $0; gsub(/^# --- | ---$/, "", h); printf "\n\033[36m%s\033[0m\n", h }
    /^alias [^=]+=/ {
        line = substr($0, 7)
        name = line; sub(/=.*/, "", name)
        cmd = line;  sub(/^[^=]+=/, "", cmd)
        desc = ""
        if (match(cmd, /[ \t]+# /)) {
            desc = substr(cmd, RSTART + RLENGTH)
            cmd = substr(cmd, 1, RSTART - 1)
        }
        gsub(/^[\047"]|[\047"]$/, "", cmd)
        emit(name, desc != "" ? desc : cmd)
    }
    /^[A-Za-z0-9_-]+\(\) *\{/ {
        name = $0; sub(/\(.*/, "", name)
        if (name ~ /^_/ || name == "TRAPALRM") next
        desc = ""
        if (match($0, /[ \t]+# /)) desc = substr($0, RSTART + RLENGTH)
        emit(name "()", desc)
    }
    END { print "" }' ~/.zshrc
}

# --- Files ---
alias cp='cp -iv'                              # copy, confirm overwrites
alias mv='mv -iv'                              # move, confirm overwrites
alias mkdir='mkdir -pv'                        # make dirs with parents, verbose
alias df='df -h'                               # disk free, human-readable
alias du='du -h'                               # disk usage, human-readable
alias duh='du -h --max-depth=1 | sort -h'      # what's eating space here

mkcd() {    # make a directory (and parents), then cd into it
    command mkdir -p -- "$1" && cd -- "$1"
}

extract() {    # extract almost any archive (zip needs unzip, 7z needs p7zip)
    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz)   tar xzf "$1" ;;
        *.tar.xz)         tar xJf "$1" ;;
        *.tar)            tar xf "$1" ;;
        *.zip)            unzip "$1" ;;
        *.7z)             7z x "$1" ;;
        *.gz)             gunzip "$1" ;;
        *.bz2)            bunzip2 "$1" ;;
        *) echo "don't know how to extract '$1'" ;;
    esac
}

# --- NixOS ---
alias rebuild='sudo nixos-rebuild switch'      # rebuild and switch to new config
alias rebuild-test='sudo nixos-rebuild test'   # apply config now, but don't make it the boot default
alias rebuild-boot='sudo nixos-rebuild boot'   # rebuild, apply on next boot
alias nixedit='sudo ${EDITOR:-nano} /etc/nixos/configuration.nix'   # edit system config
alias nixgens='sudo nix-env -p /nix/var/nix/profiles/system --list-generations'   # list generations
alias nixclean='sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +3 && sudo nix-collect-garbage'   # keep last 3 generations, then GC
alias nixs='nix search nixpkgs'                # search nixpkgs
alias nixfind='nix-locate --top-level'   # which package provides this file? e.g. nixfind bin/sslscan

nix-shell() {    # nix-shell that lands in zsh and marks the prompt
    local a
    for a in "$@"; do
        [[ $a == --run || $a == --command || $a == -c ]] && { command nix-shell "$@"; return; }
    done
    MY_NIX_SHELL=1 command nix-shell "$@" --command zsh
}
nix-develop() { MY_NIX_SHELL=1 command nix develop "$@" --command zsh; }   # nix develop that lands in zsh

# --- Networking / recon ---
alias myip='curl -s https://ifconfig.me; echo' # public IP
alias lanip='ip -4 -br addr'                   # local interface IPs
alias ports='sudo ss -tulnp'                   # listening ports + owning process
alias serve='python3 -m http.server 8000'      # file server for the current dir
alias proxychains='proxychains4 -f ~/.config/proxychains/proxychains.conf'   # proxychains with my config

scan() { nmapAutomator -H "$1" -t "${2:-Quick}"; }   # scan <ip> [mode]: nmapAutomator, default Quick
