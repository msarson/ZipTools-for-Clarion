
!---------------------------------------------------------
! ZipToolsClass.clw
!
! Implementation of the ZipToolsClass wrapper for zlibwapi.dll
! Provides functionality for creating, manipulating, and extracting ZIP files
! using a multi-threaded approach for improved performance.
!
! Last revision: 23-9-2025
!---------------------------------------------------------
          MEMBER
  include('CWSYNCHM.INC'),once
          MAP
            
            ! Thread procedure
            ProcessFilesThread(STRING pAddr, STRING ThreadNo)
            GetThreadData(LONG i), *ZipWorkerClass
            SetThreadData(LONG i, *ZipWorkerClass td)
            DisposeAllThreadData()


          END
!====================================================================
czDebugOn     EQUATE(1)
  INCLUDE('ZipApiWrapper.inc')
  INCLUDE('ZipToolsClass.inc'),ONCE
  INCLUDE('SVAPI.inc'),ONCE


!--------------------------------------------------------------------
! SelectFilesToZip - Shows file selection dialog to select files to add to a ZIP
!
! Parameters:
!   FileQueue - Queue to add selected files to
!
! Returns:
!   TRUE if files were selected, FALSE if cancelled
!--------------------------------------------------------------------

ZipToolsClass.SelectFilesToZip    PROCEDURE(*ZipQueueType FileQueue)
FileUtilities ZipFileUtilitiesClass

  CODE
  return FileUtilities.SelectFiles(FileQueue)

!--------------------------------------------------------------------
! SelectFolderToZip - Shows folder dialog to select a folder to add to a ZIP
!
! Parameters:
!   FileQueue - Queue to add selected folder and its contents to
!
! Returns:
!   TRUE if a folder was selected, FALSE if cancelled
!--------------------------------------------------------------------
ZipToolsClass.SelectFolderToZip   PROCEDURE(*ZipQueueType FileQueue, BYTE IncludeBaseFolder=true)
FilesUtility ZipFileUtilitiesClass
  CODE
  Return FilesUtility.SelectZipFolder(FileQueue, IncludeBaseFolder,Self.BaseFolder)
!--------------------------------------------------------------------
! GetErrorMessage - Gets error message for a specific error code
!
! Parameters:
!   zErrCode - Error code to get message for
!
! Returns:
!   Error message string
!
! This method delegates to the ZipErrorClass for centralized error handling
!--------------------------------------------------------------------
ZipToolsClass.GetErrorMessage PROCEDURE(LONG zErrCode)
  CODE
  RETURN Self.Errors.GetErrorMessage(zErrCode)

!--------------------------------------------------------------------
! GetErrorCode - Gets the current error code
!
! Returns:
!   Current error code
!
! This method delegates to the ZipErrorClass for centralized error handling
!--------------------------------------------------------------------
ZipToolsClass.GetErrorCode    PROCEDURE()
  CODE
  RETURN Self.Errors.GetErrorCode()


!--------------------------------------------------------------------
! GetzError - Legacy method for backward compatibility
! Returns error message for the last error
!--------------------------------------------------------------------
ZipToolsClass.GetzError   PROCEDURE()
  CODE
  RETURN Self.Errors.GetzError()

!--------------------------------------------------------------------
! Construct - Class constructor, initializes default values
!--------------------------------------------------------------------
ZipToolsClass.Construct   PROCEDURE()
  CODE
  ! Initialize compression settings
  SELF.CompressionMethod = CZ_Z_DEFLATED
  
  ! Initialize compression buffer with fixed size

  ! Create API wrapper and specialized classes
  Self.ZipApi &= NEW ZipApiWrapper
  Self.Writer &= NEW ZipWriterClass
  Self.Reader &= NEW ZipReaderClass
  Self.Errors &= NEW ZipErrorClass

!--------------------------------------------------------------------
! Trace - Outputs debug messages if debug mode is enabled
!
! Parameters:
!   pmsg - Message to output to debug console
!--------------------------------------------------------------------
ZipToolsClass.Trace   PROCEDURE(STRING pmsg)
cmsg                CSTRING(LEN(CLIP(pmsg)) + 1)
  CODE
  COMPILE('TraceOn',czDebugOn=1); 
  ! Only log if debug mode is on
  CMsg = pmsg
  SELF.ZipApi.ODS(CMsg)
  !TraceOn
  
!====================================================================

  !--------------------------------------------------------------------
  ! Destruct - Class destructor, cleans up allocated resources
  !--------------------------------------------------------------------
ZipToolsClass.Destruct    PROCEDURE()
  CODE
  ! Clean up resources
  DISPOSE(SELF.ZipApi)
  DISPOSE(SELF.Writer)
  DISPOSE(SELF.Reader)
  DISPOSE(SELF.Errors)

