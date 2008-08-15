#!/bin/bash
# To be called by KBabel Catalogmanager

test -z "$KDESVN" && {
	echo "Environment variable KDESVN not set or empty. Exiting."
	exit 1
}

log="$HOME/temp/vsd.log"
svnroot="$KDESVN"
websvnroot='http://websvn.kde.org'
browsercmd='opera --newpage'
potfile="$1"
webaddress="${1/$svnroot/$websvnroot}"
cd $(dirname $potfile)
inf="$(svn info -r PREV $(basename $potfile))"
revision=$(echo "$inf"|grep "^Revision: ")
prevrev=$(echo "$inf"|grep "^Letzte ge") # FIXME: Hangt vun locale af
revision=$((${revision#*: }+1))
prevrev=${prevrev#*: }
webaddress="$webaddress?rev=$revision&r1=$prevrev&r2=$revision"

$browsercmd $webaddress
