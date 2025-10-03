          MEMBER
  include('CWSYNCHM.INC'),once
        MAP
        END
  Include('ZipWorkerClass.inc'),ONCE
  INCLUDE('ZipToolsClass.inc'),ONCE
!--------------------------------------------------------------------
! ZipWorkerClass methods
!
! This class handles file compression and writing operations in worker threads.
! Each thread processes a subset of files to be added to the ZIP archive.
!--------------------------------------------------------------------
ZipWorkerClass.Construct PROCEDURE()
  CODE
  SELF.ErrorCount = 0
  SELF.ThreadNumber = 0  ! Initialize thread number
  SELF.StartIdx = 0
  SELF.EndIdx = 0
  SELF.SourceQueue &= NULL
  SELF.StartTime = 0
  SELF.EndTime = 0
  SELF.ElapsedTime = 0
  
  ! Initialize buffers with default capacity
  SELF.RawBuf &= NEW STRING(2097152)  ! 2MB initial capacity
  SELF.RawCap = 2097152
  
  SELF.CompBuf &= NEW STRING(4194304) ! 4MB initial capacity for better compression
  SELF.CompCap = 4194304
  
  Self.ZipApi &= NEW ZipApiWrapper
  Self.Writer &= NEW ZipWriterClass
  Self.Errors &= NEW ZipErrorClass
  Self.StringUtils &= NEW ZipStringUtilsClass
  
ZipWorkerClass.Destruct  PROCEDURE()
  CODE
  DISPOSE(Self.CompBuf)
  Self.CompBuf &= NULL
  DISPOSE(Self.RawBuf)
  Self.RawBuf &= NULL
  Dispose(Self.ZipApi)
  Dispose(Self.Writer)
  Dispose(Self.Errors)
  Dispose(Self.StringUtils)
  ! Call Kill to clean up remaining resources (buffers are already disposed above)
  SELF.Kill()

ZipWorkerClass.Kill  PROCEDURE()
  CODE
  ! Clean up references


  IF NOT Self.ZipMutex &= NULL
    ! Don't dispose ZipMutex as it's managed by the main thread
    SELF.ZipMutex &= NULL
  END
  
  ! Clean up buffer memory only if not already disposed
  IF NOT SELF.RawBuf &= NULL
    DISPOSE(SELF.RawBuf)
    SELF.RawBuf &= NULL
  END
  
  IF NOT SELF.CompBuf &= NULL
    DISPOSE(SELF.CompBuf)
    SELF.CompBuf &= NULL
  END

  ! Free queue contents if queue exists
  FREE(Self.FileQueue)
  DISPOSE(Self.FileQueue)
  
  ! Clear source queue reference (don't dispose as it's owned by main thread)
  FREE(SELF.SourceQueue)
  SELF.SourceQueue &= NULL

ZipWorkerClass.Init  PROCEDURE(LONG pStartIdx, LONG pEndIdx, *ZipQueueType pSourceQueue, LONG pZipHandle, LONG ShowProgress, *IMutex pZipMutex, LONG pThreadNum, *ZipToolsClass pZipClass)
  CODE
  
  ! Store parameters
  SELF.StartIdx = pStartIdx
  SELF.EndIdx = pEndIdx
  SELF.SourceQueue &= pSourceQueue
  SELF.ZipHandle = pZipHandle
  
  SELF.ZipMutex &= pZipMutex
  SELF.CallerThread = THREAD()  ! Store the caller's thread ID for notifications
  SELF.ThreadNumber = pThreadNum
  
  ! Base folder is now set in InitThreadData
  
  
  
  ! Create a new file queue for this thread if it doesn't exist
  IF SELF.FileQueue &= NULL
    SELF.FileQueue &= NEW ZipQueueType
  END
  
  
ZipWorkerClass.BuildQueue    PROCEDURE()
i                               LONG
FilesAdded                      LONG
  CODE
  ! Validate parameters
  IF SELF.FileQueue &= NULL
    Self.Trace('ZipWorkerClass.BuildQueue: Error - NULL FileQueue reference') 
    RETURN 0
  END
  
  IF SELF.SourceQueue &= NULL
      Self.Trace('ZipWorkerClass.BuildQueue: Error - NULL SourceQueue reference')
    RETURN 0
  END
  
  ! Ensure indices are valid
  IF SELF.StartIdx < 1 OR SELF.EndIdx > RECORDS(SELF.SourceQueue) OR SELF.StartIdx > SELF.EndIdx
    Self.Trace('ZipWorkerClass.BuildQueue: Invalid indices - Start: ' & SELF.StartIdx & ', End: ' & SELF.EndIdx & ', Total: ' & RECORDS(SELF.SourceQueue))
    RETURN 0
  END
  
  ! Clear existing queue contents
  FREE(SELF.FileQueue)
  
  ! Add files to the thread's queue
  FilesAdded = 0
  LOOP i = SELF.StartIdx TO SELF.EndIdx
    GET(SELF.SourceQueue, i)
    IF ERRORCODE()
        Self.Trace('ZipWorkerClass.BuildQueue: Error getting file at index ' & i)
      CYCLE
    END
    
    ! Add to thread's queue
    CLEAR(SELF.FileQueue)                    ! Clear the queue record
    SELF.FileQueue.ZipFileName = SELF.SourceQueue.ZipFileName
    SELF.FileQueue.version = SELF.SourceQueue.version
    SELF.FileQueue.version_needed = SELF.SourceQueue.version_needed
    SELF.FileQueue.flag = SELF.SourceQueue.flag
    SELF.FileQueue.compression_method = SELF.SourceQueue.compression_method
    SELF.FileQueue.crc = SELF.SourceQueue.crc
    SELF.FileQueue.compressed_size = SELF.SourceQueue.compressed_size
    SELF.FileQueue.uncompressed_size = SELF.SourceQueue.uncompressed_size
    SELF.FileQueue.ZipFileDate = SELF.SourceQueue.ZipFileDate
    SELF.FileQueue.ZipFileTime = SELF.SourceQueue.ZipFileTime
    SELF.FileQueue.IsFolder = SELF.SourceQueue.IsFolder
    ADD(SELF.FileQueue)
    FilesAdded += 1
  END

  Self.Trace('ZipWorkerClass.BuildQueue: Added ' & FilesAdded & ' files to thread queue')

  RETURN FilesAdded
    
