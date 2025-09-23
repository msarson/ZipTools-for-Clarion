# ZipReaderClass Documentation

`ZipReaderClass` is responsible for reading and extracting files from ZIP archives. It handles the low-level operations of opening ZIP files, reading their contents, and extracting files to the file system. It implements efficient extraction with password support and customizable overwrite behavior.

## Overview

The `ZipReaderClass` provides the core functionality for working with existing ZIP archives. It:

- Opens and reads ZIP files
- Lists the contents of ZIP archives
- Extracts files from ZIP archives
- Handles password-protected ZIP files
- Provides information about ZIP contents

## Class Methods

### `Construct`

Initializes the ZIP reader with default values.

```clarion
Construct()
```

### `Destruct`

Cleans up resources used by the ZIP reader.

```clarion
Destruct()
```

### `ExtractZipFile`

Extracts all files from a ZIP file to a folder.

```clarion
ExtractZipFile(*UnzipOptions Options)
```

**Parameters:**
- `Options`: Unzip options structure containing settings like:
  - `ZipName`: Name of the ZIP file to extract
  - `OutputFolder`: Folder to extract files to
  - `Threads`: Number of worker threads (0=auto, 1=single-thread)
  - `Password`: Optional password for encrypted ZIPs
  - `Overwrite`: Overwrite behavior (0=Ask, 1=Fail, 2=Overwrite)
  - `ShowProgress`: Whether to show progress window

**Returns:** 0 on success, error code on failure

### `GetZipContents`

Gets the contents of a ZIP file without extracting.

```clarion
GetZipContents(*STRING ZipFileName, *ZipQ ContentsQueue)
```

**Parameters:**
- `ZipFileName`: Name of the ZIP file to read
- `ContentsQueue`: Queue to populate with ZIP file contents (ZipQ type)

**Returns:** TRUE if successful, FALSE if failed


### `GetZipFileCount`

Gets the number of files in a ZIP file.

```clarion
GetZipFileCount(*STRING ZipFileName)
```

**Parameters:**
- `ZipFileName`: Name of the ZIP file to read

**Returns:** The file count, or -1 on error

### `GetZipTotalSize`

Gets the total uncompressed size of all files in a ZIP file.

```clarion
GetZipTotalSize(*STRING ZipFileName)
```

**Parameters:**
- `ZipFileName`: Name of the ZIP file to read

**Returns:** The total size in bytes, or -1 on error

### `Trace`

Outputs debug messages if debug mode is enabled.

```clarion
Trace(STRING Message)
```

**Parameters:**
- `Message`: Debug message to write

**Note:** Debug messages are only output when the czDebugOn equate is set to 1

## Configuration Properties

### `UnzipOptions`

The `UnzipOptions` structure controls extraction behavior:

```clarion
MyZipReader.UnzipOptions.ZipName = 'archive.zip'        ! ZIP file to extract
MyZipReader.UnzipOptions.OutputFolder = 'C:\Output'     ! Destination folder
MyZipReader.UnzipOptions.Password = 'secret'            ! Optional password
MyZipReader.UnzipOptions.Overwrite = UZ_OVERWRITE_ASK   ! Ask before overwriting
MyZipReader.UnzipOptions.ShowProgress = TRUE            ! Show progress window
```

Overwrite options:
- `UZ_OVERWRITE_ASK` (0): Prompt user if file exists
- `UZ_OVERWRITE_FAIL` (1): Skip file if it exists
- `UZ_OVERWRITE_SILENT` (2): Overwrite existing files without asking

## Usage Examples

### Extracting All Files from a ZIP

```clarion
MyZip CZipClass
UnzipOpts UnzipOptions
Result LONG

! Set extraction options
UnzipOpts.ZipName = 'C:\Input\Archive.zip'
UnzipOpts.OutputFolder = 'C:\Output\ExtractedFiles'
UnzipOpts.Overwrite = UZ_OVERWRITE_ASK
UnzipOpts.ShowProgress = TRUE

! Extract all files (progress window displays automatically)
Result = MyZip.ExtractZipFile(UnzipOpts)
IF Result = 0
  MESSAGE('ZIP file extracted successfully')
ELSE
  MESSAGE('Error extracting ZIP file: ' & MyZip.GetErrorMessage())
END
```

### Extracting a Password-Protected ZIP

```clarion
MyZip CZipClass
UnzipOpts UnzipOptions
Result LONG

! Set extraction options with password
UnzipOpts.ZipName = 'C:\Input\Protected.zip'
UnzipOpts.OutputFolder = 'C:\Output\ExtractedFiles'
UnzipOpts.Password = 'MySecretPassword'
UnzipOpts.Overwrite = UZ_OVERWRITE_ASK
UnzipOpts.ShowProgress = TRUE

! Extract all files (progress window displays automatically)
Result = MyZip.ExtractZipFile(UnzipOpts)
IF Result = 0
  MESSAGE('Password-protected ZIP file extracted successfully')
ELSE
  MESSAGE('Error extracting ZIP file: ' & MyZip.GetErrorMessage())
END
```

### Listing ZIP Contents

```clarion
MyZip CZipClass
ZipFile STRING(260)
ContentsQ ZipQ

! Set ZIP file name
ZipFile = 'C:\Input\Archive.zip'

! Get ZIP contents
IF MyZip.Reader.GetZipContents(ZipFile, ContentsQ)
  ! Display file count
  MESSAGE('ZIP contains ' & MyZip.Reader.GetZipFileCount(ZipFile) & ' files')
  
  ! Process contents queue
  LOOP WHILE RECORDS(ContentsQ)
    GET(ContentsQ, 1)
    ! Process each file in the queue
    ! ...
    DELETE(ContentsQ)
  END
ELSE
  MESSAGE('Error reading ZIP contents: ' & MyZip.GetErrorMessage())
END
```

## Implementation Details

The `ZipReaderClass` is designed to work with the `CZipClass` to provide ZIP file extraction functionality. Key features include:

1. **Password Support**: Handles encrypted ZIP files with password protection
2. **Configurable Overwrite Behavior**: Controls how existing files are handled during extraction
3. **Progress Reporting**: Shows extraction progress when enabled
4. **Error Handling**: Provides detailed error messages and codes

## Performance Optimizations

The `ZipReaderClass` includes several optimizations:

1. **Efficient Buffer Management**: Uses optimized buffer sizes for file I/O operations
   - Reduces the number of read/write operations
   - Improves throughput, especially for larger files

2. **Optimized Directory Creation**: Creates directories only when needed
   - Reduces file system operations during extraction
   - Improves performance when extracting many files

3. **Direct File Access**: Uses low-level file access APIs for better performance
   - Bypasses unnecessary abstraction layers
   - Provides more direct control over file operations