# --- Aliases ---
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias nv='nvim'
alias e='exit'
alias ll='ls -lrt'
alias la='ls -A'
alias l='ls -CF'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e "s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//")"'

# Safer fzf alias (use function)
fzf() {
    command fzf --height=40% --layout=reverse --border --margin=5% --bind "ctrl-j:down,ctrl-k:up" "$@"
}

# --- Helper function ---
d() {
    if [[ -z "$1" ]]; then
        echo "Need exactly 1 argument: destination directory"
        return 1
    fi
    cd "$1" || return 1
    ls -lrt
}
