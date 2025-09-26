   MEMBER()
   INCLUDE('ZipFileUtilitiesClass.inc'),ONCE
   MAP
   END

ZipFileUtilitiesClass.CONSTRUCT      PROCEDURE()
  CODE
   Self.ZipApi &= NEW ZipAPIWrapper
   Self.StringUtils &= NEW ZipStringUtilsClass
ZipFileUtilitiesClass.DESTRUCT       PROCEDURE()
   CODE
   DISPOSE(Self.ZipApi)
   DISPOSE(Self.StringUtils)

ZipFileUtilitiesClass.SelectFiles    PROCEDURE(*ZipQueueType FileQueue)
Found                           CSTRING(10000)
Path                            CSTRING(File:MaxFilePath + 1)
Separator                       STRING(1)
Pos                             UNSIGNED
NameStart                       UNSIGNED
FilesSelected                   BOOL
aFILE:queue                     QUEUE
name                              STRING(FILE:MAXFILENAME)
shortname                         STRING(13)
date                              LONG
time                              LONG
size                              LONG
attrib                            BYTE
                                END
CurrentPath                     CSTRING(File:MaxFilePath + 1)  ! To store current path

  CODE
  FilesSelected = FALSE
  
  ! Store current path
  CurrentPath = PATH()
  
  ! Use standard file dialog for file selection
  IF FILEDIALOG('Pick 1 or more files to add to zip', Found, 'All Files | *.* ', FILE:KeepDir+FILE:Multi+FILE:LongName)
    FilesSelected = TRUE
    Separator = '|'
    Pos = INSTRING(Separator, Found, 1, 1)
    
    IF Pos  ! Multi-Selected files
      ASSERT(Pos > 1)
      Path = CHOOSE(Found[Pos-1] <> '\', Found[1 : Pos-1] & '\', Found[1 : Pos-1])
      
      LOOP
        NameStart = Pos + 1
        Pos = INSTRING(Separator, Found, 1, NameStart)
        IF ~Pos THEN Pos = LEN(Found) + 1.
        
        FileQueue.ZipFileName = Found[NameStart : Pos-1]
        FREE(aFILE:queue)
        DIRECTORY(aFILE:queue, FileQueue.ZipFileName, ff_:NORMAL+ff_:HIDDEN+ff_:SYSTEM+ff_:DIRECTORY)
        GET(aFILE:queue, 1)
        
        IF FileQueue.ZipFileName = CLIP(aFILE:queue.name)
          FileQueue.ZipFileDate       = aFILE:queue.date
          FileQueue.ZipFileTime       = aFILE:queue.time
          FileQueue.uncompressed_size = aFILE:queue.size
        END
        
        FileQueue.compressed_size = 0
        CLEAR(FileQueue.crc)
        FileQueue.IsFolder = 0  ! This is a file
        ADD(FileQueue)
      WHILE Pos <= LEN(Found)
    ELSE
      ! Single file selected
      FileQueue.ZipFileName = Found
      FREE(aFILE:queue)
      DIRECTORY(aFILE:queue, Found, ff_:NORMAL+ff_:HIDDEN+ff_:SYSTEM+ff_:DIRECTORY)
      GET(aFILE:queue, 1)
      
      IF FileQueue.ZipFileName = CLIP(aFILE:queue.name)
        FileQueue.ZipFileDate       = aFILE:queue.date
        FileQueue.ZipFileTime       = aFILE:queue.time
        FileQueue.uncompressed_size = aFILE:queue.size
      END
      
      FileQueue.IsFolder = 0  ! This is a file
      ADD(FileQueue)
    END
  ELSE
    FilesSelected = FALSE
  END
  
  FREE(aFILE:queue)
  
  ! Restore original path
  SETPATH(CurrentPath)
  
  RETURN FilesSelected  

ZipFileUtilitiesClass.SelectZipFolder   PROCEDURE(*ZipQueueType FileQueue, BYTE IncludeBaseFolder=true, *CSTRING BaseFolder)
FolderPath                      CSTRING(File:MaxFilePath + 1)
FolderSelected                  BOOL
CurrentPath                     CSTRING(File:MaxFilePath + 1)  ! To store current path

  CODE
  FolderSelected = FALSE
  
  ! Store current path
  
  FolderPath = SELF.SelectFolder('Select a folder to add to zip', 'All Files | *.* ')
  ! Use directory dialog for folder selection
  IF FolderPath
    FolderSelected = TRUE
    
    ! Recursively scan the folder and add all files to the queue
    ! Only pass the FolderPath parameter when we want to exclude the base folder
    IF IncludeBaseFolder
      Self.ScanFolderRecursively(FolderPath, FileQueue,,BaseFolder)
    ELSE
      Self.ScanFolderRecursively(FolderPath, FileQueue, FolderPath, BaseFolder)
    END
  ELSE
    FolderSelected = FALSE
  END
  
  ! Restore original path
  RETURN FolderSelected

ZipFileUtilitiesClass.SelectFolder PROCEDURE(String Title, String FileTypeSelection)
FolderPath                      CSTRING(File:MaxFilePath + 1)
CurrentPath                     CSTRING(File:MaxFilePath + 1)  ! To store current path

  CODE
  ! Store current path
  CurrentPath = PATH()
  
  ! Use directory dialog for folder selection
  IF NOT FILEDIALOG(Title, FolderPath, FileTypeSelection, FILE:KeepDir+FILE:Directory+FILE:LongName)
    FolderPath = ''
  END
  SETPATH(CurrentPath)
  RETURN FolderPath
  
!--------------------------------------------------------------------
! SelectFile - Shows file dialog to select a single file
!
! Parameters:
!   Title - Dialog title
!   FileTypeSelection - File type filter (e.g., 'ZIP Files|*.zip|All Files|*.*')
!
! Returns:
!   Selected file path or empty string if cancelled
!--------------------------------------------------------------------
ZipFileUtilitiesClass.SelectFile PROCEDURE(String Title, String FileTypeSelection)
FilePath                      CSTRING(File:MaxFilePath + 1)
CurrentPath                   CSTRING(File:MaxFilePath + 1)  ! To store current path

 CODE
 ! Store current path
 CurrentPath = PATH()
 
 ! Use standard file dialog for single file selection
 IF NOT FILEDIALOG(Title, FilePath, FileTypeSelection, FILE:KeepDir+FILE:LongName)
   FilePath = ''
 END
 
 ! Restore original path
 SETPATH(CurrentPath)
 
 RETURN FilePath

ZipFileUtilitiesClass.ScanFolderRecursively   PROCEDURE(*CSTRING FolderPath, *ZipQueueType FileQueue, <*CSTRING BasePath>, *CSTRING BaseFolder)
FolderFiles                         QUEUE(FILE:Queue),PRE(ff)
                                    END
SubFolderPath                       CSTRING(FILE:MaxFilePath+1)
FullPath                            CSTRING(FILE:MaxFilePath+1)
RelativePath                        CSTRING(FILE:MaxFilePath+1)
FileCount                           LONG,AUTO
BasePathLen                         LONG,AUTO
LocalBasePath                       CSTRING(FILE:MaxFilePath+1)
SkipBaseFolder                      BYTE,AUTO
BatchSize                           LONG(100)  ! Process files in batches for better performance
BatchCount                          LONG,AUTO
ParentPath                          CSTRING(FILE:MaxFilePath+1)
CurrentPath                         CSTRING(FILE:MaxFilePath+1)
SlashPos                            LONG,AUTO
  CODE
  FileCount = 0
  
  ! Ensure folder path ends with a backslash - simplified
  IF FolderPath[LEN(CLIP(FolderPath))] <> '\'
    FolderPath = CLIP(FolderPath) & '\'
  END
  
  ! Base path determination for proper subfolder handling
  SkipBaseFolder = FALSE
  
  IF OMITTED(BasePath)
    LocalBasePath = FolderPath
    ! Store the base folder path in the class property for use in ProcessFileForZip
    BaseFolder = FolderPath
  ELSE
    LocalBasePath = BasePath
    ! Store the base folder path in the class property for use in ProcessFileForZip
    BaseFolder = BasePath
    ! Check if BasePath equals FolderPath (meaning we should skip the base folder)
    IF CLIP(LocalBasePath) = CLIP(FolderPath)
      SkipBaseFolder = TRUE
    END
  END
  BasePathLen = LEN(CLIP(LocalBasePath))
  
  ! Add the folder itself to the queue only if we're not skipping the base folder
  IF NOT SkipBaseFolder
    FileQueue.ZipFileName = FolderPath
    FileQueue.ZipFileDate = TODAY()
    FileQueue.ZipFileTime = CLOCK()
    FileQueue.uncompressed_size = 0
    FileQueue.compressed_size = 0
    CLEAR(FileQueue.crc)
    FileQueue.IsFolder = 1
    ADD(FileQueue)
  END
  
  ! Optimized file scanning - use batch processing
  DIRECTORY(FolderFiles, FolderPath & '*.*', ff_:NORMAL+ff_:HIDDEN+ff_:SYSTEM+ff_:DIRECTORY)
  BatchCount = 0
  
  LOOP WHILE RECORDS(FolderFiles)
    GET(FolderFiles, 1)
    DELETE(FolderFiles)
    
    ! Skip . and .. entries
    IF ff:name = '.' OR ff:name = '..'
      CYCLE
    END
    
    ! Build full path - simplified string operation
    FullPath = FolderPath & CLIP(ff:name)
    
    ! Check if it's a directory
    IF BAND(ff:attrib, CZ_FILE_ATTRIBUTE_DIRECTORY)
      ! Recursively scan subfolder - ensure path ends with backslash
      SubFolderPath = FullPath
      IF SubFolderPath[LEN(CLIP(SubFolderPath))] <> '\'
        SubFolderPath = CLIP(SubFolderPath) & '\'
      END
      
      ! Add this folder to the queue even if it's empty
      FileQueue.ZipFileName = SubFolderPath
      FileQueue.ZipFileDate = ff:date
      FileQueue.ZipFileTime = ff:time
      FileQueue.uncompressed_size = 0
      FileQueue.compressed_size = 0
      CLEAR(FileQueue.crc)
      FileQueue.IsFolder = 1
      ADD(FileQueue)
      
      FileCount += Self.ScanFolderRecursively(SubFolderPath, FileQueue, LocalBasePath, BaseFolder)
    ELSE
      ! It's a file, add it to the queue - simplified relative path calculation
      FileQueue.ZipFileName = FullPath
      FileQueue.ZipFileDate = ff:date
      FileQueue.ZipFileTime = ff:time
      FileQueue.uncompressed_size = ff:size
      FileQueue.compressed_size = 0
      CLEAR(FileQueue.crc)
      FileQueue.IsFolder = 0
      ADD(FileQueue)
      FileCount += 1
      BatchCount += 1
      
      ! Only log occasionally to reduce overhead
      IF (BatchCount % BatchSize = 0)
      END
    END
  END
  
  RETURN FileCount

ZipFileUtilitiesClass.PathOnly    PROCEDURE(<STRING fPath>)
  CODE
  ! Handle empty or omitted path
  IF OMITTED(fPath) OR SIZE(fPath) = 0
    RETURN ''
  END
   
  ! Use the StringUtils class to get the path only
  RETURN SELF.StringUtils.GetPathOnly(fPath)
  
!--------------------------------------------------------------------
! FileNameOnly - Extracts just the file name from a file path
!
! Parameters:
!   fPath - File path to extract file name from
!
! Returns:
!   File name without the directory path
!--------------------------------------------------------------------
ZipFileUtilitiesClass.FileNameOnly    PROCEDURE(<STRING fPath>)
  CODE
  ! Handle empty or omitted path
  IF OMITTED(fPath) OR SIZE(fPath) = 0
    RETURN ''
  END
    
  ! Use the StringUtils class to get the file name only
  RETURN SELF.StringUtils.GetFileNameOnly(fPath)

ZipFileUtilitiesClass.GetFileExtension   PROCEDURE(STRING FileName)
  CODE
  ! Use the StringUtils class to get the file extension
  RETURN SELF.StringUtils.GetFileExtension(FileName)

!--------------------------------------------------------------------
! EnsureDirectoryExists - Recursively creates directories in a path if they don't exist
!
! Parameters:
!   DirectoryPath - Path to create
!
! Returns:
!   TRUE if successful, FALSE if failed
!--------------------------------------------------------------------
ZipFileUtilitiesClass.CreateDirectoriesFromPath   PROCEDURE(STRING DirectoryPath)
CurrentPath                         CSTRING(FILE:MaxFilePath+1)
NextSlash                           LONG
i                                   LONG
LastError                           LONG
Success                             BOOL(TRUE)
TempPath                            CSTRING(FILE:MaxFilePath+1)
RetryCount                          LONG(0)
MaxRetries                          LONG(3)
DirectoryPathCString                CSTRING(FILE:MaxFilePath+1)
CleanPath                           STRING(FILE:MaxFilePath+1)
  CODE
   
  ! If path is empty, return success
  IF ~DirectoryPath
    RETURN TRUE
  END
  
  ! Call PathOnly to ensure we're only working with a directory path
  ! This handles cases where someone might pass a full path with filename
  CleanPath = DirectoryPath

  ! Find last backslash
  pos# = INSTRING('\', DirectoryPath, -1, LEN(CLIP(DirectoryPath)))
  IF pos# > 0
    ! Substring after the last backslash
    tail# = SUB(CLIP(DirectoryPath), pos#+1, LEN(CLIP(DirectoryPath))-pos#)
    ! Does it contain a dot?
    IF INSTRING('.', tail#, 1, 1) > 0
      CleanPath = SELF.PathOnly(DirectoryPath)
    END
  END
  
  ! If PathOnly returned empty but original path wasn't empty,
  ! it might be just a filename or a relative path without backslashes
  IF ~CleanPath AND DirectoryPath
    CleanPath = DirectoryPath
  END
  
  ! Convert STRING parameter to CSTRING
  DirectoryPathCString = CleanPath
  
  ! Normalize path and ensure it ends with a backslash
  TempPath = SELF.StringUtils.EnsureTrailingSlash(SELF.StringUtils.NormalizePath(DirectoryPathCString))
   
  ! Start with the drive root (e.g., "C:\")
  CurrentPath = SUB(TempPath, 1, 3)
   
  ! Create each directory level, ensuring each parent exists before creating children
  i = 4  ! Start after drive letter and colon (e.g., "C:\")
  LOOP WHILE i <= LEN(CLIP(TempPath))
    ! Find the next backslash
    NextSlash = INSTRING('\', TempPath, 1, i)
    IF NextSlash = 0
      NextSlash = LEN(CLIP(TempPath)) + 1
    END
     
    ! Extract the current path segment
    CurrentPath = SUB(TempPath, 1, NextSlash - 1)
     
    ! Create this directory level with retry logic
    RetryCount = 0
    LOOP
      IF Self.ZipApi.CreateDirectory(CurrentPath) <> 0
        ! Directory created successfully
        BREAK
      END
      
      LastError = SELF.ZipApi.GetLastError()
      IF LastError = 183  ! 183 = ERROR_ALREADY_EXISTS
        ! Directory already exists, not an error
        BREAK
      END
      
      ! Log error information
      
      
      ! Retry logic
      RetryCount += 1
      IF RetryCount >= MaxRetries
        Success = FALSE
        BREAK
      END
      
      ! Wait a bit before retrying
      SELF.ZipApi.Sleep(100 * RetryCount)  ! Increasing delay with each retry
    END
     
    ! Move to the next segment
    i = NextSlash + 1
  END
   
  RETURN Success  