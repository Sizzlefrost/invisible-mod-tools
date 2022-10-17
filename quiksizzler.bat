:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Quiksizzler v7.2
::Written by Sizzlefrost, 2019
::Last Update: 17/10/22
::detailed errors; fixed dangerous KWAD builder bug
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
setlocal EnableDelayedExpansion
::Bd is an all-purpose build variable, M is the mod path that's remembered during kwad setup, H is a Gigasizzler flag
set %%_Bd=0
set _M=0
set _H=0
:: Quiksizzler Status (QSLS) messages
set qslsOk=OK
set qslsUnresolved=UNRESOLVED
set qslsError=ERROR
set qslsKwaddingError=ERROR INSIDE KWAD BUILDER -- Try running it manually.
set qslsBuilderError=ERROR FINDING THE KWAD BUILDER -- Try placing it in steamapps/common/InvisibleInc.
set qslsScriptsMissingError=ERROR FINDING THE SCRIPTS FOLDER -- Ensure a folder named `scripts` exists in your mod.
set qslsSkip=SKIPPED
set qsls1=VERSION - 
set qsls2=SCRIPTS - 
set qsls3=KWADS - 
:: QSLS flags
set qsls1_=
set qsls2_=
set qsls3_=
:: Black stack overflow sorcery that gets rid of the "ECHO IS OFF." outputs
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)
title Quiksizzler v7.1
color 09
break>"version.tmp"
break>"modinfo.tmp"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::   I  N  I  T  I  A  L  I  Z  A  T  I  O  N   ::
::::::::::::::::::::::::::::::::::::::::::::::::::
::check that modinfo contains string "version" at the start of a line
::if yes, we assume it's written correctly (we're not changing any other lines anyway, so Sizzler won't be to blame)
::if not, we fix that
call :drawLogo
set qsls1_=1 & :: if something happens while we increment, we know that there's been an error
for /f "usebackq tokens=1 delims= " %%a in (`findstr /b version "modinfo.txt"`) do (
if %%a EQU version goto:version else goto:fixmodinfo
)

::if modinfo was empty, it's filled with placeholder data (NOTE: version ticks up to 1.0.0.1)
:fixmodinfo
echo No version information was found within modinfo.txt. Recreating and filling new modinfo.txt with placeholder data...
::> outputs to file and overwrites; >> outputs to file and appends to the next line
echo name = autofilled mod name>modinfo.txt
echo author = autofilled author name>>modinfo.txt
echo version = 1.0.0.0>>modinfo.txt
goto versionAdvance

::ask user which number of the version they'd like to increment
:version
for /f "usebackq tokens=1,3,4,5,6 delims=. " %%a in (`findstr "version" modinfo.txt`) do call :colorEcho 0B "Found existing mod build - %%b.%%c.%%d.%%e"
:versionAdvance
for /f "usebackq tokens=1,3,4,5,6 delims=. " %%a in (`findstr "version" modinfo.txt`) do echo %%a = %%b.%%c.%%d.%%e>version.tmp
echo [Format: Revision.Version.Feature.Build]
echo Type B to make a new build.
echo Type F to make a new feature.
echo Type V to make a new version.
echo Type R to make a new revision.
echo Type S to skip version increments.
echo Type G to enable Gigasizzler mode: new build, update scripts, don't update kwads, launch the game, suppress prompts.
echo Type A to abort the building process.
choice /c:BFVRSGA /n /m "Select [B], [F], [V], [R], [S], [G] or [A]."
IF %ERRORLEVEL% EQU 1 goto executeBuild
IF %ERRORLEVEL% EQU 2 goto executeFeature
IF %ERRORLEVEL% EQU 3 goto executeVersion
IF %ERRORLEVEL% EQU 4 goto executeRevision
IF %ERRORLEVEL% EQU 5 echo MODINFO SKIP && set qsls1_=2 && goto scripts
IF %ERRORLEVEL% EQU 6 echo GIGASIZZLER ENABLED && set /a _H=1 && goto executeBuild
IF %ERRORLEVEL% EQU 7 goto abort
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::   M  O  D  I  N  F  O   ::
:::::::::::::::::::::::::::::
::make a build
:executeBuild
::next line stores the final digit of the version in the Bd variable - it's about to be deleted in the file
for /f "usebackq tokens=6 delims=. " %%a in (`findstr /b version "modinfo.txt"`) do set /a _Bd =%%a+1
::next 3 lines do the following:
::1) look at version line, copy it to version.tmp except last digit (this WILL overwrite)
::2) copy the lines of modinfo.txt that are NOT version to modinfo.tmp (this WILL overwrite also)
::3) move modinfo.tmp on top of modinfo.txt (this WILL overwrite as well, and will suppress the confirmation popup)
::ENGLISH: this deletes the version line from modinfo.txt and partially puts it into a temporary file version.tmp, the other part is stored in a variable or is zero
for /f "usebackq tokens=1,3,4,5 delims=. " %%a in (`findstr /b version "modinfo.txt"`) do echo %%a = %%b.%%c.%%d.>version.tmp
findstr /v version modinfo.txt>modinfo.tmp
move /y modinfo.tmp modinfo.txt >nul
::next line goes into the version file and takes its contents (partial version number) and adds the other part from variable, and puts result back into modinfo.txt as final version.
::for non-build variations, _Bd will store feature/version/revision numbers and everything below them will be reset to form X.0.0.1 for rev, X.X.0.1 for ver, etc.
::The reason this is so overcomplicated is that any appending write effects always insert a newline at the start, so you have to write the whole version number at once,
::both the changed and unchanged parts, which is why the script jumped through all those hoops.
for /f "delims=" %%l in (version.tmp) do echo %%l!_Bd!>>modinfo.txt
set qsls1_=0
::If we're in Gigasizzler mode, we skip the prompt
IF %_H% EQU 1 goto:scriptsSilent
goto:scripts

