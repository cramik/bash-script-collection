mkdir stabilized
list=`find $FILE_PATH -iname "*.mp4"`
for f in $list
do
	echo DOING: $f
	ffmpeg -i "$f" -vf vidstabdetect -f null -
	ffmpeg -i "$f" -vf vidstabtransform "stabilized/${f%.*}-stabilized.mp4" -y
done