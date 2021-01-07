#!/bin/sh

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --dpi 98
xrandr --auto
#nextcloud&
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export GTK_IM_MODULE=ibus
ibus-daemon -drx
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap
#start polkit sesssion
/usr/lib/mate-polkit/polkit-mate-authentication-agent-1&

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi
if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

mornNum=$(xrandr -q | grep -w connected | wc -l);

if [[ mornNum -eq 2 ]]; then
	2morn
else
	1morn
fi

start-pulseaudio-x11

nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
#wal --theme $HOME/.config/.scheme/one-half-dark.json
picom&
exec awesome

