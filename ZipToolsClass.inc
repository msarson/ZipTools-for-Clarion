!=============================================================
! ZipToolsClass - Simplified zLib wrapper class
!
! This class provides a streamlined wrapper for the zlibwapi.dll functions
! to create, manipulate, and extract ZIP files with improved performance
! and maintainability. The implementation uses fixed-size buffers and
! simplified threading model for better reliability and easier maintenance.
!
! Last revision: 14-9-2025
!=============================================================
  INCLUDE('ZipTypes.inc'),ONCE
  INCLUDE('ZipEquates.inc'),ONCE
  INCLUDE('ZipAPIWrapper.inc'),ONCE
  INCLUDE('ZipFileUtilitiesClass.inc'),ONCE
  INCLUDE('ZipErrorClass.inc'),ONCE
  INCLUDE('ZipWorkerClass.inc'),ONCE
  INCLUDE('ZipWriterClass.inc'),ONCE
  INCLUDE('ZipReaderClass.inc'),ONCE
  INCLUDE('ZipStringUtilsClass.inc'),ONCE


!*************************************************************************
! ZipToolsClass - Main class for ZIP operations
!*************************************************************************
ZipToolsClass     CLASS,TYPE,THREAD,MODULE('ZipToolsClass.clw'),LINK('ZipToolsClass.clw',_ZIPLinkMode_),DLL(_ZIPDllMode_)
ZipApi          &ZipAPIWrapper  ! Reference to the ZIP API wrapper
Writer          &ZipWriterClass ! Reference to the ZIP writer class
Reader          &ZipReaderClass ! Reference to the ZIP reader class
Errors          &ZipErrorClass  ! Reference to the error handling class
StringUtils     &ZipStringUtilsClass ! Reference to the string utilities class
! Helper methods for thread management

! Constructor and Destructor
Construct       PROCEDURE()
Destruct        PROCEDURE()
Options         LIKE(ZipOptionsType)
UnzipOptions    LIKE(UnzipOptionsType)
! Private properties

Comment         CSTRING(1001)             ! Comment for the ZIP file


BaseFolder      CSTRING(FILE:MaxFilePath+1)  ! Base folder path for relative paths in ZIP

! Compression settings
! The class now uses an adaptive compression strategy that automatically selects
! the optimal compression method and level based on file type and size:
!
! Adaptive Compression Rules:
! 1. If file extension is one of the already-compressed formats (PNG, JPG, JPEG, GIF, ZIP, RAR,
!    MP3, MP4, PACK, JAR, APK, AAC, WEBP, PDF, DOCX, XLSX, PPTX, OGG, 7Z, BZ2, GZ, TGZ, EPUB, MOBI)
!    ? use STORE method (no compression)
! 2. If file is <1 KB ? use STORE method
! 3. If file extension is TXT, XML, HTML, CSS, JS, CSV, LOG ? use level 9 (maximum compression)
! 4. If file size is >50 MB and extension is EXE, DLL, BIN ? use level 1 (fastest)
! 5. Otherwise ? use level 6 (balanced default)
!
CompressionMethod   LONG              ! Compression method (default: Z_DEFLATED)

! Public methods
! Create a ZIP file from a queue of files
! CreateZipFile           PROCEDURE(*STRING ZipFileName, *ZipQueueType FileQueue, <UNSIGNED ProgressFEQ>),LONG

AddFilesToThreadQueue   PROCEDURE(*ZipWorkerClass ThreadData, *ZipQueueType FileQueue, LONG StartIdx, LONG EndIdx),LONG,PROC
AddFilesToThreadQueueBySize PROCEDURE(*ZipWorkerClass ThreadData, *ZipQueueType FileQueue, LONG ThreadNum, LONG ThreadCount, ULONG TotalFileSize),LONG,PROC
! Select files to add to a ZIP (without embedded window code)
! Returns TRUE if files were selected, FALSE if cancelled
SelectFilesToZip    PROCEDURE(*ZipQueueType FileQueue),BOOL,VIRTUAL

! Select a folder to add to a ZIP (without embedded window code)
! Returns TRUE if a folder was selected, FALSE if cancelled
! IncludeBaseFolder: TRUE to include the folder itself in the zip, FALSE to make folder contents the root
SelectFolderToZip   PROCEDURE(*ZipQueueType FileQueue, BYTE IncludeBaseFolder=TRUE),BOOL,VIRTUAL


! Get error message for the last error code (delegates to Errors)
GetErrorMessage PROCEDURE(LONG zErrCode),STRING

!Legacy error handling (delegates to Errors)
GetzError       PROCEDURE(),STRING
! Get the last error code (delegates to Errors)
GetErrorCode    PROCEDURE(),LONG


! Write a debug message to the debug output
Trace           PROCEDURE(STRING Message)
ExtractZipFile  PROCEDURE(*UnzipOptionsType Options),LONG,VIRTUAL
CreateZipFile   PROCEDURE(*ZipQueueType FileQueue, *ZipOptionsType Options),LONG,VIRTUAL
Reset           PROCEDURE()
              END



ThreadDataGroup   GROUP
Ref1                &ZipWorkerClass
Ref2                &ZipWorkerClass
Ref3                &ZipWorkerClass
Ref4                &ZipWorkerClass
Ref5                &ZipWorkerClass
Ref6                &ZipWorkerClass
Ref7                &ZipWorkerClass
Ref8                &ZipWorkerClass
                  END