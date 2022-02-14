@echo off

setlocal EnableDelayedExpansion
set /p InTime=In Time: 
set /p OutTime=Out Time: 

REM ffmpeg -ss %InTime% -i %1 %OutTtime% -c copy CLIP.mp4
REM set retime=-vf "minterpolate='fps=120':'mi_mode=mci':'me_mode=bilat'",setpts=4*PTS setpts=8*PTS

:start

SET /p choice=Rescale? [Y/N]: 
IF NOT '%choice%'=='' SET choice=%choice:~0,1%
IF '%choice%'=='Y' GOTO yes
IF '%choice%'=='y' GOTO yes
IF '%choice%'=='N' GOTO no
IF '%choice%'=='n' GOTO no
IF '%choice%'=='' GOTO no
ECHO "%choice%" is not valid
ECHO.
GOTO start

:no
goto slowmo

:yes
ECHO 1 - 900p
ECHO 2 - 768p
ECHO 3 - 720p
set /p C=Rescale Factor? 
IF %C%==1 GOTO 900p
IF %C%==2 GOTO 768p
IF %C%==3 GOTO 720p

:900p
set rescale=-vf scale=1600:-1
goto slowmo

:768p
set rescale=-vf scale=1366:-1
goto slowmo

:720p
set rescale=-vf scale=1280:-1
goto slowmo

:slowmo
SET /p choice=Slow Mo? [Y/N]: 
IF NOT '%choice%'=='' SET choice=%choice:~0,1%
IF '%choice%'=='Y' GOTO yes
IF '%choice%'=='y' GOTO yes
IF '%choice%'=='N' GOTO no
IF '%choice%'=='n' GOTO no
IF '%choice%'=='' GOTO no
ECHO "%choice%" is not valid
ECHO.
GOTO slowmo

:no
goto next

:yes
ECHO 1 - 2x
ECHO 2 - 4x
ECHO 3 - 8x
set /p Cslow=Time Factor? 
IF %Cslow%==1 GOTO 2x
IF %Cslow%==2 GOTO 4x
IF %Cslow%==3 GOTO 8x

:2x
set retime=-filter:v "minterpolate='fps=120':'mi_mode=mci',setpts=4*PTS"
goto next

:4x
set retime=-filter:v "minterpolate='fps=240',setpts=8*PTS"
goto next

:8x
set retime=-filter:v "minterpolate='fps=480',setpts=16*PTS"
goto next

:next
ECHO Bitrate
ECHO 1 - 7M
ECHO 2 - 10M
ECHO 3 - 30M
ECHO 4 - Custom
ECHO 5 - Variable (4M/8M)
ECHO 6 - Variable (7M/14M)
ECHO 7 - Variable (10M/20M)
ECHO 8 - Variable Custom
SET /P M=Encode Level? 
IF %M%==1 GOTO 7M
IF %M%==2 GOTO 10M
IF %M%==3 GOTO 30M
IF %M%==4 GOTO custom
IF %M%==5 GOTO V4M
IF %M%==6 GOTO V7M
IF %M%==7 GOTO V10M
IF %M%==8 GOTO Vcustom

:7M
set /p fileName=Filename? 
ffmpeg -hwaccel cuda -i %1 -ss !InTime! -to !OutTime!  -c:v h264_nvenc !rescale!  -b:v 7M -preset slow -af aresample=async=1 "%fileName%.mp4"
pause

goto next2

:10M
set /p fileName=Filename? 
ffmpeg -hwaccel cuda -i %1  -ss !InTime! -to !OutTime! -af "aresample=async=1" -c:v h264_nvenc !rescale! -b:v  10M -preset slow "!fileName!.mp4"
pause

goto next2

:30M
set /p fileName=Filename? 
ffmpeg -hwaccel cuda -i %1 -ss !InTime! -to !OutTime! -c:v h264_nvenc !rescale! -b:v 30M -preset slow -af aresample=async=1 "%fileName%.mp4"



goto next2

:custom
set /p fileName=Filename? 
set /p customRate=Specify Custom Bitrate Value: 
ffmpeg -hwaccel cuda -i %1 -ss !InTime! -to !OutTime! -c:v h264_nvenc !rescale! -b:v !customRate!M -preset slow -af aresample=async=1 "%fileName%.mp4"
pause

goto next2

:V4M
set /p fileName=Filename? 
ffmpeg -hwaccel cuda -i %1 -ss !InTime! -to !OutTime! -c:v h264_nvenc !rescale! -rc:v vbr_hq -cq:v 26 -b:v 4M -maxrate:v 8M -profile:v high -af aresample=async=1 "%fileName%.mp4"
goto next2

:V7M
set /p fileName=Filename?
ffmpeg -hwaccel cuda -i %1 -ss !InTime! -to !OutTime! -c:v h264_nvenc !rescale! -rc:v vbr_hq -cq:v 26 -b:v 7M -maxrate:v 14M -profile:v high -af aresample=async=1 "%fileName%.mp4"
goto next2
 
:V10M
set /p fileName=Filename? 
ffmpeg -hwaccel cuda -i %1 -ss !InTime! -to !OutTime! -c:v h264_nvenc !rescale! -rc:v vbr_hq -cq:v 26 -b:v 10M -maxrate:v 20M -profile:v high -af aresample=async=1 "%fileName%.mp4"
goto next2

:Vcustom
set /p fileName=Filename? 
set /p customRate=Specify Custom Bitrate Value:
ffmpeg -hwaccel cuda -i %1 -ss !InTime! -to !OutTime! -c:v h264_nvenc !rescale! -rc:v vbr_hq -cq:v 26 -b:v 4M -maxrate:v 8M -profile:v high -af aresample=async=1 "%fileName%.mp4"

:next2
IF '%choice%'=='Y' GOTO slowmoactual
IF '%choice%'=='y' GOTO slowmoactual
IF '%choice%'=='N' GOTO exit
IF '%choice%'=='n' GOTO exit
IF '%choice%'=='' GOTO exit

:slowmoactual
echo Slow Mo Processing will begin now
echo ***Beware, this will use CPU and lots of RAM!***
pause

ffmpeg -i "%fileName%.mp4" !retime! "%fileName%-slowmo.mp4"
del /f "%fileName%.mp4"
pause
exit

REM ffmpeg -hwaccel cuda -i input.mp4 -c:v h264_nvenc -b:v 10M -preset slow -c:a copy output.mp4
pause