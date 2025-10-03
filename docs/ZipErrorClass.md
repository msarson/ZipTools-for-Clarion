# ZipErrorClass Documentation

`ZipErrorClass` is responsible for error handling and reporting in the ZIP library. It provides a centralized way to manage error codes, error messages, and debug logging. It centralizes error handling and error messages for all ZIP operations, eliminating duplication across the various ZIP wrapper classes.

## Overview

The `ZipErrorClass` provides:

- Error code storage and retrieval
- Human-readable error messages
- Debug logging capabilities
- Error translation between zLib and application-specific codes

## Class Methods

### `SetError`

Sets the current error code and message with context prefix.

```clarion
SetError(STRING Prefix, LONG Code)
```

**Parameters:**
- `Prefix`: Context prefix to add to the error message
- `Code`: Error code to set

**Note:** This method also logs the error via TraceError if debugging is enabled

### `GetErrorCode`

Gets the current error code.

```clarion
GetErrorCode()
```

**Returns:** The current error code (zErrCode)

### `GetErrorMessage`

Gets a human-readable message for a specific error code.

```clarion
GetErrorMessage(<LONG Code>)
```

**Parameters:**
- `Code` (optional): Error code to get message for. If omitted, uses the current error code.

**Returns:** Human-readable error message

### `GetzError`

Legacy method for backward compatibility. Returns error message for the last error.

```clarion
GetzError()
```

**Returns:** Error message string

### `TraceError`

Internal method for error tracing.

```clarion
TraceError(<String prefix>)
```

**Parameters:**
- `prefix` (optional): Prefix to add to the error message in the trace

**Note:** This is a private method used internally by the class

## Error Codes

The `ZipErrorClass` handles the following error codes (defined in ZipEquates.inc):

### Standard zLib Error Codes
- `CZ_ZIP_OK` (0): No error
- `CZ_ZIP_EOF` (0): End of file
- `CZ_ZIP_ERRNO` (-1): Error number from operating system
- `CZ_ZIP_PARAMERROR` (-102): Parameter error
- `CZ_ZIP_BADZIPFILE` (-103): Bad zip file
- `CZ_ZIP_INTERNALERROR` (-104): Internal error

### Extended Clarion-zLib Error Codes
- `CZ_ZIP_ERR_FILE_OPEN2` (-201): Error opening file
- `CZ_ZIP_ERR_FILE_READ2` (-202): Error reading file
- `CZ_ZIP_ERR_FILE_WRITE2` (-203): Error writing file
- `CZ_ZIP_ERR_FILE_CLOSE2` (-204): Error closing file
- `CZ_ZIP_ERR_MEMORY` (-205): Memory allocation error
- `CZ_ZIP_ERR_EXTRACT` (-206): Error during extraction
- `CZ_ZIP_ERR_CREATE2` (-207): Error creating zip
- `CZ_ZIP_ERR_ADD_FILE2` (-208): Error adding file to zip
- `CZ_ZIP_ERR_INVALID_PARAMETER` (-209): Invalid parameter
- `CZ_ZIP_ERR_FILE_EXISTS2` (-210): File exists and user chose not to overwrite
- `CZ_ZIP_ERR_INTERNAL` (-211): Internal error in compression process

### ZipFileManager Error Codes
- `CZ_ZIP_ERR_CREATE` (-1001): Failed to create ZIP
- `CZ_ZIP_ERR_FILE_EXISTS` (-1002): File already exists
- `CZ_ZIP_ERR_ADD_FILE` (-1003): Failed while adding file to ZIP
- `CZ_ZIP_ERR_FILE_OPEN` (-1004): Failed to open file
- `CZ_ZIP_ERR_FILE_CLOSE` (-1005): Failed to close file
- `CZ_ZIP_ERR_FILE_READ` (-1006): Failed to read file
- `CZ_ZIP_ERR_FILE_WRITE` (-1007): Failed to write file

## Debug Logging

When debug mode is enabled (CZ_TRACEON equate is set to 1 in ZipEquates.inc), the `ZipErrorClass` logs error messages through the TraceError method. This can be useful for troubleshooting issues with ZIP operations.

Debug messages include:
- Error codes
- Error contexts
- Error messages

## Usage Examples

### Basic Error Handling

```clarion
MyZip ZipToolsClass
Result LONG

! Create a ZIP file
Result = MyZip.CreateZipFile(FileQueue, MyZip.Options)
IF Result <> 0
  ! An error occurred, get the error message
  MESSAGE('Error creating ZIP file: ' & MyZip.GetErrorMessage())
END
```

### Setting and Retrieving Errors

```clarion
MyErrors ZipErrorClass
ErrorCode LONG
ErrorMessage STRING(260)

! Set an error with context
MyErrors.SetError('CreateZipFile', CZ_ZIP_ERR_FILE_OPEN)

! Get the error information
ErrorCode = MyErrors.GetErrorCode()
ErrorMessage = MyErrors.GetErrorMessage()

! Display the error
MESSAGE('Error ' & ErrorCode & ': ' & ErrorMessage)
```

### Using Legacy Error Handling

```clarion
MyZip ZipToolsClass
ErrorMessage STRING(260)

! Perform an operation that might fail
IF MyZip.ExtractZipFile(UnzipOpts) <> 0
  ! Get the error message using the legacy method
  ErrorMessage = MyZip.GetzError()
  
  ! Display the error
  MESSAGE('Error extracting ZIP file: ' & ErrorMessage)
END
```

## Integration with Other Classes

The `ZipErrorClass` is used by all other classes in the ZIP library to centralize error handling:

- `ZipToolsClass` delegates error handling to ZipErrorClass
- `ZipWorkerClass` uses ZipErrorClass for thread-specific errors
- `ZipReaderClass` uses ZipErrorClass for extraction errors
- `ZipWriterClass` uses ZipErrorClass for compression errors
- `ZipApiWrapper` inherits from ZipErrorClass for low-level API errors

This centralized approach ensures consistent error reporting and handling throughout the library.

```clarion
! Example of error delegation in ZipToolsClass
ZipToolsClass.GetErrorMessage PROCEDURE(LONG zErrCode)
  CODE
  RETURN Self.Errors.GetErrorMessage(zErrCode)

ZipToolsClass.GetErrorCode PROCEDURE()
  CODE
  RETURN Self.Errors.GetErrorCode()

ZipToolsClass.GetzError PROCEDURE()
  CODE
  RETURN Self.Errors.GetzError()