!--------------------------------------------------------------------
! Reset - Resets the class state for reuse
!
! This method resets all state variables to their initial values
! without recreating the objects, allowing the class to be reused
! for multiple operations without memory leaks or state conflicts.
!--------------------------------------------------------------------
ZipToolsClass.Reset    PROCEDURE()
 CODE
 ! Ensure ThreadDataGroup is clean first
 DisposeAllThreadData()
 
 ! Dispose of existing objects
 DISPOSE(SELF.ZipApi)
 DISPOSE(SELF.Writer)
 DISPOSE(SELF.Reader)
 DISPOSE(SELF.Errors)
 
 ! Recreate all objects
 Self.ZipApi &= NEW ZipApiWrapper
 Self.Writer &= NEW ZipWriterClass
 Self.Reader &= NEW ZipReaderClass
 Self.Errors &= NEW ZipErrorClass
 
 ! Reset compression settings to defaults
 SELF.CompressionMethod = CZ_Z_DEFLATED
 
 ! Clear options structures
 CLEAR(SELF.Options)
 CLEAR(SELF.UnzipOptions)
 
 ! Reset default options to their initial values
 SELF.Options.Threads = 8            ! Default number of worker threads
 SELF.Options.ShowProgress = TRUE    ! Show progress window by default
 SELF.Options.Overwrite = CZ_ZIP_OVERWRITE_ASK  ! Ask before overwriting
 
 ! Clear base folder and comment
 SELF.BaseFolder = ''
 SELF.Comment = ''

!--------------------------------------------------------------------
! ExtractZipFile - Extracts all files from a ZIP file to a folder
!
! Parameters:
!   ZipFileName - Name of the ZIP file to extract
!   OutputFolder - Folder to extract files to
!   ProgressFEQ - Optional progress bar control
!
! Returns:
!   0 on success, error code on failure
!--------------------------------------------------------------------
!--------------------------------------------------------------------
! ExtractZipFile - Extracts all files from a ZIP file to a folder
!
! Parameters:
!   Options - UnzipOptions structure containing extraction settings
!
! Returns:
!   0 on success, error code on failure
!--------------------------------------------------------------------
ZipToolsClass.ExtractZipFile PROCEDURE(*UnzipOptionsType Options)
Result                   LONG
  CODE
  ! Store options and delegate to the Reader class
  Self.UnzipOptions = Options
  Self.Reader.UnzipOptions = Options
  
  ! Log extraction start
  Self.Trace('ExtractZipFile: Starting extraction from ' & Options.ZipName & ' to ' & Options.OutputFolder)
  
  ! Perform extraction through Reader class
  Result = Self.Reader.ExtractZipFile(Options)
  
  ! Log extraction completion
  Self.Trace('ExtractZipFile: Completed extraction from ' & Options.ZipName & ' to ' & Options.OutputFolder)
  Self.Trace('ExtractZipFile: Result = ' & Result)
  
  ! Return the error code from the error handler
  RETURN Self.Errors.GetErrorCode()
  




!--------------------------------------------------------------------
! CreateZipFile - Creates a ZIP file from a queue of files using multiple threads
!
! Parameters:
!   ZipFileName - Name of the ZIP file to create
!   FileQueue - Queue of files to add to the ZIP
!   ProgressFEQ - Optional progress bar control
!   NotifyFEQ - Optional control for notification events
!
! Returns:
!   0 on success, error count on failure
!--------------------------------------------------------------------
!--------------------------------------------------------------------
! CreateZipFile - Creates a ZIP file from a queue of files using multiple threads
!
! Parameters:
!   FileQueue - Queue of files to add to the ZIP
!   Options - ZipOptions structure containing compression settings
!
! Returns:
!   0 on success, error count on failure
!--------------------------------------------------------------------
ZipToolsClass.CreateZipFile   PROCEDURE(*ZipQueueType FileQueue, *ZipOptionsType Options)
i                           LONG
FilesPerThread              LONG
ErrorCount                  LONG
zipFH                       LONG
td                          &ZipWorkerClass
ZipMutex                    &IMutex
CompletedThreads            LONG
ThreadCount                 LONG(8)
WorkerThreads               LONG,DIM(8)
NotifyCode                  UNSIGNED
NotifyThread                LONG
NotifyParam                 LONG
ThreadNum                   LONG
ThreadErrors                LONG
FileToZip                   CSTRING(FILE:MaxFileName + 1)
ProgressCounter             LONG
FileCount                   LONG
MAX_THREADS                 EQUATE(8)
UserResponse                LONG
ZipPath                     CSTRING(FILE:MaxFileName + 1)
FileUtility                 ZipFileUtilitiesClass
Window                      WINDOW('Zipping Files'),AT(,,218,72),CENTER,GRAY,FONT('Segoe UI',9)
                              PROGRESS,AT(13,21,187,24),USE(?PROGRESS1),RANGE(0,100)
                            END
