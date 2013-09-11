#!/usr/bin/bash                                                                  
################################################################################ 
# Auto-download file by wget
#                                                                                
# History:                                                                       
#        2013/09/11 Dennis Create                                                
################################################################################ 

url_pre="http://testsite.com/pdf/name3700"

i=10

while [ $i -lt 70 ]
do
	url=$url_pre"$i"".pdf"
	echo wget $url
	wget $url
	i=$(( i + 1 ))
done

