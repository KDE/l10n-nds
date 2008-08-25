#!/bin/bash

status=$(msgfmt --statistics -cvo /dev/null $1 2>&1)
kdialog --msgbox "$status"