TotalFileSize               ULONG 
  CODE
  Self.Options = Options
  IF Self.Options.Threads < 1
    ThreadCount = 1
  ELSIF Self.Options.Threads > MAX_THREADS
    ThreadCount = MAX_THREADS
  ELSE
    ThreadCount = Self.Options.Threads
  END
  Self.Trace('CreateZipFile: Start') 
  FileToZip = CLIP(Self.Options.ZipName)
  IF FileToZip <> ''
    !Ensures full path exists
    zipPath = FileUtility.PathOnly(FileToZip)
    IF zipPath <> ''
      FileUtility.CreateDirectoriesFromPath(zipPath)
    END
    

  END
  IF EXISTS(FileToZip)
    Self.Trace('CreateZipFile: File already exists: ' & FileToZip & ' Overwrite=' & Self.Options.OverWrite) 

    CASE Self.Options.Overwrite
    OF CZ_ZIP_OVERWRITE_ASK   ! Ask user
      SetCursor()  ! Reset cursor for message box
      UserResponse = MESSAGE('The file "' & FileToZip & '" already exists.|Do you want to overwrite it?', 'File Exists', ICON:Question, BUTTON:Yes+BUTTON:No, BUTTON:No)
      SetCursor(Cursor:Wait)  ! Restore wait cursor

      IF UserResponse = BUTTON:No
        Self.Errors.SetError('CreateZipFile: User chose not to overwrite existing file',CZ_ZIP_ERR_FILE_EXISTS)
        SetCursor()
        RETURN 1
      END

      Self.Trace('CreateZipFile: User chose to overwrite existing file') 

    OF CZ_ZIP_OVERWRITE_FAIL   ! Fail if exists
      Self.Errors.SetError('CreateZipFile: Overwrite=1 ? Failing since file exists',CZ_ZIP_ERR_FILE_EXISTS)
      SetCursor()
      RETURN 1

    OF CZ_ZIP_OVERWRITE_SILENT   ! Overwrite silently
      Self.Trace('CreateZipFile: Overwrite=2 ? Overwriting silently') 

    OF CZ_ZIP_OVERWRITE_APPEND   ! Append mode  left for later implementation
      Self.Trace('CreateZipFile: Overwrite=3 (Append)  not implemented yet') 
      ! TODO: implement append if needed
    END
  END



  ! Create the ZIP file
  
  zipFH = SELF.ZipApi.zipOpen(FileToZip, CZ_ZIP_APPEND_STATUS_CREATE)
  IF zipFH <= 0
    MESSAGE('Failed to create zip file: ' & Options.ZipName, 'Error')
    RETURN 1
  END

  ! Setup Mutex
  ZipMutex &= NewMutex()
  IF ZipMutex &= NULL
    MESSAGE('Failed to create mutex', 'Error')
    RETURN 1
  END

  ! Calculate total file size and count
  FileCount = 0
  
  LOOP i = 1 TO RECORDS(FileQueue)
    GET(FileQueue, i)
    IF FileQueue.IsFolder = 0
      FileCount += 1
      TotalFileSize += FileQueue.uncompressed_size
    END
  END
  
  ! Sort the queue by file size (descending) to better distribute workload
  SORT(FileQueue, -FileQueue.uncompressed_size)
  
  ! Files per thread - we'll still calculate this for backward compatibility
  FilesPerThread = RECORDS(FileQueue) / ThreadCount
  IF FilesPerThread < 1
    FilesPerThread = 1
  END

  CompletedThreads = 0
  ProgressCounter  = 0

  OPEN(Window)
  ErrorCount = 0
  ACCEPT
    CASE EVENT()
    OF EVENT:OpenWindow
      ! Initialize progress bar once window is visible
      IF Options.ShowProgress
        ?PROGRESS1{PROP:RangeLow}  = 0
        ?PROGRESS1{PROP:RangeHigh} = FileCount
        ?PROGRESS1{PROP:Progress}  = 0
        DISPLAY(?PROGRESS1)
      ELSE
        Window{prop:hide} = TRUE
      END
      

      ! Initialize and start threads
      LOOP i = 1 TO ThreadCount
        td &= NEW ZipWorkerClass
        IF td &= NULL
          Self.Trace('Error newing data class')
          ErrorCount += 1
          CYCLE
        END

        ! Pass total file size to InitThreadData for better workload distribution
        td.InitThreadData(zipFH, ZipMutex, FileQueue, i, FilesPerThread, ThreadCount, self, TotalFileSize)
        SetThreadData(i, td)

        WorkerThreads[i] = START(ProcessFilesThread, 32000, ADDRESS(td), i)
        IF WorkerThreads[i] = 0
          Self.Trace('Failed to start thread ' & i) 
          ErrorCount += 1
          CompletedThreads += 1
        ELSE
          Self.Trace('Thread ' & i & ' started with ID ' & WorkerThreads[i]) 
        END
      END

    OF EVENT:Notify
      IF NOTIFICATION(NotifyCode, NotifyThread, NotifyParam)
       ! Debug trace for notification events
       ! Self.Trace('Notify code:' & NotifyCode & ' ' & NotifyThread)
        CASE NotifyCode
        OF CZ_ZIP_NOTIFY:ThreadInitFailed
          Self.Trace('Notify Thread Init Failed for ')
          ErrorCount += 1
          CompletedThreads += 1
          IF CompletedThreads = ThreadCount
            BREAK
          END

        OF CZ_ZIP_NOTIFY:ThreadComplete
          CompletedThreads += 1

          ThreadNum    = BSHIFT(NotifyParam, -16)       ! upper 16 bits
          ThreadErrors = BAND(NotifyParam, 0FFFFh)      ! lower 16 bits
          
          ! Get thread data to access timing information
          td &= GetThreadData(ThreadNum)
          IF NOT td &= NULL
            Self.Trace('CreateZipFile: Thread ' & ThreadNum & ' completed in ' & FORMAT(td.ElapsedTime, @n5.2) & ' seconds')
          END
          
          IF ThreadErrors
            Self.Trace('CreateZipFile: ****** ' & ThreadNum & |
              ' completed with ' & ThreadErrors & ' errors (NotifyParam=' & NotifyParam & ')')

            ErrorCount  += ThreadErrors
          END

          IF CompletedThreads = ThreadCount
            ! Log timing summary for all threads
            Self.Trace('CreateZipFile: Thread timing summary:')
            LOOP i = 1 TO ThreadCount
              td &= GetThreadData(i)
              IF NOT td &= NULL
                Self.Trace('  Thread ' & i & ': ' & FORMAT(td.ElapsedTime, @n5.2) & ' seconds, ' & RECORDS(td.FileQueue) & ' files')
              END
            END
            BREAK
          END


        OF CZ_ZIP_NOTIFY:ThreadProgress
          IF NOT Options.ShowProgress THEN CYCLE.
          ProgressCounter += 1
          ?PROGRESS1{PROP:Progress} = ProgressCounter
          DISPLAY(?PROGRESS1)

        OF CZ_ZIP_NOTIFY:ThreadError
          Self.Trace('Thread Error') 
          
          ErrorCount += 1
        END
      END
    END
  END

  CLOSE(Window)

  DisposeAllThreadData()

  ! Clean up
  IF NOT ZipMutex &= NULL
    ZipMutex.Kill()
    ZipMutex &= NULL
  END

  SELF.ZipApi.zipClose(zipFH, Self.Comment)
  Self.Trace('CreateZipFile: End') 
  RETURN ErrorCount
  

  
