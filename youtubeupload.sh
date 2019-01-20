#!/bin/bash


while true
do
for filename in /home/jacob/CSGODemo/saved/*
do
if [ "$filename" != "/home/jacob/CSGODemo/saved/*" ]
	then

	name=$(basename "$filename")
	name="${name%.*}"
	hltvid=$(mysql -D csgopovs -ss -N -e "select hltvid from complete where title='$name';")
	vidid=$(mysql -D csgopovs -ss -N -e "select id from complete where title='$name' and hltvid='$hltvid';")
 	youtubeid=$(youtube-upload --description="If there is a problem with this video please alert me - http://jacobisme.me/CSGODemo/alert.php?id=$vidid" --title="$name" "$filename") #remember to change this if no ffmpeg
 	mysql -D csgopovs -ss -N -e "update complete set youtubeid='$youtubeid' where title='$name' and hltvid='$hltvid'"
	rm "$filename"
	
 	fi
done
sleep 30
done
