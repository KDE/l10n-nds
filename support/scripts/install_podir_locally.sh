#! /bin/bash
# To be called by KBabel Catalogmanager

logfile=${TEMP:-$TMP}
logfile=${logfile:-$HOME}
logfile="$logfile/kbabel_install_podir.log"

retval=0

exec 2>"$logfile"
echo "$(basename $0) $@" >> "$logfile"
for f in $@
do	target="$(basename $f)"
	target="${target/.po/.mo}"
	test -r "$f" && msgfmt -o $HOME/.kde/share/locale/nds/LC_MESSAGES/"$target" "$f" ||
	{	echo "Fehler bi $f" >> "$logfile"
		retval=1
	}
done
exit $retval
