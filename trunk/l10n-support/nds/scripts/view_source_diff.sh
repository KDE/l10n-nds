#!/bin/bash
# To be called by KBabel Catalogmanager

test -z "$KDESVN" && {
	echo "Environment variable KDESVN not set or empty. Exiting."
	exit 1
}

logfile=${TEMP:-$TMP}
logfile=${logfile:-$HOME}
logfile="$logfile/kbabel_view_source_diff.log"

svnroot="$KDESVN"
websvnroot='http://websvn.kde.org'
browsercmd='opera --newpage'
potfile="$1"
webaddress="${1/$svnroot/$websvnroot}"

exec 2>"$logfile"
cd $(dirname $potfile)
inf="$(LANG=en_US.utf8 svn info -r PREV $(basename $potfile))"
revision=$(echo "$inf"|grep "^Revision:")
prevrev=$(echo "$inf"|grep "^Last Changed Rev:")
revision=$((${revision#*: }+1))
prevrev=${prevrev#*: }
webaddress="$webaddress?rev=$revision&r1=$prevrev&r2=$revision"

$browsercmd $webaddress
