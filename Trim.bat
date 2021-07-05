@echo off

setlocal EnableDelayedExpansion
set /p InTime=In Time: 
set /p OutTime=Out Time: 

REM ffmpeg -ss %InTime% -i %1 %OutTtime% -c copy CLIP.mp4

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
set /p C=Time Factor? 
IF %C%==1 GOTO 2x
IF %C%==2 GOTO 4x
IF %C%==3 GOTO 8x

:2x
set retime=-vf minterpolate='fps=120':'mi_mode=blend',setpts=4*PTS
goto next

:4x
set retime=-vf minterpolate='fps=240':'mi_mode=blend',setpts=8*PTS
goto next

:8x
set retime=-vf minterpolate='fps=360':'mi_mode=blend',setpts=16*PTS
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
ffmpeg -hwaccel cuda -i %1 -ss !InTime! -to !OutTime!  -c:v h264_nvenc !rescale! !retime! -b:v 7M -preset slow -af aresample=async=1 "%fileName%.mp4"
pause
exit

:10M
set /p fileName=Filename? 
ffmpeg -hwaccel cuda -i %1  -ss !InTime! -to !OutTime! -af "aresample=async=1" -c:v h264_nvenc !rescale! !retime! -b:v  10M -preset slow "!fileName!.mp4"
pause
exit

:30M
set /p fileName=Filename? 
ffmpeg -hwaccel cuda -i %1 -ss !InTime! -to !OutTime! -c:v h264_nvenc !rescale! !retime! -b:v 30M -preset slow -af aresample=async=1 "%fileName%.mp4"
pause
exit

:custom
set /p fileName=Filename? 
set /p customRate=Specify Custom Bitrate Value: 
ffmpeg -hwaccel cuda -i %1 -ss !InTime! -to !OutTime! -c:v h264_nvenc !rescale! !retime! -b:v !customRate!M -preset slow -af aresample=async=1 "%fileName%.mp4"
pause
exit

:V4M
set /p fileName=Filename? 
ffmpeg -hwaccel cuda -i %1 -ss !InTime! -to !OutTime! -c:v h264_nvenc !rescale! !retime! -rc:v vbr_hq -cq:v 26 -b:v 4M -maxrate:v 8M -profile:v high -af aresample=async=1 "%fileName%.mp4"
exit

:V7M
set /p fileName=Filename?
ffmpeg -hwaccel cuda -i %1 -ss !InTime! -to !OutTime! -c:v h264_nvenc !rescale! !retime! -rc:v vbr_hq -cq:v 26 -b:v 7M -maxrate:v 14M -profile:v high -af aresample=async=1 "%fileName%.mp4"
exit
 
:V10M
set /p fileName=Filename? 
ffmpeg -hwaccel cuda -i %1 -ss !InTime! -to !OutTime! -c:v h264_nvenc !rescale! !retime! -rc:v vbr_hq -cq:v 26 -b:v 10M -maxrate:v 20M -profile:v high -af aresample=async=1 "%fileName%.mp4"
exit

:Vcustom
set /p fileName=Filename? 
set /p customRate=Specify Custom Bitrate Value:
ffmpeg -hwaccel cuda -i %1 -ss !InTime! -to !OutTime! -c:v h264_nvenc !rescale! !retime! -rc:v vbr_hq -cq:v 26 -b:v 4M -maxrate:v 8M -profile:v high -af aresample=async=1 "%fileName%.mp4"

exit


REM ffmpeg -hwaccel cuda -i input.mp4 -c:v h264_nvenc -b:v 10M -preset slow -c:a copy output.mp4
pause
