
!---------------------------------------------------------
! ZipReaderClass.clw
!
! Implementation of the ZipReaderClass for ZIP reading and extraction
! Handles all reading and extraction operations for ZIP files
!
! Last revision: 18-9-2025
!---------------------------------------------------------
          MEMBER
  include('CWSYNCHM.INC'),once
          MAP
          END
  Include('ZipReaderClass.inc'),ONCE
  INCLUDE('CZipClass.inc'),ONCE

!====================================================================
czDebugOn     EQUATE(1)  ! Enable debug tracing to help diagnose issues

!--------------------------------------------------------------------
! ZipReaderClass methods
!--------------------------------------------------------------------
ZipReaderClass.Construct PROCEDURE()
  CODE
  Self.ZipApi &= NEW ZipApiWrapper
  Self.Errors &= NEW ZipErrorClass
  
ZipReaderClass.Destruct  PROCEDURE()
  CODE
  Dispose(Self.ZipApi)
  Dispose(Self.Errors)

!--------------------------------------------------------------------
! ExtractZipFile - Extracts all files from a ZIP file to a folder
!
! Parameters:
!   Options - Extraction options
!
! Returns:
!   0 on success, error code on failure
!--------------------------------------------------------------------
ZipReaderClass.ExtractZipFile PROCEDURE(*UnzipOptions Options)
unzFH             LONG
FileBuffer        &STRING
BufferSize        LONG(262144)        ! Default 256KB buffer size
BytesRead         LONG
BytesWritten      ULONG
FileHandle        LONG
FileName          CSTRING(65536)
FilePath          CSTRING(FILE:MaxFilePath*2)
DirectoryPath     CSTRING(FILE:MaxFilePath+1)
Result            LONG
OutputDir         CSTRING(FILE:MaxFilePath+1)
csZipName         CSTRING(FILE:MaxFilePath+1)
TotalFiles        LONG
CurrentFile       LONG
FileUtility       FileUtilitiesClass
ClosingWindow     BYTE(0)
FileInfo          LIKE(UnzipFileInfo)
FileOpened        BYTE(FALSE)
LocalPassword     CSTRING(256)
ReturnValue       LONG
PrevFileName      CSTRING(FILE:MaxFilePath+1)
Window            WINDOW('Extracting Files'),AT(,,218,72),CENTER,GRAY,FONT('Segoe UI',9)
                    PROGRESS,AT(13,21,187,24),USE(?PROGRESS1),RANGE(0,100)
                  END
  CODE
  Self.Trace('ExtractZipFile: Start')
  SetCursor(Cursor:Wait)
  Self.UnzipOptions = Options
  ! Reset any previous error state so success requires a new error to be set
  Self.Errors.SetError('',CZ_Z_OK)

  FileBuffer &= NEW STRING(BufferSize)

  OPEN(Window)
  IF NOT Self.UnzipOptions.ShowProgress
    Window{PROP:Hide} = TRUE
  END

  ACCEPT
    CASE EVENT()

    OF EVENT:OpenWindow
      OutputDir = CLIP(Self.UnzipOptions.OutputFolder)
      IF LEN(CLIP(OutputDir)) = 0 OR OutputDir[LEN(CLIP(OutputDir))] <> '\'
        OutputDir = CLIP(OutputDir) & '\'
      END

      csZipName = CLIP(Self.UnzipOptions.ZipName)
      unzFH = SELF.ZipApi.unzOpen(csZipName)
      IF unzFH <= 0
        Self.Errors.SetError('ExtractZipFile: Failed to open ZIP [' & csZipName & ']',CZ_ZIP_ERR_FILE_OPEN)
        ClosingWindow = 1
        POST(EVENT:CloseWindow)
      ELSE
        IF Self.UnzipOptions.ShowProgress
          Result = SELF.ZipApi.unzGoToFirstFile(unzFH)
          LOOP WHILE Result = CZ_Z_OK
            TotalFiles += 1
            Result = SELF.ZipApi.unzGoToNextFile(unzFH)
          END
          ?PROGRESS1{PROP:RangeLow}  = 0
          ?PROGRESS1{PROP:RangeHigh} = TotalFiles
          ?PROGRESS1{PROP:Progress}  = 0
          DISPLAY(?PROGRESS1)
        END

        Result = SELF.ZipApi.unzGoToFirstFile(unzFH)
        IF Result = CZ_Z_OK
          CurrentFile = 0
          POST(EVENT:User+1)
        ELSIF Result = CZ_END_OF_LIST
          SELF.Trace('ExtractZipFile: ZIP contains no files (END_OF_LIST)')
          ClosingWindow = 1
          POST(EVENT:CloseWindow)
        ELSE
          Self.Errors.SetError('ExtractZipFile: unzGoToFirstFile', Result)
          ClosingWindow = 1
          POST(EVENT:CloseWindow)
        END
      END

    OF EVENT:User+1
      IF NOT ClosingWindow
        CurrentFile += 1
        IF Self.UnzipOptions.ShowProgress
          ?PROGRESS1{PROP:Progress} = CurrentFile
          DISPLAY(?PROGRESS1)
        END

        CLEAR(FileInfo)
        Result = SELF.ZipApi.unzGetCurrentFileInfo(unzFH, FileInfo, FileName, SIZE(FileName), 0, 0, 0, 0)
        IF Result = CZ_Z_OK
          IF LEN(CLIP(FileName))
            FilePath = OutputDir & FileName
            Self.Trace('ExtractZipFile: Processing [' & CLIP(FileName) & ']')

            IF FileName[LEN(CLIP(FileName))] = '/' OR FileName[LEN(CLIP(FileName))] = '\' OR BAND(FileInfo.external_fa, CZ_FILE_ATTRIBUTE_DIRECTORY) <> 0
              Self.Trace('ExtractZipFile: Creating directory [' & CLIP(FilePath) & ']')
              IF NOT FileUtility.CreateDirectoriesFromPath(FilePath)
                Self.Errors.SetError('ExtractZipFile: Failed to create directory [' & CLIP(FilePath) & ']', CZ_ZIP_ERR_EXTRACT)
                ClosingWindow = 1
                POST(EVENT:CloseWindow)
              END
            ELSE
              DirectoryPath = FileUtility.PathOnly(FilePath)
              IF LEN(CLIP(DirectoryPath)) > 0
                IF NOT FileUtility.CreateDirectoriesFromPath(DirectoryPath)
                  Self.Errors.SetError('ExtractZipFile: Failed to ensure directory exists [' & CLIP(DirectoryPath) & ']', CZ_ZIP_ERR_EXTRACT)
                  ClosingWindow = 1
                  POST(EVENT:CloseWindow)
                END
              END

              ! Handle encrypted files
              IF BAND(FileInfo.flag,1) <> 0
                IF LEN(CLIP(Self.UnzipOptions.Password)) = 0
                  Self.Errors.SetError('ExtractZipFile: Encrypted file, no password provided [' & CLIP(FileName) & ']', CZ_ZIP_ERR_INVALID_PARAMETER)
                  ClosingWindow = 1
                  POST(EVENT:CloseWindow)
                ELSE
                  LocalPassword = CLIP(Self.UnzipOptions.Password)
                  SELF.Trace('ExtractZipFile: Encrypted file, using password [' & LocalPassword & ']')
                  Result = SELF.ZipApi.unzOpenCurrentFilePassword(unzFH, LocalPassword)
                  SELF.Trace('ExtractZipFile: Result from unzOpenCurrentFilePassword = ' & Result)
                END
              ELSE
                Result = SELF.ZipApi.unzOpenCurrentFile(unzFH)
                SELF.Trace('ExtractZipFile: Result from unzOpenCurrentFile = ' & Result)
              END

              FileOpened = CHOOSE(Result = CZ_Z_OK,1,0)

              IF FileOpened
                FileHandle = SELF.ZipApi.CreateFile(FilePath, CZ_GENERIC_WRITE, 0,,CZ_CREATE_ALWAYS, CZ_FILE_ATTRIBUTE_NORMAL, 0)
                IF FileHandle <> CZ_INVALID_HANDLE_VALUE
                  Self.Trace('ExtractZipFile: Writing to [' & CLIP(FilePath) & ']')
                  LOOP
                    BytesRead = SELF.ZipApi.unzReadCurrentFile(unzFH, FileBuffer, SIZE(FileBuffer))
                    IF BytesRead < 0
                      Self.Errors.SetError('ExtractZipFile: Read error = ' & BytesRead, CZ_ZIP_ERR_FILE_READ)
                      ClosingWindow = 1
                      BREAK
                    END
                    IF BytesRead = 0
                      BREAK
                    END
                    IF NOT SELF.ZipApi.WriteFile(FileHandle, FileBuffer, BytesRead, BytesWritten) OR BytesWritten <> BytesRead
                      Self.Errors.SetError('ExtractZipFile: Write error, requested ' & BytesRead & ' wrote ' & BytesWritten, CZ_ZIP_ERR_FILE_WRITE)
                      ClosingWindow = 1
                      BREAK
                    END
                  END
                  SELF.ZipApi.CloseFile(FileHandle)
                ELSE
                  Self.Errors.SetError('ExtractZipFile: Failed to create output file [' & CLIP(FilePath) & ']', CZ_ZIP_ERR_FILE_WRITE)
                END

                Result = SELF.ZipApi.unzCloseCurrentFile(unzFH)
                IF Result <> CZ_Z_OK
                  Self.Errors.SetError('ExtractZipFile: unzCloseCurrentFile returned error ', CZ_ZIP_ERR_EXTRACT)
                END
                FileOpened = FALSE
              ELSE
                Self.Errors.SetError('ExtractZipFile: Failed to open file [' & CLIP(FileName) & ']',Result)
                ClosingWindow = 1
                POST(EVENT:CloseWindow)
              END
            END
          END
        ELSE
          Self.Errors.SetError('ExtractZipFile: unzGetCurrentFileInfo failed', CZ_ZIP_ERR_EXTRACT)
          ClosingWindow = 1
          POST(EVENT:CloseWindow)
        END

        IF FileOpened
          SELF.Trace('ExtractZipFile: Cleanup closing file left open [' & CLIP(FileName) & ']')
          SELF.ZipApi.unzCloseCurrentFile(unzFH)
          FileOpened = FALSE
        END

        PrevFileName = FileName
        Result = SELF.ZipApi.unzGoToNextFile(unzFH)
        SELF.Trace('ExtractZipFile: unzGoToNextFile returned ' & Result)

        IF Result = CZ_Z_OK AND NOT ClosingWindow
          POST(EVENT:User+1)
        ELSIF Result = CZ_END_OF_LIST
          SELF.Trace('ExtractZipFile: Reached end of file list')
          ClosingWindow = 1
          POST(EVENT:CloseWindow)
        ELSE
          IF Result <> CZ_Z_OK
            Self.Errors.SetError('ExtractZipFile: Error from unzGoToNextFile',Result)
          END
          ClosingWindow = 1
          POST(EVENT:CloseWindow)
        END
      END

    OF EVENT:CloseWindow
      Self.Trace('ExtractZipFile: Closing window event received')
      BREAK
    END
  END

  ! Prepare return value
  IF ClosingWindow = 0 AND Self.Errors.GetErrorCode() = CZ_ZIP_OK
    Self.Trace('ExtractZipFile: Completed successfully')
    ReturnValue = CZ_ZIP_OK
  ELSE
    Self.Trace('ExtractZipFile: Ended with errors (ErrorCode=' & Self.Errors.GetErrorCode() & ')')
    ReturnValue = Self.Errors.GetErrorCode()
  END

  CLOSE(Window)

  IF FileOpened
    SELF.Trace('ExtractZipFile: Cleanup closing file still open')
    Result = SELF.ZipApi.unzCloseCurrentFile(unzFH)
    IF Result <> CZ_Z_OK
      Self.Errors.SetError('ExtractZipFile: Cleanup close current file error ', CZ_ZIP_ERR_EXTRACT)
    END
    FileOpened = FALSE
  END

  IF unzFH > 0
    Result = SELF.ZipApi.unzClose(unzFH)
    IF Result <> CZ_Z_OK
      Self.Errors.SetError('ExtractZipFile: Failed to Close File', CZ_ZIP_ERR_EXTRACT)
    END
  END

  DISPOSE(FileBuffer)

  SetCursor()
  Self.Trace('ExtractZipFile: End with return value ' & ReturnValue)

  RETURN ReturnValue
