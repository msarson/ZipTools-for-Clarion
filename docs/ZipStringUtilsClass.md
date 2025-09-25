# ZipStringUtilsClass

The `ZipStringUtilsClass` provides utility methods for string manipulation operations commonly needed when working with ZIP files and file paths. It uses dynamic memory allocation to efficiently handle strings of varying lengths.

## Class Declaration

```clarion
ZipStringUtilsClass   CLASS,TYPE,MODULE('ZipStringUtilsClass.CLW'),LINK('ZipStringUtilsClass.CLW')

! Public interface
Construct               PROCEDURE()
Destruct                PROCEDURE()
SetValue                PROCEDURE(STRING s)
GetValue                PROCEDURE(),STRING
Append                  PROCEDURE(STRING s)
ReplaceAt               PROCEDURE(LONG pos, LONG skip, STRING replacement)
ReplaceAll              PROCEDURE(STRING find, STRING replacement)
GetFileExtension        PROCEDURE(STRING fName),STRING
NormalizePath           PROCEDURE(STRING path),STRING
EnsureTrailingSlash     PROCEDURE(STRING path),STRING
GetFileNameOnly         PROCEDURE(STRING path),STRING
GetPathOnly             PROCEDURE(STRING path),STRING
Start                   PROCEDURE()

! Private state
Buffer                  &STRING,PRIVATE
Capacity                LONG,PRIVATE
Length                  LONG,PRIVATE

! Private helpers
EnsureCap               PROCEDURE(LONG newCap),PRIVATE

                      END
```

## Public Methods

### Construct

Initializes a new instance of the class, setting up the internal state. This method is automatically called when an instance of the class is created.

```clarion
Construct PROCEDURE()
```

### Destruct

Cleans up resources used by the class, freeing any allocated memory. This method is automatically called when an instance of the class goes out of scope.

```clarion
Destruct PROCEDURE()
```

### SetValue

Sets the internal buffer to the specified string.

```clarion
SetValue PROCEDURE(STRING s)
```

#### Parameters

- `s` - The string to set as the buffer value

### GetValue

Returns the current value of the internal buffer.

```clarion
GetValue PROCEDURE(),STRING
```

#### Returns

The current string value stored in the buffer.

## String Operation Methods

### Start

Resets the buffer to an empty string.

```clarion
Start PROCEDURE()
```

### Append

Appends a string to the current buffer content.

```clarion
Append PROCEDURE(STRING s)
```

#### Parameters

- `s` - The string to append to the buffer

### ReplaceAt

Replaces a portion of the internal buffer at a specific position with a replacement string.

```clarion
ReplaceAt PROCEDURE(LONG pos, LONG skip, STRING replacement)
```

#### Parameters

- `pos` - The position in the string where replacement should begin (1-based)
- `skip` - The number of characters to skip/replace
- `replacement` - The string to insert at the specified position

#### Example

```clarion
StringUtils ZipStringUtilsClass
StringUtils.SetValue('Hello World')
StringUtils.ReplaceAt(7, 5, 'Clarion')
Result = StringUtils.GetValue()
! Result now contains 'Hello Clarion'
```

### ReplaceAll

Replaces all occurrences of a substring with another string in the internal buffer.

```clarion
ReplaceAll PROCEDURE(STRING find, STRING replacement)
```

#### Parameters

- `find` - The substring to find and replace
- `replacement` - The string to replace with

#### Example

```clarion
StringUtils ZipStringUtilsClass
StringUtils.SetValue('Hello Hello World')
StringUtils.ReplaceAll('Hello', 'Hi')
Result = StringUtils.GetValue()
! Result now contains 'Hi Hi World'
```

### GetFileExtension

Extracts the file extension from a filename.

```clarion
GetFileExtension PROCEDURE(STRING fileName),STRING
```

#### Parameters

- `fileName` - The filename to extract the extension from

#### Returns

The uppercase file extension without the dot, or an empty string if no extension is found.

#### Example

```clarion
StringUtils ZipStringUtilsClass
Extension STRING
Extension = StringUtils.GetFileExtension('document.pdf')
! Extension now contains 'PDF'

Extension = StringUtils.GetFileExtension('readme.txt')
! Extension now contains 'TXT'

Extension = StringUtils.GetFileExtension('noextension')
! Extension now contains '' (empty string)
```

