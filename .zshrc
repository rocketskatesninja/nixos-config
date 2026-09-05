# User configuration

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

export PATH="$PATH:/home/nope/.local/bin"

# Make autosuggestions more visible
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#888888'

# Terminal screensaver — cmatrix after 5 min idle, any key exits
TMOUT=300
TRAPALRM() { cmatrix -C magenta -u 7 -s; }

# Aliases
alias fman='compgen -c | fzf | xargs man'

# Custom agnoster prompt with transparent username background
prompt_context() {
    if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
        print -n " %{%f%k%}%(!.%{%F{yellow}%}.%{%F{green}%})%n@%m "
    fi
}

# Custom agnoster prompt ending with timestamp and newline
prompt_end() {
    local timestamp="%D{%I:%M:%S %p}"
    print -n " %{%f%k%} $timestamp "  # Reset color to default here
    if [[ -n $CURRENT_BG ]]; then
        print -n "%{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
    else
        print -n "%{%k%}"
    fi
    print -n "%{%f%}"
    CURRENT_BG=''
    printf "\n >>>"
}
