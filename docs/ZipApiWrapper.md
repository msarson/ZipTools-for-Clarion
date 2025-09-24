# ZipApiWrapper Documentation

`ZipApiWrapper` provides a low-level wrapper for the zLib library functions. It serves as the interface between the Clarion code and the native zLib DLL functions, handling the necessary data type conversions and function calls. It separates the low-level API bindings from the business logic, providing a clean interface to the underlying compression libraries.

The wrapper now dynamically loads the zlib and zlibwapi DLLs at runtime, which provides better compatibility and flexibility when deploying your application.

## Overview

The `ZipApiWrapper` class:

- Dynamically loads and manages the zLib DLLs at runtime
- Provides Clarion-friendly wrappers for zLib functions
- Handles data type conversions between Clarion and C
- Manages memory allocation and deallocation for zLib operations
- Provides error handling for zLib function calls

## Class Methods

### `Construct`

Initializes the wrapper and dynamically loads the zLib DLLs.

```clarion
Construct()
```

### `LoadLibs`

Dynamically loads the zlib and zlibwapi DLLs and resolves all function pointers.

```clarion
LoadLibs()
```

This method:
1. Attempts to load zlibwapi.dll
2. Attempts to load zlib1.dll
3. Resolves all function pointers for ZIP, UNZIP, and core zLib functions
4. Returns LEVEL:Benign on success or LEVEL:Notify on failure

### `Destruct`

Cleans up resources used by the wrapper.

```clarion
Destruct()
```

### ZIP Creation Methods

#### `zipOpen`

Opens a ZIP file for writing.

```clarion
zipOpen(*CSTRING ZipFileName, LONG appendmode)
```

**Parameters:**
- `ZipFileName`: Name of the ZIP file to open
- `appendmode`: Mode to open the file in:
  - `CZ_ZIP_APPEND_STATUS_CREATE` (0): Create a new file
  - `CZ_ZIP_APPEND_STATUS_CREATEAFTER` (1): Append to existing file
  - `CZ_ZIP_APPEND_STATUS_ADDINZIP` (2): Add to existing ZIP entry

**Returns:** ZIP file handle, or 0 on error

#### `zipOpenNewFileInZip`

Opens a new file entry in the ZIP archive.

```clarion
zipOpenNewFileInZip(LONG zipFile, *CSTRING filename, *zip_fileinfo_s zipfi, *CSTRING extrafield_local, LONG size_extrafield_local, *CSTRING extrafield_global, LONG size_extrafield_global, *CSTRING comment, LONG method, LONG level)
```

**Parameters:**
- `zipFile`: Handle to the open ZIP file
- `filename`: Name of the file within the ZIP
- `zipfi`: File information structure
- `extrafield_local`: Local extra field data
- `size_extrafield_local`: Size of local extra field
- `extrafield_global`: Global extra field data
- `size_extrafield_global`: Size of global extra field
- `comment`: File comment
- `method`: Compression method (CZ_Z_DEFLATED or CZ_Z_STORE)
- `level`: Compression level (0-9)

**Returns:** 0 on success, error code on failure

#### `zipOpenNewFileInZip3`

Opens a new file entry in the ZIP archive with password protection.

```clarion
zipOpenNewFileInZip3(LONG zipFile, *CSTRING filename, *zip_fileinfo_s zipfi, *CSTRING extrafield_local, LONG size_extrafield_local, *CSTRING extrafield_global, LONG size_extrafield_global, *CSTRING comment, LONG method, LONG level, LONG raw, LONG windowBits, LONG memLevel, LONG strategy, *CSTRING password, ULONG crcForCrypting)
```

**Parameters:**
- Additional parameters beyond zipOpenNewFileInZip:
- `raw`: Raw mode flag
- `windowBits`: Window bits parameter
- `memLevel`: Memory level parameter
- `strategy`: Compression strategy
- `password`: Password for encryption
- `crcForCrypting`: CRC of uncompressed data (required if password is used)

**Returns:** 0 on success, error code on failure

#### `zipWriteInFileInZip`

Writes data to the current file in the ZIP archive.

```clarion
zipWriteInFileInZip(LONG zipHandle, LONG pBuf, ULONG len)
```

**Parameters:**
- `zipHandle`: Handle to the open ZIP file
- `pBuf`: Pointer to the data buffer to write
- `len`: Size of the data buffer

**Returns:** 0 on success, error code on failure

#### `zipCloseFileInZip`

Closes the current file in the ZIP archive.

```clarion
zipCloseFileInZip(LONG zipFile)
```

**Parameters:**
- `zipFile`: Handle to the open ZIP file

**Returns:** 0 on success, error code on failure

#### `zipCloseFileInZipRaw`

Closes the current file in the ZIP archive with raw data.

```clarion
zipCloseFileInZipRaw(LONG zipFile, LONG uncompressed_size, ULONG crc32)
```

**Parameters:**
- `zipFile`: Handle to the open ZIP file
- `uncompressed_size`: Uncompressed size of the file
- `crc32`: CRC32 checksum of the file

**Returns:** 0 on success, error code on failure

