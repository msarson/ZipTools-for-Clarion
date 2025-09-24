@echo off
REM ====================================================================
REM InstallZipTools.bat - Installs ZipTools files to Clarion directories
REM ====================================================================

REM Check if ClarionPath parameter was provided
if "%1"=="" (
    echo ERROR: ClarionPath parameter is required.
    echo Usage: InstallZipTools.bat ClarionPath
    echo Example: InstallZipTools.bat "C:\Clarion\Clarion11.1"
    exit /b 1
)

set ClarionPath=%1
set BinPath=%ClarionPath%\Accessory\bin
set LibsrcPath=%ClarionPath%\Accessory\Libsrc\win
set LibPath=%ClarionPath%\Accessory\lib
set TemplatePath=%ClarionPath%\Accessory\Template\win

REM Verify directories exist
if not exist "%BinPath%" (
    echo ERROR: Bin directory not found: %BinPath%
    exit /b 1
)
if not exist "%LibsrcPath%" (
    echo ERROR: Libsrc directory not found: %LibsrcPath%
    exit /b 1
)
if not exist "%LibPath%" (
    echo ERROR: Lib directory not found: %LibPath%
    exit /b 1
)
if not exist "%TemplatePath%" (
    echo ERROR: Template directory not found: %TemplatePath%
    exit /b 1
)

echo Installing ZipTools to %ClarionPath%...

REM Copy DLL files to Accessory\bin
echo Copying DLL files to %BinPath%...
copy /Y *.dll "%BinPath%" > nul

REM Copy INC and CLW files to Accessory\Libsrc\win (excluding ZipClassTesting files)
echo Copying INC and CLW files to %LibsrcPath%...
for %%F in (*.inc) do (
    if /I not "%%F"=="ZipClassTesting.inc" (
        copy /Y "%%F" "%LibsrcPath%" > nul
    )
)

for %%F in (*.clw) do (
    if /I not "%%F"=="ZipClassTesting.clw" (
        copy /Y "%%F" "%LibsrcPath%" > nul
    )
)

REM Copy LIB files to Accessory\lib
echo Copying LIB files to %LibPath%...
copy /Y zlib1.lib "%LibPath%" > nul
copy /Y zlibwapi.lib "%LibPath%" > nul

REM Copy TPL file to Accessory\Template\win
echo Copying TPL file to %TemplatePath%...
copy /Y ZipTools.TPL "%TemplatePath%" > nul

REM Remove old renamed files from previous versions
echo Removing obsolete files from previous versions...
if exist "%LibsrcPath%\CZipClass.inc" del /Q "%LibsrcPath%\CZipClass.inc" > nul
if exist "%LibsrcPath%\CZipClass.clw" del /Q "%LibsrcPath%\CZipClass.clw" > nul
if exist "%LibsrcPath%\FileUtilitiesClass.inc" del /Q "%LibsrcPath%\FileUtilitiesClass.inc" > nul
if exist "%LibsrcPath%\FileUtilitiesClass.clw" del /Q "%LibsrcPath%\FileUtilitiesClass.clw" > nul

echo Installation complete!