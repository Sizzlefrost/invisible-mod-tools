:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Quiksizzler v6.1
::Written by Sizzlefrost, 2019
::Last Update: 09/11/19
::Quiksizzler now cleans up Invisible's .mdmp crash dumps on game startup
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
setlocal
setlocal EnableDelayedExpansion
::Bd is an all-purpose build variable, M is the mod path that's remembered during kwad setup, H is a Gigasizzler flag
set %%_Bd=0
set _M=0
set _H=0
title Quiksizzler v6
color 1B
break>"version.tmp"
break>"modinfo.tmp"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::   I  N  I  T  I  A  L  I  Z  A  T  I  O  N   ::
::::::::::::::::::::::::::::::::::::::::::::::::::
::check that modinfo contains string "version" at the start of a line
::if yes, we assume it's written correctly (we're not changing any other lines anyway, so Sizzler won't be to blame)
::if not, we fix that
for /f "usebackq tokens=1 delims= " %%a in (`findstr /b version "modinfo.txt"`) do (
if %%a EQU version goto:version else goto:fixmodinfo
)

::if modinfo was empty, it's filled with placeholder data (NOTE: version ticks up to 1.0.0.1)
:fixmodinfo
echo No version information was found within modinfo.txt. Recreating and filling new modinfo.txt with placeholder data...
::this explains potential compile crash risk
echo WARNING: you may need to change the mod icon - it's possible the file Quiksizzler puts as default doesn't actually exist!
::> outputs to file and overwrites; >> outputs to file and appends to the next line
echo name = autofilled mod name>modinfo.txt
echo author = autofilled author name>>modinfo.txt
echo icon = gui/icons/icon.png>>modinfo.txt
echo version = 1.0.0.0>>modinfo.txt
goto versionAdvance

::ask user which number of the version they'd like to increment
:version
for /f "usebackq tokens=1,3,4,5,6 delims=. " %%a in (`findstr "version" modinfo.txt`) do echo Found existing mod build: %%b.%%c.%%d.%%e
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
IF %ERRORLEVEL% EQU 5 echo MODINFO SKIP && goto scripts
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
echo MODINFO OK
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
echo MODINFO OK
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
echo MODINFO OK
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
echo MODINFO OK
goto:scripts
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::   S  C  R  I  P  T  S  .  Z  I  P   ::
:::::::::::::::::::::::::::::::::::::::::
:scripts
choice /n /m "Would you like to update scripts.zip? [Y/N]"
IF %ERRORLEVEL% EQU 2 echo SCRIPTS SKIP && goto:skipscripts
::check that scripts folder exists, update scripts.zip from it if it does

:scriptsSilent
if exist "scripts" (
if exist scripts.zip del /q scripts.zip
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('scripts', 'scripts.zip'); }"
) else ( 
echo "ERROR: Scripts folder not found. Proceeding without building scripts.zip..."
pause 
exit /b 0
)
echo SCRIPTS OK

:skipscripts
IF %_H% EQU 1 echo KWADS SKIP && goto:end
choice /n /m "Would you like to update the .kwad files? [Y/N]"
::Before we move anywhere, let's save our current location so we can always recall to it
set _M="%cd%"
IF %ERRORLEVEL% EQU 1 goto:kwadFind
IF %ERRORLEVEL% EQU 2 echo KWADS SKIP && goto:end
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
dir /s /a:d "KWAD builder" >nul && goto:kwadCall || set /a _Bd+=1
cd "Invisible Inc Mod Uploader"
dir /s /a:d "KWAD builder" >nul && goto:kwadCall || set /a _Bd+=1
if "%_Bd%" EQU 3 (
	echo "ERROR: KWAD Builder not found. Proceeding without building .kwad files..."
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
if exist "KWAD builder" cd "KWAD builder" || for /f "usebackq delims=" %%a in (`dir /s /a:d /b "KWAD builder"`) do (cd %%~dp)
::now we run the builder
echo KWAD BUILDER FOUND
::we silence the output of the builder
call build.bat >nul
::now it should have output files into a subfolder called \out
cd "out"
::so we grab every .kwad we see and we put it back where the script is at (the mod directory); /a:-d means everything but directories (i.e. normal files only)
for /f "usebackq delims=" %%a in (`dir /b /a:-d "*.kwad"`) do (move /y "%%a" !_M!\%%~nxa >nul)
::and we report success
echo KWADS OK
cd %_M%
goto:end
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::   E  X  I  T  S   ::
:::::::::::::::::::::::
:end
::clean up temp files
if exist version.tmp del /q version.tmp
if exist modinfo.tmp del /q modinfo.tmp
echo CLEANUP OK
for /f "usebackq tokens=3,4,5,6 delims=. " %%b in (`findstr /b version "modinfo.txt"`) do echo Build successful: written new version %%b.%%c.%%d.%%e
IF %_H% EQU 1 goto launchGame
choice /n /m "Would you like to start Invisible, Inc.? [Y/N] (EXPERIENCED MODDERS, HEADS UP: this also cleans up previous .mdmp crash logs)"
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
endlocal
exit /b 0

:abort
endlocal
::clean up temp files - in case of abort, it's possible modinfo.tmp won't overwrite modinfo.txt yet, so we're deleting it to be certain
if exist version.tmp del /q version.tmp
if exist modinfo.tmp del /q modinfo.tmp
echo Cleaned up, aborting...
exit /b 1