!--------------------------------------------------------------------
! AddFilesToThreadQueue - Adds files to a thread's queue
!
! Parameters:
!   ThreadData - Reference to the ThreadData object
!   FileQueue - Source queue containing files to add
!   StartIdx - Starting index in the source queue
!   EndIdx - Ending index in the source queue
!
! Returns:
!   Number of files added
!--------------------------------------------------------------------
ZipToolsClass.AddFilesToThreadQueue   PROCEDURE(*ZipWorkerClass ThreadData, *ZipQueueType FileQueue, LONG StartIdx, LONG EndIdx)
i                                   LONG
FilesAdded                          LONG
  CODE
  ! Only log in debug mode
  Self.Trace('AddFilesToThreadQueue: Adding files from index ' & StartIdx & ' to ' & EndIdx) 

  ! Quick validation
  IF ThreadData &= NULL OR ThreadData.FileQueue &= NULL
    RETURN 0
  END
  
  ! Ensure indices are valid
  IF StartIdx < 1 OR EndIdx > RECORDS(FileQueue) OR StartIdx > EndIdx
    RETURN 0
  END
  
  ! Add files to the thread's queue
  FilesAdded = 0
  LOOP i = StartIdx TO EndIdx
    GET(FileQueue, i)
    IF ERRORCODE()
      CYCLE
    END
    
    ! Add to thread's queue
    CLEAR(ThreadData.FileQueue)
    ThreadData.FileQueue.ZipFileName = FileQueue.ZipFileName
    ThreadData.FileQueue.version = FileQueue.version
    ThreadData.FileQueue.version_needed = FileQueue.version_needed
    ThreadData.FileQueue.flag = FileQueue.flag
    ThreadData.FileQueue.compression_method = FileQueue.compression_method
    ThreadData.FileQueue.crc = FileQueue.crc
    ThreadData.FileQueue.compressed_size = FileQueue.compressed_size
    ThreadData.FileQueue.uncompressed_size = FileQueue.uncompressed_size
    ThreadData.FileQueue.ZipFileDate = FileQueue.ZipFileDate
    ThreadData.FileQueue.ZipFileTime = FileQueue.ZipFileTime
    ThreadData.FileQueue.IsFolder = FileQueue.IsFolder
    ADD(ThreadData.FileQueue)
    FilesAdded += 1
  END
  
  ! Only log in debug mode
  Self.Trace('AddFilesToThreadQueue: Added ' & FilesAdded & ' files to thread queue') 
  RETURN FilesAdded
  
