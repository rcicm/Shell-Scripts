#!/bin/bash
##############################################################
# Script to execute a group of queries and generate some 
# output files.
# 
# 2013/01/03 - Rafael Campos
##############################################################

## query execution function
function queryexec {
        mysql -u username -pPASSWORD -h myhost.mysql.com DATABASE -e \"$1\" |sed 's/\t/;/g' >> $2
}

#oas_cadastro_anunciante
queryexec "SELECT * FROM MyTable" /tmp/outputfile.csv
