!---------------------------------------------------------
! ZipApiWrapper.clw
!
! Implementation of the ZipApiWrapper class for zlibwapi.dll
! Provides DLL bindings for ZIP operations
!
! Last revision: 15-9-2025
!---------------------------------------------------------
          MEMBER
          MAP            
            MODULE('zlibwapi dynamic')
!================================================================
! ZIP API (minizip-style functions from zlib)
!================================================================
              cz_zipOpen(CONST *CSTRING ZipFileName, LONG appendmode),LONG,PASCAL,RAW,DLL(_fp_)
              cz_zipWriteInFileInZip(LONG zipHandle, LONG pBuf, ULONG len),LONG,PASCAL,RAW,DLL(_fp_)
              cz_zipCloseFileInZipRaw(LONG zipFile, LONG uncompressed_size, ULONG crc32),LONG,PASCAL,RAW,DLL(_fp_)
              cz_zipCloseFileInZip(LONG zipFile),LONG,PROC,PASCAL,RAW,DLL(_fp_)
              cz_zipClose(LONG zipFile, *CSTRING global_comment),LONG,PASCAL,RAW,PROC,DLL(_fp_)
              cz_zipOpenNewFileInZip(LONG zipFile, LONG lpfilename, LONG zipfi, LONG lpextrafield_local, ULONG size_extrafield_local, LONG lpextrafield_global, ULONG size_extrafield_global, LONG lpcomment, LONG method, LONG level),LONG,PROC,PASCAL,RAW,DLL(_fp_)
              cz_zipOpenNewFileInZip2(LONG zipFile, LONG lpfilename, LONG zipfi, LONG lpextrafield_local, ULONG size_extrafield_local, LONG lpextrafield_global, ULONG size_extrafield_global, LONG lpcomment, LONG method, LONG level, LONG raw, LONG windowBits, LONG memLevel, LONG strategy),LONG,PASCAL,RAW,DLL(_fp_)
              cz_zipOpenNewFileInZip3(LONG zipFile, LONG lpfilename, LONG zipfi, LONG lpextralield_local, LONG size_extrafield_local, LONG lpextrafield_global, LONG size_extrafield_global, LONG lpcomment, LONG method, LONG level, LONG raw, LONG windowBits, LONG memLevel, LONG strategy, LONG lppassword, ULONG crcForCrypting),LONG,PASCAL,RAW,DLL(_fp_)

!================================================================
! UNZIP API
!================================================================
              cz_unzOpen(CONST *CSTRING ZipFileName),LONG,PASCAL,RAW,DLL(_fp_)
              cz_unzClose(LONG unzFile),LONG,PROC,PASCAL,RAW,DLL(_fp_)
              cz_unzGoToFirstFile(LONG unzFile),LONG,PASCAL,RAW,DLL(_fp_)
              cz_unzGoToNextFile(LONG unzFile),LONG,PASCAL,RAW,DLL(_fp_)
              cz_unzOpenCurrentFilePassword(LONG unzFile, LONG password),LONG,PROC,PASCAL,RAW,DLL(_fp_)
              cz_unzGetCurrentFileInfo(LONG unzFile, LONG pfile_info, LONG filename, ULONG filenameBufferSize, LONG extraField, ULONG extraFieldBufferSize, LONG comment, ULONG commentBufferSize),LONG,PASCAL,RAW,DLL(_fp_)
              cz_unzOpenCurrentFile(LONG unzFile),LONG,PROC,PASCAL,RAW,DLL(_fp_)
              cz_unzReadCurrentFile(LONG unzFile, *STRING buf, ULONG len),LONG,PASCAL,RAW,DLL(_fp_)
              cz_unzCloseCurrentFile(LONG unzFile),LONG,PROC,PASCAL,RAW,DLL(_fp_)

!================================================================
! ZLIB CORE COMPRESSION API
!================================================================
              cz_deflateInit2_(LONG strm, LONG level, LONG method, LONG windowBits, LONG memLevel, LONG strategy, *CSTRING version, LONG stream_size),LONG,PASCAL,RAW,DLL(_fp_)
              cz_deflate(LONG strm, LONG flush),LONG,PASCAL,RAW,DLL(_fp_)
              cz_deflateEnd(LONG strm),LONG,PROC,PASCAL,RAW,DLL(_fp_)
              cz_crc32(ULONG crc, LONG buf, ULONG len),ULONG,PASCAL,RAW,DLL(_fp_)
            END


            MODULE('c functions')
