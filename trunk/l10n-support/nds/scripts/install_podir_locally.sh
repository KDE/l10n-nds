#! /bin/bash
exec 2>/home/soe/inst_podir.log
retval=0
echo "$(basename $0) $@" > /home/soe/temp/inst_podir.log
for f in $@
do	target="$(basename $f)"
	target="${target/.po/.mo}"
	test -e "$f" && msgfmt -fo /home/soe/.kde/share/locale/nds/LC_MESSAGES/$target $f \
	    || {	echo "Error: $f" >> /home/soe/temp/inst_podir.log
			retval=1
		}
done
exit $retval
