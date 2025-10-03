# ZipWriterClass Documentation

`ZipWriterClass` is responsible for creating and writing ZIP files. It handles the low-level operations of adding files to a ZIP archive, managing compression settings, and ensuring proper ZIP file structure. It implements efficient compression algorithms with adaptive compression levels based on file types.

## Overview

The `ZipWriterClass` provides the core functionality for creating ZIP archives. It:

- Opens and initializes ZIP files
- Adds files to the archive with proper compression
- Handles password protection
- Manages file metadata and ZIP headers
- Ensures proper ZIP file closure

## Class Methods

### `Construct`

Initializes the ZIP writer with default values.

```clarion
Construct()
```

### `Destruct`

Cleans up resources used by the ZIP writer.

```clarion
Destruct()
```

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

### `WritePrecompressedToZip`

Writes precompressed data to the ZIP file.

```clarion
WritePrecompressedToZip(LONG ZipHandle, *CSTRING ZipEntryName, zip_fileinfo_s zipfi, LONG pCompBuf, ULONG CompSize, ULONG UncSize, ULONG Crc, *IMutex ZipMutex, BYTE UseStoreMethod, <*CSTRING OriginalFilePath>)
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
- `OriginalFilePath` (optional): Original file path (for logging)

**Returns:** 0 on success, error code on failure

### `DumpHex`

Utility method to dump buffer contents as hex for debugging.

```clarion
DumpHex(LONG pBuffer, LONG pLen)
```

**Parameters:**
- `pBuffer`: Pointer to the buffer to dump
- `pLen`: Length of the buffer

**Returns:** String containing hex representation of buffer

### `Trace`

Outputs debug messages if debug mode is enabled.

```clarion
Trace(STRING Message)
```

**Parameters:**
- `Message`: Debug message to write

**Note:** Debug messages are only output when the CZ_TRACEON equate is set to 1 in ZipEquates.inc

## Configuration Properties

### `Options`

The `Options` structure controls compression behavior:

```clarion
MyZipWriter.Options.ZipName = 'archive.zip'        ! ZIP file to create
MyZipWriter.Options.Compression = CZ_Z_DEFAULT_LEVEL  ! Compression level (default: 6)
MyZipWriter.Options.Password = 'secret'            ! Optional password
```

### `ZipCompBuf` and `ZipCompCap`

Internal buffer for compression operations:

```clarion
ZipCompBuf &STRING  ! Buffer for compressed data
ZipCompCap  ULONG   ! Capacity of compressed buffer
```

## Implementation Details

The `ZipWriterClass` is designed to work with the `ZipToolsClass` and `ZipWorkerClass` to enable efficient ZIP file creation. It implements:

1. **File Reading**: Efficiently reads files into memory buffers
2. **CRC Calculation**: Calculates CRC32 checksums for data integrity
3. **Compression**: Compresses file data using zlib deflate algorithm
4. **ZIP Entry Creation**: Creates properly formatted ZIP entries
5. **Thread Synchronization**: Ensures thread-safe writing to ZIP files

The class is typically used by worker threads in a multi-threaded ZIP creation process, where each thread:

1. Reads a file into memory
2. Calculates the CRC32 checksum
3. Compresses the file data (if appropriate)
4. Writes the compressed data to the ZIP file with proper synchronization

## Adaptive Compression

The class supports an adaptive compression strategy that automatically selects the optimal compression method and level based on file type and size:

1. If file extension is one of the already-compressed formats (PNG, JPG, etc.) → use STORE method (no compression)
2. If file is <1 KB → use STORE method
3. If file extension is TXT, XML, HTML, CSS, JS, CSV, LOG → use level 9 (maximum compression)
4. If file size is >50 MB and extension is EXE, DLL, BIN → use level 1 (fastest)
5. Otherwise → use level 6 (balanced default)

## Performance Optimizations

The `ZipWriterClass` includes several optimizations:

1. **Efficient Buffer Management**: Uses optimized buffer sizes for file I/O operations
   - Reduces the number of read/write operations
   - Improves throughput, especially for larger files

2. **Adaptive Compression Strategy**: Selects optimal compression method and level based on file type and size
   - Uses STORE method (no compression) for already-compressed formats
   - Uses maximum compression for highly compressible text formats
   - Uses fastest compression for large binary files
   - Balances compression ratio and speed for optimal performance

3. **Direct Memory Access**: Uses low-level memory operations for better performance
   - Bypasses unnecessary abstraction layers
   - Provides more direct control over memory operations