!================================================================
! WINDOWS API CALLS
!================================================================
              cz_CreateFile(*CSTRING lpFileName, ULONG dwDesiredAccess, ULONG dwShareMode, <*?>, ULONG dwCreationDisposition, ULONG dwFlagsAndAttributes, UNSIGNED hTemplateFile),LONG,PASCAL,RAW,NAME('CreateFileA')
              cz_WriteFile(UNSIGNED hFile, *STRING lpBuffer, ULONG nNumberOfBytesToWrite, *ULONG lpNumberOfBytesWritten, <*?>),PROC,BOOL,PASCAL,RAW,NAME('WriteFile')
              cz_ReadFile(UNSIGNED hFile, LONG lpBuffer, ULONG nNumberOfBytesToRead, *ULONG lpNumberOfBytesRead, LONG lpOverlapped),BOOL,PASCAL,RAW,NAME('ReadFile')
              
              cz_CloseFile(UNSIGNED hObject),BOOL,PASCAL,RAW,PROC,NAME('CloseHandle')
              cz_GetLastError(),ULONG,PASCAL,RAW,NAME('GetLastError')
              cz_CreateDirectory(LONG lpPathName, LONG lpSecurityAttributes),BOOL,PASCAL,RAW,NAME('CreateDirectoryA')
              cz_DeleteFile(*CSTRING lpFileName),BOOL,PROC,PASCAL,RAW,NAME('DeleteFileA')
              cz_GetCurrentDirectory(ULONG nBufferLength, *CSTRING lpBuffer),ULONG,PROC,PASCAL,RAW,NAME('GetCurrentDirectoryA')
              cz_ODS(*CSTRING lpOutputString),RAW,PASCAL,NAME('OutputDebugStringA')
              cz_WaitForThread(LONG ThreadID),LONG,PROC,PASCAL,NAME('WaitForSingleObject')
              cz_Sleep(ULONG dwMilliseconds),PASCAL,RAW,NAME('Sleep')
              cz_GetFileSize(*LONG hFile),ULONG,PASCAL,RAW,NAME('GetFileSize')
              cz_FlushFileBuffers(LONG hFile),BOOL,PROC,PASCAL,RAW,NAME('FlushFileBuffers')
              cz_memcpy(LONG lpDest,LONG lpSource,LONG nCount),LONG,PROC,NAME('_memcpy')
              cz_GetFileSize(LONG hFile, LONG lpFileSizeHigh),ULONG,PASCAL,RAW,NAME('GetFileSize')
              cz_LoadLibrary(*cstring lpLibFileName), long, pascal, raw, name('LoadLibraryA'), dll(1)
              cz_GetProcAddress(ulong hModule, *cstring lpProcName), ulong, pascal, raw, name('GetProcAddress'), dll(1)
            END
            
          END

  INCLUDE('ZipApiWrapper.inc'),ONCE

!================================================================
! Function pointer definitions for zlibwapi dynamic loading
!================================================================
hZlibWapi     unsigned
hZlib1    unsigned
fp_zipOpen    UNSIGNED,NAME('cz_zipOpen')
fp_zipWriteInFileInZip    UNSIGNED,NAME('cz_zipWriteInFileInZip')
fp_zipCloseFileInZipRaw   UNSIGNED,NAME('cz_zipCloseFileInZipRaw')
fp_zipCloseFileInZip  UNSIGNED,NAME('cz_zipCloseFileInZip')
fp_zipClose   UNSIGNED,NAME('cz_zipClose')
fp_zipOpenNewFileInZip    UNSIGNED,NAME('cz_zipOpenNewFileInZip')
fp_zipOpenNewFileInZip2   UNSIGNED,NAME('cz_zipOpenNewFileInZip2')
fp_zipOpenNewFileInZip3   UNSIGNED,NAME('cz_zipOpenNewFileInZip3')

