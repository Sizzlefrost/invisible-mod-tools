:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Invisible, Inc. Mod Name Generator v1
::Written by Sizzlefrost, 2021
::Last Update: 20/05/21
::Tool created; made to work around spaces and other characters in the mod names
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::SETUP
@echo off
title II Mod Namegen v1
color 1B
::FOR EACH FOLDER, ACCESS MODINFO & FIND MOD NAME
for /f "tokens=*" %%G in ('dir /b /a:d "workshop-*"') do (
	echo Found %%G
	setlocal EnableDelayedExpansion
	for /f "usebackq tokens=2 delims==" %%a in (`findstr "name" "%~dp0\%%G\modinfo.txt"`) do (
		set oldName=%%a
		::remove leading space
		set workedName=!oldName:~1!
		::Generation Options+
		set workedName=!workedName:+=_plus!
		::Untitled Inc. Goose Protocol; remove both . and , for compatibility
		set workedName=!workedName:,=!
		set workedName=!workedName:.=!
		::spaces
		set newName=!workedName: =_!
		ren "%%G" "!newName!"
	)
	endlocal
)
echo Done!
pause
exit /b 0