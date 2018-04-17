@echo off

if "%JAVA_HOME%"=="" set JAVA_HOME=%~dp0..\jdks\win\jdk1.8.0_60
set MAVEN_OPTS=-Xmx640m

echo.
echo CWD        = %CD%
echo JAVA_HOME  = %JAVA_HOME%
echo M2_HOME    = %M2_HOME%
echo MAVEN_OPTS = %MAVEN_OPTS%
echo.

rem if not exist "%USERPROFILE%\.m2\repository\com\cisco\ipics\poms\parent-s3-pom" (
rem     echo.
rem     echo ERROR: Cannot find Cisco bootstrap POM files.  
rem     echo Please run s3_tools\bin\bootstrap-devenv.bat and try again.
rem     echo.
rem )

rem if exist "%USERPROFILE%\.m2\repository\com\cisco\ipics\poms\parent-s3-pom" (
	%~dp0..\maven\current\bin\mvn %*
rem )

%~dp0..\maven\current\bin\mvn %*