fp_unzOpen    UNSIGNED,NAME('cz_unzOpen')
fp_unzClose   UNSIGNED,NAME('cz_unzClose')
fp_unzGoToFirstFile   UNSIGNED,NAME('cz_unzGoToFirstFile')
fp_unzGoToNextFile    UNSIGNED,NAME('cz_unzGoToNextFile')
fp_unzOpenCurrentFilePassword UNSIGNED,NAME('cz_unzOpenCurrentFilePassword')
fp_unzGetCurrentFileInfo  UNSIGNED,NAME('cz_unzGetCurrentFileInfo')
fp_unzOpenCurrentFile UNSIGNED,NAME('cz_unzOpenCurrentFile')
fp_unzReadCurrentFile UNSIGNED,NAME('cz_unzReadCurrentFile')
fp_unzCloseCurrentFile    UNSIGNED,NAME('cz_unzCloseCurrentFile')

fp_deflateInit2_  UNSIGNED,NAME('cz_deflateInit2_')
fp_deflate    UNSIGNED,NAME('cz_deflate')
fp_deflateEnd UNSIGNED,NAME('cz_deflateEnd')
fp_crc32  UNSIGNED,NAME('cz_crc32')


!--------------------------------------------------------------------
! Constructor - Class constructor
!--------------------------------------------------------------------
ZipApiWrapper.Construct   PROCEDURE()
  CODE
  IF Self.LoadLibs() <> LEVEL:BENIGN
    HALT(0,'ZipApiWrapper: Failed to load zlibwapi.dll')
  END
  ! Nothing to initialize

!--------------------------------------------------------------------
! Destructor - Class destructor
!--------------------------------------------------------------------
ZipApiWrapper.Destruct    PROCEDURE()
  CODE
  ! Nothing to clean up

ZipApiWrapper.LoadLibs PROCEDURE()!,LONG
cName   CSTRING(64)
Result  LONG
  CODE
  IF hZlibWapi = 0
    cName = 'zlibwapi.dll'
    hZlibWapi = cz_LoadLibrary(cName)
    IF hZlibWapi = 0
      Self.Trace('LoadLibs: Failed to load ' & CLIP(cName))
      RETURN LEVEL:Notify
    END
  END

  IF hZlib1 = 0
    cName = 'zlib1.dll'
    hZlib1 = cz_LoadLibrary(cName)
    IF hZlib1 = 0
      Self.Trace('LoadLibs: Failed to load ' & CLIP(cName))
      RETURN LEVEL:Notify
    END
  END

  Result = LEVEL:Benign

  ! ---------------- ZIP API (zlibwapi.dll)
  cName = 'zipOpen'
  fp_zipOpen = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_zipOpen = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'zipWriteInFileInZip'
  fp_zipWriteInFileInZip = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_zipWriteInFileInZip = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'zipCloseFileInZipRaw'
  fp_zipCloseFileInZipRaw = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_zipCloseFileInZipRaw = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'zipCloseFileInZip'
  fp_zipCloseFileInZip = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_zipCloseFileInZip = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'zipClose'
  fp_zipClose = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_zipClose = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'zipOpenNewFileInZip'
  fp_zipOpenNewFileInZip = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_zipOpenNewFileInZip = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'zipOpenNewFileInZip2'
  fp_zipOpenNewFileInZip2 = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_zipOpenNewFileInZip2 = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'zipOpenNewFileInZip3'
  fp_zipOpenNewFileInZip3 = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_zipOpenNewFileInZip3 = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  ! ---------------- UNZIP API (zlibwapi.dll)
  cName = 'unzOpen'
  fp_unzOpen = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_unzOpen = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'unzClose'
  fp_unzClose = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_unzClose = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'unzGoToFirstFile'
  fp_unzGoToFirstFile = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_unzGoToFirstFile = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'unzGoToNextFile'
  fp_unzGoToNextFile = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_unzGoToNextFile = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'unzOpenCurrentFilePassword'
  fp_unzOpenCurrentFilePassword = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_unzOpenCurrentFilePassword = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'unzGetCurrentFileInfo'
  fp_unzGetCurrentFileInfo = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_unzGetCurrentFileInfo = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'unzOpenCurrentFile'
  fp_unzOpenCurrentFile = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_unzOpenCurrentFile = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'unzReadCurrentFile'
  fp_unzReadCurrentFile = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_unzReadCurrentFile = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'unzCloseCurrentFile'
  fp_unzCloseCurrentFile = cz_GetProcAddress(hZlibWapi, cName)
  IF fp_unzCloseCurrentFile = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  ! ---------------- CORE ZLIB API (zlib1.dll)
  cName = 'deflateInit2_'
  fp_deflateInit2_ = cz_GetProcAddress(hZlib1, cName)
  IF fp_deflateInit2_ = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'deflate'
  fp_deflate = cz_GetProcAddress(hZlib1, cName)
  IF fp_deflate = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'deflateEnd'
  fp_deflateEnd = cz_GetProcAddress(hZlib1, cName)
  IF fp_deflateEnd = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  cName = 'crc32'
  fp_crc32 = cz_GetProcAddress(hZlib1, cName)
  IF fp_crc32 = 0 ; Self.Trace('Failed ' & CLIP(cName)) ; Result = LEVEL:Notify; END

  RETURN Result


