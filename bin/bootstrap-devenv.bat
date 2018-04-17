@echo off
REM
REM Bootstrap Developer Maven Environment
REM 
setlocal

set DEBUG=0
set MVNOPT=--quiet
if "%1" == "-h" goto HELP
if "%1" == "-?" goto HELP
if "%1" == "/h" goto HELP
if "%1" == "/?" goto HELP
if "%1" == "-d" set DEBUG=1
if "%1" == "/d" set DEBUG=1
if "%1" == "-X" set DEBUG=2
if "%1" == "/X" set DEBUG=2

if "%DEBUG" == "1" set MVNOPT=
if "%DEBUG" == "2" set MVNOPT=-X

cd /d %~dp0..\maven
echo.

:INSTALL_BOOTSTRAPS
echo.
echo ## Phase 1/3 - Install bootstrap POMs...
echo.
REM
REM IPICS Bootstraps (\s3_tools\maven\)
REM  Don't install the nightly POMs, however, because they override/overwrite the non-nightly POMs.
for %%z in (bootstrap-s3-pom.xml bootstrap-ipics-pom.xml bootstrap-crs-ippe-pom.xml) do (
	set POM=%%z
	echo #### Installing "%%z"
	if "%DEBUG%" == "2" echo ###### mvn %MVNOPT% -f %%z install
	call ..\bin\mvn %MVNOPT% -f %%z install
	if %ERRORLEVEL% NEQ 0 goto ERROR_ABORT
	echo.
)

:INSTALL_PARENTS
echo.
echo.
echo.
echo ## Phase 2/3 - Install parent POMs...
echo.
REM
REM Parent POMs (\s3\poms\)
REM
if exist ..\..\s3\poms (
	cd /d %~dp0..\..\s3\poms

	for %%z in (parent-s3-pom.xml parent-ipics-pom.xml parent-ippe-pom.xml) do (
		set POM=%%z
		echo #### Installing "%%z"
		if "%DEBUG%" == "2" echo ###### mvn %MVNOPT% -f %%z install
		call ..\..\s3_tools\bin\mvn %MVNOPT% -f %%z install
		if %ERRORLEVEL% NEQ 0 goto ERROR_ABORT
		echo.
	)
) else (
	echo Cannot find ..\..\s3\poms!  Check your clearcase load rules.
)

echo.
echo.
echo.
echo ## Phase 3/3 - Configure local environment...
echo.
REM
REM Some workarounds for some common environment problems...
REM
if not exist "%USERPROFILE%\.m2" (
	echo Making '.m2' folder in '%USERPROFILE%'.
	mkdir "%USERPROFILE%\.m2"
)
if not exist "%USERPROFILE%\.m2\settings.xml" (
	echo Making a default settings.xml so m2eclipse doesn't complain so much...
	echo ^<?xml version="1.0" encoding="UTF-8"?^>^<settings xsi:schemaLocation="http://maven.apache.org/xsd/settings-1.0.0.xsd"^>^</settings^>  >  "%USERPROFILE%\.m2\settings.xml"
)
if "%CD:~0,2%" == "C:" (
	REM If the current working directory begins with "C:", assume it is a snapshot view...
	REM Note you cannot hijack a file in a clearcase dynamic view.
	cd ..\..\s3
	echo Hijacking all Eclipse .project files to prevent future Eclipse problems...
	REM (e.g. Making changes in the Project dialog won't persist if the .project 
	REM       is read-only, but Eclipse doesn't warn you either.)
	attrib /s -r .project > NUL
	echo Hijacking all Eclipse .classpath files to prevent future Eclipse problems...
	REM (e.g. So you can set the Source and/or Help paths)
	attrib /s -r .classpath > NUL
)

echo.
echo ## Done!
echo.

goto END


REM -----------------------------------
:HELP
REM -----------------------------------
echo bootstrap-devenv.bat [/h] [/d] [/X]
echo   /h Help
echo   /d Debug
echo   /X Verbose Debug
goto END


REM -----------------------------------
:ERROR_ABORT
REM -----------------------------------
echo.
echo.
REM FIXME - CMD shows literally "%pom" here, but 4NT shell works?
echo ## Error while installing "%pom"!
if "%DEBUG" == "0" (
	echo ## Try running again with either the '/d' or '/X' debug flags for more information
)
echo.
echo.
goto END

REM -----------------------------------
:END
REM -----------------------------------