#### `zipClose`

Closes the ZIP archive.

```clarion
zipClose(LONG zipFile, *CSTRING global_comment)
```

**Parameters:**
- `zipFile`: Handle to the open ZIP file
- `global_comment`: Global comment for the ZIP file

**Returns:** 0 on success, error code on failure

### ZIP Reading Methods

#### `unzOpen`

Opens a ZIP file for reading.

```clarion
unzOpen(*CSTRING ZipFileName)
```

**Parameters:**
- `ZipFileName`: Name of the ZIP file to open

**Returns:** ZIP file handle, or 0 on error


#### `unzGoToFirstFile`

Positions to the first file in the ZIP archive.

```clarion
unzGoToFirstFile(LONG unzFile)
```

**Parameters:**
- `unzFile`: Handle to the open ZIP file

**Returns:** 0 on success, error code on failure

#### `unzGoToNextFile`

Positions to the next file in the ZIP archive.

```clarion
unzGoToNextFile(LONG unzFile)
```

**Parameters:**
- `unzFile`: Handle to the open ZIP file

**Returns:** 0 on success, error code on failure


#### `unzGetCurrentFileInfo`

Gets information about the current file in the ZIP archive.

```clarion
unzGetCurrentFileInfo(LONG unzFile, *UnzipFileInfoType pfile_info, *CSTRING filename, ULONG filenameBufferSize, <LONG extraField>, ULONG extraFieldBufferSize, <LONG comment>, ULONG commentBufferSize)
```

**Parameters:**
- `unzFile`: Handle to the open ZIP file
- `pfile_info`: Structure to receive file information
- `filename`: Buffer to receive the file name
- `filenameBufferSize`: Size of the file name buffer
- `extraField` (optional): Buffer to receive extra field data
- `extraFieldBufferSize`: Size of the extra field buffer
- `comment` (optional): Buffer to receive file comment
- `commentBufferSize`: Size of the comment buffer

**Returns:** 0 on success, error code on failure

#### `unzOpenCurrentFilePassword`

Opens the current file in the ZIP archive for reading with password.

```clarion
unzOpenCurrentFilePassword(LONG unzFile, *CSTRING password)
```

**Parameters:**
- `unzFile`: Handle to the open ZIP file
- `password`: Password to decrypt the file with

**Returns:** 0 on success, error code on failure

#### `unzOpenCurrentFile`

Opens the current file in the ZIP archive for reading.

```clarion
unzOpenCurrentFile(LONG unzFile)
```

**Parameters:**
- `unzFile`: Handle to the open ZIP file

**Returns:** 0 on success, error code on failure

#### `unzReadCurrentFile`

Reads data from the current file in the ZIP archive.

```clarion
unzReadCurrentFile(LONG unzFile, *STRING buf, ULONG len)
```

**Parameters:**
- `unzFile`: Handle to the open ZIP file
- `buf`: Buffer to receive the data
- `len`: Size of the buffer

**Returns:** Number of bytes read, or negative error code on failure

#### `unzCloseCurrentFile`

Closes the current file in the ZIP archive.

```clarion
unzCloseCurrentFile(LONG unzFile)
```

**Parameters:**
- `unzFile`: Handle to the open ZIP file

**Returns:** 0 on success, error code on failure

#### `unzClose`

Closes the ZIP archive.

```clarion
unzClose(LONG unzFile)
```

**Parameters:**
- `unzFile`: Handle to the open ZIP file

**Returns:** 0 on success, error code on failure

### ZLIB Core Compression API

#### `deflateInit2_`

Initializes the compression stream with advanced options.

```clarion
deflateInit2_(*STRING strm, LONG level, LONG method, LONG windowBits, LONG memLevel, LONG strategy, *CSTRING version, LONG stream_size)
```

**Parameters:**
- `strm`: Compression stream structure
- `level`: Compression level (0-9)
- `method`: Compression method (CZ_Z_DEFLATED)
- `windowBits`: Window size bits
- `memLevel`: Memory level
- `strategy`: Compression strategy
- `version`: zlib version string
- `stream_size`: Size of the z_stream structure

**Returns:** 0 on success, error code on failure

#### `deflate`

Compresses data using the deflate algorithm.

```clarion
deflate(LONG strm, LONG flush)
```

**Parameters:**
- `strm`: Compression stream structure
- `flush`: Flush mode (CZ_Z_NO_FLUSH, CZ_Z_SYNC_FLUSH, CZ_Z_FULL_FLUSH, CZ_Z_FINISH)

**Returns:** 0 on success, error code on failure

#### `deflateEnd`

Cleans up the compression stream.

```clarion
deflateEnd(*STRING strm)
```

**Parameters:**
- `strm`: Compression stream structure

**Returns:** 0 on success, error code on failure

#### `crc32`

Calculates the CRC32 checksum of data.

```clarion
crc32(ULONG crc, *STRING buf, ULONG len)
```

**Parameters:**
- `crc`: Initial CRC value (0 for first call)
- `buf`: Data buffer
- `len`: Length of data

**Returns:** Updated CRC32 value

