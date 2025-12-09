# --- Aliases ---
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias zg='rg -z'
alias rgs='rg -S'
alias zgs='rg -z -S'
alias fzv='tmp=$(fzf); echo $tmp; nvim $tmp'
alias fzd='tmp=$(fd --type d | fzf); echo $tmp; d $tmp'
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
alias py='python3'
alias tl='tail -Fn 40'

# Safer fzf alias (use function)
fzf() {
    command fzf --height=40% --layout=reverse --border --margin=2% --bind "ctrl-j:down,ctrl-k:up" "$@"
}

# --- Helper function ---
d() {
    if [[ -z "$1" ]]; then
        cd ~/
        ls -lrt
        return 0
    fi
    cd "$1" || return 1
    ls -lrt
}