ZipReaderClass.GetZipTotalSize PROCEDURE(*STRING ZipFileName)
unzFH                       LONG
FileName                    CSTRING(FILE:MaxFilePath+1)
Result                      LONG,AUTO
csZipName                   CSTRING(FILE:MaxFilePath+1)
TotalSize                   LONG
FileInfo                    LIKE(UnzipFileInfo)
LastError                   LONG
CurrentDir                  CSTRING(FILE:MaxFilePath+1)  ! Current directory
AbsolutePath                CSTRING(FILE:MaxFilePath+1)  ! Absolute path to ZIP file
FileHandle                  LONG
  CODE
  Self.Trace('GetZipTotalSize: Start') 
 

 ! Initialize
  csZipName = CLIP(ZipFileName)
   Self.Trace('GetZipTotalSize: ZIP file = [' & csZipName & ']') 
  Self.Errors.SetError('',CZ_ZIP_OK)  ! Reset error code
  TotalSize = 0
 
 ! Open the ZIP file - try to use absolute path if relative
  IF csZipName[1:2] = '.\' OR csZipName[1:2] = './'
   ! Convert relative path to absolute
    CurrentDir = ''
    SELF.ZipApi.GetCurrentDirectory(SIZE(CurrentDir), CurrentDir)
    IF LEN(CLIP(CurrentDir)) > 0
      IF CurrentDir[LEN(CLIP(CurrentDir))] <> '\'
        CurrentDir = CLIP(CurrentDir) & '\'
      END
      AbsolutePath = CLIP(CurrentDir) & SUB(csZipName, 3, LEN(CLIP(csZipName)) - 2)
       Self.Trace('GetZipTotalSize: Converting relative path [' & csZipName & '] to absolute path [' & AbsolutePath & ']') 
      csZipName = AbsolutePath
    END
  END
 
 ! Try to open the ZIP file
   Self.Trace('GetZipTotalSize: Attempting to open ZIP file: [' & csZipName & ']') 
  unzFH = SELF.ZipApi.unzOpen(csZipName)
  IF unzFH <= 0
    LastError = SELF.ZipApi.GetLastError()
    Self.Errors.SetError('GetZipTotalSize: Failed to open ZIP file: [' & csZipName & ']',CZ_ZIP_ERR_FILE_OPEN)
   
   ! Check if the file exists
    FileHandle = SELF.ZipApi.CreateFile(csZipName, CZ_GENERIC_READ, CZ_FILE_SHARE_READ,,CZ_OPEN_EXISTING, 0, 0)
    IF FileHandle = CZ_INVALID_HANDLE_VALUE
       Self.Errors.SetError('GetZipTotalSize: ZIP file does not exist or cannot be accessed: [' & csZipName & ']', FileHandle) 
    ELSE
      SELF.ZipApi.CloseFile(FileHandle)
       Self.Trace('GetZipTotalSize: ZIP file exists but could not be opened by unzOpen') 
    END
   
    RETURN -1
  END
 
 ! Go to the first file in the ZIP
  Result = SELF.ZipApi.unzGoToFirstFile(unzFH)
   Self.Trace('GetZipTotalSize: Result after GoToFirstFile = ' & Result) 
 
 ! Loop through all files in the ZIP
  LOOP WHILE Result = CZ_Z_OK
   ! Get the current file info
    IF SELF.ZipApi.unzGetCurrentFileInfo(unzFH, FileInfo, FileName, SIZE(FileName), 0, 0, 0, 0) <> CZ_Z_OK
      Self.Errors.SetError('GetZipTotalSize: Error getting file info',CZ_ZIP_ERR_EXTRACT)
      BREAK
    END
   
   ! Skip empty file names or single slashes
    IF LEN(CLIP(FileName)) = 0 OR CLIP(FileName) = '\' OR CLIP(FileName) = '/'
       Self.Trace('GetZipTotalSize: Skipping empty or root entry: [' & FileName & ']') 
      Result = SELF.ZipApi.unzGoToNextFile(unzFH)
      CYCLE
    END
   
   ! Add the uncompressed size to the total
    TotalSize += FileInfo.uncompressed_size
     Self.Trace('GetZipTotalSize: Added ' & FileInfo.uncompressed_size & ' bytes for [' & FileName & ']') 
   
   ! Go to the next file in the ZIP
    Result = SELF.ZipApi.unzGoToNextFile(unzFH)
  END
 
 ! Close the ZIP file
  SELF.ZipApi.unzClose(unzFH)
 
   Self.Trace('GetZipTotalSize: End - Total size = ' & TotalSize & ' bytes') 
  RETURN CHOOSE(Self.Errors.GetErrorCode() = CZ_ZIP_OK, TotalSize, -1)

