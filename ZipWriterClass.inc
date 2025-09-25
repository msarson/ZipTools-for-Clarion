!=============================================================
! ZipWriterClass - Class for ZIP writing and compression operations
!
! This class handles all ZIP writing and compression operations,
! providing a clean separation of concerns from reading operations.
! It implements efficient compression algorithms with adaptive
! compression levels based on file types.
!
! Last revision: 23-9-2025
!=============================================================
    INCLUDE('ZipEquates.inc'),ONCE
    INCLUDE('ZipAPIWrapper.inc'),ONCE
    INCLUDE('ZipTypes.inc'),ONCE
    INCLUDE('ZipErrorClass.inc'),ONCE
    INCLUDE('ZipStringUtilsClass.inc'),ONCE

!*************************************************************************
! ZipWriterClass - Class for ZIP writing and compression operations
!*************************************************************************
ZipWriterClass   CLASS,TYPE,THREAD,MODULE('ZipWriterClass.clw'),LINK('ZipWriterClass.clw',_ZIPLinkMode_),DLL(_ZIPDllMode_)
ZipApi           &ZipAPIWrapper  ! Reference to the ZIP API wrapper
Errors           &ZipErrorClass  ! Reference to the error handling class
StringUtils      &ZipStringUtilsClass  ! Reference to the string utilities class
ZipCompBuf       &STRING         ! Fixed-size buffer for compressed data
ZipCompCap       ULONG           ! Capacity of compressed buffer (fixed at initialization)
Options          LIKE(ZipOptionsType)

! Constructor and Destructor
Construct        PROCEDURE()
Destruct         PROCEDURE()

! Core compression and writing methods
! Core file operations
CompressFileToBuffer    PROCEDURE(*CSTRING FileName, *ULONG OutUncSize, *ULONG OutCrc, *ULONG OutCompSize),LONG,VIRTUAL
ReadFileToBuffer        PROCEDURE(STRING FileName, *STRING BufRef, ULONG MaxSize, *ULONG OutSize, *ULONG OutCrc),LONG,VIRTUAL

! ZIP entry operations
WritePrecompressedToZip PROCEDURE(LONG ZipHandle, *CSTRING ZipEntryName, zip_fileinfo_s zipfi, LONG pCompBuf, ULONG CompSize, ULONG UncSize, ULONG Crc, *IMutex ZipMutex, BYTE UseStoreMethod, <*CSTRING OriginalFilePath>),LONG,VIRTUAL

! Utility methods
DumpHex  PROCEDURE(LONG pBuffer, LONG pLen),STRING
! Debug and error handling
Trace            PROCEDURE(STRING Message)
                END