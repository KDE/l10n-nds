#!/bin/bash
logfile=/home/soe/temp/kbab_inst.log
rm -f $logfile
msgfmt $3 -o /home/soe/.kde/share/locale/nds/LC_MESSAGES/$1.mo $2 > $logfile 2>&1 && dcop knotify default notify Success Catalogmanager "Dat funkscheneer wull." '' '' 16 0
test -s $logfile && kdialog --textbox $logfile
