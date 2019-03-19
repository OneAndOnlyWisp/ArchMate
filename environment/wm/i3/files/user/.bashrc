#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Terminal startup command
PROMPT_COMMAND="history -a; echo -ne \"\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007\""

# Eternal bash history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
export HISTFILE=~/.bash_eternal_history

# History quick search
alias hs='history | grep'

# Colors
PS1='\[\033[01;32m\][\[\033[01;36m\]\u\[\033[01;32m\]@\[\033[01;36m\]\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
alias ls='ls --color=auto'
alias ll='ls -la'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'

# Confirm before overwriting something
alias cp="cp -i"
# Human-readable sizes
alias df='df -h'

#################################### EXTRAS ####################################

# ex - archive extractor
# usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

################################################################################
