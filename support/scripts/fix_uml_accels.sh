#!/bin/bash
if [ -z "$1" ]
then	files=$(pogrep -l "&[äöüÄÖÜß]")
elif [ -e $1 ]
then	files="$1"
else	echo "$1 not found."
	exit 1
fi
for f in $files
do	echo "Processing $f..."
	sed -i.bak -e 's/\(.*\)&\([ÄÖÜäöüß]\)\(.*\)/\1\2\&\3/' $f
	sed -i -e "/PO-Revision-Date/s/200.*/$(date "+%F %H:%M%z\\\n\"")/" $f
done