ZipApiWrapper.zipOpen PROCEDURE(*CSTRING ZipFileName, LONG appendmode)
  CODE
  RETURN cz_zipOpen(ZipFileName, appendmode)

ZipApiWrapper.zipWriteInFileInZip PROCEDURE(LONG zipHandle, LONG pBuf, ULONG len)
RetValue                            LONG
  CODE

  RetValue = cz_zipWriteInFileInZip(zipHandle, pBuf, len)
  IF RetValue < 0
    Self.SetError('ZipApiWrapper: zipWriteInFileInZip Buffer Pointer ' & pBuf & ' Len ' & len, RetValue)
  END
  RETURN RetValue


ZipApiWrapper.zipCloseFileInZipRaw    PROCEDURE(LONG zipFile, LONG uncompressed_size, ULONG crc32)
RetValue                                LONG
  CODE
  RetValue = cz_zipCloseFileInZipRaw(zipFile, uncompressed_size, crc32)
  IF RetValue < 0
    Self.SetError('ZipApiWrapper: zipCloseFileInZipRaw', RetValue)
  END
  RETURN RetValue

ZipApiWrapper.zipCloseFileInZip   PROCEDURE(LONG zipFile)
RetValue                            LONG
  CODE
  RetValue = cz_zipCloseFileInZip(zipFile)
  IF RetValue < 0
    SELF.SetError('ZipApiWrapper: zipCloseFileInZip', RetValue)
  END
  RETURN RetValue

ZipApiWrapper.zipClose    PROCEDURE(LONG zipFile, *CSTRING global_comment)
RetValue                    LONG
  CODE
  RetValue = cz_zipClose(zipFile, global_comment)
  IF RetValue < 0
    SELF.SetError('ZipApiWrapper: zipClose', RetValue)
  END
  RETURN RetValue

ZipApiWrapper.zipOpenNewFileInZip PROCEDURE(LONG zipFile, *CSTRING filename, *zip_fileinfo_s zipfi, *CSTRING extrafield_local, LONG size_extrafield_local, *CSTRING extrafield_global, LONG size_extrafield_global, *CSTRING comment, LONG method, LONG level)
fnPtr                               LONG
zfPtr                               LONG
locPtr                              LONG
globPtr                             LONG
cmtPtr                              LONG
RetValue                            LONG
  CODE
  fnPtr  = CHOOSE(LEN(CLIP(filename))=0, 0, ADDRESS(filename))
  zfPtr  = ADDRESS(zipfi)
  locPtr = CHOOSE(LEN(CLIP(extrafield_local))=0, 0, ADDRESS(extrafield_local))
  globPtr= CHOOSE(LEN(CLIP(extrafield_global))=0, 0, ADDRESS(extrafield_global))
  cmtPtr = CHOOSE(LEN(CLIP(comment))=0, 0, ADDRESS(comment))
  
  RetValue = cz_zipOpenNewFileInZip(zipFile, fnPtr, zfPtr, locPtr, size_extrafield_local, globPtr, size_extrafield_global, cmtPtr, method, level)
  
  IF RetValue < 0
    DO TracezipOpenNewFileInZipError
  END
  RETURN RetValue
