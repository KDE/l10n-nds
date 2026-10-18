#!/bin/bash

localedef -f ISO-8859-1 -i nds_DE nds/nds_DE/
localedef -f ISO-8859-15 -i nds_DE@euro nds/nds_DE@euro/
localedef -f UTF-8 -i nds_DE nds/nds_DE.utf8
