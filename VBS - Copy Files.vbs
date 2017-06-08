' ************************************************************
' ** Detects which version of office is running and        **
' ** uses robocopy to pull down the appropriate            **
' ** macros.  Also pulls down pcsup directory                 **
' **                                                                                              **
' ************************************************************


On Error Resume Next
Err.Clear

' -============================================-
' - Create scripting objects and set variables -
' -============================================-

		
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
strComputer = objShell.ExpandEnvironmentStrings("%computername%")
strOutputfile = "\\mhorl107\logontracking$\officefiles\" & strComputer & "_macros.txt"
strOutputfile2 = "\\mhorl107\logontracking$\officefiles\" & strComputer & "_pcsup.txt"

' -================================================-
' - Initiate Subscripts                            -
' -================================================-


GetOfficeVersion()

VerRoboCopy()


' -================================================-
' - Copy Robocopy.exe if it does not already exist -
' -================================================-

Sub VerRoboCopy()

If objFSO.FileExists("C:\Windows\System32\robocopy.exe") Then
    Exit Sub

Else
    strCmdLine = "xcopy \\mh-domain.local\mhdfs\programs\robocopy\robocopy.exe C:\windows\system32\ /d /i /q /y"
    'strCmdLine = "xcopy \\mhorl101\programs\robocopy\robocopy.exe C:\windows\system32\ /d /i /q /y"
    objShell.Run strCmdLine, 0, 1

End If

End Sub

' -================================================-
' - Copy latest office macros and forms            -
' -================================================-
' 10/26/2015 Commented out this section to prepare for elimination of old macros.dot. Has been replaced by
' PowerShell scripts in mhdfs\programs\office dir and the Macros2.0.dotm template.
'Sub CopyOfficeFiles(strVersion)

'Dim macrosFile
'Set macrosFile = CreateObject("Scripting.FileSystemObject")

'Dim logObj
'Dim logFile
'Set logObj = CreateObject("Scripting.FileSystemObject")
'Set logFile = logObj.CreateTextFile("C:\temp\roboLog.txt")

' Added 10/23/2015: if macros.dot already exists, don't perform robocopy
'If (macrosFile.FileExists("C:\OFFICEFILES\Macros\macros.dot")) Then

'	logFile.WriteLine "macros.dot already exists at C:\OFFICEFILES\Macros and has not been re-copied"

'Else
'	objShell.Run "c:\windows\system32\robocopy.exe \\mh-domain.local\mhdfs\programs\pcsup c:\pcsup /COPY:DT /E /R:0 /W:0 /LOG+:" & strOutputfile2 & " /v /TS /FP /purge"

'   	Select Case strVersion
'       	Case "Word.Application.14", "Word.Application.15", "Word.Application.16"
'         	objShell.Run "c:\windows\system32\robocopy.exe \\mh-domain.local\mhdfs\OfficeFiles\2010Macros c:\OFFICEFILES\Macros /COPY:DT /E /R:0 /W:0 /LOG+:" & strOutputfile & " /v /TS /FP /purge" '/NFL /NDL"

'      	Case "Word.Application.11"
'         	objShell.Run "c:\windows\system32\robocopy.exe \\mh-domain.local\mhdfs\OfficeFiles\Macros c:\OFFICEFILES\Macros /COPY:DT /E /R:0 /W:0 /LOG+:" & strOutputfile & " /v /TS /FP /purge" '/NFL /NDL"

'	Case Else
'	       	Exit Sub
'   	End Select
	
'	logFile.WriteLine "macros.dot has been copied to C:\OFFICEFILES\Macros"
'End If

'End Sub


' -================================================-
' - Get OfficeVersion from the registry            -
' -================================================-
Sub GetOfficeVersion

const HKEY_CLASSES_ROOT = &H0000000

WordVersion = objShell.RegRead("HKEY_CLASSES_ROOT\Word.Application\CurVer\")
CopyOfficeFiles(WordVersion)

End Sub

Wscript.Quit

