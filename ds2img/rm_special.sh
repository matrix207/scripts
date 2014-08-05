#!/bin/bash

filename=$1

# replace "} __packed;" with "};"
sed -i 's/}.*packed;/};/' $filename

# delete \t or space at the end
sed -i 's/[ \t]*$//' $filename

# TODO:replace [NO_DIGITS] with []
#sed -i 's/\[[^0-9*]\]/\[\]/' $filename

#
#struct {
#	unsigned ahslength : 8;
#	unsigned datalength : 24;
#} length;
sed -i '/.*struct {/d' $filename
sed -i '/.*} .*;/d' $filename

# replace multi tab to one
sed -i 's/\t\t*/\t/' $filename
