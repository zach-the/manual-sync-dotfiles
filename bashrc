# ~/.bashrc

# Only run interactively
[[ $- != *i* ]] && return

# --- Path Exports ---
export PATH="$HOME/.local/bin:$PATH"
export TERM=xterm-256color

# --- History Settings ---
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=3000
HISTFILESIZE=10000
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

# --- Key Bindings ---
bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete-backward'
bind "set show-all-if-ambiguous on"
bind "set menu-complete-display-prefix on"
bind "set completion-ignore-case on"

# --- Time Zone Fix ---
export TZ='America/Denver'

[ -f ~/.bash_aliases ] && source ~/.bash_aliases
    
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

[ -f /home/zb900042/toolbox/setup/toolboxrc ] && source /home/zb900042/toolbox/setup/toolboxrc

[ -f /home/zb900042/.local_aliases ] && source /home/zb900042/.local_aliases

clear