::make a feature
:executeFeature
::feature stores the penultimate digit instead!
for /f "usebackq tokens=5 delims=. " %%a in (`findstr /b version "modinfo.txt"`) do set /a _Bd =%%a+1
::this part is nearly unchanged: one less digit in version, but modinfo.txt and .tmp behave exactly the same
for /f "usebackq tokens=1,3,4 delims=. " %%a in (`findstr /b version "modinfo.txt"`) do echo %%a = %%b.%%c.>version.tmp
findstr /v version modinfo.txt>modinfo.tmp
move /y modinfo.tmp modinfo.txt >nul
::this part is similar too, but we're keeping in mind we have only rev.ver. in version.tmp and only feat. in variable
::so we reset the build to 1
for /f "delims=" %%l in (version.tmp) do echo %%l!_Bd!.1>>modinfo.txt
set qsls1_=0
goto:scripts

::make a version
:executeVersion
::version stores the second, version, digit
for /f "usebackq tokens=4 delims=. " %%a in (`findstr /b version "modinfo.txt"`) do set /a _Bd =%%a+1
::again, one less digit in version, only revision number remains there
for /f "usebackq tokens=1,3 delims=. " %%a in (`findstr /b version "modinfo.txt"`) do echo %%a = %%b.>version.tmp
findstr /v version modinfo.txt>modinfo.tmp
move /y modinfo.tmp modinfo.txt >nul
::and we account for lack of value in feature slot by resetting it to zero, along with resetting build to 1 like above
for /f "delims=" %%l in (version.tmp) do echo %%l!_Bd!.0.1>>modinfo.txt
set qsls1_=0
goto:scripts

::make a revision
:executeRevision
::can you guess what's happening here?
for /f "usebackq tokens=3 delims=. " %%a in (`findstr /b version "modinfo.txt"`) do set /a _Bd =%%a+1
::still required; version not only stores the number, but also the string "version = ". Somewhat redundant, though - it could be hardcoded.
for /f "usebackq tokens=1 delims=. " %%a in (`findstr /b version "modinfo.txt"`) do echo %%a = >version.tmp
findstr /v version modinfo.txt>modinfo.tmp
move /y modinfo.tmp modinfo.txt >nul
for /f "delims=" %%l in (version.tmp) do echo %%l!_Bd!.0.0.1>>modinfo.txt
set qsls1_=0
goto:scripts
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::   S  C  R  I  P  T  S  .  Z  I  P   ::
:::::::::::::::::::::::::::::::::::::::::
:scripts
call :drawLogo
set qsls2_=1 & :: if something happens while we make the zip, we know that there's been an error
choice /n /m "Would you like to update scripts.zip? [Y/N]"
IF %ERRORLEVEL% EQU 2 echo SCRIPTS SKIP && set qsls2_=2 && goto:skipscripts
::check that scripts folder exists, update scripts.zip from it if it does

:scriptsSilent
if not exist "scripts" goto scriptsInvalid

:: kinda ugly, lol
:: Line by line, we're assembling a VBS script that writes a ZIP archive
:: this lets us zip up the scripts folder cleanly
:: the previous method used here was simpler, but less robust
:: () backward-compatible and also couldn't handle subfolders

echo Assembling Quikzipper...

