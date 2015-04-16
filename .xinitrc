#!/bin/bash

#update the xterm colors, font size, etc
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# run the window manager in the background first
# mutter &
metacity &

# get the window manager process id
wm_pid=$!

# wait a little while for the window manager to load (extend this if the xterm is not being properly maximised)
sleep 2

# run the xterm in fullscreen
#xterm +u8 -js -fullscreen &
#xterm -en en_AU.UTF-8 -js -fullscreen &
urxvt &

# do not let the window manager become a zombie
wait $wm_pid

# this would run xterm first, then the window manager. doesn't maximise properly the first time startx is run
#xterm -fullscreen &
#exec mutter