TracezipOpenNewFileInZipError Routine
  SELF.Trace('ZipApiWrapper: zipOpenNewFileInZip called for ' & CLIP(filename))
  Self.Trace('  Method: ' & method & ', Level: ' & level)
  Self.Trace('   Size of zipfi: ' & SIZE(zipfi))
  Self.Trace('   zipfi.tmz_date.tm_year: ' & zipfi.tmz_date.tm_year & ', tm_mon: ' & zipfi.tmz_date.tm_mon & ', tm_mday: ' & zipfi.tmz_date.tm_mday)
  Self.Trace('   zipfi.tmz_date.tm_hour: ' & zipfi.tmz_date.tm_hour & ', tm_min: ' & zipfi.tmz_date.tm_min & ', tm_sec: ' & zipfi.tmz_date.tm_sec)
  Self.Trace('   zipfi.dosDate: ' & zipfi.dosDate &  ', zipfi.internal_fa: ' & zipfi.internal_fa & ', zipfi.external_fa: ' & zipfi.external_fa)
  Self.Trace('  Pointers - fnPtr: ' & fnPtr & ', zfPtr: ' & zfPtr & ', locPtr: ' & locPtr)
  Self.Trace('             globPtr: ' & globPtr & ', cmtPtr: ' & cmtPtr)

ZipApiWrapper.zipOpenNewFileInZip2    PROCEDURE( |
                                        LONG zipFile, *CSTRING filename, *zip_fileinfo_s zipfi, |
                                        *CSTRING extrafield_local, ULONG size_extrafield_local, |
                                        *CSTRING extrafield_global, ULONG size_extrafield_global, |
                                        *CSTRING comment, LONG method, LONG level, LONG raw, |
                                        LONG windowBits, LONG memLevel, LONG strategy)

fnPtr                                   LONG
zfPtr                                   LONG
locPtr                                  LONG
globPtr                                 LONG
cmtPtr                                  LONG
RetValue                                LONG
  CODE
  fnPtr  = CHOOSE(LEN(CLIP(filename))=0, 0, ADDRESS(filename))
  zfPtr  = ADDRESS(zipfi)
  locPtr = CHOOSE(LEN(CLIP(extrafield_local))=0, 0, ADDRESS(extrafield_local))
  globPtr= CHOOSE(LEN(CLIP(extrafield_global))=0, 0, ADDRESS(extrafield_global))
  cmtPtr = CHOOSE(LEN(CLIP(comment))=0, 0, ADDRESS(comment))
  
  RetValue = cz_zipOpenNewFileInZip2( |
    zipFile, fnPtr, zfPtr, |
    locPtr, size_extrafield_local, |
    globPtr, size_extrafield_global, |
    cmtPtr, method, level, raw, windowBits, memLevel, strategy)

  IF RetValue < 0
    DO TracezipOpenNewFileInZip2Error
  END
  RETURN RetValue

TracezipOpenNewFileInZip2Error    Routine
  SELF.Trace('ZipApiWrapper: zipOpenNewFileInZip2 called for ' & CLIP(filename))
  Self.Trace('  Method: ' & method & ', Level: ' & level & ', Raw: ' & raw)
  Self.Trace('  WindowBits: ' & windowBits & ', MemLevel: ' & memLevel & ', Strategy: ' & strategy)
  Self.Trace('   Size of zipfi: ' & SIZE(zipfi))
  Self.Trace('   zipfi.tmz_date.tm_year: ' & zipfi.tmz_date.tm_year & ', tm_mon: ' & zipfi.tmz_date.tm_mon & ', tm_mday: ' & zipfi.tmz_date.tm_mday)
  Self.Trace('   zipfi.tmz_date.tm_hour: ' & zipfi.tmz_date.tm_hour & ', tm_min: ' & zipfi.tmz_date.tm_min & ', tm_sec: ' & zipfi.tmz_date.tm_sec)
  Self.Trace('   zipfi.dosDate: ' & zipfi.dosDate &  ', zipfi.internal_fa: ' & zipfi.internal_fa & ', zipfi.external_fa: ' & zipfi.external_fa)
  Self.Trace('  Pointers - fnPtr: ' & fnPtr & ', zfPtr: ' & zfPtr & ', locPtr: ' & locPtr)
  Self.Trace('             globPtr: ' & globPtr & ', cmtPtr: ' & cmtPtr)

