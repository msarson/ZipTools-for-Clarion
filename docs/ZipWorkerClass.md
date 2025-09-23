# ZipWorkerClass Documentation

`ZipWorkerClass` is responsible for handling threading and worker operations in the ZIP library. It enables parallel processing of files during ZIP operations, significantly improving performance on multi-core systems. Each worker thread processes a subset of files to be added to the ZIP archive.

## Overview

The `ZipWorkerClass` manages worker threads that process files in parallel during ZIP operations. It handles:

- Thread creation and management
- Work distribution among threads
- Progress tracking and reporting
- Thread synchronization
- Error handling across threads

## Class Methods

### `Construct`

Initializes the worker class with default values.

```clarion
Construct()
```

### `Destruct`

Cleans up resources used by the worker class.

```clarion
Destruct()
```

### `Kill`

Cleans up remaining resources (but not buffers which are already disposed).

```clarion
Kill()
```

### `InitThreadData`

Initializes thread data for parallel processing.

```clarion
InitThreadData(LONG ZipHandle, *IMutex ZipMutex, *ZipQ FileQueue, LONG ThreadNum, LONG FilesPerThread, LONG ThreadCount, *CZipClass zipBase, <ULONG TotalFileSize>)
```

**Parameters:**
- `ZipHandle`: Handle to the open ZIP file
- `ZipMutex`: Mutex for thread synchronization
- `FileQueue`: Queue containing all files to be processed
- `ThreadNum`: Thread number (1-based)
- `FilesPerThread`: Number of files per thread (for count-based distribution)
- `ThreadCount`: Total number of threads
- `zipBase`: Reference to the parent CZipClass
- `TotalFileSize` (optional): Total size of all files (for size-based distribution)

**Note:** This method distributes files to be processed either by count (equal number of files per thread) or by size (equal amount of data per thread) depending on whether TotalFileSize is provided.

### `BuildQueue`

Builds the file queue for this thread based on the source queue and assigned indices.

```clarion
BuildQueue()
```

**Returns:** Number of files added to the thread's queue

### `WritePrecompressedToZip`

Writes precompressed data to the ZIP file.

```clarion
WritePrecompressedToZip(LONG ZipHandle, *CSTRING ZipEntryName, zip_fileinfo_s zipfi, LONG pCompBuf, ULONG CompSize, ULONG UncSize, ULONG Crc, *IMutex ZipMutex, BYTE UseStoreMethod, *CSTRING ZipPath)
```

**Parameters:**
- `ZipHandle`: Handle to the open ZIP file
- `ZipEntryName`: Name of the entry in the ZIP file
- `zipfi`: File information structure
- `pCompBuf`: Pointer to the compressed data buffer
- `CompSize`: Size of the compressed data
- `UncSize`: Uncompressed size of the data
- `Crc`: CRC32 checksum of the uncompressed data
- `ZipMutex`: Mutex for thread synchronization
- `UseStoreMethod`: TRUE to use STORE method, FALSE to use DEFLATE
- `ZipPath`: Path of the file within the ZIP archive

**Returns:** 0 on success, error code on failure

### `CompressFileToBuffer`

Reads a file and compresses it to the internal buffer.

```clarion
CompressFileToBuffer(*CSTRING FileName, *ULONG OutUncSize, *ULONG OutCrc, *ULONG OutCompSize)
```

**Parameters:**
- `FileName`: Name of the file to compress
- `OutUncSize`: Output parameter for uncompressed size
- `OutCrc`: Output parameter for CRC32 checksum
- `OutCompSize`: Output parameter for compressed size

**Returns:** 0 on success, error code on failure

### `ReadFileToBuffer`

Reads a file into a buffer and calculates CRC.

```clarion
ReadFileToBuffer(STRING FileName, *STRING BufRef, ULONG MaxSize, *ULONG OutSize, *ULONG OutCrc)
```

**Parameters:**
- `FileName`: Name of the file to read
- `BufRef`: Reference to the buffer to read into
- `MaxSize`: Maximum size to read
- `OutSize`: Output parameter for actual size read
- `OutCrc`: Output parameter for CRC32 checksum

**Returns:** 0 on success, error code on failure

### `Trace`

Outputs debug messages if debug mode is enabled.

```clarion
Trace(STRING Message)
```

**Parameters:**
- `Message`: Debug message to write

**Note:** Debug messages are only output when the czDebugOn equate is set to 1

## Thread Notification Codes

The following notification codes are used for thread communication:

- `CZ_ZIP_NOTIFY:ThreadComplete`: A worker thread has completed
- `CZ_ZIP_NOTIFY:ThreadProgress`: A worker thread has processed a file
- `CZ_ZIP_NOTIFY:ThreadError`: A worker thread has encountered an error
- `CZ_ZIP_NOTIFY:ThreadInitFailed`: A worker thread failed to initialize properly

## Implementation Details

The `ZipWorkerClass` is designed to work with the `CZipClass` to enable multi-threaded ZIP file creation. Each worker thread:

1. Receives a subset of files to process
2. Reads and compresses each file
3. Calculates CRC checksums
4. Writes the compressed data to the ZIP file with proper synchronization
5. Reports progress and errors back to the main thread

The class implements an adaptive compression strategy that automatically selects the optimal compression method and level based on file type and size:

1. If file extension is one of the already-compressed formats (PNG, JPG, etc.) → use STORE method (no compression)
2. If file is <1 KB → use STORE method
3. If file extension is TXT, XML, HTML, CSS, JS, CSV, LOG → use level 9 (maximum compression)
4. If file size is >50 MB and extension is EXE, DLL, BIN → use level 1 (fastest)
5. Otherwise → use level 6 (balanced default)

## Performance Considerations

- The optimal number of threads depends on the CPU cores available and the I/O characteristics of the system
- For I/O-bound operations (like ZIP operations), using more threads than CPU cores can sometimes improve performance
- For very small files, the overhead of threading may outweigh the benefits
- The class supports two distribution strategies:
  - Count-based: Distributes an equal number of files to each thread
  - Size-based: Distributes files to balance the total data size across threads
- Size-based distribution typically provides better performance with mixed file sizes