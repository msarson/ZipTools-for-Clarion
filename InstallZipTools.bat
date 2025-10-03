@echo off
setlocal EnableDelayedExpansion
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

if not exist "%TemplatePath%" (
    echo ERROR: Template directory not found: %TemplatePath%
    exit /b 1
)

echo Installing ZipTools to %ClarionPath%...

REM Check if zlib DLLs already exist and prompt before overwriting
echo Checking for existing zlib DLLs...

if exist "%BinPath%\zlib1.dll" (
    echo WARNING: zlib1.dll already exists in %BinPath%
    set /p OVERWRITE_ZLIB1="Do you want to overwrite the existing zlib1.dll? This may affect compatibility with other tools. (Y/N): "
    if /i "!OVERWRITE_ZLIB1!"=="Y" (
        echo Copying zlib1.dll to %BinPath%...
        copy /Y "zlib1.dll" "%BinPath%" > nul
    ) else (
        echo Skipping zlib1.dll installation.
    )
) else (
    echo Copying zlib1.dll to %BinPath%...
    copy /Y "zlib1.dll" "%BinPath%" > nul
)

if exist "%BinPath%\zlibwapi.dll" (
    echo WARNING: zlibwapi.dll already exists in %BinPath%
    set /p OVERWRITE_ZLIBWAPI="Do you want to overwrite the existing zlibwapi.dll? This may affect compatibility with other tools. (Y/N): "
    if /i "!OVERWRITE_ZLIBWAPI!"=="Y" (
        echo Copying zlibwapi.dll to %BinPath%...
        copy /Y "zlibwapi.dll" "%BinPath%" > nul
    ) else (
        echo Skipping zlibwapi.dll installation.
    )
) else (
    echo Copying zlibwapi.dll to %BinPath%...
    copy /Y "zlibwapi.dll" "%BinPath%" > nul
)


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