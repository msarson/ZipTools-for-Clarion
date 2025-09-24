# CZipClass Documentation

`CZipClass` is the main class for ZIP operations in this library. It provides high-level methods for creating and extracting ZIP files, with support for password protection, progress reporting, and multi-threading. The implementation uses an adaptive compression strategy that automatically selects the optimal compression method and level based on file type and size.

## Class Methods

### Creating ZIP Files

#### `CreateZipFile`

Creates a ZIP file from a queue of files using multiple threads for improved performance.

```clarion
CreateZipFile(*ZipQueueType FileQueue, *ZipOptionsType Options)
```

**Parameters:**
- `FileQueue`: Queue of files to add to the ZIP (ZipQueueType type)
- `Options`: ZIP options structure containing settings like:
  - `ZipName`: Name of the ZIP file to create
  - `Threads`: Number of worker threads to use (default: 8)
  - `Password`: Optional password for encryption
  - `Overwrite`: Overwrite behavior (0=Ask, 1=Fail, 2=Overwrite, 3=Append)
  - `ShowProgress`: Whether to show progress window

**Note:** The implementation uses an adaptive compression strategy that automatically selects the optimal compression method and level based on file type and size.

**Returns:** 0 on success, error count on failure

<!-- Note: The CreateZipFileMultiThreaded and CreatePasswordProtectedZip methods have been replaced by the more flexible CreateZipFile method with the Options parameter -->

### Selecting Files for ZIP

#### `SelectFilesToZip`

Shows a file dialog to select files to add to a ZIP.

```clarion
SelectFilesToZip(*ZipQueueType FileQueue)
```

**Parameters:**
- `FileQueue`: Queue to add selected files to (ZipQueueType type)

**Returns:** TRUE if files were selected, FALSE if cancelled

#### `SelectFolderToZip`

Shows a folder dialog to select a folder to add to a ZIP.

```clarion
SelectFolderToZip(*ZipQueueType FileQueue, BYTE IncludeBaseFolder=TRUE)
```

**Parameters:**
- `FileQueue`: Queue to add selected folder and its contents to (ZipQueueType type)
- `IncludeBaseFolder` (optional): TRUE to include the folder itself in the ZIP, FALSE to make folder contents the root (defaults to TRUE)

**Returns:** TRUE if a folder was selected, FALSE if cancelled

### Extracting ZIP Files

#### `ExtractZipFile`

Extracts all files from a ZIP file to a folder.

```clarion
ExtractZipFile(*UnzipOptionsType Options)
```

**Parameters:**
- `Options`: Unzip options structure containing settings like:
  - `ZipName`: Name of the ZIP file to extract
  - `OutputFolder`: Folder to extract files to
  - `Threads`: Number of worker threads (0=auto, 1=single-thread)
  - `Password`: Optional password for encrypted ZIPs
  - `Overwrite`: Overwrite behavior (0=Ask, 1=Fail, 2=Overwrite)
  - `ShowProgress`: Whether to show progress window

**Note:** Progress is displayed automatically if ShowProgress is TRUE

**Returns:** 0 on success, error code on failure

<!-- Note: The ExtractSpecificFile and ExtractPasswordProtectedZip methods have been replaced by the more flexible ExtractZipFile method with the Options parameter -->

<!-- Note: The ZIP Information Methods (GetZipContents, GetZipFileCount, GetZipTotalSize) are now implemented in the ZipReaderClass -->

### Error Handling

#### `GetErrorMessage`

Returns a descriptive error message for the last error.

```clarion
GetErrorMessage()
```

**Returns:** Error message string

#### `GetErrorCode`

Returns the last error code.

```clarion
GetErrorCode()
```

**Returns:** Error code

#### `GetzError`

Legacy method for backward compatibility. Returns error message for the last error.

```clarion
GetzError()
```

**Returns:** Error message string

### Debugging

<!-- Note: Debug mode is now controlled through the czDebugOn equate in ZipEquates.inc -->

