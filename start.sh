#!/bin/bash

IFS=$'\n'

#screen -S "youtube-upload" -d -m /home/jacob/CSGODemo/youtubeupload.sh

cd /home/jacob/CSGODemo
function initialise {
	bootstrap="/home/jacob/.steam/steam/logs/bootstrap_log.txt"
	rm $bootstrap
	screen -S "SteamClient" -d -m steam -login [username] [password]
	loopvar="0"
	while  [ "$loopvar" -eq "0" ]
	do
	if [ ! -f "$bootstrap" ]
	then 
	sleep 1 
	else
	for i in $(cat "$bootstrap"); do
		if [[ "$i" == *"Verification complete"* ]]
		then
		loopvar="1"
		echo "Steam Loaded!"
		fi	
	done
	sleep 2 
	fi
	done
	screen -S "SimpleScreenRecorder" -d -m simplescreenrecorder

	sleep 30
	rm "/home/jacob/.steam/steam/steamapps/common/Counter-Strike Global Offensive/csgo/console.log"

	screen -S "csgo" -d -m ssr-glinject /home/jacob/.steam/steam/steamapps/common/Counter-Strike\ Global\ Offensive/csgo.sh -steam -high -novid -windowed -w 1280 -h 720 -condebug +exec autoexec.cfg +map waitmap

	consolefile="/home/jacob/.steam/steam/steamapps/common/Counter-Strike Global Offensive/csgo/console.log"
	mysql -D csgopovs -ss -N -e "delete from lastdemo;"
	loopvar="0"
	while  [ "$loopvar" -eq "0" ]
	do
	if [ ! -f "$consolefile" ]
	then 
	sleep 1 
	else
	for i in $(cat "$consolefile"); do
		if [[ "$i" == *"Map: waitmap"* ]]
		then
		loopvar="1"
		echo "Loaded!"
		fi	
	done
	sleep 2 
	fi
	done
	sleep 5
}

initialise
while true
do


newdemo=$(mysql -D csgopovs -ss -N -e "select MIN(id) from queue;")
if [ "$newdemo" == "NULL" ]
then
echo "No files added to queue"
else

	if [ -f "/home/jacob/CSGODemo/demo.dem" ]; then  rm -f "/home/jacob/CSGODemo/demo.dem"; fi
	if [ -f "/home/jacob/CSGODemo/demo.vdm" ]; then  rm -f "/home/jacob/CSGODemo/demo.vdm"; fi
	#Get tick info and create VDM File
	demoname=$(mysql -D csgopovs -ss -N -e "select demoname from queue where id = $newdemo;")
	playername=$(mysql -D csgopovs -ss -N -e "select player from queue where id = $newdemo;")
	#getting playername using hex to avoid encoding issues with mysql/texteditor
	hexval=$(mysql --default-character-set=utf8 -D csgopovs -ss -N -e "select hex(player) from queue where id = $newdemo;")
	hex=$(echo "737065635f706c617965725f62795f6e616d652022$hexval" | sed 's/../&\\x/g')
	playerinput=$(echo "$hexval" | sed 's/../&\\x/g')
	
	if [ "${hex: -2}" == "\x" ] #remove trailing \x if exists
	then
		hex=${hex:: -2}
	fi
	
	if [ "${playerinput: -2}" == "\x" ]
	then
		playerinput=${playerinput:: -2}
	fi

	
	hltvid=$(mysql -D csgopovs -ss -N -e "select hltvid from queue where id = $newdemo;")
	lastdemo=$(mysql -D csgopovs -ss -N -e "select demoname from lastdemo;")
	title=$(mysql -D csgopovs -ss -N -e "select title from queue where id = $newdemo;")
	
	if [ "$title" == "NULL" ]
	then
	title="$playername-vs-$demoname"
	fi
	
	cp "/var/www/html/demo/$demoname" "/home/jacob/CSGODemo/demo.dem"
	if [ "$lastdemo" == "$demoname" ]
	then
	/home/jacob/CSGODemo/processdump "\x$playerinput"
	else
	/home/jacob/CSGODemo/analysetick.sh "\x$playerinput"
	fi
	echo -n -e "\x$hex\x22" > "/home/jacob/.steam/steam/steamapps/common/Counter-Strike Global Offensive/csgo/cfg/specplayer.cfg"
	/home/jacob/CSGODemo/startrecord.sh
	filebase=$(basename "$demoname" .dem)
	filename=$(ls Records)
	length=$(ffprobe -i "Records/$filename" -show_format -v quiet | sed -n 's/duration=//p')
	length=$(printf '%.*f' 0 "$length")

	 if [[ $length -lt 100 ]]
        then
        echo "error with recording, re-initialising..."
		rm /home/jacob/CSGODemo/Records/*
		screen -X -S "csgo" quit
		screen -X -S "SteamClient" quit
		screen -X -S "SimpleScreenRecorder" quit
		sleep 5
		initialise
		else

	#ffmpeg -i "Records/$filename" -c:v libx264 -b:v 5000k -minrate 4500k -maxrate 5500k -bufsize 5000k -c:a copy  "Records/output.mp4";mv "Records/output.mp4" "saved/$playername-Vs-$filebase.mp4"
	#youtube-upload --title="$playername Vs $filebase" "Records/output.mp4" #remember to change this if no ffmpeg
	mysql -D csgopovs -ss -N -e "delete from queue where id = $newdemo"
	mysql -D csgopovs -ss -N -e "INSERT INTO complete (demoname, player, hltvid, title) VALUES ('$demoname', '$playername', '$hltvid', '$title')"
	mysql -D csgopovs -ss -N -e "delete from lastdemo"
	mysql -D csgopovs -ss -N -e "insert into lastdemo (demoname) values ('$demoname');"
	mv "Records/$filename" "saved/$title.mp4"
	fi
	rm /home/jacob/CSGODemo/Records/*
	#scp "Records/$playername_Vs_$filebase.mp4" admin@192.168.0.4:~/
	fi
	
sleep 10	
done
