:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Invisible Inc animation filter v1
::Written by Sizzlefrost, 2021
::Last Update: 31/05/21
::Tool created
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::SETUP
@echo off
setlocal DisableDelayedExpansion
setlocal EnableDelayedExpansion
title InvisibleInc Anim Filter v1
color 1B
cls
call :startTrackingTime
rem look in every directory for .anim dumps
for /f "usebackq tokens=* delims=" %%Z in (`dir /b /s /a:d "*.anim"`) do (
	set targetPath=%%Z
	echo Inside !targetPath!:
	echo -----------------------------------
	rem look inside build.xml in the anim
	set /a lineNumber=0
	set /a skipToLine=0
	for /f "usebackq tokens=* delims=" %%a in (`findstr /R /C:".*" "!targetPath!\build.xml"`) do (

		set /a lineNumber=lineNumber+1
		rem echo [LINECTRL] #!lineNumber!: [%%a]
		title InvisibleInc Anim Filter v1 // File: !targetPath!\build.xml // Line: !lineNumber!

		if !lineNumber! EQU 1 (
			rem check for a flag that would make us skip lines
			set target=[?IIAF
			set baseStr=%%a
			set cleansedStr=!baseStr:^<=[!
			set cleansedStr=!cleansedStr:^>=]!
			set cleansedStr=!cleansedStr:^^!=!
			set cleansedStr=!cleansedStr: =!
			set checkStr=!cleansedStr:~0,6!
			if "!checkStr!" EQU "!target!" (
				set cleansedStr=!cleansedStr:~6!
				set skipToLine=!cleansedStr:~0,-2!
				echo [LINECTRL] Skip flag detected, skipping to line !skipToLine!
			)
		)

		rem if skip flag is set, skip the line
		if !skipToLine! LSS !lineNumber! (
			rem STAGE ONE: attempt to get image filename from string
			rem save the entire line and cleanse the poison characters - temporarily
			set baseStr=%%a
			set strFlux=!baseStr:^<=[!
			set strFlux=!strFlux:^>=]!
			set strFlux=!strFlux:"='!
			rem get starting position
			set target=image=
			set /a pos=-1
			call :getIndex 0
			if defined strFlux (
				set strNew=!strAntiflux!
				set /a startPos=pos+6
				rem get ending position, with strFlux already cut
				rem for this, we need to locate the second quote after image=
				rem therefore, search twice; save everything before our macguffin
				set target='
				call :getIndex 0
				set strNew=!strNew!!strAntiflux!
				set strFlux=!strFlux:~1!
				call :getIndex 0
				set /a endPos=pos
				rem calculate length
				set /a length=endPos-startPos
				rem use start pos and length to match the substring
				call set substring=%%baseStr:~!startPos!,!length!%%
				set substring=!substring:~1,-1!
				rem echo [LINECTRL] Filename found: [!substring!]
				rem echo [LINECTRL] Status of strNew: [!strNew!]
				rem echo [LINECTRL] Status of strFlux: [!strFlux!]

				rem ensure string needs to be 
				rem use the indexer to check substring for "-"
				rem only replace name if -*-1 ending
				set target=-
				set endSub=!substring!
				set "startSub="
				set /a posSub=-1
				rem echo #!lineNumber!: PREINDEXER 1 /!endSub!/
				call :getIndex 1
				set endSub=!endSub:~1!
				rem echo #!lineNumber!: PREINDEXER 2 /!endSub!/
				if fallThrough NEQ 1 call :getIndex 1
				rem echo #!lineNumber!: POSTINDEXER /!endSub!/
				if fallThrough NEQ 1 if !endSub! EQU -1 (
					set substring=!substring:~0,-2!
					rem echo [LINECTRL] #!lineNumber!: Attempting to check file !substring!^(-1^).png
					rem STAGE TWO: remove evil twin and rename our image to work properly
					if exist "!targetPath!\!substring!.png" (
						rem echo [LINECTRL] #!lineNumber!: Working files
						del "!targetPath!\!substring!.png"	
						if exist "!targetPath!\!substring!-1.png" ren "!targetPath!\!substring!-1.png" "!substring!.png"
					)
				)
				rem STAGE THREE: edit the XML
				rem reintroduce the poison. It's necessary - XML is a helluva lab
				set strNew=!strNew:[=^<!
				set strNew=!strNew:]=^>!
				set strNew=!strNew:'="!
				set strFlux=!strFlux:[=^<!
				set strFlux=!strFlux:]=^>!
				set strFlux=!strFlux:'="!
				call :cutTrailSpaces !strFlux!
				echo !strNew!^"!substring!!strFlux!>>"!targetPath!\build.tmp"
				set "fallThrough="
			)
			rem ...and for the strings that didn't contain image filenames, they rejoin the flow here
			rem pause >nul
		)
		if !skipToLine! GEQ !lineNumber! (
			echo %%a >>"!targetPath!\build.tmp"
		)
	)
	rem skipToLine is 0 if theres no flag
	rem skipToLine is "total lines - 1" if the whole file was worked
	rem decrement line number and compare
	echo [FILECTRL] File !targetPath!\build.xml done; skip: !skipToLine!, lines: !lineNumber!
	if !skipToLine! NEQ 0 (
		set /a lineNumber-=1
		if !skipToLine! LSS !lineNumber! (
			set /a lineNumber+=1
			rem delete skip flag
			echo [FILECTRL] Recreating skip flag
			call :createSkipFlag 1
		)
	) else (
		echo [FILECTRL] Creating skip flag
		call :createSkipFlag 0
	) 
	cd "!targetPath!"
	move /y build.tmp build.xml >nul
	cd %~dp0
)
rem echo Program execution ending...
call :stopTrackingTime
endlocal
pause >nul
exit /b 0

:cutTrailSpaces <variable>
set string=%1
set character=!string:~-1!
if "!character!" EQU " " set string=!string:~0,-1! && set %~1=!string! && call :cutTrailSpaces %1
exit /b

:createSkipFlag <recreate>
cd "!targetPath!"
if %1 EQU 1 (
	rem remove old flag first
	for /f "skip=1 delims=" %%a in (build.tmp) do echo %%a>>build_new.tmp
	move /y build_new.tmp build.tmp
)
rem Create a flag that will skip over some/all lines of the build.xml in the future
rem temporarily rename build.tmp to append to the front
rem put the flag at the front of build
echo ^<?IIAF!lineNumber!?^>>>flux.tmp
rem echo [FILECTRL] Flux created
rem append file to the build
type build.tmp>>flux.tmp
rem echo [FILECTRL] Content appended to flux
rem delete original
del build.tmp
rem echo [FILECTRL] Original content removed
ren flux.tmp build.tmp
rem echo [FILECTRL] Flux renamed
exit /b

:getIndex <substringCycle>
if not !running! EQU 1 (
	call :strlen targetLength target
	if %~1 EQU 0 set "strAntiflux="
	set /a running=1
)
if %~1 EQU 0 set /a pos+=1
if %~1 NEQ 0 set /a posSub+=1
rem if the target matches the first X digits of flux, return pos
if %~1 EQU 0 call set strFluxSub=%%strFlux:~0,%targetLength%%%
if %~1 NEQ 0 call set strFluxSub=%%endSub:~0,%targetLength%%%
if "!strFluxSub!" EQU "!target!" (
	set /a running=0 
	goto :eof
)
rem if we're here, we didn't match, so we need to shift flux material by 1 character
if %~1 EQU 0 set strAntiflux=%strAntiflux%%strFlux:~0,1%
if %~1 EQU 0 set strFlux=%strFlux:~1%
if %~1 NEQ 0 set endSub=%endSub:~1%
rem uncomment to follow the unveiling of the filename. Looks pretty cool!
rem if %~1 EQU 0 echo String: [!strAntiflux!\\\\!strFlux!] && if %~1 NEQ 0 echo String: [\\\\!endSub!]
rem sometimes we iterate through the whole string and get nothing.
rem In that case, the line just didn't have an image filename.
if %~1 EQU 0 if not defined strFlux (
	set /a running=0 
	call :lineWithNoImage
	goto :eof
)
if %~1 NEQ 0 if not defined endSub (
	set /a running=0 
	call :subFail
	goto :eof
)
goto :getIndex %~1

:subFail
rem if we're here, we've searched the filename for "-" and found none
rem that's fine, we just need to ensure that we can tell that we found none
set fallThrough=1
rem echo Fallthrough triggered, [!endSub!] remains
exit /b

rem jeb's strlen implementation. Sick!
:strlen <resultVar> <stringVar>
(   
    setlocal
    (set^ tmp=!%~2!)
    if defined tmp (
        set "len=1"
        for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
            if "!tmp:~%%P,1!" NEQ "" ( 
                set /a "len+=%%P"
                set "tmp=!tmp:~%%P!"
            )
        )
    ) ELSE (
        set len=0
    )
)
( 
    endlocal
    set "%~1=%len%"
    goto :eof
)

