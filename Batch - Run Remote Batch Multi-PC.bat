REM This batch creates a cmd.exe process on a list of remote machines, which in turn calls another batch located in pcsup
REM Remember to set the values in /node:(machines) and after "cmd.exe /c C:\path\to\batch.bat" correctly

@echo off
WMIC /node:@"D:\PCLists\ShortList.txt" process call create "cmd.exe /c C:\temp\CoolBatch.bat"
/nointeractive
Exit
