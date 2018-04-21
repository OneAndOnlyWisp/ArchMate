#!/bin/sh
clear

function FindAndReplaceAll {
  sed "s/""$1""/""$2""/g" $3
}

FindAndReplaceAll "# %wheel ALL=(ALL) ALL" "%wheel ALL=(ALL) ALL" /etc/sudoers

#NEED TO TEST
#FindAndReplaceAll "# %wheel ALL=(ALL) ALL" "%wheel ALL=(ALL) ALL" /etc/sudoers | sudo EDITOR='tee -a' visudo
