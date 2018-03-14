#!/bin/sh
absfilepath=$1
echo $absfilepath
sed -e "s#mylocal#${API_HOST}#" $absfilepath/HOST.js > $absfilepath/HOST2.js
mv $absfilepath/HOST2.js $absfilepath/HOST.js
