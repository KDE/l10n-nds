#!/bin/bash

test -z "$KDESVN" && {
  echo "Environment variable KDESVN not set or empty. Exiting."
  exit 1
}

while test -n "$1"
do	case "$1" in
		--commit) commit=yes ;;
		--help|-h) dohelp=yes ;;
		*) echo -e "\aUnknown option: $1"; dohelp=yes ;;
	esac
	shift
done

test -n "$dohelp" && {
  echo "Usage: $(basename $0) [--help|-h|--commit]"
  echo "Updates SVN trees and merges changes into l10n-support."
  echo "--help | -h	Show this help message"
  echo "--commit	Commit the changes to l10n-support after updating and merging"
  exit 0
}

cd $KDESVN/branches/stable
svn update l10n{,-kde4}/{nds,scripts,templates/messages} || exit 128
revstable=$(svn stat -vN l10n-kde4/nds | sed -ne 's/ *\([0-9]\+\).*nds$/\1/p')
cd $KDESVN/trunk
svn update l10n-kde{3,4}/{nds,scripts,templates/messages} || exit 129
revtrunk=$(svn stat -vN l10n-kde4/nds | sed -ne 's/ *\([0-9]\+\).*nds$/\1/p')
cd l10n-support
svn update nds scripts pology templates/summit/messages || exit 130
nice -n 15 posummit.py $KDESVN/trunk/l10n-support/scripts/messages.summit nds merge || exit 4
test -n "$commit" && {
  svn commit -m "Scripted merge of stable rev. $revstable and trunk rev. $revtrunk" nds
}
