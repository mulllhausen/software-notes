#!/bin/bash

# keep the video the same and recode the audio to mp3 192kbps
#ffmpeg -i "$1" -acodec mp3 -b:a 192k -sn -vcodec copy "audio-recoded $1"

# convert video from mkv to mp4 without re-encoding
#ffmpeg -i "$1" -codec copy "$1.mp4"

# scale to 576p (height) while keeping the aspect ratio and same encoder. this
# is probably as small as my tv can go before quality becomes noticably bad.
# also convert audio to 192kbps mp3
# -sn = remove subs
#ffmpeg -i "$1" -acodec mp3 -b:a 192k -vf scale=-2:576 -sn "560p-$1"

# convert video to a version of h264 that plays on my tv and audio
#ffmpeg -i "$1" -acodec mp3 -b:a 192k -vcodec libx264 -sn "x264-$1.mp4"

if false;then
for f in *.mkv;do
    echo
    echo
    echo "encoding $f (pass 1)"
    date
    echo
    echo

    # desired filesize = 328MB = 328 * 8192 = 2686976 KB
    # desired bitrate = 2686976 KB / 52min43s = 2686976 / 3163 = 849kbps
    # now do 2 passes at this bitrate (http://trac.ffmpeg.org/wiki/Encode/H.264#Two-PassExample):
    ffmpeg -y -i "$f" -c:v libx264 -preset slow -b:v 850k -pass 1 -passlogfile "$f" -an -f mp4 /dev/null

    if [[ $? != 0 ]]; then
        echo
        echo
        echo "failed to encode $f - skip to next file without doing pass 2"
        continue
    fi

    echo
    echo
    echo "encoding $f (pass 2)"
    date
    echo
    echo
    ffmpeg -y -i "$f" -c:v libx264 -preset slow -b:v 850k -pass 2 -passlogfile "$f" -c:a mp3 -b:a 192k "2pass-$f.mp4"

    echo
    echo
    echo "finished"
    date

done
fi

# extract subs track $2 from file $1 (the count starts from 0)
ffmpeg -i "$1" -map 0:s:$2 "$1-track$2.srt"