ZipApiWrapper.zipOpenNewFileInZip3    PROCEDURE( |
                                        LONG zipFile, *CSTRING filename, *zip_fileinfo_s zipfi, |
                                        *CSTRING extrafield_local, LONG size_extrafield_local, |
                                        *CSTRING extrafield_global, LONG size_extrafield_global, |
                                        *CSTRING comment, LONG method, LONG level, LONG raw, |
                                        LONG windowBits, LONG memLevel, LONG strategy, |
                                        *CSTRING password, ULONG crcForCrypting)

fnPtr                                   LONG
zfPtr                                   LONG
locPtr                                  LONG
globPtr                                 LONG
cmtPtr                                  LONG
pwdPtr                                  LONG
RetValue                                LONG
  CODE
  IF password <> ''
    WindowBits = 15
    MemLevel  = 8
    Strategy  = 0
  END
  
  
  fnPtr  = CHOOSE(LEN(CLIP(filename))=0, 0, ADDRESS(filename))
  zfPtr  = ADDRESS(zipfi)
 
  locPtr = CHOOSE(LEN(CLIP(extrafield_local))=0, 0, ADDRESS(extrafield_local))
  globPtr= CHOOSE(LEN(CLIP(extrafield_global))=0, 0, ADDRESS(extrafield_global))
  cmtPtr = CHOOSE(LEN(CLIP(comment))=0, 0, ADDRESS(comment))
  pwdPtr = CHOOSE(LEN(CLIP(password))=0, 0, ADDRESS(password))
  
  RetValue = cz_zipOpenNewFileInZip3(zipFile, fnPtr, zfPtr, |
    locPtr, size_extrafield_local, globPtr, size_extrafield_global, |
    cmtPtr, method, level, raw, windowBits, memLevel, strategy, |
    pwdPtr, crcForCrypting)

  IF RetValue < 0 
    DO TracezipOpenNewFileInZip3Error
  END
  RETURN RetValue
TracezipOpenNewFileInZip3Error    Routine
  SELF.Trace('ZipApiWrapper: zipOpenNewFileInZip3 called for ' & CLIP(filename))
  Self.Trace('  Method: ' & method & ', Level: ' & level & ', Raw: ' & raw)
  Self.Trace('  WindowBits: ' & windowBits & ', MemLevel: ' & memLevel & ', Strategy: ' & strategy)
  Self.Trace('  Password: ' & CHOOSE(LEN(CLIP(password))=0, '<none>', '<provided>') & ', CRC for crypting: ' & crcForCrypting)  
  self.Trace('   Size of zipfi' & SIZE(zipfi ))
  Self.Trace('   zipfi.tmz_date.tm_year: ' & zipfi.tmz_date.tm_year & ', tm_mon: ' & zipfi.tmz_date.tm_mon & ', tm_mday: ' & zipfi.tmz_date.tm_mday)
  Self.Trace('   zipfi.tmz_date.tm_hour: ' & zipfi.tmz_date.tm_hour & ', tm_min: ' & zipfi.tmz_date.tm_min & ', tm_sec: ' & zipfi.tmz_date.tm_sec)
  Self.Trace('   zipfi.dosDate: ' & zipfi.dosDate &  ', zipfi.internal_fa: ' & zipfi.internal_fa & ', zipfi.external_fa: ' & zipfi.external_fa)
  self.Trace('  Password buffer [' & LEN(CLIP(password)) & ']: [' & password & ']')
  Self.Trace('  Pointers - fnPtr: ' & fnPtr & ', zfPtr: ' & zfPtr & ', locPtr: ' & locPtr)
  Self.Trace('             globPtr: ' & globPtr & ', cmtPtr: ' & cmtPtr & ', pwdPtr: ' & pwdPtr)
!--------------------------------------------------------------------
! UNZIP API wrapper methods
!--------------------------------------------------------------------
ZipApiWrapper.unzOpen PROCEDURE(*CSTRING ZipFileName)
  CODE
  RETURN cz_unzOpen(ZipFileName)

ZipApiWrapper.unzClose    PROCEDURE(LONG unzFile)
RetValue                    LONG
  CODE
  RetValue = cz_unzClose(unzFile)
  IF RetValue < 0
    SELF.SetError('ZipApiWrapper: unzClose error: ', RetValue)
  END
  RETURN RetValue

ZipApiWrapper.unzGoToFirstFile    PROCEDURE(LONG unzFile)
  CODE
  RETURN cz_unzGoToFirstFile(unzFile)

