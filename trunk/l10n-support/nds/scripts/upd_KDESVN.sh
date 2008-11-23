#!/bin/bash

test -z "$KDESVN" && {
	echo "Environment variable KDESVN not set or empty. Exiting."
	exit 1
}

test -n "$1" && test "$1" != "--no-commit" -a "$1" != "--help" -a "$1" != "-h" && {
	echo -e "\aUnknown option: $1"
	set "--help"
}

test "$1" = "--help" -o "$1" = "-h" && {
	echo "Usage: $0 [--help|-h|--no-commit]"
	echo "--help | -h	Show this help message"
	echo "--no-commit	Only update svn trees and merge changes into l10n-support, but do not commit"
	exit 0
}

cd $KDESVN/branches/stable
svn update l10n{,-kde4}/{nds,scripts,templates/messages} || exit 1
revstable=$(svn stat -vN l10n-kde4/nds | sed -ne 's/ *\([0-9]\+\).*nds$/\1/p')
cd $KDESVN/trunk
svn update l10n-kde{3,4}/{nds,scripts,templates/messages} || exit 2
revtrunk=$(svn stat -vN l10n-kde4/nds | sed -ne 's/ *\([0-9]\+\).*nds$/\1/p')
cd l10n-support
svn update nds scripts pology templates/summit/messages || exit 3
nice -n 15 posummit.py $KDESVN/trunk/l10n-support/scripts/messages.summit nds merge || exit 4
test "$1" = "--no-commit" || {
	svn commit -m "Scripted merge of stable rev. $revstable and trunk rev. $revtrunk" nds
}