### Windows API Calls

The wrapper also provides access to several Windows API functions for file operations:

- `CreateFile`: Creates or opens a file
- `WriteFile`: Writes data to a file
- `ReadFile`: Reads data from a file
- `CloseFile`: Closes a file handle
- `GetLastError`: Gets the last Windows error code
- `CreateDirectory`: Creates a directory
- `DeleteFile`: Deletes a file
- `GetCurrentDirectory`: Gets the current directory
- `GetFileSize`: Gets the size of a file
- `FlushFileBuffers`: Flushes file buffers to disk
- `MemCpy`: Copies memory from one location to another
- `ODS`: Outputs a debug string
- `WaitForThread`: Waits for a thread to complete
- `Sleep`: Pauses execution for a specified time

### Debug Methods

#### `Trace`

Outputs debug messages.

```clarion
Trace(STRING Message)
```

**Parameters:**
- `Message`: Debug message to write

## Data Structures

### `tm_zip_s`

Structure containing date/time information.

```clarion
tm_zip_s GROUP,TYPE
  tm_sec  LONG  ! seconds after the minute - [0,59]
  tm_min  LONG  ! minutes after the hour - [0,59]
  tm_hour LONG  ! hours since midnight - [0,23]
  tm_mday LONG  ! day of the month - [1,31]
  tm_mon  LONG  ! months since January - [0,11]
  tm_year LONG  ! years
END
```

### `zip_fileinfo_s`

Structure containing information about a file to be added to a ZIP archive.

```clarion
zip_fileinfo_s GROUP,TYPE
  tmz_date    LIKE(tm_zip_s)  ! Date/time information
  dosDate     ULONG           ! DOS date/time
  internal_fa ULONG           ! Internal file attributes
  external_fa ULONG           ! External file attributes
END
```

### `UnzipFileInfoType`

Structure containing information about a file in a ZIP archive.

```clarion
UnzipFileInfoType GROUP,TYPE
  version             ULONG
  version_needed      ULONG
  flag                ULONG
  compression_method  ULONG
  dosDate             ULONG
  crc                 ULONG
  compressed_size     ULONG
  uncompressed_size   ULONG
  size_filename       ULONG
  size_file_extra     ULONG
  size_file_comment   ULONG
  disk_num_start      ULONG
  internal_fa         ULONG
  external_fa         ULONG
  tmu_date            ULONG,DIM(6)  ! [0]=sec, [1]=min, [2]=hour, [3]=day, [4]=month, [5]=year
END
```

## Constants

### Compression Methods

- `CZ_Z_DEFLATED` (8): Standard deflate compression
- `CZ_Z_STORE` (0): No compression, store only

### Compression Levels

- `CZ_Z_NO_COMPRESSION` (0): No compression
- `CZ_Z_BEST_SPEED` (1): Fastest compression
- `CZ_Z_DEFAULT_LEVEL` (6): Default compression level
- `CZ_Z_BEST_COMPRESSION` (9): Maximum compression

### Append Status Modes

- `CZ_ZIP_APPEND_STATUS_CREATE` (0): Create a new zip file
- `CZ_ZIP_APPEND_STATUS_CREATEAFTER` (1): Add to existing zip file
- `CZ_ZIP_APPEND_STATUS_ADDINZIP` (2): Add to existing zip entry

### Error Codes

- `CZ_ZIP_OK` (0): No error
- `CZ_ZIP_EOF` (0): End of file
- `CZ_ZIP_ERRNO` (-1): Error number from operating system
- `CZ_ZIP_PARAMERROR` (-102): Parameter error
- `CZ_ZIP_BADZIPFILE` (-103): Bad zip file
- `CZ_ZIP_INTERNALERROR` (-104): Internal error

## Usage Example

This class is typically used internally by the higher-level classes (`ZipToolsClass`, `ZipWriterClass`, and `ZipReaderClass`), but can be used directly for more advanced operations:

```clarion
MyZipApi ZipApiWrapper
ZipHandle LONG
FileName CSTRING(FILE:MaxFileName+1)
FileData STRING(1048576)  ! 1MB buffer
BytesRead LONG

! Create a new instance
MyZipApi &= NEW ZipApiWrapper

! Open a ZIP file
FileName = 'C:\Input\Archive.zip'
ZipHandle = MyZipApi.unzOpen(FileName)
IF ZipHandle
  ! Go to the first file
  IF MyZipApi.unzGoToFirstFile(ZipHandle) = CZ_ZIP_OK
    ! Open the current file
    IF MyZipApi.unzOpenCurrentFile(ZipHandle) = CZ_ZIP_OK
      ! Read the file data
      BytesRead = MyZipApi.unzReadCurrentFile(ZipHandle, FileData, SIZE(FileData))
      IF BytesRead >= 0
        ! Process the file data
        ! ...
      END
      
      ! Close the current file
      MyZipApi.unzCloseCurrentFile(ZipHandle)
    END
  END
  
  ! Close the ZIP file
  MyZipApi.unzClose(ZipHandle)
END

! Clean up
DISPOSE(MyZipApi)