!--------------------------------------------------------------------
! GetZipFileCount - Get the number of files in a ZIP file
!
! Parameters:
!   ZipFileName - Name of the ZIP file to read
!
! Returns:
!   The file count, or -1 on error
!--------------------------------------------------------------------
ZipReaderClass.GetZipFileCount PROCEDURE(*STRING ZipFileName)
unzFH                       LONG
FileName                    CSTRING(FILE:MaxFilePath+1)
Result                      LONG,AUTO
csZipName                   CSTRING(FILE:MaxFilePath+1)
FileCount                   LONG
LastError                   LONG
CurrentDir                  CSTRING(FILE:MaxFilePath+1)  ! Current directory
AbsolutePath                CSTRING(FILE:MaxFilePath+1)  ! Absolute path to ZIP file
FileHandle                        LONG
FileInfo  LIKE(UnzipFileInfo)
  CODE
   Self.Trace('GetZipFileCount: Start') 
 
 ! Initialize
  csZipName = CLIP(ZipFileName)
   Self.Trace('GetZipFileCount: ZIP file = [' & csZipName & ']') 
  Self.Errors.SetError('',CZ_ZIP_OK)  ! Reset error code
  FileCount = 0
 
 ! Open the ZIP file - try to use absolute path if relative
  IF csZipName[1:2] = '.\' OR csZipName[1:2] = './'
   ! Convert relative path to absolute
    CurrentDir = ''
    SELF.ZipApi.GetCurrentDirectory(SIZE(CurrentDir), CurrentDir)
    IF LEN(CLIP(CurrentDir)) > 0
      IF CurrentDir[LEN(CLIP(CurrentDir))] <> '\'
        CurrentDir = CLIP(CurrentDir) & '\'
      END
      AbsolutePath = CLIP(CurrentDir) & SUB(csZipName, 3, LEN(CLIP(csZipName)) - 2)
       Self.Trace('GetZipFileCount: Converting relative path [' & csZipName & '] to absolute path [' & AbsolutePath & ']') 
      csZipName = AbsolutePath
    END
  END
 
 ! Try to open the ZIP file
   Self.Trace('GetZipFileCount: Attempting to open ZIP file: [' & csZipName & ']') 
  unzFH = SELF.ZipApi.unzOpen(csZipName)
  IF unzFH <= 0
    LastError = SELF.ZipApi.GetLastError()
    Self.Errors.SetError('GetZipFileCount: Failed to open ZIP file: [' & csZipName & ']',CZ_ZIP_ERR_FILE_OPEN)
   
   ! Check if the file exists
    FileHandle = SELF.ZipApi.CreateFile(csZipName, CZ_GENERIC_READ, CZ_FILE_SHARE_READ,,CZ_OPEN_EXISTING, 0, 0)
    IF FileHandle = CZ_INVALID_HANDLE_VALUE
       Self.Errors.SetError('GetZipFileCount: ZIP file does not exist or cannot be accessed: [' & csZipName & ']', CZ_INVALID_HANDLE_VALUE)
    ELSE
      SELF.ZipApi.CloseFile(FileHandle)
       Self.Trace('GetZipFileCount: ZIP file exists but could not be opened by unzOpen') 
    END
   
    RETURN -1
  END
 
 ! Go to the first file in the ZIP
  Result = SELF.ZipApi.unzGoToFirstFile(unzFH)
   Self.Trace('GetZipFileCount: Result after GoToFirstFile = ' & Result) 
 
 ! Loop through all files in the ZIP
  LOOP WHILE Result = CZ_Z_OK
   ! Get the current file info
    IF SELF.ZipApi.unzGetCurrentFileInfo(unzFH, FileInfo, FileName, SIZE(FileName), 0, 0, 0, 0) <> CZ_Z_OK
      Self.Errors.SetError('GetZipFileCount: Error getting file info', CZ_ZIP_ERR_EXTRACT)
      BREAK
    END
   
   ! Skip empty file names or single slashes
    IF LEN(CLIP(FileName)) = 0 OR CLIP(FileName) = '\' OR CLIP(FileName) = '/'
       Self.Trace('GetZipFileCount: Skipping empty or root entry: [' & FileName & ']') 
      Result = SELF.ZipApi.unzGoToNextFile(unzFH)
      CYCLE
    END
   
   ! Increment the file count
    FileCount += 1
   
   ! Go to the next file in the ZIP
    Result = SELF.ZipApi.unzGoToNextFile(unzFH)
  END
 
 ! Close the ZIP file
  SELF.ZipApi.unzClose(unzFH)
 
   Self.Trace('GetZipFileCount: End - Found ' & FileCount & ' files') 
  RETURN CHOOSE(Self.Errors.GetErrorCode() = CZ_ZIP_OK, FileCount, -1)

