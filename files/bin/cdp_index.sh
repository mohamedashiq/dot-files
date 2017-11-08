#!/bin/bash -e

if [ -z "$HOME" ]; then
    HOME=$1; shift
fi

if [ -z "$USER" ]; then
    USER=$1; shift
fi

if [ -e $HOME/.cdprc ]; then
    source $HOME/.cdprc	
fi

if [ -z "$SCAN_DIR" ]; then
    SCAN_DIR="$HOME/repos"
fi

TMP_FILE=$(mktemp)
IDX_FILE="$HOME/.cdp.index"

find "$SCAN_DIR" -name ".git" -o -name ".svn" | xargs -I % dirname % | grep -v '/build/' | awk -F '/' '{print $5,$NF,$0}' | sort > $TMP_FILE

mv $TMP_FILE $IDX_FILE

/usr/sbin/chown $USER $IDX_FILE

chmod 664 $IDX_FILE
