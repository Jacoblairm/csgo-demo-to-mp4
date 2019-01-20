#!/bin/bash
IFS=$'\n'
rm /home/jacob/CSGODemo/Records/*
wmctrl -a Counter
sleep 10
xte 'key j'
sleep 30
xte 'key h'
sleep 2
xte 'key g'
xte 'key m'
wmctrl -a Counter
sleep 1
xte 'key f'

trimvar="-1"
linenumber="1"
linenumber1="1"
while [ "$trimvar" -eq "-1" ]; do
	for i in $(cat "/home/jacob/.steam/steam/steamapps/common/Counter-Strike Global Offensive/csgo/console.log"); do
		if [[ "$i" == *"DemoStartRe4cord12"* ]]
		then
		trimvar="$linenumber"
		fi
		linenumber=$(($linenumber+1))	
	done
done


loopvar=0
while [ "$loopvar" -eq "0" ]; do
	tail -n+$trimvar "/home/jacob/.steam/steam/steamapps/common/Counter-Strike Global Offensive/csgo/console.log" > "/home/jacob/CSGODemo/teststart" 

	for i in $(cat "/home/jacob/CSGODemo/teststart" ); do
		if [[ "$i" == *"Demo playback finished"* ]]
		then
		loopvar=1
		fi
		linenumber1=$(($linenumber1+1))
	done
	
	xte 'key f'
	sleep 1
done

rm "/home/jacob/CSGODemo/teststart"
wmctrl -a Counter
xte 'key m'
sleep 2
wmctrl -a Counter
sleep 5
wmctrl -a Counter
sleep 2
xte 'str hideconsole'
xte 'key Return'
sleep 1
xte 'str `'
sleep 0.5
xte 'str disconnect'
xte 'key Return'
sleep 5
xte 'str hideconsole'
xte 'key Return'
sleep 1
xte 'str `'
sleep 0.5
xte 'str finish'
sleep 0.1
xte 'key Return'
wmctrl -a Counter