!--------------------------------------------------------------------
! GetZipContents - Get contents of a ZIP file without extracting
!
! Parameters:
!   ZipFileName - Name of the ZIP file to read
!   ContentsQueue - Queue to populate with ZIP file contents
!
! Returns:
!   TRUE if successful, FALSE if failed
!--------------------------------------------------------------------
ZipReaderClass.GetZipContents  PROCEDURE(*STRING ZipFileName, *ZipQ ContentsQueue)
unzFH                       LONG
FileName                    CSTRING(FILE:MaxFilePath+1)
Result                      LONG,AUTO
csZipName                   CSTRING(FILE:MaxFilePath+1)
FileInfo                    Like(UnzipFileInfo)
  
LastError                   LONG
CurrentDir                  CSTRING(FILE:MaxFilePath+1)  ! Current directory
AbsolutePath                CSTRING(FILE:MaxFilePath+1)  ! Absolute path to ZIP file
FileHandle                  LONG

FileInfoSplit               GROUP,OVER(FileInfo.DosDate)
DateWord                      USHORT   ! upper 16 bits
TimeWord                      USHORT   ! lower 16 bits
                            END
  CODE
   Self.Trace('GetZipContents: Start') 
  SetCursor(Cursor:Wait)
 
 ! Initialize
  csZipName = CLIP(ZipFileName)
   Self.Trace('GetZipContents: ZIP file = [' & csZipName & ']') 
  Self.Errors.SetError('', CZ_ZIP_OK)  ! Reset error code
 
 ! Clear the contents queue
  LOOP WHILE RECORDS(ContentsQueue)
    GET(ContentsQueue, 1)
    DELETE(ContentsQueue)
  END
 
 ! Open the ZIP file - try to use absolute path if relative
  IF csZipName[1:2] = '.\' OR csZipName[1:2] = './'
   ! Convert relative path to absolute
    CurrentDir = ''
    SELF.ZipApi.GetCurrentDirectory(SIZE(CurrentDir), CurrentDir)
    IF LEN(CLIP(CurrentDir)) > 0
      IF CurrentDir[LEN(CLIP(CurrentDir))] <> '\'
        CurrentDir = CLIP(CurrentDir) & '\'
      END
      AbsolutePath = CLIP(CurrentDir) & SUB(csZipName, 3, LEN(CLIP(csZipName)) - 2)
       Self.Trace('GetZipContents: Converting relative path [' & csZipName & '] to absolute path [' & AbsolutePath & ']') 
      csZipName = AbsolutePath
    END
  END
 
 ! Try to open the ZIP file
   Self.Trace('GetZipContents: Attempting to open ZIP file: [' & csZipName & ']') 
  unzFH = SELF.ZipApi.unzOpen(csZipName)
  IF unzFH <= 0
    LastError = SELF.ZipApi.GetLastError()
    Self.Errors.SetError('GetZipContents: Failed to open ZIP file: [' & csZipName & ']' , CZ_ZIP_ERR_FILE_OPEN)
   
   ! Check if the file exists
    FileHandle = SELF.ZipApi.CreateFile(csZipName, CZ_GENERIC_READ, CZ_FILE_SHARE_READ,,CZ_OPEN_EXISTING, 0, 0)
    IF FileHandle = CZ_INVALID_HANDLE_VALUE
       Self.Trace('GetZipContents: ZIP file does not exist or cannot be accessed: [' & csZipName & '] (Error: ' & SELF.ZipApi.GetLastError() & ')') 
    ELSE
      SELF.ZipApi.CloseFile(FileHandle)
       Self.Trace('GetZipContents: ZIP file exists but could not be opened by unzOpen') 
    END
   
    SetCursor()
    RETURN FALSE
  END
 
 ! Go to the first file in the ZIP
  Result = SELF.ZipApi.unzGoToFirstFile(unzFH)
   Self.Trace('GetZipContents: Result after GoToFirstFile = ' & Result) 
 
 ! Loop through all files in the ZIP
  LOOP WHILE Result = CZ_Z_OK
   ! Get the current file info
    IF SELF.ZipApi.unzGetCurrentFileInfo(unzFH, FileInfo, FileName, SIZE(FileName), 0, 0, 0, 0) <> CZ_Z_OK
      Self.Errors.SetError('GetZipContents: Error getting file info', CZ_ZIP_ERR_EXTRACT)
      BREAK
    END
   
   ! Skip empty file names or single slashes
    IF LEN(CLIP(FileName)) = 0 OR CLIP(FileName) = '\' OR CLIP(FileName) = '/'
       Self.Trace('GetZipContents: Skipping empty or root entry: [' & FileName & ']') 
      Result = SELF.ZipApi.unzGoToNextFile(unzFH)
      CYCLE
    END
   
     Self.Trace('GetZipContents: Processing entry: [' & FileName & ']') 
   
   ! Add the file info to the queue
    ContentsQueue.ZipFileName = FileName
    ContentsQueue.version = FileInfo.version
    ContentsQueue.version_needed = FileInfo.version_needed
    ContentsQueue.flag = FileInfo.flag
    ContentsQueue.compression_method = FileInfo.compression_method
   
   ! Convert CRC from ULONG to STRING(8)
    ContentsQueue.crc = FileInfo.crc
   
    ContentsQueue.compressed_size = FileInfo.compressed_size
    ContentsQueue.uncompressed_size = FileInfo.uncompressed_size
   
   ! Extract date and time from DOS date
    ContentsQueue.ZipFileDate = FileInfoSplit.DateWord
    ContentsQueue.ZipFileTime = FileInfoSplit.TimeWord

   
   ! Check if this is a directory entry (ends with '/' or '\')
    ContentsQueue.IsFolder = CHOOSE((INSTRING('/', FileName, -1, LEN(CLIP(FileName))) = LEN(CLIP(FileName)) OR INSTRING('\', FileName, -1, LEN(CLIP(FileName))) = LEN(CLIP(FileName))), 1, 0)
   
    ADD(ContentsQueue)
     Self.Trace('GetZipContents: Added entry to queue: [' & FileName & ']') 
   
   ! Go to the next file in the ZIP
    Result = SELF.ZipApi.unzGoToNextFile(unzFH)
  END
 
 ! Close the ZIP file
  SELF.ZipApi.unzClose(unzFH)
 
  SetCursor()
   Self.Trace('GetZipContents: End - Found ' & RECORDS(ContentsQueue) & ' entries') 
  RETURN CHOOSE(Self.Errors.GetErrorCode() = CZ_ZIP_OK, TRUE, FALSE)

ZipReaderClass.Trace   PROCEDURE(STRING pmsg)
cmsg                CSTRING(LEN(CLIP(pmsg)) + 1)
  CODE
  ! Only log if debug mode is on
  COMPILE('TraceOn',czDebugOn=1); 
    CMsg = pmsg
    SELF.ZipApi.ODS(CMsg)
  !TraceOn

