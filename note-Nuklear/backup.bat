SET backupPath=D:\
SET XCOPYArgs=/Y /I
MKDIR %backupPath%
XCOPY main.cpp %backupPath% %XCOPYArgs%
XCOPY *.vs %backupPath% %XCOPYArgs%
XCOPY *.fs %backupPath% %XCOPYArgs%
Pause