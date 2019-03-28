#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Bash promt style and color
PS1='\[\033[01;32m\][\[\033[01;36m\]\u\[\033[01;32m\]@\[\033[01;36m\]\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '

# Terminal identity
export TERM=xterm

################################### HISTORY ####################################
# Terminal startup command -----------------------------------------------------
PROMPT_COMMAND="history -a; echo -ne \"\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007\""
# Eternal bash history ---------------------------------------------------------
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
export HISTFILE=~/.bash_eternal_history
################################################################################

#################################### ALIAS #####################################
# Colored output ---------------------------------------------------------------
alias ls='ls --color=auto'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
#-------------------------------------------------------------------------------
alias sudo='sudo '                     # To make aliases work with sudo
alias ll='ls -l -all'                  # Detailed list
alias cp='cp -i'                       # Confirm before overwriting something
alias df='df -h'                       # Human-readable sizes
alias hs='history | grep'              # History Search
################################################################################

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
