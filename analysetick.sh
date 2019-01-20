#!/bin/sh
#Delete old console.log
rm "/home/jacob/CSGODemo/condump"

sleep 2
wmctrl -a Counter
xte 'key Return'
sleep 2
xte 'key k'
sleep 50
xte 'key l'
sleep 10

cp "/home/jacob/.steam/steam/steamapps/common/Counter-Strike Global Offensive/csgo/console.log" "/home/jacob/CSGODemo/condump"

/home/jacob/CSGODemo/processdump "$1"

sleep 5
