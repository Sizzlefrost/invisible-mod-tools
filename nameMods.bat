:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Invisible, Inc. Mod Name Generator v2.2
::Written by Sizzlefrost, 2021
::Last Update: 05/02/23
::Added newline into modinfo, to avoid messing up file structure
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::SETUP
@echo off
title II Mod Namegen v2
color 09
::FOR EACH FOLDER, ACCESS MODINFO
::fetch workshop ID from folder
for /f "tokens=1,2 delims=-" %%a in ('dir /b /a:d "workshop-*"') do set "fullName=%%a-%%b" & set "id=%%b`n" && call :performRenaming
echo Done!
pause

::unset variables and quit
set test=
set newName=
set workedName=
set oldName=
set id=
exit /b 0

:performRenaming
setlocal EnableDelayedExpansion
::if a workshop field doesn't exist, create one
for /f "tokens=*" %%t in ('findstr "workshop" "%~dp0\!fullName!\modinfo.txt"') do set "test=%%t"
if not defined test (echo \nworkshop = !id! >> "%~dp0\!fullName!\modinfo.txt")
::fetch mod name from modinfo
for /f "usebackq tokens=2 delims==" %%a in (`findstr "name" "%~dp0\!fullName!\modinfo.txt"`) do set "oldName=%%a"
::remove leading space
set workedName=!oldName:~1!
::Generation Options+
set workedName=!workedName:+=_plus!
::Untitled Inc. Goose Protocol; remove both . and , for compatibility
set workedName=!workedName:,=!
set workedName=!workedName:.=!
::New Agent: Valkyrie
set workedName=!workedName::=_!
::spaces
set newName=!workedName: =_!
echo Found !fullName!, renaming to !newName!
ren "!fullName!" "!newName!"
endlocal

exit /b 0