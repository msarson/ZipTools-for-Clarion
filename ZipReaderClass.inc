!=============================================================
! ZipReaderClass - Class for ZIP reading and extraction operations
!
! This class handles all ZIP reading and extraction operations,
! providing a clean separation of concerns from writing operations.
! It implements efficient extraction with password support and
! customizable overwrite behavior.
!
! Last revision: 23-9-2025
!=============================================================
    INCLUDE('ZipEquates.inc'),ONCE
    INCLUDE('ZipAPIWrapper.inc'),ONCE
    INCLUDE('ZipTypes.inc'),ONCE
    INCLUDE('FileUtilitiesClass.inc'),ONCE
    INCLUDE('ZipErrorClass.inc'),ONCE

!*************************************************************************
! ZipReaderClass - Class for ZIP reading and extraction operations
!*************************************************************************
ZipReaderClass   CLASS,TYPE,THREAD,MODULE('ZipReaderClass.clw'),LINK('ZipReaderClass.clw',_ZIPLinkMode_),DLL(_ZIPDllMode_)
ZipApi           &ZipAPIWrapper  ! Reference to the ZIP API wrapper
Errors           &ZipErrorClass  ! Reference to the error handling class
UnzipOptions     LIKE(UnzipOptionsType)

! Constructor and Destructor
Construct        PROCEDURE()
Destruct         PROCEDURE()

! Core extraction and reading methods
! Extraction operations
ExtractZipFile   PROCEDURE(*UnzipOptionsType Options),LONG  ! Extract all files from a ZIP

! ZIP information methods
GetZipContents   PROCEDURE(*STRING ZipFileName, *ZipQueueType ContentsQueue),BOOL  ! Get list of files in ZIP
GetZipFileCount  PROCEDURE(*STRING ZipFileName),LONG  ! Get number of files in ZIP
GetZipTotalSize  PROCEDURE(*STRING ZipFileName),LONG  ! Get total uncompressed size of ZIP contents

! Debug and error handling
Trace            PROCEDURE(STRING Message)
                END