echo Set objArgs = WScript.Arguments >> quikzipper.vbs
echo ZipFile = objArgs(1) >> quikzipper.vbs
echo Set objShell = CreateObject("Shell.Application") >> quikzipper.vbs
echo Set objFS = CreateObject("Scripting.FileSystemObject") >> quikzipper.vbs
echo Wscript.Echo "QZIPR - Creating empty ZIP" >> quikzipper.vbs
echo objFS.CreateTextFile(ZipFile, True).Write "PK" ^& Chr(5) ^& Chr(6) ^& String(18, vbNullChar) >> quikzipper.vbs
echo InputFolder = objFS.GetAbsolutePathName(objArgs(0)) >> quikzipper.vbs
echo ZipFile = objFS.GetAbsolutePathName(objArgs(1)) >> quikzipper.vbs
echo Wscript.Echo "QZIPR - Initiating file copying" >> quikzipper.vbs
echo Set source = objShell.NameSpace(InputFolder).Items >> quikzipper.vbs 
echo Count = objShell.NameSpace(ZipFile).Items().Count >> quikzipper.vbs
echo objShell.NameSpace(ZipFile).CopyHere(source) >> quikzipper.vbs
echo Wscript.Echo "QZIPR - Awaiting end of file copying" >> quikzipper.vbs
echo Do While Count = objShell.NameSpace(ZipFile).Items().Count >> quikzipper.vbs
echo 	Wscript.Echo "QZIPR - ..." >> quikzipper.vbs
echo 	wScript.Sleep 200 >> quikzipper.vbs
echo Loop >> quikzipper.vbs
echo Wscript.Echo "QZIPR - SUCCESS" >> quikzipper.vbs
:: wait for user input - TODO
cls
echo "  ____          _   __         _                       "
echo " / __ \ __ __  (_) / /__ ___  (_) ___   ___  ___   ____"
echo "/ /_/ // // / / / /  '_//_ / / / / _ \ / _ \/ -_) / __/"
echo "\___\_\\_,_/ /_/ /_/\_\ /__//_/ / .__// .__/\__/ /_/   "
echo "                               /_/   /_/               "
CScript  quikzipper.vbs  scripts  scripts.zip
echo "/_____________________________________________________/"
echo Disassembling Quikzipper...

del /q quikzipper.vbs
set qsls2_=0
goto skipscripts
:: if powershell is installed, run that
:: powershell.exe -nologo -noprofile -command "& { Add-Type -Assembly 'System.IO.Compression.FileSystem'; [System.AppContext]::SetSwitch('Switch.System.IO.Compression.ZipFile.UseBackslash', $false); [IO.Compression.ZipFile]::CreateFromDirectory('scripts', 'scripts.zip'); }"
:scriptsInvalid
echo "ERROR: Scripts folder not found. It is required for any mod, please build one!"
set qsls2_=5
goto:skipscripts

:skipscripts
IF %_H% EQU 1 echo KWADS SKIP && set qsls3_=2 && goto:end
call :drawLogo
set qsls3_=1 & :: if something happens while we increment, we know that there's been an error
choice /n /m "Would you like to update the .kwad files? [Y/N]"
::Before we move anywhere, let's save our current location so we can always recall to it
set _M="%cd%"
IF %ERRORLEVEL% EQU 1 goto:kwadFind
IF %ERRORLEVEL% EQU 2 echo KWADS SKIP && set qsls3_=2 && goto:end
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::   K  W  A  D     B  U  I  L  D  E  R   ::
::::::::::::::::::::::::::::::::::::::::::::
:kwadFind
::I have no idea where you would keep the KWAD builder. Neither does the script.
::So we'll have it search 3 places: 
::...steamapps\common\InvisibleInc
::...steamapps\common\Invisible Inc Mod Uploader
::and the desktop, because of course
cd..\..\..
cd "InvisibleInc"
::/s means "look inside subfolders as well"; /a:d means "attribute: directory" to limit search to directiories (folders) as opposed to files.
::>nul prevents output (actually, > reads as "output this to..." and nul means "nowhere" here).
::&& executes command only if previous command on this line is executed successfully; || executes only if previous is unsuccessful.
dir /s /a:d "KWAD builder" >nul && goto:kwadCall || set /a _Bd+=1
cd "%USERPROFILE%\Desktop"
	 >nul && goto:kwadCall || set /a _Bd+=1
cd "Invisible Inc Mod Uploader"
dir /s /a:d "KWAD builder" >nul && goto:kwadCall || set /a _Bd+=1
if "%_Bd%" EQU 3 (
	echo "ERROR: KWAD Builder not found. Proceeding without building .kwad files..."
	set qsls3_=4
	goto:end
)
::if we're here, something's gone terribly wrong
goto:abort

