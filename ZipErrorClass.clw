!---------------------------------------------------------
! ZipErrorClass.clw
!
! Implementation of the ZipErrorClass for centralized error handling
! Provides error code management and error message mapping for ZIP operations
!
! Last revision: 18-9-2025
!---------------------------------------------------------
          MEMBER
          MAP
            MODULE('KERNEL32.DLL')
              loc_ODS(*CSTRING lpOutputString),PASCAL,RAW,NAME('OutputDebugStringA')
            END
            ODS(STRING S),PRIVATE
          END
  Include('ZipErrorClass.inc'),ONCE
  INCLUDE('ZipEquates.inc'),ONCE

!====================================================================
czDebugOn     EQUATE(1)

!--------------------------------------------------------------------
! ZipErrorClass methods
!--------------------------------------------------------------------

!--------------------------------------------------------------------
! SetError - Sets the error code
!--------------------------------------------------------------------
! ZipErrorClass.SetError PROCEDURE(LONG Code)
!   CODE
!   SELF.zErrCode = Code
!   IF Self.zErrCode <> CZ_Z_OK
!     Self.TraceError('Error:')
!   END
!   RETURN

ZipErrorClass.SetError PROCEDURE(STRING Prefix,LONG Code)
  CODE
  SELF.zErrCode = Code
  IF Self.zErrCode <> CZ_Z_OK
    Self.TraceError(CLIP(Prefix) & ' Error:')
  END
  RETURN

!--------------------------------------------------------------------
! GetErrorCode - Returns the last error code
!--------------------------------------------------------------------
ZipErrorClass.GetErrorCode    PROCEDURE()
  CODE
  
  RETURN Self.zErrCode

!--------------------------------------------------------------------
! GetErrorMessage - Returns a descriptive error message for the given error code
! If no code is provided, uses the stored error code
!--------------------------------------------------------------------
ZipErrorClass.GetErrorMessage PROCEDURE(<LONG Code>)
ErrorString                 CSTRING(128)
UseCode                     LONG
  CODE
  ! If no code provided, use the stored error code
  IF OMITTED(Code)
    UseCode = Self.zErrCode
  ELSE
    UseCode = Code
  END

  CASE UseCode
  ! Standard zlib error codes
  OF CZ_Z_OK                   ; ErrorString = 'Success'
  OF CZ_Z_STREAM_END           ; ErrorString = 'End of stream'
  OF CZ_Z_NEED_DICT            ; ErrorString = 'Dictionary needed'
  OF CZ_Z_ERRNO                ; ErrorString = 'System error'
  OF CZ_Z_STREAM_ERROR         ; ErrorString = 'Stream error'
  OF CZ_Z_DATA_ERROR           ; ErrorString = 'Data error'
  OF CZ_Z_MEM_ERROR            ; ErrorString = 'Memory error'
  OF CZ_Z_BUF_ERROR            ; ErrorString = 'Buffer error'
  OF CZ_Z_VERSION_ERROR        ; ErrorString = 'Version error'

  ! Custom ZIP wrapper error codes
  OF CZ_ZIP_ERR_ALLOC          ; ErrorString = 'Allocation error'
  OF CZ_ZIP_PARAMERROR         ; ErrorString = 'Parameter error'
  OF CZ_ZIP_BADZIPFILE         ; ErrorString = 'Bad ZIP file'
  OF CZ_ZIP_INTERNALERROR      ; ErrorString = 'Internal error'
  OF CZ_ZIP_ERR_FILE_OPEN      ; ErrorString = 'Error opening file'
  OF CZ_ZIP_ERR_FILE_READ      ; ErrorString = 'Error reading file'
  OF CZ_ZIP_ERR_FILE_WRITE     ; ErrorString = 'Error writing file'
  OF CZ_ZIP_ERR_FILE_CLOSE     ; ErrorString = 'Error closing file'
  OF CZ_ZIP_ERR_EXTRACT        ; ErrorString = 'Error during extraction'
  OF CZ_ZIP_ERR_CREATE         ; ErrorString = 'Error creating ZIP'
  OF CZ_ZIP_ERR_ADD_FILE       ; ErrorString = 'Error adding file to ZIP'
  OF CZ_ZIP_ERR_INVALID_PARAMETER; ErrorString = 'Invalid parameter'
  OF CZ_ZIP_ERR_FILE_EXISTS    ; ErrorString = 'File exists and was not overwritten'

  ! Legacy error codes
  OF CZ_InputFileError         ; ErrorString = 'Input file error'
  OF CZ_OutputFileError        ; ErrorString = 'Output file error'
  OF CZ_OutOfMemoryError       ; ErrorString = 'Out of memory error'

  ELSE                         ; ErrorString = 'Unknown error'
  END

  ErrorString = CLIP(ErrorString) & ' (Code: ' & UseCode & ')'
  RETURN ErrorString

!--------------------------------------------------------------------
! GetzError - Legacy method for backward compatibility
!--------------------------------------------------------------------
ZipErrorClass.GetzError   PROCEDURE()
  CODE
  RETURN Self.GetErrorMessage()

!--------------------------------------------------------------------
! TraceError - Writes error information to debug output
!--------------------------------------------------------------------
ZipErrorClass.TraceError PROCEDURE(<String prefix>)
  CODE
  COMPILE('TraceOn',czDebugOn=1)
  ! Output to debug
  IF NOT OMITTED(prefix) AND CLIP(prefix) <> ''
    ODS(CLIP(Prefix) & ' - ' & Self.GetErrorMessage() & ' (Code: ' & Self.zErrCode & ')')
  ELSE
    ODS(CLIP(Self.GetErrorMessage()) & ' - ' & Self.GetErrorMessage() & ' (Code: ' & Self.zErrCode & ')')
  END
  !TraceOn

!--------------------------------------------------------------------
! ODS - Local wrapper around OutputDebugStringA to avoid API wrapper dependency
!--------------------------------------------------------------------
ODS               PROCEDURE(STRING S)
buf CSTRING(LEN(CLIP(S))+1)
  CODE
  buf = CLIP(S)
  LOC_ODS(buf)
  