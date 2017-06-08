REM If new software version cannot be installed across domain due to stale records left over from previoius
REM installs in the registry, this script removes the offending reg entries
REM - Can be run with GP for easy rollout
REM - UPDATE: **this script has been replaced with superior PowerShell version**

@echo off
reg query HKLM\Software\Classes\Installer\Products\4EA42A62D9304AC4784BF238120750FF /e >nul 2>nul
If %ERRORLEVEL% EQU 0 (
	REM reg delete "HKLM\Software\Classes\Installer\Products\4EA42A62D9304AC4784BF238120750FF" /f
	echo Java 7 Update someversion removed! >> c:\temp\javaLog.txt
) else (
	echo Java 7 Update someversion not found >> c:\temp\javaLog.txt
)

reg query HKLM\Software\Classes\Installer\Products\4EA42A62D9304AC4784BF230120756FF /e >nul 2>nul
If %ERRORLEVEL% EQU 0 (
	REM reg delete "HKLM\Software\Classes\Installer\Products\4EA42A62D9304AC4784BF230120756FF" /f
	echo Java 7 Update 65 removed! >> c:\temp\javaLog.txt
) else (
	echo Java 7 Update 65 not found >> c:\temp\javaLog.txt
)

reg query HKLM\Software\Classes\Installer\Products\4EA42A62D9304AC4784BF230120776FF /e >nul 2>nul
If %ERRORLEVEL% EQU 0 (
	REM reg delete "HKLM\Software\Classes\Installer\Products\4EA42A62D9304AC4784BF230120776FF" /f
	echo Java 7 Update 67 removed! >> c:\temp\javaLog.txt
) else (
	echo Java 7 Update 67 not found >> c:\temp\javaLog.txt
)

reg query HKLM\Software\Classes\Installer\Products\68AB67CA7DA73301B744BA0000000010 /e >nul 2>nul
If %ERRORLEVEL% EQU 0 (
	REM reg delete "HKLM\Software\Classes\Installer\Products\68AB67CA7DA73301B744BA0000000010" /f
	echo Adobe removed! >> c:\temp\adobeLog.txt
) else (
	echo Adobe not found >> c:\temp\adobeLog.txt
)

reg query HKLM\Software\Classes\Installer\Products\B9F5A093E85A9A74595B788B70986179 /e >nul 2>nul
If %ERRORLEVEL% EQU 0 (
	REM reg delete "HKLM\Software\Classes\Installer\Products\B9F5A093E85A9A74595B788B70986179" /f
	echo iScrub 1 removed! >> c:\temp\iScrubLog.txt
) else (
	echo iScrub not found >> c:\temp\iScrubLog.txt
)

reg query HKLM\Software\Classes\Installer\Products\9806BF71754A1EC4B864B2622BF4FD05 /e >nul 2>nul
If %ERRORLEVEL% EQU 0 (
	REM reg delete "HKLM\Software\Classes\Installer\Products\9806BF71754A1EC4B864B2622BF4FD05" /f
	echo iScrub 2 removed! >> c:\temp\iScrubLog.txt
) else (
	echo iScrub not found >> c:\temp\iScrubLog.txt
)
Exit
