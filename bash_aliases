# --- Aliases ---
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias lg='ls -lrt | rg'
alias zg='rg -z'
alias rgs='rg -S'
alias zgs='rg -z -S'
alias fzv='tmp=$(fzf) && echo $tmp && nvim $tmp'
alias fzd='tmp=$(fd --type d -d 4 | fzf) && echo $tmp && d $tmp'
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
alias tm='tmux a'

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

# --- make a directory and go to it ---
md() {
    if [[ -n "$2" ]]; then
        echo "all arguments after the first argument are being ignored"
    fi
    if [[ -n "$1" ]]; then
        mkdir -p $1
        cd $1
        ls -lrt
        return 0
    else
        echo "no arguments supplied. doing nothing"
        return 1
    fi
}

# --- to easily diff two directories ---
zd ()
{ 
    if [[ -z "$2" ]]; then
        echo "you need 2 arguments";
        return 0;
    fi;

    diff -r -y --suppress-common-lines -W $(tput cols) \
        --exclude="*def" --exclude="eco?.tcl" --exclude="*csv" \
        --exclude="*log" --exclude="*rpt" --exclude="*\.shadow*" --expand-tabs "$1" "$2" | \
        # This sed captures the last two space-separated strings (the paths) 
        # on lines starting with 'diff'
        sed -E 's/^diff .* ([^ ]+) ([^ ]+)$/FILE: \1 <-> \2/' | \
        rg -v "Common\ subdirectories" | \
        # The -- tells rg that "FILE:" is a pattern, not a flag
        rg --color=always -- "FILE:.*|Only in |$" | \
        rg -v "Only in"
}

zd_with_shadow ()
{ 
    if [[ -z "$2" ]]; then
        echo "you need 2 arguments";
        return 0;
    fi;

    diff -r -y --suppress-common-lines -W $(tput cols) \
        --exclude="*def" --exclude="eco?.tcl" --exclude="*csv" \
        --exclude="*log" --exclude="*rpt" --expand-tabs "$1" "$2" | \
        # This sed captures the last two space-separated strings (the paths) 
        # on lines starting with 'diff'
        sed -E 's/^diff .* ([^ ]+) ([^ ]+)$/FILE: \1 <-> \2/' | \
        rg -v "Common\ subdirectories" | \
        # The -- tells rg that "FILE:" is a pattern, not a flag
        rg --color=always -- "FILE:.*|Only in .*|$" | \
        rg -v "Only in"
}
