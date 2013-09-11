#!/usr/bin/bash                                                                  
################################################################################ 
# Decrypt pdf file and join to one
#                                                                                
# History:                                                                       
#        2013/09/11 Dennis Create                                                
################################################################################ 

############################################################
# Checks the dependencies
############################################################
DEPS=(qpdf pdftk)

for x in "${DEPS[@]}" ; do
	whereis $x >/dev/null 2>&1
	if [  $? != 0  ] ; then
		echo "Failed! "$x" not found"
		exit 0
	fi
done

############################################################
# Decrypt pdf file
############################################################
i=0
for j in *.pdf
do
	i=$(( i + 1 ))
	# add 1000 to make the new file name sequence, special 
	# for command 'pdftk *.pdf ...'
	file_name=$(( i + 1000 ))
	# qpdf --password= --decrypt encrypted.pdf decrypted.pdf
	# for empty password 
	qpdf --decrypt $j $file_name.dpdf
done

############################################################
# Join to one
############################################################
pdftk *.dpdf cat output one.pdf

############################################################
# Clean temperate file
############################################################
rm *.dpdf

