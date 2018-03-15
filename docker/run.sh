#!/bin/bash

arguapppath=/var/www/argusapp/
argusphonepath=/var/www/argusphone/
cd /argus-web/app 
sh /argus-web/changehost.sh $1 $arguapppath
cnpm run build && mv dist/ /var/www/argusapp/
cd /argus-web/app_phone
sh /argus-web/changehost.sh $1 $argusphonepath
cnpm run build && mv dist/ /var/www/argusphone/
nginx -g "daemon off;"
