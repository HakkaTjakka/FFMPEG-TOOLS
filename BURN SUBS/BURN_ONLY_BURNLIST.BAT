@echo off
set PATH=%CD%\BIN;%PATH%
setlocal ENABLEDELAYEDEXPANSION

for /F "tokens=*" %%A in (burnlist.txt) do (
	echo Burning video file: %%A

	if exist "%%A"  (
		call :BURN_FILE "%%A"
	) else (
		echo does not exist: %%A
		pause
	)
)
pause
exit /b

:BURN_FILE
rem echo filename:  %1
rem echo extension: %~x1
rem 
rem set L=%~n1
rem echo l: %L%
rem echo videoname: %~n1
rem if exist "%1" (
rem 	echo file exist
rem ) else (
rem 	echo file does not exist
rem )
rem for /f "tokens=*" %%J in ('dir /b "%~n1.*.srt"') do (
rem 	echo subtitles: %%J
rem )
rem pause
rem exit /b

for /f "tokens=*" %%J in ('dir /b "%~n1.*.vtt"') do (
	if not exist "%%~nJ.srt" ffmpeg -i "%%J" "%%~nJ.srt"
)
for /f "tokens=*" %%J in ('dir /b "%~n1.*.srt"') do (
rem for /f "tokens=*" %%J in ('dir /b "%~n1.nl.srt"') do (
	if not exist "%%J.fixed" sof.exe "%%J"

	call :GET_LANGUAGE "%%~nJ"
	call :GET_BITRATE %1

	rem	ECHO LANGUAGE=!LANGUAGE!  BITRATE=!BITRATE!
	if not exist !LANGUAGE! mkdir !LANGUAGE!

	for %%X in ("%%J.fixed") do (
		if not %%~zX == 0 (
			if not exist "!LANGUAGE!/%~n1.!LANGUAGE!.mp4" (

				if not exist ADVANCE_STARTED.TXT (
					start cmd /k ADVANCE_DOWNLOADS.BAT
					echo STARTED > ADVANCE_STARTED.TXT
				)
rem REPLACE: -c:v h264_nvenc -profile:v high -pix_fmt yuv420p -bufsize 20M -bf:v 3 -crf 23 -preset slow -rc-lookahead 32
rem WITH: -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p
rem for non nvidia cards
				echo ffmpeg_new.exe -n -hide_banner -i %1 -map 0:v:0 -map 0:a:0 -strict -2 -filter_complex "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black,subtitles=f='%%J.fixed':force_style='FontName=Mada Black,FontSize=28,Shadow=2,BackColour=&H90000000,BorderStyle=4'" -c:s mov_text -c:v h264_nvenc -profile:v high -pix_fmt yuv420p -bufsize 20M -bf:v 3 -crf 23 -preset slow -rc-lookahead 32 -c:a copy "%~n1.!LANGUAGE!.mp4" > burn.!LANGUAGE!.bat 
				type burn.!LANGUAGE!.bat >> !LANGUAGE!/burn.!LANGUAGE!.bat
				ffmpeg.exe -y -hide_banner -i %1 -map 0:v:0 -map 0:a:0 -strict -2 -filter_complex "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black,subtitles=f='%%J.fixed':force_style='FontName=Mada Black,FontSize=28,Shadow=2,BackColour=&H90000000,BorderStyle=4'" -c:s mov_text -c:v h264_nvenc -profile:v high -pix_fmt yuv420p -bufsize 20M -bf:v 3 -crf 23 -preset slow -rc-lookahead 32 -c:a copy "!LANGUAGE!/%~n1.!LANGUAGE!.PART.mp4" 
				if exist "!LANGUAGE!\%~n1.!LANGUAGE!.PART.mp4" (
					echo Conversion ready: %1 >> burn.!LANGUAGE!.log
					rename "!LANGUAGE!\%~n1.!LANGUAGE!.PART.mp4" "%~n1.!LANGUAGE!.mp4"
				) else (
					echo Conversion failed: %1
					echo Conversion failed: %1 >> error.log
				)
			) else (
				echo Already exists: !LANGUAGE!/%~n1.!LANGUAGE!.mp4
				echo Already exists: !LANGUAGE!/%~n1.!LANGUAGE!.mp4 >> error.log
			)
		) else (
			echo Subtitle file empty: %%J.fixed
			echo Subtitle file empty: %%J.fixed >> error.log
		)
	)
)
if not exist ORIGINAL mkdir ORIGINAL
move "%~n1.*" ORIGINAL >NUL
echo -------------------------------------------------------------------------------------------------
exit /b


:GET_LANGUAGE
set LANGUAGE=%~x1
set LANGUAGE=!LANGUAGE:~1!
exit /b
	
:GET_BITRATE
bin\ffprobe.exe -v error -select_streams v:0 -show_entries format=bit_rate -of default=nw=1 %1 > bit_rate.txt
for /F "tokens=*" %%R in (bit_rate.txt) do (
	for /f "tokens=1,2 delims==" %%a in ("%%R") do set NAME=%%a & set BITRATE=%%b
)
rem ffprobe -select_streams v -show_entries packet=size:stream=duration -of compact=p=0:nk=1
echo BITRATE=!BITRATE!
exit /b
	