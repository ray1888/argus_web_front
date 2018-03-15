#!/bin/sh
Host=$1
absfilepath=$2
echo $absfilepath
sed -e "s#mylocal#$1#g" $absfilepath/HOST.js > $absfilepath/HOST2.js
mv $absfilepath/HOST2.js $absfilepath/HOST.js