:lineWithNoImage
rem we're here because we tested a line and it didn't have an image filename
rem make the preparations and jump back to the XML editing step
echo !baseStr!>>"!targetPath!/build.tmp"
goto :eof

:startTrackingTime
For /f "tokens=1-3 delims=1234567890 " %%a in ("%time%") Do set "delims=%%a%%b%%c"
For /f "tokens=1-4 delims=%delims%" %%G in ("%time%") Do (
	Set _hh=%%G
	rem Strip any leading spaces
	Set _hh=!_hh: =!
	Set _min=%%H
	Set _ss=%%I
	Set _ms=%%J
)
set /a startTimeWhole=(_hh*3600)+(_min*60)+_ss
set startTimeFractional=!_ms!
rem echo TIME START - !_hh!:!_min!:!_ss!.!_ms! - !startTimeWhole!.!startTimeFractional!
exit /b

:stopTrackingTime
For /f "tokens=1-3 delims=1234567890 " %%a in ("%time%") Do set "delims=%%a%%b%%c"
For /f "tokens=1-4 delims=%delims%" %%G in ("%time%") Do (
	Set _hh=%%G
	rem Strip any leading spaces
	Set _hh=!_hh: =!
	Set _min=%%H
	Set _ss=%%I
	Set _ms=%%J
)
set /a endTimeWhole=(_hh*3600)+(_min*60)+_ss
set endTimeFractional=!_ms!
rem echo TIME END - !_hh!:!_min!:!_ss!.!_ms! - !endTimeWhole!.!endTimeFractional!
if !endTimeWhole! LSS !startTimeWhole! set /a endTimeWhole=endTimeWhole+86400
set /a execSeconds=endTimeWhole-startTimeWhole
set /a execMilliseconds=endTimeFractional-startTimeFractional
rem echo !endTimeFractional!-!startTimeFractional!=!execMilliseconds! ms
if !execMilliseconds! LSS 10 if !execMilliseconds! GEQ 0 set execMilliseconds=0!execMilliseconds!
if !execMilliseconds! GTR -10 if !execMilliseconds! LSS 0 set execMilliseconds=0!execMilliseconds!
if !execMilliseconds! LSS 0 set /a execMilliseconds+=100 && set /a execSeconds-=1

if !execSeconds! GTR 59 (set /a execMinutes=execSeconds/60 && set /a execSeconds=execSeconds%%60) else set execMinutes=00
if !execSeconds! LSS 10 set execSeconds=0!execSeconds!
echo Executed in !execMinutes!:!execSeconds!.!execMilliseconds!
exit /b