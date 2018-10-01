# files on ntfs drives cannot be made executable. however they can be run like so:
# bash file.sh

# generate a list of all drive contents (in alphabetical order) into a file
echo -e "# list of movies\n" > movies_list.txt
for f in */*;do echo ${f##*/} >> movies_list.txt;done

# generate a list of all drive contents (in order of latest update) into a file
ls -t */* > newest.txt

# generate a list of all movies that require testing to see if the tv will play them
ls -1 */*test* > test.txt

# generate a list of all low quality movies
ls -1 */*lowquality* > lowquality.txt

# generate a list of files (not dirs) with the largest size first
du -ah * | grep -E "\..{3}$" | sort -rh > largest.txt

# generate a lsit of files with their metadata
echo "filename,size,duration,vformat,audio format,v profile,video library,v bitrate,v dims,aud profile,audio lib,aud bitrate" > stats.csv
for f in *;do
    echo -n "\"$f\"" | sed 's/,/;/g' >> stats.csv
    echo -n "," >> stats.csv
    mediainfo --Inform="file:///mediainfo.template" "$f" >> stats.csv
done
cat stats.csv | column -tns, > stats.columns

# copy to clipboard (use middle click to paste)
cat movies_list.txt | xclip