!--------------------------------------------------------------------
! InitThreadData - Initializes thread data for parallel processing
!
! Parameters:
!   ZipHandle - Handle to the open ZIP file
!   ZipMutex - Mutex for thread synchronization
!   FileQueue - Queue containing all files to be processed
!   ThreadNum - Thread number (1-based)
!   FilesPerThread - Number of files per thread (for count-based distribution)
!   ThreadCount - Total number of threads
!   ZipBase - Reference to the parent ZipToolsClass
!   TotalFileSize - Optional total size of all files (for size-based distribution)
!
! This method initializes the thread data and distributes files to be processed
! either by count (equal number of files per thread) or by size (equal amount
! of data per thread) depending on whether TotalFileSize is provided.
!--------------------------------------------------------------------
ZipWorkerClass.InitThreadData  PROCEDURE(LONG ZipHandle, *IMutex ZipMutex, *ZipQueueType FileQueue, LONG ThreadNum, LONG FilesPerThread, LONG ThreadCount, *ZipToolsClass ZipBase, <ULONG TotalFileSize>)
startIdx                    LONG
endIdx                      LONG
FilesAdded                  LONG
BytesPerThread ULONG         ! Size-based distribution
CurrentSize ULONG            ! Running total of bytes assigned to this thread
TargetSize ULONG             ! Target size for this thread

  CODE
   ! Debug trace for thread initialization
  Self.Trace('InitThreadData: Initializing thread data for thread ' & ThreadNum)

   
   ! Create a new file queue for this thread if needed
  IF Self.FileQueue &= NULL
    Self.FileQueue &= NEW ZipQueueType
  END
   
   ! Set up the thread data with minimal properties
  Self.ZipHandle = ZipHandle
  
  Self.ZipMutex &= ZipMutex
  Self.CallerThread = THREAD()
  
  Self.ErrorCount = 0
  Self.ThreadNumber = ThreadNum
  
  Self.BaseFolder = zipBase.BaseFolder
  
  ! Dispose and recreate all helper objects to ensure clean state
  DISPOSE(Self.Errors)
  DISPOSE(Self.Writer)
  DISPOSE(Self.ZipApi)
  DISPOSE(Self.StringUtils)
  
  ! Ensure buffers are properly disposed and recreated
  IF NOT Self.RawBuf &= NULL
    DISPOSE(Self.RawBuf)
    Self.RawBuf &= NULL
  END
  
  IF NOT Self.CompBuf &= NULL
    DISPOSE(Self.CompBuf)
    Self.CompBuf &= NULL
  END
  
  ! Recreate buffers with default capacity
  Self.RawBuf &= NEW STRING(2097152)  ! 2MB initial capacity
  Self.RawCap = 2097152
  
  Self.CompBuf &= NEW STRING(4194304) ! 4MB initial capacity for better compression
  Self.CompCap = 4194304
  
  Self.Errors &= NEW ZipErrorClass
  Self.Writer &= NEW ZipWriterClass
  Self.ZipApi &= NEW ZipApiWrapper
  Self.StringUtils &= NEW ZipStringUtilsClass
  
  ! Copy options from the base class
  Self.Options.ZipName = zipBase.Options.ZipName
  Self.Options.Threads = zipBase.Options.Threads
  ! Compression is handled adaptively based on file type and size
  Self.Options.Password = zipBase.Options.Password
  Self.Options.Overwrite = zipBase.Options.Overwrite
  Self.Options.ShowProgress = zipBase.Options.ShowProgress
  Self.Options.Comment = zipBase.Options.Comment
   
  ! If TotalFileSize is provided, use size-based distribution
  IF OMITTED(TotalFileSize) OR TotalFileSize = 0
    ! Fall back to count-based distribution if no size info
    startIdx = (ThreadNum-1) * FilesPerThread + 1
    endIdx = ThreadNum * FilesPerThread
    IF ThreadNum = ThreadCount
      endIdx = RECORDS(FileQueue)  ! Last thread takes remaining files
    END
    
    ! Add files to the thread's queue using index-based approach
    FilesAdded = ZipBase.AddFilesToThreadQueue(Self, FileQueue, startIdx, endIdx)
  ELSE
    ! Use size-based distribution
    ! Calculate target bytes per thread
    BytesPerThread = TotalFileSize / ThreadCount
    Self.Trace('InitThreadData: Size-based distribution. Total bytes: ' & TotalFileSize & ', Target per thread: ' & BytesPerThread)
    
    ! Let the ZipToolsClass handle the size-based distribution
    FilesAdded = ZipBase.AddFilesToThreadQueueBySize(Self, FileQueue, ThreadNum, ThreadCount, TotalFileSize)
  END
   
   ! Debug trace for thread file assignment
  IF FilesAdded >= 0
    Self.Trace('InitThreadData: Thread ' & ThreadNum & ' assigned ' & FilesAdded & ' files')
  END
   
  RETURN
  