ZipApiWrapper.unzGoToNextFile PROCEDURE(LONG unzFile)
  CODE
  RETURN cz_unzGoToNextFile(unzFile)

ZipApiWrapper.unzOpenCurrentFilePassword  PROCEDURE(LONG unzFile, *CSTRING password)
pwdPtr                                      LONG
RetValue                                    LONG
  CODE
  ! Handle password parameter carefully
  SELF.Trace('unzOpenCurrentFilePassword: Password length = ' & LEN(CLIP(password)))
  
  ! Use NULL pointer if password is empty, otherwise use address of password
  pwdPtr = CHOOSE(LEN(CLIP(password))=0, 0, ADDRESS(password))
  
  ! Log the password pointer for debugging
  SELF.Trace('unzOpenCurrentFilePassword: Password pointer = ' & pwdPtr)
  
  ! Call the DLL function with the password pointer
  RetValue =  cz_unzOpenCurrentFilePassword(unzFile, pwdPtr)
  IF RetValue < 0
    SELF.SetError('ZipApiWrapper: unzOpenCurrentFilePassword error:', RetValue)
  END
  ! Log the result
  SELF.Trace('unzOpenCurrentFilePassword: Result = ' & RetValue)
  
  RETURN RetValue

ZipApiWrapper.unzGetCurrentFileInfo   PROCEDURE( |
                                        LONG unzFile, *UnzipFileInfo pfile_info, *CSTRING filename, ULONG filenameBufferSize, |
                                        <LONG extraField>, ULONG extraFieldBufferSize, <LONG comment>, ULONG commentBufferSize)

RetValue                                LONG
  CODE
  Self.Trace('unzGetCurrentFileInfo: Called with buffer size=' & filenameBufferSize)
  Self.Trace('unzGetCurrentFileInfo: filename addr=' & ADDRESS(filename) & ' extraField=' & extraField & ' comment=' & comment)

  RetValue = cz_unzGetCurrentFileInfo(unzFile, ADDRESS(pfile_info), ADDRESS(filename), |
    filenameBufferSize, extraField, |
    extraFieldBufferSize, comment, commentBufferSize)

  Self.Trace('unzGetCurrentFileInfo: Result=' & RetValue)
  IF RetValue = 0
    Self.Trace('unzGetCurrentFileInfo: Returned filename=[' & CLIP(filename) & ']')
  END

  RETURN RetValue
ZipApiWrapper.unzOpenCurrentFile  PROCEDURE(LONG unzFile)
  CODE
  RETURN cz_unzOpenCurrentFile(unzFile)

ZipApiWrapper.unzReadCurrentFile  PROCEDURE(LONG unzFile, *STRING buf, ULONG len)
  CODE
  RETURN cz_unzReadCurrentFile(unzFile, buf, len)

ZipApiWrapper.unzCloseCurrentFile PROCEDURE(LONG unzFile)
RetValue                            LONG
  CODE
  RetValue = cz_unzCloseCurrentFile(unzFile)
  IF RetValue < 0
    SELF.SetError('ZipApiWrapper: unzCloseCurrentFile error:', RetValue)
  END
  RETURN RetValue

!--------------------------------------------------------------------
! ZLIB CORE COMPRESSION API wrapper methods
!--------------------------------------------------------------------
ZipApiWrapper.deflateInit2_   PROCEDURE(*STRING strm, LONG level, LONG method, LONG windowBits, LONG memLevel, LONG strategy, *CSTRING version, LONG stream_size)
  CODE
  RETURN cz_deflateInit2_(ADDRESS(strm), level, method, windowBits, memLevel, strategy, version, stream_size)

ZipApiWrapper.deflate PROCEDURE(LONG strm, LONG flush)
  CODE
  RETURN cz_deflate(strm, flush)

ZipApiWrapper.deflateEnd  PROCEDURE(*STRING strm)
RetValue                    LONG
  CODE
  RetValue = cz_deflateEnd(ADDRESS(strm))
  IF RetValue < 0
    SELF.SetError('ZipApiWrapper: deflateEnd error:', RetValue)
  END
  RETURN RetValue

ZipApiWrapper.crc32   PROCEDURE(ULONG crc, *STRING buf, ULONG len)
  CODE
  RETURN cz_crc32(crc, ADDRESS(buf), len)

