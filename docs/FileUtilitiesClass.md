# FileUtilitiesClass Documentation

`FileUtilitiesClass` provides utility functions for file system operations in the ZIP library. It handles common file and directory operations needed for ZIP file creation and extraction, including file selection, path manipulation, and directory scanning.

## Overview

The `FileUtilitiesClass` provides:

- File path manipulation and normalization
- Directory creation and verification
- File existence checking
- File attribute handling
- File and directory scanning

## Class Methods

### `CONSTRUCT`

Initializes the file utilities class.

```clarion
CONSTRUCT()
```

### `DESTRUCT`

Cleans up resources used by the file utilities class.

```clarion
DESTRUCT()
```

### Path Manipulation Methods

#### `PathOnly`

Extracts the directory path from a file path.

```clarion
PathOnly(<STRING fPath>)
```

**Parameters:**
- `fPath`: File path to extract directory from (optional)

**Returns:** Directory path without the filename

#### `FileNameOnly`

Extracts just the file name from a file path.

```clarion
FileNameOnly(<STRING fPath>)
```

**Parameters:**
- `fPath`: File path to extract file name from (optional)

**Returns:** File name without the directory path

#### `GetFileExtension`

Gets the file extension from a file name.

```clarion
GetFileExtension(STRING FileName)
```

**Parameters:**
- `FileName`: File name to extract extension from

**Returns:** File extension including the dot (e.g., '.txt')

### Directory Operations

#### `CreateDirectoriesFromPath`

Recursively creates directories in a path if they don't exist.

```clarion
CreateDirectoriesFromPath(*CSTRING DirectoryPath)
```

**Parameters:**
- `DirectoryPath`: Path to create

**Returns:** TRUE if successful, FALSE if failed

#### `ScanFolderRecursively`

Recursively scans a folder and adds all files to the queue.

```clarion
ScanFolderRecursively(*CSTRING FolderPath, *ZipQ FileQueue, <*CSTRING BasePath>, *CSTRING BaseFolder)
```

**Parameters:**
- `FolderPath`: Directory to scan
- `FileQueue`: Queue to add files to
- `BasePath` (optional): Base path for relative path calculation
- `BaseFolder`: Base folder path for relative paths in ZIP

**Returns:** Number of files added to the queue

### File Selection Operations

#### `SelectFiles`

Shows file dialog to select files to add to a ZIP.

```clarion
SelectFiles(*ZipQ FileQueue)
```

**Parameters:**
- `FileQueue`: Queue to add selected files to

**Returns:** TRUE if files were selected, FALSE if cancelled

#### `SelectZipFolder`

Shows folder dialog to select a folder to add to a ZIP.

```clarion
SelectZipFolder(*ZipQ FileQueue, BYTE IncludeBaseFolder=TRUE, *CSTRING BaseFolder)
```

**Parameters:**
- `FileQueue`: Queue to add selected folder and its contents to
- `IncludeBaseFolder`: TRUE to include the folder itself in the ZIP, FALSE to make folder contents the root
- `BaseFolder`: Base folder path for relative paths in ZIP

**Returns:** TRUE if a folder was selected, FALSE if cancelled

#### `SelectFolder`

Shows folder dialog to select a folder.

```clarion
SelectFolder(String Title, String FileTypeSelection)
```

**Parameters:**
- `Title`: Dialog title
- `FileTypeSelection`: File type filter

**Returns:** Selected folder path or empty string if cancelled

#### `SelectFile`

Shows file dialog to select a single file.

```clarion
SelectFile(String Title, String FileTypeSelection)
```

**Parameters:**
- `Title`: Dialog title
- `FileTypeSelection`: File type filter (e.g., 'ZIP Files|*.zip|All Files|*.*')

**Returns:** Selected file path or empty string if cancelled

## Usage Examples

### Path Manipulation

```clarion
MyFileUtils FileUtilitiesClass
FilePath STRING(260)
DirPath STRING(260)
FileName STRING(260)
FileExt STRING(10)

! Create a new instance
MyFileUtils &= NEW FileUtilitiesClass

! Set a file path
FilePath = 'C:\Documents\Reports\Annual\2025\Q1Report.pdf'

! Extract directory path and file name
DirPath = MyFileUtils.PathOnly(FilePath)    ! 'C:\Documents\Reports\Annual\2025'
FileName = MyFileUtils.FileNameOnly(FilePath)  ! 'Q1Report.pdf'
FileExt = MyFileUtils.GetFileExtension(FilePath)  ! '.pdf'

! Clean up
DISPOSE(MyFileUtils)
```

### Directory Operations

```clarion
MyFileUtils FileUtilitiesClass
DirPath STRING(260)
FileQ ZipQ
BaseFolder STRING(260)

! Create a new instance
MyFileUtils &= NEW FileUtilitiesClass

! Create a directory structure
DirPath = 'C:\Output\Reports\2025\Q1'
IF MyFileUtils.CreateDirectoriesFromPath(DirPath)
  MESSAGE('Directory created successfully')
ELSE
  MESSAGE('Error creating directory')
END

! Scan a directory for files
BaseFolder = 'C:\Documents'
DirPath = 'C:\Documents\Reports'
FileCount = MyFileUtils.ScanFolderRecursively(DirPath, FileQ, BaseFolder, BaseFolder)
MESSAGE('Found ' & FileCount & ' files in the directory')

! Clean up
DISPOSE(MyFileUtils)
```

### File Selection Operations

```clarion
MyFileUtils FileUtilitiesClass
FileQ ZipQ
FilePath STRING(260)
FolderPath STRING(260)
BaseFolder STRING(260)

! Create a new instance
MyFileUtils &= NEW FileUtilitiesClass

! Select files to add to a ZIP
IF MyFileUtils.SelectFiles(FileQ)
  MESSAGE('Files selected: ' & RECORDS(FileQ))
ELSE
  MESSAGE('File selection cancelled')
END

! Select a folder to add to a ZIP
BaseFolder = 'C:\'
IF MyFileUtils.SelectZipFolder(FileQ, TRUE, BaseFolder)
  MESSAGE('Folder selected and added to queue')
ELSE
  MESSAGE('Folder selection cancelled')
END

! Select a single file
FilePath = MyFileUtils.SelectFile('Select a ZIP file', 'ZIP Files|*.zip|All Files|*.*')
IF FilePath <> ''
  MESSAGE('Selected file: ' & FilePath)
ELSE
  MESSAGE('File selection cancelled')
END

! Clean up
DISPOSE(MyFileUtils)
```

## Implementation Details

The `FileUtilitiesClass` provides essential file system operations for the ZIP library:

1. **Path Manipulation**: Handles file paths, extracts file names and extensions, and normalizes paths
2. **Directory Creation**: Creates directory structures recursively
3. **File Selection**: Provides user interfaces for selecting files and folders
4. **Directory Scanning**: Recursively scans directories and adds files to queues

## Performance Optimizations

The `FileUtilitiesClass` includes several optimizations:

1. **Efficient Path Handling**: Uses optimized string operations for path manipulation
   - Normalizes paths by replacing forward slashes with backslashes
   - Removes duplicate separators
   - Improves performance for operations on many files

2. **Batch Directory Scanning**: Processes directories in batches
   - Uses a batch size of 100 files for better performance
   - Reduces overhead for scanning large directories
   - Improves memory usage for large file sets

3. **Retry Logic**: Implements retry logic for directory creation
   - Handles transient file system errors
   - Increases delay between retries
   - Improves reliability in network environments