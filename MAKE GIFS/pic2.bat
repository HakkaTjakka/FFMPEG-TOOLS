ffmpeg -y -loop 1 -i "b (2).jpg" -t 0.5 -vf pad="width=ceil(iw/2)*2:height=ceil(ih/2)*2" "ct1.mp4"
ffmpeg -y -loop 1 -i "b (3).jpg" -t 0.5 -vf pad="width=ceil(iw/2)*2:height=ceil(ih/2)*2" "ct2.mp4"
ffmpeg -y -loop 1 -i "b (4).jpg" -t 1.0 -vf pad="width=ceil(iw/2)*2:height=ceil(ih/2)*2" "ct3.mp4"


echo file 'ct1.mp4' > mylist.txt
echo file 'ct2.mp4' >> mylist.txt
echo file 'ct3.mp4' >> mylist.txt
ffmpeg -y -safe 0 -f concat -i mylist.txt -c copy ct.mp4

ffmpeg -y -i "ct.mp4" -vf fps=30,palettegen "ct.png"
rem rem ffmpeg -y -i "b (3).jpg" -vf fps=30,palettegen "ct.png"
ffmpeg -y -i ct.mp4 -i ct.png -filter_complex "fps=10[x];[x][1:v]paletteuse" circus.gif
pause