### NormalizePath

Normalizes a file path by converting forward slashes to backslashes and collapsing double backslashes.

```clarion
NormalizePath PROCEDURE(STRING path),STRING
```

#### Parameters

- `path` - The file path to normalize

#### Returns

The normalized path with consistent backslash separators.

#### Example

```clarion
StringUtils ZipStringUtilsClass
NormalizedPath STRING
NormalizedPath = StringUtils.NormalizePath('C:/folder1//folder2/file.txt')
! NormalizedPath now contains 'C:\folder1\folder2\file.txt'
```

### EnsureTrailingSlash

Ensures a path ends with a backslash character.

```clarion
EnsureTrailingSlash PROCEDURE(STRING path),STRING
```

#### Parameters

- `path` - The file path to ensure has a trailing slash

#### Returns

The path with a trailing backslash added if it didn't already have one.

#### Example

```clarion
StringUtils ZipStringUtilsClass
Path STRING
Path = StringUtils.EnsureTrailingSlash('C:\folder1\folder2')
! Path now contains 'C:\folder1\folder2\'

Path = StringUtils.EnsureTrailingSlash('C:\folder1\folder2\')
! Path remains 'C:\folder1\folder2\' (unchanged)
```

### GetFileNameOnly

Extracts just the filename from a full path.

```clarion
GetFileNameOnly PROCEDURE(STRING path),STRING
```

#### Parameters

- `path` - The full file path

#### Returns

The filename portion of the path without the directory.

#### Example

```clarion
StringUtils ZipStringUtilsClass
FileName STRING
FileName = StringUtils.GetFileNameOnly('C:\folder1\folder2\document.pdf')
! FileName now contains 'document.pdf'
```

### GetPathOnly

Extracts just the path portion from a full path.

```clarion
GetPathOnly PROCEDURE(STRING path),STRING
```

#### Parameters

- `path` - The full file path

#### Returns

The directory portion of the path without the filename.

#### Example

```clarion
StringUtils ZipStringUtilsClass
PathOnly STRING
PathOnly = StringUtils.GetPathOnly('C:\folder1\folder2\document.pdf')
! PathOnly now contains 'C:\folder1\folder2\'
```

## Private Helper Methods

### EnsureCap

Ensures the internal buffer has at least the specified capacity. If the buffer needs to be resized, it preserves the existing content.

```clarion
EnsureCap PROCEDURE(LONG newCap),PRIVATE
```

#### Parameters

- `newCap` - The minimum capacity required for the buffer

## Implementation Details

The class implements dynamic string handling with these key features:

- Uses a dynamically allocated internal buffer to store string data (private)
- Automatically manages memory allocation and deallocation
- Tracks both the capacity (allocated size) and the actual length of the string (private)
- Resizes the buffer as needed to accommodate growing strings, preserving existing content
- Provides methods for common string operations that modify the buffer in-place
- Clearly separates public interface from private implementation details

The string manipulation methods work as follows:

- `ReplaceAt` modifies the internal buffer directly, replacing the specified portion
- `ReplaceAll` finds all occurrences of a substring and calls `ReplaceAt` in a loop
- `GetFileExtension` uses `INSTRING()` with the `-1` parameter to find the last occurrence of a dot in the filename

## Usage in ZipTools

This utility class is used internally by other ZipTools classes to handle string operations when:

- Processing file paths
  - Normalizing paths with consistent separators
  - Extracting filenames and directory paths
  - Ensuring paths have trailing slashes when needed
- Manipulating ZIP entry names
- Extracting file extensions to determine compression strategies
- Building dynamic strings for file operations

## Memory Management

This class uses dynamic memory allocation to manage string data. In Clarion:

- The `Construct()` method is automatically called when an instance of the class is created
- The `Destruct()` method is automatically called when an instance goes out of scope

This means you don't need to explicitly call these methods in your code:

```clarion
StringUtils ZipStringUtilsClass
! Construct() is automatically called here

! Use the string utils...
StringUtils.SetValue('Hello')
Result = StringUtils.GetValue()

! Destruct() is automatically called when StringUtils goes out of scope