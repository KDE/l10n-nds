#!/bin/bash

test -z "$1" -o -z "$2" -o -z "$3" && {
	echo -e "Nich noog Argumenten.\n Bruuk: $(basename $0) <Söökwoort> <Tuuschwoort> <Sekerkopie-Verwiedern>\n Bispill: $(basename $0) Funktschoon Funkschoon .Funktschoon.bak"
	exit 1
}
expr "$1$2" : ".*@" > /dev/null && {
#	echo "De Argumenten mööt keen Klammerapen ('@') bargen."
#	exit 1
	een="${1//@/\\@}"
	twee="${2//@/\\@}"
	set $een $twee $3
}

#pushd /home/soe/l10n/nds/messages
expr "$(pwd)" : ".*/nds.*/messages" > /dev/null || {
	echo "Föhr dissen Befehl bitte bloots binnen en KDE-SVN-Orner för nds ut!"
	exit 1
}

filelist=$(find . -name "*.po")
for fil in $filelist
do	grep -lq "$1" $fil && {
		echo "$fil warrt ännert."
		sed -i$3 -e "s@$1@$2@g" $fil
		sed -i -e "/PO-Revision-Date/s/200.*/$(date "+%F %H:%M%z\\\n\"")/" $fil
	}
done
#popd