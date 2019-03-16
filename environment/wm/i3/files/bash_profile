#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx;
fi

if [[ ! $XDG_VTNR ]]; then
  neofetch;
fi
