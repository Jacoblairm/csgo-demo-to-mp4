#!/bin/bash
filename=$(ls Records)
youtube-upload --title="Hello" "Records/$filename"
echo "$filename"
