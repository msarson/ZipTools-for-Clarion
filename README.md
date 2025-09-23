# CZipClass - Optimized ZIP Library for Clarion

A high-performance ZIP library for Clarion applications that provides simple interfaces for creating, manipulating, and extracting ZIP files.

## Quick Start

### Basic Zipping

```clarion
MyZip CZipClass
FileQ ZipQ
ZipOpts LIKE(ZipOptions)

! Add files to queue
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
    MESSAGE('Error: ' & MyZip.GetErrorMessage())
  END
END
```

### Basic Unzipping

```clarion
MyZip CZipClass
UnzipOpts LIKE(UnzipOptions)

! Configure unzip options
UnzipOpts.ZipName = 'C:\Input\Archive.zip'
UnzipOpts.OutputFolder = 'C:\Output\ExtractedFiles'
UnzipOpts.ShowProgress = TRUE
UnzipOpts.Overwrite = UZ_OVERWRITE_SILENT

! Extract ZIP file (progress window displays automatically)
IF MyZip.ExtractZipFile(UnzipOpts) = 0
  MESSAGE('ZIP file extracted successfully')
ELSE
  MESSAGE('Error: ' & MyZip.GetErrorMessage())
END
```


## Options Structures

The library uses two main options structures to control ZIP operations:

### ZipOptions

Used for creating ZIP files with `CreateZipFile`:

```clarion
ZipOpts LIKE(ZipOptions)
ZipOpts.ZipName = 'C:\Output\MyArchive.zip'  ! Name of the ZIP file to create
ZipOpts.Threads = 8                          ! Number of worker threads (default: 8)
ZipOpts.Password = 'SecretPassword'          ! Optional password for encryption
ZipOpts.Overwrite = CZ_ZIP_OVERWRITE_ASK     ! Overwrite behavior
ZipOpts.ShowProgress = TRUE                  ! Whether to show progress window
ZipOpts.Comment = 'Archive created by CZipClass'  ! Optional ZIP comment
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

### UnzipOptions

Used for extracting ZIP files with `ExtractZipFile`:

```clarion
UnzipOpts LIKE(UnzipOptions)
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

- [CZipClass](docs/CZipClass.md) - Main class for ZIP operations
- [ZipWorkerClass](docs/ZipWorkerClass.md) - Handles threading and worker operations
- [ZipWriterClass](docs/ZipWriterClass.md) - Manages ZIP file creation
- [ZipReaderClass](docs/ZipReaderClass.md) - Manages ZIP file extraction
- [ZipApiWrapper](docs/ZipApiWrapper.md) - Low-level wrapper for zLib functions
- [ZipErrorClass](docs/ZipErrorClass.md) - Error handling functionality
- [FileUtilitiesClass](docs/FileUtilitiesClass.md) - File system utilities

## Dependencies

This repository includes the required zLib DLL files:
- `zlib1.dll` - Standard zLib library
- `zlibwapi.dll` - Windows API version of zLib

These DLLs were compiled from the latest zLib version and are ready to use with the library.

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

While Marcelo's ClarionZipClass provided the initial inspiration and shares the same class name (CZipClass), this library is actually a complete rewrite from the ground up rather than a modification of the original code.

The current implementation features a different architecture with:
- Multi-threaded processing
- Adaptive compression strategies
- Comprehensive error handling
- Password protection support
- Progress reporting
- Extraction capabilities
- Improved memory management

If you're familiar with Marcelo's original work, you'll find this implementation takes a significantly different approach while addressing the same fundamental need for ZIP functionality in Clarion applications.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.