[![Build Status](https://img.shields.io/badge/status-stable-brightgreen)]()
[![Last Commit](https://img.shields.io/github/last-commit/msarson/ZipTools-for-Clarion)](https://github.com/msarson/ZipTools-for-Clarion/commits/master)
[![Issues](https://img.shields.io/github/issues/msarson/ZipTools-for-Clarion)](https://github.com/msarson/ZipTools-for-Clarion/issues)
[![Stars](https://img.shields.io/github/stars/msarson/ZipTools-for-Clarion?style=social)](https://github.com/msarson/ZipTools-for-Clarion/stargazers)
# ZipTools-for-Clarion Optimized ZIP Library🗜️

Modern ZIP/UNZIP for Clarion: multi-threaded, password support, progress reporting.

A high-performance ZIP library for Clarion applications that provides simple interfaces for creating, manipulating, and extracting ZIP files.

> **Important:** The ZipTools template requires cape01.tpw and cape02.tpw files to be installed. These are available with any Capesoft product - their free GUTS or REFLECTION addons include these files. See the [Installation and Usage](#installation-and-usage) section for details.

## ⚠️ Breaking Changes in Version 1.2.0 ⚠️

Version 1.2.0 includes several breaking changes that require updates to your code:

- The main class has been renamed from `CZipClass` to `ZipToolsClass` for better naming consistency
- Several type names have been updated for clarity and consistency (see [CHANGELOG](CHANGELOG.md) for details)

### Updating Your Code

1. **If using the template:**
   - Run the updated `InstallZipTools.bat` script which will automatically remove obsolete files
   - Open your application in the Clarion IDE
   - Go to Application > Global Properties
   - Select the "Extensions" tab
   - Open the "Activate ZipTools" extension
   - Go to the "Classes" tab and click "Refresh"

2. **If using the local extension:**
   - Open the extension dialog in your procedure
   - If you see the Class Name is set to "CZipClass", change it to "ZipToolsClass"

3. **If using hand-coded projects:**
   - Update your include statements from `include('CZipClass.Inc'),Once` to `include('ZipToolsClass.Inc'),Once`
   - Update any variable declarations from `CZipClass` to `ZipToolsClass`

For a detailed list of changes and version history, see the [CHANGELOG](CHANGELOG.md).

## Quick Start

### Basic Zipping

```clarion
MyZip ZipToolsClass
FileQ ZipQueueType
ZipOpts LIKE(ZipOptionsType)

! Add files to queue using file selection dialog
IF MyZip.SelectFilesToZip(FileQ)
  ! Configure ZIP options
  ZipOpts.ZipName = 'C:\Output\MyArchive.zip'
  ZipOpts.ShowProgress = TRUE
  ZipOpts.Threads = 8
  ZipOpts.Overwrite = CZ_ZIP_OVERWRITE_ASK
  
  ! Create ZIP file (progress window displays automatically)
  IF MyZip.CreateZipFile(FileQ, ZipOpts) = 0
    MESSAGE('ZIP file created successfully')
  ELSE
    MESSAGE('Error: ' & MyZip.Errors.GetErrorMessage())
  END
END
```

### Zipping a Folder

```clarion
MyZip ZipToolsClass
FileQ ZipQueueType
ZipOpts LIKE(ZipOptionsType)

! Add folder contents to queue using folder selection dialog
! Second parameter (false) means don't include the base folder itself, just its contents
IF MyZip.SelectFolderToZip(FileQ, FALSE)
  ! Configure ZIP options
  ZipOpts.ZipName = 'C:\Output\FolderContents.zip'
  ZipOpts.ShowProgress = TRUE
  ZipOpts.Threads = 8
  ZipOpts.Overwrite = CZ_ZIP_OVERWRITE_ASK
  
  ! Create ZIP file (progress window displays automatically)
  IF MyZip.CreateZipFile(FileQ, ZipOpts) = 0
    MESSAGE('Folder contents zipped successfully')
  ELSE
    MESSAGE('Error: ' & MyZip.Errors.GetErrorMessage())
  END
END
```

### Zipping a Folder Including Base Directory

```clarion
MyZip ZipToolsClass
FileQ ZipQueueType
ZipOpts LIKE(ZipOptionsType)

! Add folder and all its contents to queue using folder selection dialog
! Default or TRUE for second parameter includes the base folder in the zip
IF MyZip.SelectFolderToZip(FileQ, TRUE)
  ! Configure ZIP options
  ZipOpts.ZipName = 'C:\Output\FolderWithContents.zip'
  ZipOpts.ShowProgress = TRUE
  ZipOpts.Threads = 8
  ZipOpts.Overwrite = CZ_ZIP_OVERWRITE_ASK
  
  ! Create ZIP file (progress window displays automatically)
  IF MyZip.CreateZipFile(FileQ, ZipOpts) = 0
    MESSAGE('Folder with contents zipped successfully')
  ELSE
    MESSAGE('Error: ' & MyZip.Errors.GetErrorMessage())
  END
END
```

### Basic Unzipping

```clarion
MyZip ZipToolsClass
UnzipOpts LIKE(UnzipOptionsType)

! Configure unzip options
UnzipOpts.ZipName = 'C:\Input\Archive.zip'
UnzipOpts.OutputFolder = 'C:\Output\ExtractedFiles'
UnzipOpts.ShowProgress = TRUE
UnzipOpts.Overwrite = UZ_OVERWRITE_SILENT

! Extract ZIP file (progress window displays automatically)
IF MyZip.ExtractZipFile(UnzipOpts) = 0
  MESSAGE('ZIP file extracted successfully')
ELSE
  MESSAGE('Error: ' & MyZip.Errors.GetErrorMessage())
END
```


## Options Structures

The library uses two main options structures to control ZIP operations:

### ZipOptionsType

Used for creating ZIP files with `CreateZipFile`:

```clarion
ZipOpts LIKE(ZipOptionsType)
ZipOpts.ZipName = 'C:\Output\MyArchive.zip'  ! Name of the ZIP file to create
ZipOpts.Threads = 8                          ! Number of worker threads (default: 8)
ZipOpts.Password = 'SecretPassword'          ! Optional password for encryption
ZipOpts.Overwrite = CZ_ZIP_OVERWRITE_ASK     ! Overwrite behavior
ZipOpts.ShowProgress = TRUE                  ! Whether to show progress window
ZipOpts.Comment = 'Archive created by ZipToolsClass'  ! Optional ZIP comment
```

**Overwrite Options:**
- `CZ_ZIP_OVERWRITE_ASK` (0): Ask user before overwriting
- `CZ_ZIP_OVERWRITE_FAIL` (1): Fail if file exists
- `CZ_ZIP_OVERWRITE_SILENT` (2): Overwrite silently
- `CZ_ZIP_OVERWRITE_APPEND` (3): Append to existing zip

**Note on Compression:**
The library uses an adaptive compression strategy that automatically selects the optimal compression method and level based on file type and size:

1. If file extension is one of the already-compressed formats (PNG, JPG, JPEG, GIF, ZIP, RAR, etc.) → use STORE method (no compression)
2. If file is <1 KB → use STORE method
3. If file extension is TXT, XML, HTML, CSS, JS, CSV, LOG → use level 9 (maximum compression)
4. If file size is >50 MB and extension is EXE, DLL, BIN → use level 1 (fastest)
5. Otherwise → use level 6 (balanced default)

### UnzipOptionsType

Used for extracting ZIP files with `ExtractZipFile`:

```clarion
UnzipOpts LIKE(UnzipOptionsType)
UnzipOpts.ZipName = 'C:\Input\Archive.zip'     ! Name of the ZIP file to extract
UnzipOpts.OutputFolder = 'C:\Output\Files'     ! Folder to extract files to
UnzipOpts.Threads = 8                          ! Number of worker threads (0=auto)
UnzipOpts.Password = 'SecretPassword'          ! Optional password for encrypted ZIPs
UnzipOpts.Overwrite = UZ_OVERWRITE_SILENT      ! Overwrite behavior
UnzipOpts.ShowProgress = TRUE                  ! Whether to show progress window
```

**Overwrite Options:**
- `UZ_OVERWRITE_ASK` (0): Prompt user if file exists
- `UZ_OVERWRITE_FAIL` (1): Skip file if it exists
- `UZ_OVERWRITE_SILENT` (2): Overwrite existing files without asking

## Detailed Documentation

- [ZipToolsClass](docs/ZipToolsClass.md) - Main class for ZIP operations
- [ZipWorkerClass](docs/ZipWorkerClass.md) - Handles threading and worker operations
- [ZipWriterClass](docs/ZipWriterClass.md) - Manages ZIP file creation
- [ZipReaderClass](docs/ZipReaderClass.md) - Manages ZIP file extraction
- [ZipApiWrapper](docs/ZipApiWrapper.md) - Low-level wrapper for zLib functions
- [ZipErrorClass](docs/ZipErrorClass.md) - Error handling functionality
- [ZipFileUtilitiesClass](docs/ZipFileUtilitiesClass.md) - File system utilities

## Dependencies

This repository includes the required zLib DLL files:
- `zlib1.dll` - Standard zLib library
- `zlibwapi.dll` - Windows API version of zLib

These DLLs were compiled from the latest zLib version and are ready to use with the library. The library now dynamically loads these DLLs at runtime, which provides better compatibility and flexibility when deploying your application.

## Installation and Usage

### Using the Clarion Template

The repository now includes a Clarion template (`ZipTools.tpl`) that makes it easy to integrate the ZIP functionality into your Clarion applications:

1. Run the `InstallZipTools.bat` script with the path to your Clarion root folder:
   ```
   InstallZipTools.bat "C:\Clarion\Clarion11.1"
   ```
   This will copy all necessary files to the appropriate Clarion directories.

2. Register the `ZipTools.tpl` template in your Clarion IDE:
   - Open the Clarion IDE
   - Go to Tools > Template Registry
   - Click "Register"
   - Navigate to your Clarion template directory (e.g., `C:\Clarion\Clarion11.1\Accessory\Template\win`)
   - Select `ZipTools.tpl` and click "Open"

3. Add the ZipTools template to your application:
   - Open your application
   - Go to Application > Global Properties
   - Select the "Extensions" tab
   - Add "Activate ZipTools" extension

**Note:** The ZipTools template requires at least one Capesoft product that contains cape01.tpw and cape02.tpw to be installed in order to be able to register. If you don't have them, you can get them from [Capesoft](https://capesoft.com/clarion) - their GUTS or REFLECTION addons are free and contain these.

### Manual Project Configuration

To use ZipToolsClass in your Clarion application without the template, you must define the following in your project file:

```clarion
_ZIPLinkMode_=>1
_ZIPDllMode_=>0
```

- Set `_ZIPLinkMode_=>1` if the class should be linked into your project
- Set `_ZIPDllMode_=>1` if the object is exported from another DLL

### Using ZipToolsClass in a Hand-Coded Project

To add ZipToolsClass to a hand-coded project (with no APP and hence no Global Extension template), do the following:

1. Add this include statement to your main module:
   ```clarion
   include('ZipToolsClass.Inc'),Once
   ```

2. Add the `_ZIPLinkMode_` and `_ZIPDllMode_` project defines to your project as described above.

### Important Note About DLL Versions

This library contains an updated version of zlib1.dll and zlibwapi.dll. Some third-party tools (like StringTheory) contain an earlier version of these DLLs in the clarion\accessories\bin directory. If you are adding this library to your application, be aware that the shipping DLLs may be overwritten by the older version when deploying your application.

### Testing

The repository includes a ZipClassTesting solution that can be used for testing the functionality of the library.

### Third-Party Tool Compatibility

**Capesoft StringTheory**: Some third-party tools, specifically Capesoft StringTheory, ship with zLib version 1.2.8. The zLib library generally maintains good backward compatibility, so this version should be compatible with the core functionality used in this ZIP library. However:

- Some newer features added after version 1.2.8 may not be available
- Performance improvements in newer versions won't be present
- Bug fixes in newer versions might affect behavior in edge cases

If you're using Capesoft StringTheory in the same application, you'll likely be able to use both libraries without conflicts, but comprehensive testing is recommended to ensure compatibility in your specific use case.

## zlib Library Attribution

This project uses the [zlib](https://zlib.net/) compression library (zlibwapi.dll).

zlib is Copyright (C) 1995-2024 Jean-loup Gailly and Mark Adler.

zlib is distributed under the zlib License:

> This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
>
> Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
>
> 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
> 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
> 3. This notice may not be removed or altered from any source distribution.

## Attribution

This project was inspired by work originally shared by Marcelo_Sanseau in the ClarionHub thread "Zip / Unzip options within an APP?" (posted 27-Nov-2023):

https://clarionhub.com/t/zip-unzip-options-within-an-app/6805

While Marcelo's ClarionZipClass provided the initial inspiration, this library is actually a complete rewrite from the ground up rather than a modification of the original code.

The current implementation features a different architecture with:
- Multi-threaded processing
- Adaptive compression strategies
- Comprehensive error handling
- Password protection support
- Progress reporting
- Extraction capabilities
- Improved memory management

If you're familiar with Marcelo's original work, you'll find this implementation takes a significantly different approach while addressing the same fundamental need for ZIP functionality in Clarion applications.

### Capesoft

The ZipTools template uses cape01.tpw and cape02.tpw from Capesoft. I would like to thank Capesoft for their excellent Clarion tools and templates that have made this integration possible. Their GUTS or REFLECTION addons, which include these template files, are available for free from [Capesoft](https://capesoft.com/clarion).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
