#!/bin/bash
# To be called by KBabel Catalogmanager

logfile=${TEMP:-$TMP}
logfile=${logfile:-$HOME}
logfile="$logfile/kbabel_install_po.log"

exec 2>"$logfile"
msgfmt $3 -o $HOME/.kde/share/locale/nds/LC_MESSAGES/$1.mo $2 >> "$logfile" && dcop knotify default notify Success Catalogmanager "Dat funkscheneer wull." '' '' 16 0
test -s "$logfile" && kdialog --textbox "$logfile"
