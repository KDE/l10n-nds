#!/bin/bash

function getMetaData() {
	totl=$(msgattrib --no-obsolete -o - $1 |grep -c "^msgid ")
	fuzz=$(msgattrib --only-fuzzy -o - $1 |grep -c "^msgid ")
	utrl=$(msgattrib --untranslated -o - $1 |grep -c "^msgid ")
	((--totl))
	test $fuzz -ne 0 && ((--fuzz))
	test $utrl -ne 0 && ((--utrl))
}

test -z "$KDESVN" && {
	echo "Environment variable KDESVN not set or empty. Exiting."
	exit 1
}

while test -n "$1"
do	case "$1" in
		--help|-h) dohelp=yes ;;
		-*) echo -e "\aUnknown option: $1"; dohelp=yes ;;
		*) test -f "$1" && pofiles[${#pofiles[@]}]="$1" || { echo -e "\aNot a file: $1"; dohelp=yes; } ;;
	esac
	shift
done

test -n "$dohelp" && {
	echo "Usage: $(basename $0) [--help|-h|<file> [<file2> ...]]"
	echo "--help | -h	Show this help message"
	echo "<file>		File containing new translations. Tar.gz files get untarred."
	exit 0
}

for pofile in ${pofiles[@]}
do	test -n "$pofile" && {
		if [ "${pofile%.po}" != "$pofile" ]
		then	cp $pofile $KDESVN/trunk/l10n-support/nds
		elif [ "${pofile%.tar.gz}" != "$pofile" ]
		then	tmpdir=$(mktemp -d -p /tmp merge_pos_tmpls.XXXXXXXX)
			curwd=$(pwd)
			test "${pofile:0:1}" != "/" && pofile="$curwd/$pofile"
			cd $tmpdir
			echo "Unpacking $pofile..."
			tar -xzf $pofile
			for pof in $(find . -name '*.po');
			do	cp $pof $KDESVN/trunk/l10n-support/nds/$(basename $pof)
			done
			cd $curwd
			rm -r $tmpdir
		else	echo -e "\aDon't know how to handle »$pofile«."
		fi
	}
done

cd $KDESVN/trunk/l10n-support
if polist=$(ls nds/*.po 2>/dev/null)
then	for po_new in $polist
	do	pot_base="$(basename ${po_new}t)"
		pot="$(find templates/summit/messages -name "$pot_base")"
		test $(echo "$pot" | wc -l) -eq 1 || {
			echo -e "Multiple occurence of $pot_base:\n$pot\n$po_new skipped."
			continue
		}
		po_out="${po_new%.po}.new.po"
		po_old="${pot%t}"
		po_old="${po_old/templates/nds}"

		msgmerge -qo "$po_out" "$po_new" "$pot"
		getMetaData "$po_out"
		utrl_out=$utrl
		fuzz_out=$fuzz
		totl_out=$totl
		share_out=$(((utrl_out+fuzz_out)*10000/totl_out))
		echo -e "$po_out:\r\t\t\t\t\t\t\tT:$totl_out F:$fuzz_out U:$utrl_out -- $share_out"
		test -f "$po_old" && {
			getMetaData "$po_old"
			utrl_old=$utrl
			fuzz_old=$fuzz
			totl_old=$totl
			share_old=$(((utrl_old+fuzz_old)*10000/totl_old))
			echo -e "$po_old:\r\t\t\t\t\t\t\tT:$totl_old F:$fuzz_old U:$utrl_old -- $share_old"
			test $share_out -gt $share_old && {
				echo "Existing file has better translation shares. Skipped."
				continue
			}
		}

		test -d "$(dirname "$po_old")" || mkdir -p "$(dirname "$po_old")"
		mv "$po_out" "$po_old"
		rm "$po_new"
	done
else	echo "No PO files found in $KDESVN/trunk/l10n-support/nds/."
fi