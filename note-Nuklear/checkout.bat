REM @echo off
SET checkoutPath=D:\hzh\_notes\note-Nuklear
SET checkoutHeaderPath=%checkoutPath%\third\include

SET currentPath=D:\hzh\projects\Playground\Play_Nuklear
REM SET currentPath=C:\Users\ls\Desktop\tmp\dir\src
SET headerPath=%currentPath%\..\third\include

SET camera_h="camera.h"
SET shader_h="shader.h"
SET main_cpp="main.cpp"

REM backup file before checkout
SET t=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
SET backupFirst=".\_backup_temp_at_%t%"

REM test space in path
REM SET backupFirst=".\_backup_temp_at_ 111"

REM echo %backupFirst%
SET backupFirstHeader=%backupFirst%\third\include



MKDIR %backupFirstHeader%
XCOPY *.h    %backupFirst%  %XCOPYArgs%
XCOPY *.c    %backupFirst%  %XCOPYArgs%
XCOPY *.cpp  %backupFirst%  %XCOPYArgs%
XCOPY *.vs   %backupFirst%  %XCOPYArgs%
XCOPY *.fs   %backupFirst%  %XCOPYArgs%

XCOPY %headerPath%\%camera_h%  %backupFirstHeader%  %XCOPYArgs%
XCOPY %headerPath%\%shader_h%  %backupFirstHeader%  %XCOPYArgs%

REM =======================================================
REM do checkout

MKDIR %currentPath%
MKDIR %headerPath%

REM XCOPY parameter
SET XCOPYArgs=/Y /I

REM XCOPY [from] [to] [parameter]

REM for source code
XCOPY %checkoutPath%\%main_cpp% %currentPath% %XCOPYArgs%

REM for shaders
XCOPY %checkoutPath%\*.vs %currentPath% %XCOPYArgs%
XCOPY %checkoutPath%\*.fs %currentPath% %XCOPYArgs%

REM for headers
XCOPY %checkoutHeaderPath%\%camera_h% %headerPath% %XCOPYArgs%
XCOPY %checkoutHeaderPath%\%shader_h% %headerPath% %XCOPYArgs%

PAUSE