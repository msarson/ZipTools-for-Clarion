
!---------------------------------------------------------
! ZipWorkerClass.inc
!
! Thread worker class for parallel ZIP file operations
! Handles file compression and writing in separate threads
!
! Last revision: 23-9-2025
!---------------------------------------------------------
    INCLUDE('ZipEquates.inc'),ONCE
    INCLUDE('ZipAPIWrapper.inc'),ONCE
    INCLUDE('ZipFileUtilitiesClass.inc'),ONCE
    INCLUDE('ZipErrorClass.inc'),ONCE

!*************************************************************************
! Thread data class for passing data to the thread
!*************************************************************************
ZipWorkerClass   CLASS,TYPE,THREAD,MODULE('ZipWorkerClass.clw'),LINK('ZipWorkerClass.clw')!,_ZIPLinkMode_),DLL(_ZIPDllMode_)
ZipApi        &ZipAPIWrapper  ! Reference to the ZIP API wrapper
Writer        &ZipWriterClass ! Reference to the ZIP writer class
Errors        &ZipErrorClass  ! Reference to the error handling class
ZipHandle           LONG        ! Handle to the ZIP file
ErrorCount          LONG        ! Number of errors encountered
CallerThread        LONG        ! Thread ID of the caller
ThreadNumber        LONG        ! Thread number (1-8) for identification
ZipMutex            &IMutex     ! Mutex for ZIP file access
! Reference to parent CZipClass is no longer needed - worker is self-contained
FileQueue           &ZipQueueType       ! Reference to the file queue
StartTime           LONG        ! Thread start time (for timing measurements)
EndTime             LONG        ! Thread end time (for timing measurements)
ElapsedTime         REAL        ! Elapsed time in seconds
RawBuf              &STRING     ! Buffer for raw file data
RawCap              ULONG       ! Capacity of raw buffer
CompBuf             &STRING     ! Buffer for compressed data
CompCap             ULONG       ! Capacity of compressed buffer
StartIdx            LONG        ! Start index for this thread's file slice
EndIdx              LONG        ! End index for this thread's file slice
SourceQueue         &ZipQueueType       ! Reference to the source file queue
BaseFolder      CSTRING(FILE:MaxFilePath+1)  ! Base folder path for relative paths in ZIP
Options         LIKE(ZipOptionsType)

! BaseFolder is now defined above and no longer commented out
Construct           PROCEDURE()
Destruct            PROCEDURE()
! Legacy initialization method - replaced by InitThreadData
Init                PROCEDURE(LONG pStartIdx, LONG pEndIdx, *ZipQueueType pSourceQueue, LONG pZipHandle, LONG ShowProgress, *IMutex pZipMutex, LONG pThreadNum, *CZipClass pZipClass)
! Modern initialization method with improved workload distribution
InitThreadData      PROCEDURE(LONG ZipHandle, *IMutex ZipMutex, *ZipQueueType FileQueue, LONG ThreadNum, LONG FilesPerThread, LONG ThreadCount, *CZipClass zipBase, <ULONG TotalFileSize>),PROC
BuildQueue          PROCEDURE(),LONG,PROC
Kill                PROCEDURE()
! Debug and error handling
Trace                   PROCEDURE(STRING Message)
WritePrecompressedToZip PROCEDURE(LONG ZipHandle, *CSTRING ZipEntryName, *zip_fileinfo_s zipfi, LONG pCompBuf, ULONG CompSize, ULONG UncSize, ULONG Crc, *IMutex ZipMutex, BYTE UseStoreMethod, *CSTRING ZipPath),LONG,Virtual
CompressFileToBuffer    PROCEDURE(*CSTRING FileName, *ULONG OutUncSize, *ULONG OutCrc, *ULONG OutCompSize),LONG
ReadFileToBuffer        PROCEDURE(STRING FileName, *STRING BufRef, ULONG MaxSize, *ULONG OutSize, *ULONG OutCrc),LONG
                  END