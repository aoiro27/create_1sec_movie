#!/bin/bash
mkdir tmp
i=0
for file in *.MOV
do
    ((i++))
    base=$(basename "$file" .MOV)
    ffmpeg -i "$base.MOV" -ss 00:00:00.000 -t 00:00:03.000 "tmp/$base.conv.MOV"

    echo "file $base.conv.MOV" >> tmp/config   

done

time=$(printf "00:00:%02d.000\n" $(($i*3)))


ffmpeg -f concat -i tmp/config -c copy tmp/outfile_1.mp4
ffmpeg -i tmp/outfile_1.mp4 -i bgm.mp3 -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 tmp/outfile_2.mp4

# 音声が付いてサイズが延びてるのでトリミング
ffmpeg -i tmp/outfile_2.mp4 -ss 00:00:00.000 -t "$time" "tmp/outfile_3.mp4"

# フェードイン/フェードアウトをつける
ffmpeg -i tmp/outfile_3.mp4 -vf "fade=t=in:st=0:d=1,fade=t=out:st=$((i*3-3)):d=3" tmp/outfile_4.mp4
ffmpeg -i tmp/outfile_4.mp4 -af "afade=t=out:st=$((i*3-3)):d=3" tmp/outfile_5.mp4

# フォントを埋め込む
ffmpeg -i tmp/outfile_5.mp4 -filter_complex "drawtext=fontfile=./font.ttc:text=2023 Apr-Jun:enable='between(t,0,3)':x=(w-text_w)/2:y=(h-text_h-line_h)/2:fontcolor=white:fontsize=80" tmp/outfile_6.mp4

# ロゴを最後に埋め込む
ffmpeg -i tmp/outfile_6.mp4 -i logo.png -filter_complex "overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2:enable='between(t,$((i*3-1)),$((i*3)))'" brainco_1秒動画.mp4

rm -rf tmp