:kwadCall
::if we're here, we know KWAD builder folder exists in one of the three spots, but we're not sure where
::this next thing finds the builder again and CHDIRs to it (/b designates bare format, useful since we're automating the process)

::dir /s works correctly if we find the target in a subdirectory, then it'll return the path of the target
::if we find it right in the initial directory, it'll instead return subdirectories of the target, which we don't want to do
::so we attempt to find the builder in the initial directory first, and if we fail, we dig deeper
if exist "KWAD builder" cd "KWAD builder" || for /f "usebackq delims=" %%a in (`dir /s /a:d /b "KWAD builder"`) do (cd %%~a)
::now we run the builder
echo KWAD BUILDER FOUND
for /f "usebackq delims=" %%A in (`dir /s /a:d /b "KWAD builder"`) do cd %%~dpfA
::we silence the output of the builder; if it is unsuccessful, or no "out" folder exists, quit before grabbing the output
::this error message is a bit wack; we print it first, abusing the fact that builder pauses on failure
echo KWADDING ERROR - Press any key to continue & call build.bat >nul && (cd "out" || set qsls3_=3) || (set qsls3_=3)
if %qsls3_%=="3" cd %_M% & goto:end
for /f "usebackq delims=" %%a in (`dir /b /a:-d "*.kwad"`) do (move /y "%%a" !_M!\%%~nxa >nul) && set qsls3_=0 || set qsls3_=1
cd %_M%
goto:end
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::   E  X  I  T  S   ::
:::::::::::::::::::::::
:end
call :drawLogo
for /f "usebackq tokens=3,4,5,6 delims=. " %%b in (`findstr /b version "modinfo.txt"`) do call :colorEcho 0B "Build successful - version %%b.%%c.%%d.%%e ready"
call :cleanup
IF %_H% EQU 1 goto launchGame
choice /n /m "Would you like to start Invisible, Inc.? [Y/N]"
IF %ERRORLEVEL% EQU 1 goto launchGame
endlocal
exit /b 0

:launchGame
::we're assuming you're making the mod inside the mod folder (duh, that's where I told you to place this file)
::that's steamapps\common\InvisibleInc\mods\<modname>
::so we're going two levels up to InvisibleInc, where the executable is located
cd..\..
start "Invisible Mod Test" "invisibleinc.exe"

::EXTREMELY IMPORTANT LINE HERE
::cleans up .mdmp crash log files
::personally, my game always produced one on startup despite running normally
::I cleared these up manually for a long time but now included the feature in Quiksizzler
::you can comment out the line if you want to keep the crash logs
if exist *.mdmp del /q *.mdmp
set _H=
endlocal
exit /b 0

:abort
endlocal
::clean up temp files - in case of abort, it's possible modinfo.tmp won't overwrite modinfo.txt yet, so we're deleting it to be certain
call :cleanup
echo Cleaned up, aborting...
exit /b 1

:cleanup
if exist version.tmp del /q version.tmp
if exist modinfo.tmp del /q modinfo.tmp
::unset variables
set _Bd=
set _M=
set qslsOk=
set qslsUnresolved=
set qslsKwaddingError=
set qslsBuilderError=
set qslsScriptsMissingError=
set qslsError=
set qslsSkip=
set qsls1=
set qsls2=
set qsls3=
set qsls1_=
set qsls2_=
set qsls3_=
set DEL=
set dummy=
exit /b 0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::   L  O  G  O   ::
::::::::::::::::::::
:: font name: Slant & modified 4Max; @ https://patorjk.com/software/taag/
:drawLogo
cls
call :colorEcho 0B " dPOYb   88   88  88  db  dP   dPOY8  88  8888P  8888P  88      888888  88OOYb        Yb    dP 888888P   oP`8b"
call :colorEcho 0B "dP   Yb  88   88  88  88oP     Y8b    88    dP     dP   88      88__    88__dP         Yb  dP      dP    `  dP"
call :colorEcho 0B "Yb  _dP  Y8   8P  88  88~b       Y8b  88   dP     dP    88      88^    88OYb           YbdP      dP       dP  "
call :colorEcho 0B " YOYoYo_  YbodP   88  YP  Yb  8bod8P  88  d8888  d8888  88ood8  888888  88  Yb           YP      dP   O  d8888"
echo ### STATUS ###
<nul set /p dummy="%qsls1%"
call :displayStatus %qsls1_%
<nul set /p dummy="%qsls2%"
call :displayStatus %qsls2_%
<nul set /p dummy="%qsls3%"
call :displayStatus %qsls3_%
echo ##############
EXIT /B 0

:displayStatus
if "%~1"=="0" call :colorEcho A0 "%qslsOk%" & EXIT /B 0
if "%~1"=="1" call :colorEcho 4F "%qslsError%" & EXIT /B 0
if "%~1"=="2" call :colorEcho 08 "%qslsSkip%" & EXIT /B 0
if "%~1"=="3" call :colorEcho 4F "%qslsKwaddingError%" & EXIT /B 0
if "%~1"=="4" call :colorEcho 4F "%qslsBuilderError%" & EXIT /B 0
if "%~1"=="5" call :colorEcho 4F "%qslsScriptsMissingError%" & EXIT /B 0
call :colorEcho 0F "%qslsUnresolved%"
EXIT /B 0

:colorEcho
echo off
echo %DEL% > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
EXIT /B 0