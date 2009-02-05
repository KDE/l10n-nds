#!/bin/bash

# set -x
posummitpy=trunk/l10n-support/pology/scripts/posummit.py
upd_stable='l10n{,-kde4}/{documentation,nds,scripts,templates/{,doc}messages}'
upd_trunk='l10n-kde{3,4}/{documentation,nds,scripts,templates/{,doc}messages}'
upd_support='nds scripts pology templates/summit/{,doc}messages'

test -z "$KDESVN" && {
  echo "Environment variable KDESVN not set or empty. Exiting."
  exit 1
}

while test -n "$1"
do	case "$1" in
		--commit)	docommit=yes ;;
		--help|-h)	dohelp=yes ;;
		--gui-only)	upd_stable='l10n{,-kde4}/{scripts,{nds,templates}/messages}'
				upd_trunk='l10n-kde{3,4}/{scripts,{nds,templates}/messages}'
				upd_support='scripts pology {nds,templates}/summit/messages'
				onlygui=yes ;;
		--doc-only)	upd_stable='l10n{,-kde4}/{documentation,scripts,nds/doc{s,messages},templates/docmessages}'
				upd_trunk='l10n-kde{3,4}/{documentation,scripts,nds/doc{s,messages},templates/docmessages}'
				upd_support='scripts pology {nds,templates}/summit/docmessages'
				onlydoc=yes ;;
		*) echo -e "\aUnknown option: $1"; dohelp=yes ;;
	esac
	shift
done

test -n "$dohelp" && {
  echo "Usage: $(basename $0) [--help|-h|--commit]"
  echo "Updates SVN trees and merges changes into l10n-support."
  echo "--help | -h	Show this help message"
  echo "--commit	Commit the changes to l10n-support after updating and merging"
  echo "--gui-only	Only update and process GUI messages"
  echo "--doc-only	Only update and process documentation messages"
  exit 0
}

cd $KDESVN/branches/stable
eval svn update $upd_stable || exit 128
revstable=$(svn stat -vN l10n-kde4/nds | sed -ne 's/ *\([0-9]\+\).*nds$/\1/p')
cd $KDESVN/trunk
eval svn update $upd_trunk || exit 129
revtrunk=$(svn stat -vN l10n-kde4/nds | sed -ne 's/ *\([0-9]\+\).*nds$/\1/p')
cd l10n-support
eval svn update $upd_support || exit 130
test -z "$onlydoc" && { nice -n 15 $KDESVN/$posummitpy $KDESVN/trunk/l10n-support/scripts/messages.summit nds merge || exit 4; }
test -z "$onlygui" && { nice -n 15 $KDESVN/$posummitpy $KDESVN/trunk/l10n-support/scripts/docmessages.summit nds merge || exit 5; }
test -n "$docommit" && {
  svn commit -m "Scripted merge of stable rev. $revstable and trunk rev. $revtrunk" nds
}