!--------------------------------------------------------------------
! AddFilesToThreadQueueBySize - Adds files to a thread's queue based on file size
!
! This method distributes files to threads based on file size rather than count,
! ensuring each thread processes approximately the same amount of data.
!
! Parameters:
!   ThreadData - Reference to the ThreadData object
!   FileQueue - Source queue containing files to add
!   ThreadNum - Thread number (1-based)
!   ThreadCount - Total number of threads
!   TotalFileSize - Total size of all files in bytes
!
! Returns:
!   Number of files added
!--------------------------------------------------------------------
ZipToolsClass.AddFilesToThreadQueueBySize PROCEDURE(*ZipWorkerClass ThreadData, *ZipQueueType FileQueue, LONG ThreadNum, LONG ThreadCount, ULONG TotalFileSize)
i                                   LONG
j                                   LONG
FilesAdded                          LONG
BytesPerThread ULONG                 ! Target bytes per thread
CurrentThreadSize ULONG              ! Current bytes assigned to this thread
ThreadSizes ULONG,DIM(8)  ! Track sizes for all threads
ThreadAssignments LONG,DIM(RECORDS(FileQueue))  ! Track which thread each file is assigned to
BestThreadIdx LONG                   ! Thread with smallest current size
SmallestSize ULONG                   ! Size of the thread with smallest workload
  CODE
  ! Only log in debug mode
  Self.Trace('AddFilesToThreadQueueBySize: Distributing files by size for thread ' & ThreadNum & ' of ' & ThreadCount)
  
  ! Quick validation
  IF ThreadData &= NULL OR ThreadData.FileQueue &= NULL
    RETURN 0
  END
  
  ! Calculate target bytes per thread
  BytesPerThread = TotalFileSize / ThreadCount
  Self.Trace('AddFilesToThreadQueueBySize: Total bytes: ' & TotalFileSize & ', Target per thread: ' & BytesPerThread)
  
  ! Initialize thread size tracking
  LOOP i = 1 TO ThreadCount
    ThreadSizes[i] = 0
  END
  
  ! First pass: Assign files to threads using a greedy algorithm
  ! Always assign to the thread with the smallest current size
  LOOP i = 1 TO RECORDS(FileQueue)
    GET(FileQueue, i)
    IF ERRORCODE() OR FileQueue.IsFolder = 1
      CYCLE
    END
    
    ! Find thread with smallest current size
    SmallestSize = 4294967295  ! ULONG max value
    BestThreadIdx = 1
    LOOP j = 1 TO ThreadCount
      IF ThreadSizes[j] < SmallestSize
        SmallestSize = ThreadSizes[j]
        BestThreadIdx = j
      END
    END
    
    ! Assign file to this thread
    ThreadAssignments[i] = BestThreadIdx
    ThreadSizes[BestThreadIdx] += FileQueue.uncompressed_size
  END
  
  ! Second pass: Add files assigned to this thread to its queue
  FilesAdded = 0
  LOOP i = 1 TO RECORDS(FileQueue)
    IF ThreadAssignments[i] <> ThreadNum
      CYCLE  ! Skip files not assigned to this thread
    END
    
    GET(FileQueue, i)
    IF ERRORCODE() OR FileQueue.IsFolder = 1
      CYCLE
    END
    
    ! Add to thread's queue
    CLEAR(ThreadData.FileQueue)
    ThreadData.FileQueue.ZipFileName = FileQueue.ZipFileName
    ThreadData.FileQueue.version = FileQueue.version
    ThreadData.FileQueue.version_needed = FileQueue.version_needed
    ThreadData.FileQueue.flag = FileQueue.flag
    ThreadData.FileQueue.compression_method = FileQueue.compression_method
    ThreadData.FileQueue.crc = FileQueue.crc
    ThreadData.FileQueue.compressed_size = FileQueue.compressed_size
    ThreadData.FileQueue.uncompressed_size = FileQueue.uncompressed_size
    ThreadData.FileQueue.ZipFileDate = FileQueue.ZipFileDate
    ThreadData.FileQueue.ZipFileTime = FileQueue.ZipFileTime
    ThreadData.FileQueue.IsFolder = FileQueue.IsFolder
    ADD(ThreadData.FileQueue)
    FilesAdded += 1
  END
  
  ! Log thread assignment results
  Self.Trace('AddFilesToThreadQueueBySize: Thread ' & ThreadNum & ' assigned ' & FilesAdded & ' files, ' & ThreadSizes[ThreadNum] & ' bytes')
  
  RETURN FilesAdded
  




