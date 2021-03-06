#!/bin/bash

target_video_size_MB="50"
origin_duration_s=$(ffprobe -v error -show_streams -select_streams a "$1" | grep -Po "(?<=^duration\=)\d*\.\d*")
origin_audio_bitrate_kbit_s=$(ffprobe -v error -pretty -show_streams -select_streams a "$1" | grep -Po "(?<=^bit_rate\=)\d*\.\d*")
target_audio_bitrate_kbit_s=$origin_audio_bitrate_kbit_s # TODO for now, make audio bitrate the same
target_video_bitrate_kbit_s=$(\
    awk \
    -v size="$target_video_size_MB" \
    -v duration="$origin_duration_s" \
    -v audio_rate="$target_audio_bitrate_kbit_s" \
    'BEGIN { print  ( ( size * 8192.0 ) / ( 1.048576 * duration ) - audio_rate ) }')

ffmpeg \
    -y \
    -i "$1" \
    -c:v libvpx-vp9 \
    -b:v "$target_video_bitrate_kbit_s"k \
    -pass 1 \
    -an \
    -f mp4 \
    /dev/null \
&& \
ffmpeg \
    -i "$1" \
    -c:v libvpx-vp9 \
    -b:v "$target_video_bitrate_kbit_s"k \
    -pass 2 \
    -c:a libopus \
    -b:a "$target_audio_bitrate_kbit_s"k \
    "${1%.*}-$target_video_size_MBmB.webm"