#!/bin/bash

file="info.html"
host="localhost"

while [ true ]
do
  read a
  a=`echo ${a} | sed 's/\r//'`
  if [ "${a}" == "" ]
  then
    break
  fi
  command=`echo ${a} | grep Host:`
  if [ "${command}" != "" ]
  then
    host=`echo ${a} | awk '{ print $2 }'`
  fi
done


len=`ls -la ${file} | awk '{ print $5 }'`
echo "HTTP/1.1 200 OK"
echo "Host: ${host}"
echo "Content-Length: ${len}"
echo ""
cat ${file}
rm ${file}
