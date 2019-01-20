#!/bin/bash

hexval=$(mysql --default-character-set=utf8 -D csgopovs -ss -N -e "select hex(player) from complete where id='116';")
hex=$(echo "737065635f706c617965725f62795f6e616d6520$hexval" | sed 's/../&\\x/g')
playerinput=$(echo "$hexval" | sed 's/../&\\x/g')
if [ "${hex: -2}" == "\x" ]
then
hex=${hex:: -2}
fi

if [ "${playerinput: -2}" == "\x" ]
then
playerinput=${playerinput:: -2}
fi

#echo -n -e "\x$hex" > rsg

player=$(echo -e "\x$playerinput")
echo $player