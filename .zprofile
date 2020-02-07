XDG_CONFIG_HOME="/home/violeine/.config" 
export XDG_CONFIG_HOME

#auto startx when login
if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx
fi