!--------------------------------------------------------------------
! WritePrecompressedToZip - Writes precompressed data to the ZIP file
!
! Parameters:
!   ZipHandle - Handle to the open ZIP file
!   ZipEntryName - Name of the entry in the ZIP file
!   zipfi - File information structure
!   pCompBuf - Pointer to the compressed data buffer
!   CompSize - Size of the compressed data
!   UncSize - Uncompressed size of the data
!   Crc - CRC32 checksum of the uncompressed data
!   ZipMutex - Mutex for thread synchronization
!   UseStoreMethod - TRUE to use STORE method, FALSE to use DEFLATE
!   ZipPath - Original file path (for logging)
!
! Returns:
!   0 on success, error code on failure
!--------------------------------------------------------------------
ZipWorkerClass.WritePrecompressedToZip PROCEDURE(LONG ZipHandle, *CSTRING ZipEntryName, *zip_fileinfo_s zipfi, LONG pCompBuf, ULONG CompSize, ULONG UncSize, ULONG Crc, *IMutex ZipMutex, BYTE UseStoreMethod, *CSTRING ZipPath)

  CODE
  ! Pass options to Writer
  Self.Writer.Options = Self.Options
  
  ! Delegate to Writer class
  RETURN Self.Writer.WritePrecompressedToZip(ZipHandle, ZipEntryName, zipfi, |
                                           pCompBuf, CompSize, UncSize, Crc, ZipMutex, UseStoreMethod, ZipPath)
  
!--------------------------------------------------------------------
! CompressFileToBuffer - Reads a file and compresses it to the internal buffer using raw deflate
!
! Parameters:
!   FileName - Name of the file to compress
!   OutUncSize - Output parameter for uncompressed size
!   OutCrc - Output parameter for CRC32 checksum
!   OutCompSize - Output parameter for compressed size
!
! Returns:
!   0 on success, error code on failure
!--------------------------------------------------------------------
!--------------------------------------------------------------------
! CompressFileToBuffer - Reads a file and compresses it to the internal buffer
!
! Parameters:
!   FileName - Name of the file to compress
!   OutUncSize - Output parameter for uncompressed size
!   OutCrc - Output parameter for CRC32 checksum
!   OutCompSize - Output parameter for compressed size
!
! Returns:
!   0 on success, error code on failure
!--------------------------------------------------------------------
ZipWorkerClass.CompressFileToBuffer    PROCEDURE(*CSTRING FileName, *ULONG OutUncSize, *ULONG OutCrc, *ULONG OutCompSize)
  CODE
  ! Pass options to Writer
  Self.Writer.Options = Self.Options
  
  ! Delegate to Writer class
  RETURN Self.Writer.CompressFileToBuffer(FileName, OutUncSize, OutCrc, OutCompSize)

!--------------------------------------------------------------------
! ReadFileToBuffer - Reads a file into a buffer and calculates CRC
!
! Parameters:
!   FileName - Name of the file to read
!   BufRef - Reference to the buffer to read into
!   MaxSize - Maximum size to read
!   OutSize - Output parameter for actual size read
!   OutCrc - Output parameter for CRC32 checksum
!
! Returns:
!   0 on success, error code on failure
!--------------------------------------------------------------------
ZipWorkerClass.ReadFileToBuffer    PROCEDURE(STRING FileName, *STRING BufRef, ULONG MaxSize, *ULONG OutSize, *ULONG OutCrc)
  CODE
  ! Delegate to Writer class
  RETURN Self.Writer.ReadFileToBuffer(FileName, BufRef, MaxSize, OutSize, OutCrc)

!--------------------------------------------------------------------
! Trace - Outputs debug messages if debug mode is enabled
!
! Parameters:
!   pmsg - Message to output to debug console
!--------------------------------------------------------------------
ZipWorkerClass.Trace   PROCEDURE(STRING pmsg)
cmsg                CSTRING(LEN(CLIP(pmsg)) + 1)
  CODE
  COMPILE('TraceOn',CZ_TRACEON=1);
  ! Only log if debug mode is on
  CMsg = pmsg
  SELF.ZipApi.ODS(CMsg)  
  !TraceOn

