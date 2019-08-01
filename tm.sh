#!/bin/bash

path=$1
channel=$2
value=`sed ':a ; N;s/\n/\\n/; t a ;' $1`
##取当前时间戳, 每key为5秒; key=app_channel_timestamp； 每个ky期间5小时
p1=`date +%s`
p2=$(((${p1}/5)*5))
key=$2_$p2
p3=`redis-cli set $key "$value" ex 72000`
echo $p3
