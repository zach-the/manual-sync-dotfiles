
# ~/.bashrc

# Only run interactively
[[ $- != *i* ]] && return

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
    
# --- Path Exports ---
export PATH="$HOME/.local/bin:$HOME/.local/kitty/bin:$PATH"
export TERM=xterm-256color

# Safer tmux alias (only if file exists)
if [[ -x ~/.config/tmux/TMUX ]]; then
    alias tmux='~/.config/tmux/TMUX'
fi

# --- History Settings ---
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize
shopt -s direxpand

# --- Less / dircolors ---
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b ~/.dircolors 2>/dev/null || dircolors -b)"
fi

# --- Prompt ---
# Only run this if the terminal supports colors and powerline-shell is installed
if command -v powerline-shell &>/dev/null && [[ $TERM != linux ]]; then
    function _update_ps1() {
        PS1=$(powerline-shell $?)
    }

    # Append _update_ps1 to PROMPT_COMMAND if not already present
    if [[ ! "$PROMPT_COMMAND" =~ _update_ps1 ]]; then
        PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
    fi
else
    # fallback prompt
    PS1='[\u@\h \W]\$ '
fi

# If xterm, set window title
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
esac

# --- Key Bindings ---
bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete-backward'
bind "set show-all-if-ambiguous on"
bind "set menu-complete-display-prefix on"

[
