REM SET backupPath=C:\Users\ls\Desktop\tmp\bak
SET backupPath=D:\hzh\_notes\note-Nuklear
SET backupHeaderPath=%backupPath%\third\include
SET headerPath=..\third\include
SET XCOPYArgs=/Y /I

MKDIR %backupPath%
MKDIR %backupHeaderPath%

REM for source code
XCOPY main.cpp %backupPath% %XCOPYArgs%

REM for shaders
XCOPY *.vs %backupPath% %XCOPYArgs%
XCOPY *.fs %backupPath% %XCOPYArgs%

REM for headers
XCOPY %headerPath%\camera.h %backupHeaderPath% %XCOPYArgs%
XCOPY %headerPath%\shader.h %backupHeaderPath% %XCOPYArgs%

PAUSE