!--------------------------------------------------------------------
! ProcessFilesThread - Thread procedure for processing files in parallel
!
! Parameters:
!   pAddr - Address of the ZipWorkerClass object
!   ThreadNo - Thread number (1-based)
!
! This procedure is executed by each worker thread to process its assigned
! files. It handles file compression, CRC calculation, and adding files to
! the ZIP archive with appropriate synchronization.
!--------------------------------------------------------------------
ProcessFilesThread    PROCEDURE(String pAddr, STRING ThreadNo )
! Thread-local variables for processing files
i                       LONG
Result                  LONG
ThreadContext           &ZipWorkerClass
CMsg                    CSTRING(256)
ThreadNum               LONG
NotifyParam             LONG
ProcessedFiles          LONG
RecordQueueCount        LONG
UncSize                 ULONG
CompSize                ULONG
Crc                     ULONG
zip_fileinfo            LIKE(zip_fileinfo_s)
STime                   STRING(8),AUTO
RelativePath            CSTRING(FILE:MaxFilePath+1)
MutexAcquired           BYTE
UseStoreMethod          BYTE
CompressionLevel        LONG        ! Adaptive compression level
FileHandle              LONG
FileSize                ULONG
FileSizeHigh            ULONG
czFileName              CSTRING(FILE:MaxFilePath+1)
Err                     LONG
FileUtility             ZipFileUtilitiesClass
HasPassword             BYTE
FileExt                 CSTRING(10)  ! For storing file extension

  CODE
  ThreadNum = ThreadNo + 0
  
  ! Convert the address string to a reference to the ZipWorkerClass
  ThreadContext &= pAddr + 0
  
  IF ThreadContext &= NULL OR ThreadContext.FileQueue &= NULL
    NOTIFY(CZ_ZIP_NOTIFY:ThreadInitFailed, THREAD(), 0)
    RETURN
  END
  
  ! Record thread start time
  ThreadContext.StartTime = CLOCK()
  ThreadContext.Trace('Thread ' & ThreadNum & ' starting at ' & FORMAT(ThreadContext.StartTime, @T8))
  
    
  
  IF ThreadNum > 0
    ThreadContext.ThreadNumber = ThreadNum
  END
  
  RecordQueueCount = RECORDS(ThreadContext.FileQueue)
  IF RecordQueueCount = 0
    NOTIFY(CZ_ZIP_NOTIFY:ThreadComplete, ThreadContext.CallerThread, ThreadContext.ThreadNumber * 65536)
    RETURN
  END
  
  LOOP i = 1 TO RecordQueueCount
    GET(ThreadContext.FileQueue, i)
    IF ERRORCODE()
      CYCLE
    END
    
    IF ThreadContext.FileQueue.IsFolder = 1
      CYCLE
    END
    
    UncSize = 0
    CompSize = 0
    Crc = 0
    
    !---------------------------------------------------------------------------
    ! Adaptive Compression Strategy
    !
    ! Rules:
    ! 1. If file extension is one of the already-compressed formats ? use STORE method (no compression)
    ! 2. If file is <1 KB ? use STORE method
    ! 3. If file extension is TXT, XML, HTML, CSS, JS, CSV, LOG ? use level 9 (maximum compression)
    ! 4. If file size is >50 MB and extension is EXE, DLL, BIN ? use level 1 (fastest)
    ! 5. Otherwise ? use level 6 (balanced default)
    !---------------------------------------------------------------------------
    
    ! Get file extension
    FileExt = FileUtility.GetFileExtension(ThreadContext.FileQueue.ZipFileName)
    IF FileExt <> ''
      ! Remove the dot from the extension
      FileExt = SUB(FileExt, 2, LEN(CLIP(FileExt))-1)
    END
    
    ! Default compression level (balanced)
    CompressionLevel = CZ_Z_DEFAULT_LEVEL  ! Level 6
    
    ! Rule 1: Check if file is already compressed based on extension
    UseStoreMethod = FALSE
    CASE FileExt
         OF   'PNG'  OROF 'JPG' OROF 'JPEG' OROF 'GIF' 
         OROF 'ZIP'  OROF 'RAR' OROF 'MP3'  OROF 'MP4' 
         OROF 'PACK' OROF 'JAR' OROF 'APK'  OROF 'AAC' 
         OROF 'WEBP' OROF 'PDF' OROF 'DOCX' OROF 'XLSX' 
         OROF 'PPTX' OROF 'OGG' OROF '7Z'   OROF 'BZ2' 
         OROF 'GZ'   OROF 'TGZ' OROF 'EPUB' OROF 'MOBI'
      UseStoreMethod = TRUE  ! Use STORE method (no compression) for already compressed files
      ThreadContext.Trace('CreateZipFile: Using STORE method for already compressed file: ' & ThreadContext.FileQueue.ZipFileName)
    END
    
    ! Rule 2: Check file size - if very small (under 1KB), use STORE method
    IF NOT UseStoreMethod AND ThreadContext.FileQueue.uncompressed_size < 1024
      UseStoreMethod = TRUE  ! Use STORE method for very small files
      ThreadContext.Trace('CreateZipFile: Using STORE method for small file (<<1KB): ' & ThreadContext.FileQueue.ZipFileName)
    END
    
    ! Rule 3: Highly compressible text formats - use maximum compression
    IF NOT UseStoreMethod AND (FileExt = 'TXT' OR FileExt = 'XML' OR FileExt = 'HTML' OR |
                              FileExt = 'CSS' OR FileExt = 'JS' OR FileExt = 'CSV' OR |
                              FileExt = 'LOG')
      CompressionLevel = CZ_Z_BEST_COMPRESSION  ! Level 9
      ThreadContext.Trace('CreateZipFile: Using maximum compression (level 9) for text file: ' & ThreadContext.FileQueue.ZipFileName)
    END
    
    ! Rule 4: Large binary files - use fastest compression
    IF NOT UseStoreMethod AND ThreadContext.FileQueue.uncompressed_size > 52428800 AND |
       (FileExt = 'EXE' OR FileExt = 'DLL' OR FileExt = 'BIN')
      CompressionLevel = CZ_Z_BEST_SPEED  ! Level 1
      ThreadContext.Trace('CreateZipFile: Using fastest compression (level 1) for large binary file: ' & ThreadContext.FileQueue.ZipFileName)
    END
    
    ThreadContext.Trace('CreateZipFile: Processing file ' & ThreadContext.FileQueue.ZipFileName)
    
    ! Calculate CRC and size for the file (same approach for both password and non-password)
    HasPassword = CHOOSE(ThreadContext.Options.Password <> '',1,0)
    
    IF HasPassword
      ThreadContext.Trace('CreateZipFile: Password mode - calculating CRC and size for ' & ThreadContext.FileQueue.ZipFileName)
    ELSE
      ThreadContext.Trace('CreateZipFile: Non-password mode - calculating CRC and size for ' & ThreadContext.FileQueue.ZipFileName)
    END
    
    czFileName = ThreadContext.FileQueue.ZipFileName
    
    ! Open the file just to get size
    FileHandle = ThreadContext.ZipApi.CreateFile(czFileName, CZ_GENERIC_READ, CZ_FILE_SHARE_READ,,CZ_OPEN_EXISTING, 0, 0)
    IF FileHandle = CZ_INVALID_HANDLE_VALUE
      Result = CZ_ZIP_ERR_FILE_OPEN
    ELSE
      FileSize = ThreadContext.ZipApi.GetFileSize(FileHandle)
      IF FileSize = 4294967295
        Err = ThreadContext.ZipApi.GetLastError()
        ThreadContext.Trace('GetFileSize failed, Err=' & Err & ' File=' & czFileName)
        Result = CZ_ZIP_ERR_FILE_READ
      ELSE
        ThreadContext.ZipApi.CloseFile(FileHandle)
        
        ! Ensure CompBuf is allocated large enough for CRC calculation
        IF ThreadContext.CompBuf &= NULL OR FileSize > ThreadContext.CompCap
          IF NOT ThreadContext.CompBuf &= NULL
            DISPOSE(ThreadContext.CompBuf)
          END
          ThreadContext.CompBuf &= NEW STRING(FileSize)
          ThreadContext.CompCap = FileSize
        END
        
        ! Read file to get CRC and size
        Result = ThreadContext.ReadFileToBuffer( |
          ThreadContext.FileQueue.ZipFileName, |
          ThreadContext.CompBuf, |
          ThreadContext.CompCap, |
          UncSize, Crc)
          
        CompSize = UncSize  ! Set compressed size equal to uncompressed size
        UseStoreMethod = FALSE  ! Don't use store method
      END
    END
    


    
   IF Result <> 0
     ThreadContext.Errors.SetError('CreateZipFile: Thread encountered an error while compressing file ', Result)
     ThreadContext.ErrorCount += 1
     NOTIFY(CZ_ZIP_NOTIFY:ThreadError, ThreadContext.CallerThread, i)
     CYCLE
   END
   
   ! ---- Phase B: Write to ZIP ----
   STime = FORMAT(ThreadContext.FileQueue.ZipFileTime, @T4)
   zip_fileinfo.tmz_date.tm_hour = STime[1:2]
   zip_fileinfo.tmz_date.tm_min  = STime[4:5]
   zip_fileinfo.tmz_date.tm_sec  = STime[7:8]
   zip_fileinfo.tmz_date.tm_mday = DAY(ThreadContext.FileQueue.ZipFileDate)
   zip_fileinfo.tmz_date.tm_mon  = MONTH(ThreadContext.FileQueue.ZipFileDate) - 1
   zip_fileinfo.tmz_date.tm_year = YEAR(ThreadContext.FileQueue.ZipFileDate) 
   zip_fileinfo.dosDate          = 0
   ! zip_fileinfo.flag is not used in this implementation
   zip_fileinfo.internal_fa      = 0
   zip_fileinfo.external_fa      = 0
   
   ! Relative path
   IF ThreadContext.BaseFolder <> ''
     IF SUB(ThreadContext.FileQueue.ZipFileName,1,LEN(CLIP(ThreadContext.BaseFolder))) = CLIP(ThreadContext.BaseFolder)
       RelativePath = SUB(ThreadContext.FileQueue.ZipFileName, LEN(CLIP(ThreadContext.BaseFolder))+1, LEN(CLIP(ThreadContext.FileQueue.ZipFileName)) - LEN(CLIP(ThreadContext.BaseFolder)))
     ELSE
       RelativePath = FileUtility.FileNameOnly(ThreadContext.FileQueue.ZipFileName)
     END
   ELSE
     IF INSTRING(':', ThreadContext.FileQueue.ZipFileName) > 0 OR ThreadContext.FileQueue.ZipFileName[1:1] = '\'
       RelativePath = FileUtility.FileNameOnly(ThreadContext.FileQueue.ZipFileName)
     ELSE
       RelativePath = ThreadContext.FileQueue.ZipFileName
     END
   END
   
   ! Validate buffer before writing
   IF ThreadContext.CompBuf &= NULL OR LEN(ThreadContext.CompBuf) = 0
     ThreadContext.Trace('CreateZipFile: ERROR - Cannot write empty or NULL buffer for ' & ThreadContext.FileQueue.ZipFileName)
     Result = CZ_ZIP_ERR_FILE_READ
   ELSE
     ! Write precompressed or stored file - mutex is handled inside WritePrecompressedToZip
     ! Adaptive compression level is determined by the logic above
     
     Result = ThreadContext.WritePrecompressedToZip( |
       ThreadContext.ZipHandle,                |
       RelativePath,                           |
       zip_fileinfo,                           |
       ADDRESS(ThreadContext.CompBuf),                  |
       CompSize, UncSize, Crc,                 |
       ThreadContext.ZipMutex, UseStoreMethod, |
       ThreadContext.FileQueue.ZipFileName)    ! NEW param
   END
   
   IF Result <> 0
     ThreadContext.ErrorCount += 1
     NOTIFY(CZ_ZIP_NOTIFY:ThreadError, ThreadContext.CallerThread, i)
   END
   
   ProcessedFiles += 1
   NOTIFY(CZ_ZIP_NOTIFY:ThreadProgress, ThreadContext.CallerThread, i)
 END  ! End of LOOP i = 1 TO RecordQueueCount
 
 ! Record thread end time and calculate elapsed time
 ThreadContext.EndTime = CLOCK()
 ThreadContext.ElapsedTime = (ThreadContext.EndTime - ThreadContext.StartTime) / 100  ! Convert to seconds
 
 ThreadContext.Trace('Thread ' & ThreadNum & ' completed at ' & FORMAT(ThreadContext.EndTime, @T8))
 ThreadContext.Trace('Thread ' & ThreadNum & ' elapsed time: ' & FORMAT(ThreadContext.ElapsedTime, @n5.2) & ' seconds')
 ThreadContext.Trace('Thread ' & ThreadNum & ' processed ' & ProcessedFiles & ' files')
 
 ! Include timing info in the notification
 NotifyParam = BSHIFT(ThreadContext.ThreadNumber,16) + BAND(ThreadContext.ErrorCount,0FFFFh)
 NOTIFY(CZ_ZIP_NOTIFY:ThreadComplete, ThreadContext.CallerThread, NotifyParam)
 RETURN
