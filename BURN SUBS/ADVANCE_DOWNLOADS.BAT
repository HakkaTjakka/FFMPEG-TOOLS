@echo off
set PATH=%CD%\BIN\FFMPEG_NEW;%CD%\BIN;%PATH%
setlocal ENABLEDELAYEDEXPANSION

for /F "tokens=*" %%A in (list.txt) do (
	echo Downloading from YouTube: %%A
	youtube-dl --restrict-filenames --abort-on-error --no-mtime --sub-lang "en,nl" --write-sub --convert-subs srt --write-auto-sub --download-archive ARCHIVE.TXT --skip-unavailable-fragments --write-thumbnail --write-info-json --geo-bypass "%%A"

)
pause
exit /b
