#!/bin/bash

test -z "$KDESVN" && {
	echo "Environment variable KDESVN not set or empty. Exiting."
	exit 1
}

while test -n "$1"
do	case "$1" in
		--help|-h) dohelp=yes ;;
		--all) scatterall=yes ;;
		--*) echo -e "\aUnknown option: $1"; dohelp=yes ;;
		*) commitmsg="$@"; break ;;
	esac
	shift
done

test -n "$dohelp" && {
	echo "Usage: $(basename $0) [[--help|-h]|[--all] [<commit message>]]"
	echo "--help | -h	Show this help message"
	echo "--all		Scatter all PO-files, not only those svn identifies as 'Added' or 'Modified'"
	echo "<commit message>	Message to write into l10n-support commit log"
	exit 0
}

msgroot=$KDESVN/trunk/l10n-support
cd $msgroot/nds/summit/messages

svnstat=$(svn stat)
echo "$svnstat"

changed=$(echo "$svnstat" | grep '^?')
for f in $(echo "$changed"|sed -e 's/\? \+//')
do	test -d "$f" && test -d "$msgroot/templates/summit/messages/$f" && svn add "$f" && svnstat=$(svn stat) && continue
	if [ -f $msgroot/templates/summit/messages/${f}t ]
	then	svn add $f && svnstat=$(svn stat)
	else	echo "l10n-support/templates/summit/messages/${f}t not found - skipped."
	fi
done

test -n "$scatterall" || {
	changed=$(echo "$svnstat" | grep '^A')
	for f in $(echo "$changed"|sed -e 's/^A \+//')
	do	test "${f%.po}" = "$f" || to_scatter="$to_scatter $(basename ${f%.po})"
	done

	changed=$(echo "$svnstat" | grep '^M')
	for f in $(echo "$changed"|sed -e 's/^M \+//')
	do	to_scatter="$to_scatter $(basename ${f%.po})"
	done
}

echo "posummit.py $KDESVN/trunk/l10n-support/scripts/messages.summit nds scatter $to_scatter"

posummit.py $msgroot/scripts/messages.summit nds scatter $to_scatter && {
	cd $KDESVN/branches/stable/l10n-kde4
	confl_stable="$(svn update templates/messages nds)"
	echo "Update stable:"
	echo "$confl_stable"
	confl_stable="$(echo "$confl_stable" | grep '^C')"
	cd $KDESVN/trunk/l10n-kde4
	confl_trunk="$(svn update templates/messages nds | grep '^C')"
	echo "Update trunk:"
	echo "$confl_trunk"
	confl_trunk="$(echo "$confl_trunk" | grep '^C')"
	test -n "$confl_stable$confl_trunk" && echo -e "Conflicts:\n$confl_stable\n$confl_trunk" || {
		echo "No conflicts. Committing."
		cd $msgroot/nds/summit/messages
		echo "svn commit -m '${1:-Translation and maintainance}':"
		crev=$(svn commit -m "${1:-Translation and maintainance}")
		echo "$crev"
		crev="$(echo "$crev" | grep -o '[0-9]\{6,7\}')"
		cd $KDESVN/trunk/l10n-kde4
		echo "svn commit -m 'Scattered changes from trunk revision $crev.'"
		svn commit -m "Scattered changes from trunk revision $crev." nds/messages
		cd $KDESVN/branches/stable/l10n-kde4
		echo "svn commit -m 'Scattered changes from stable revision $crev.'"
		svn commit -m "Scattered changes from stable revision $crev." nds/messages
	}
}