!--------------------------------------------------------------------
! GetThreadData - Retrieves the thread data for a specific thread
!
! Parameters:
!   i - Thread index (1-based)
!
! Returns:
!   Reference to the ZipWorkerClass object for the specified thread
!--------------------------------------------------------------------
GetThreadData PROCEDURE(LONG i)
  CODE
  CASE i
  OF 1 ; RETURN ThreadDataGroup.Ref1
  OF 2 ; RETURN ThreadDataGroup.Ref2
  OF 3 ; RETURN ThreadDataGroup.Ref3
  OF 4 ; RETURN ThreadDataGroup.Ref4
  OF 5 ; RETURN ThreadDataGroup.Ref5
  OF 6 ; RETURN ThreadDataGroup.Ref6
  OF 7 ; RETURN ThreadDataGroup.Ref7
  OF 8 ; RETURN ThreadDataGroup.Ref8
  ELSE ; RETURN NULL
  END

!--------------------------------------------------------------------
! SetThreadData - Sets the thread data for a specific thread
!
! Parameters:
!   i - Thread index (1-based)
!   td - Reference to the ZipWorkerClass object to store
!--------------------------------------------------------------------
SetThreadData PROCEDURE(LONG i, *ZipWorkerClass td)
  CODE
  CASE i
  OF 1 ; ThreadDataGroup.Ref1 &= td
  OF 2 ; ThreadDataGroup.Ref2 &= td
  OF 3 ; ThreadDataGroup.Ref3 &= td
  OF 4 ; ThreadDataGroup.Ref4 &= td
  OF 5 ; ThreadDataGroup.Ref5 &= td
  OF 6 ; ThreadDataGroup.Ref6 &= td
  OF 7 ; ThreadDataGroup.Ref7 &= td
  OF 8 ; ThreadDataGroup.Ref8 &= td
  END