#### `Trace`

Writes a debug message to the debug output if debug mode is enabled.

```clarion
Trace(Message)
```

**Parameters:**
- `Message`: Debug message to write

**Note:** Debug messages are only output when the czDebugOn equate is set to 1

## Configuration Properties


### `CompressionMethod`

Sets the compression method for ZIP operations.

```clarion
! Note: CompressionMethod is now handled automatically by the adaptive compression strategy
! These settings are only needed for special cases
ZipClass.CompressionMethod = CZ_Z_DEFLATED  ! Default compression
ZipClass.CompressionMethod = CZ_Z_STORE     ! No compression (store only)
```

### Adaptive Compression

The class uses an adaptive compression strategy that automatically selects the optimal compression method and level based on file type and size:

1. If file extension is one of the already-compressed formats (PNG, JPG, JPEG, GIF, ZIP, RAR, etc.) → use STORE method (no compression)
2. If file is <1 KB → use STORE method
3. If file extension is TXT, XML, HTML, CSS, JS, CSV, LOG → use level 9 (maximum compression)
4. If file size is >50 MB and extension is EXE, DLL, BIN → use level 1 (fastest)
5. Otherwise → use level 6 (balanced default)

## Usage Examples

### Creating a ZIP File

```clarion
MyZip CZipClass
FileQ ZipQueueType
ZipOpts LIKE(ZipOptionsType)

! Set ZIP file name
ZipOpts.ZipName = 'C:\Output\LargeArchive.zip'
ZipOpts.ShowProgress = TRUE
ZipOpts.Threads = 8  ! Multi-threading is enabled by default
ZipOpts.Overwrite = CZ_ZIP_OVERWRITE_ASK

! Select files to add to the ZIP
IF MyZip.SelectFilesToZip(FileQ)
  ! Create the ZIP file (progress window displays automatically)
  IF MyZip.CreateZipFile(FileQ, ZipOpts) = 0
    MESSAGE('ZIP file created successfully')
  ELSE
    MESSAGE('Error: ' & MyZip.GetErrorMessage())
  END
END
```

### Creating a Password-Protected ZIP File

```clarion
MyZip CZipClass
FileQ ZipQueueType
ZipOpts LIKE(ZipOptionsType)

! Set ZIP file name and password
ZipOpts.ZipName = 'C:\Output\ProtectedArchive.zip'
ZipOpts.Password = 'MySecretPassword'
ZipOpts.ShowProgress = TRUE
ZipOpts.Threads = 8  ! Multi-threading is enabled by default
ZipOpts.Overwrite = CZ_ZIP_OVERWRITE_ASK

! Select files to add to the ZIP
IF MyZip.SelectFilesToZip(FileQ)
  ! Create the password-protected ZIP file (progress window displays automatically)
  IF MyZip.CreateZipFile(FileQ, ZipOpts) = 0
    MESSAGE('Password-protected ZIP file created successfully')
  ELSE
    MESSAGE('Error: ' & MyZip.GetErrorMessage())
  END
END
```

### Getting ZIP File Information

```clarion
MyZip CZipClass
ZipFile STRING(260)
ContentsQ ZipQueueType
FileCount LONG
TotalSize LONG

! Set ZIP file name
ZipFile = 'C:\Input\Archive.zip'

! Get ZIP file information using the Reader reference
FileCount = MyZip.Reader.GetZipFileCount(ZipFile)
TotalSize = MyZip.Reader.GetZipTotalSize(ZipFile)

IF FileCount > 0
  MESSAGE('ZIP file contains ' & FileCount & ' files with a total size of ' & TotalSize & ' bytes')
  
  ! Get detailed contents
  IF MyZip.Reader.GetZipContents(ZipFile, ContentsQ)
    ! Process contents queue
    ! ...
  END
ELSE
  MESSAGE('Error reading ZIP file: ' & MyZip.GetErrorMessage())
END