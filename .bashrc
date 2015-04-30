# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=200000

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will match all files and zero or more directories and subdirectories.
shopt -s globstar

# make 'less' more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# pretty prompt and font colors
. ~/.pretty_bash_prompt 2> /dev/null

##############
# aliases and functions
##############

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias dir='dir --color=auto'
	alias vdir='vdir --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
	alias rm="rm -i"
	alias untargz="tar -zxvf"
fi

alias x='exit'
function n() {
	# run this function like: n progname
	nohup >> "/tmp/$1.nohup-output" $@ &
	echo "started running '$@' on $(date). pid is $!" >> "/tmp/$1.nohup-output"
}

# include private aliases
. ~/.private_aliases 2> /dev/null

##############
# end aliases and functions
##############

# enable programmable completion features (you don't need to enable this, if it's already enabled in /etc/bash.bashrc and /etc/profile sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# set the sound to 20% of full volume if on a pts (not tty), and if not in screen
# or over ssh
IS_PTS=$(tty | grep pts)
PARENT_PROG=$(cat /proc/$PPID/status | head -1 | cut -f2)
[ "$IS_PTS" ] && [ "$PARENT_PROG" != "sshd" ] && \
[ "$PARENT_PROG" != "screen" ] && amixer sset 'Master' 20%

# set tabs to 4 spaces in terminal
tabs 5,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4,+4

PATH=/usr/local/bin:/usr/bin:/bin:/sbin

export LC_ALL=en_AU.UTF-8
export LANG=en_AU.UTF-8
export LANGUAGE=en_AU.UTF-8

# final logon actions:

# go straight to x on login. only do this for tty1 so that we can still use the
# other tty consoles withouth starting x. also only do this when there is no
# display, otherwise the terminal will try and do this after x starts aswell
[[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]] && startx

# if using rxvt or urxvt set the window to fullscreen
[[ $TERM == *"rxvt"* ]] && wmctrl -r :ACTIVE: -b add,fullscreen