!--------------------------------------------------------------------
! WINDOWS API wrapper methods
!--------------------------------------------------------------------
ZipApiWrapper.CreateFile  PROCEDURE(*CSTRING lpFileName, ULONG dwDesiredAccess, ULONG dwShareMode, <*? lpSecurityAttributes>, ULONG dwCreationDisposition, ULONG dwFlagsAndAttributes, UNSIGNED hTemplateFile)
  CODE
  RETURN cz_CreateFile(lpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes, dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile)

ZipApiWrapper.WriteFile   PROCEDURE(UNSIGNED hFile, *STRING lpBuffer, ULONG nNumberOfBytesToWrite, *ULONG lpNumberOfBytesWritten, <*? lpOverlapped>)
RetValue                    BOOL
  CODE
  RetValue = cz_WriteFile(hFile, lpBuffer, nNumberOfBytesToWrite, lpNumberOfBytesWritten, lpOverlapped)
  IF RetValue = FALSE
    SELF.SetError('ZipApiWrapper: WriteFile error', cz_GetLastError())
  END
  RETURN RetValue

ZipApiWrapper.ReadFile    PROCEDURE(UNSIGNED hFile, *STRING lpBuffer, ULONG nNumberOfBytesToRead, *ULONG lpNumberOfBytesRead, LONG lpOverlapped)
  CODE
  RETURN cz_ReadFile(hFile, ADDRESS(lpBuffer), nNumberOfBytesToRead, lpNumberOfBytesRead, lpOverlapped)

ZipApiWrapper.CloseFile   PROCEDURE(UNSIGNED hObject)
RetValue                    BOOL
  CODE
  RetValue = cz_CloseFile(hObject)
  IF RetValue = FALSE
    SELF.SetError('ZipApiWrapper: CloseFile error', cz_GetLastError())
  END
  RETURN RetValue

ZipApiWrapper.GetLastError    PROCEDURE()
  CODE
  RETURN cz_GetLastError()

ZipApiWrapper.CreateDirectory PROCEDURE(*CSTRING lpPathName)
  CODE
  RETURN cz_CreateDirectory(ADDRESS(lpPathName), 0)

ZipApiWrapper.DeleteFile  PROCEDURE(*CSTRING lpFileName)
  CODE
  RETURN cz_DeleteFile(lpFileName)

ZipApiWrapper.GetCurrentDirectory PROCEDURE(ULONG nBufferLength, *CSTRING lpBuffer)
RetValue                            ULONG
  CODE
  RetValue = cz_GetCurrentDirectory(nBufferLength, lpBuffer)
  IF RetValue = 0  !Is this an error?
    SELF.Trace('ZipApiWrapper: GetCurrentDirectory error')
  END
  RETURN RetValue

ZipApiWrapper.ODS PROCEDURE(*CSTRING lpOutputString)
  CODE
  cz_ODS(lpOutputString)

ZipApiWrapper.WaitForThread   PROCEDURE(LONG ThreadID)
  CODE
  RETURN cz_WaitForThread(ThreadID)

ZipApiWrapper.Sleep   PROCEDURE(ULONG dwMilliseconds)
  CODE
  cz_Sleep(dwMilliseconds)

ZipApiWrapper.GetFileSize PROCEDURE(*LONG hFile)
lpFileSizeHigh              LONG
  CODE
  RETURN cz_GetFileSize(hFile, lpFileSizeHigh)

ZipApiWrapper.FlushFileBuffers    PROCEDURE(LONG hFile)
  CODE
  RETURN cz_FlushFileBuffers(hFile)
  
ZipApiWrapper.MemCpy  PROCEDURE(*String Dest,*String Source,LONG nCount)
RetValue                LONG
  CODE
  RetValue = cz_memcpy(Address(Dest), Address(Source) ,nCount)
  IF RetValue = 0
    SELF.Trace('ZipApiWrapper: MemCpy error: Memory copy failed')
  END
  RETURN RetValue
  
  
ZipApiWrapper.Trace   PROCEDURE(STRING pmsg)
cmsg                    CSTRING(LEN(CLIP(pmsg)) + 1)
  CODE
  ! Only log if debug mode is on
  CMsg = pmsg
  SELF.ODS(CMsg)  