!--------------------------------------------------------------------
! DisposeAllThreadData - Cleans up all thread data objects
!
! This procedure disposes of all ZipWorkerClass objects stored in the
! ThreadDataGroup to prevent memory leaks when threads complete.
!--------------------------------------------------------------------
DisposeAllThreadData  PROCEDURE()
  CODE
  IF NOT ThreadDataGroup.Ref1 &= NULL
    DISPOSE(ThreadDataGroup.Ref1)
    ThreadDataGroup.Ref1 &= NULL
  END
  IF NOT ThreadDataGroup.Ref2 &= NULL
    DISPOSE(ThreadDataGroup.Ref2)
    ThreadDataGroup.Ref2 &= NULL
  END
  IF NOT ThreadDataGroup.Ref3 &= NULL
    DISPOSE(ThreadDataGroup.Ref3)
    ThreadDataGroup.Ref3 &= NULL
  END
  IF NOT ThreadDataGroup.Ref4 &= NULL
    DISPOSE(ThreadDataGroup.Ref4)
    ThreadDataGroup.Ref4 &= NULL
  END
  IF NOT ThreadDataGroup.Ref5 &= NULL
    DISPOSE(ThreadDataGroup.Ref5)
    ThreadDataGroup.Ref5 &= NULL
  END
  IF NOT ThreadDataGroup.Ref6 &= NULL
    DISPOSE(ThreadDataGroup.Ref6)
    ThreadDataGroup.Ref6 &= NULL
  END
  IF NOT ThreadDataGroup.Ref7 &= NULL
    DISPOSE(ThreadDataGroup.Ref7)
    ThreadDataGroup.Ref7 &= NULL
  END
  IF NOT ThreadDataGroup.Ref8 &= NULL
    DISPOSE(ThreadDataGroup.Ref8)
    ThreadDataGroup.Ref8 &= NULL
  END