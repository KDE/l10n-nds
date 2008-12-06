#!/bin/bash

test -z "$KDESVN" && {
	echo "Environment variable KDESVN not set or empty. Exiting."
	exit 1
}

test -n "$1" && test "$1" != "--all" -a "$1" != "--help" -a "$1" != "-h" && {
	echo -e "\aUnknown option: $1"
	set 'help'
}

test "$1" = "--help" -o "$1" = "-h" -o "$1" = "help" && {
	echo "Usage: $(basename $0) [--help|-h|--all]"
	echo "--help | -h	Show this help message"
	echo "--all		Scatter all PO-files, not only those svn identifies as 'Added' or 'Modified'"
	exit 0
}

cd $KDESVN/trunk/l10n-support/nds/summit

svnstat=$(svn stat)
echo "$svnstat"

changed=$(echo "$svnstat" | grep '^?')
for f in $(echo "$changed"|sed -e 's/\? \+//')
do	test -d "$f" && test -d "../../templates/summit/$f" && svn add "$f" && svnstat=$(svn stat) && continue
	if [ -f ../../templates/summit/${f}t ]
	then	svn add $f && svnstat=$(svn stat)
	else	echo "l10n-support/templates/summit/${f}t not found - skipped."
	fi
done

test "$1" = "--all" && shift || {
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

posummit.py $KDESVN/trunk/l10n-support/scripts/messages.summit nds scatter $to_scatter && {
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
		cd $KDESVN/trunk/l10n-support/nds/summit/messages
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
