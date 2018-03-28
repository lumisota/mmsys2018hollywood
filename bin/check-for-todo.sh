#!/bin/sh

if [ "$1" = "" ]; then
 echo "usage: bin/check-for-todo.sh <file> ..."
 exit
fi
 
egrep -H -i -n --color "\\\\todo\\{" $* | grep -v ".*%.*\\\\todo" || true
egrep -H -i -n --color "FIXME"       $* | grep -v ".*%.*\\\\todo" || true
