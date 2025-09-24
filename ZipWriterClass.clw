!---------------------------------------------------------
! ZipWriterClass.clw
!
! Implementation of the ZipWriterClass for ZIP writing and compression
! Handles all compression and writing operations for ZIP files
!
! Last revision: 18-9-2025
!---------------------------------------------------------
          MEMBER
  include('CWSYNCHM.INC'),once
          MAP
          END
  Include('ZipWriterClass.inc'),ONCE
  INCLUDE('ZipToolsClass.inc'),ONCE

!====================================================================
czDebugOn     EQUATE(1)

!--------------------------------------------------------------------
! ZipWriterClass methods
!--------------------------------------------------------------------
ZipWriterClass.Construct PROCEDURE()
  CODE
  ! Initialize buffers with default capacity
  SELF.ZipCompBuf &= NEW STRING(4194304) ! 4MB initial capacity for better compression
  SELF.ZipCompCap = 4194304
  
  Self.ZipApi &= NEW ZipApiWrapper
  Self.Errors &= NEW ZipErrorClass
  
ZipWriterClass.Destruct  PROCEDURE()
  CODE
  DISPOSE(Self.ZipCompBuf)
  Dispose(Self.ZipApi)
  Dispose(Self.Errors)

!--------------------------------------------------------------------
! WritePrecompressedToZip - Writes precompressed data to a ZIP file
!
! Parameters:
!   ZipHandle - Handle to the ZIP file
!   ZipEntryName - Name of the entry in the ZIP file
!   zipfi - File info structure
!   pCompBuf - Buffer containing compressed data
!   CompSize - Size of compressed data
!   UncSize - Uncompressed size
!   Crc - CRC32 checksum
!   ZipMutex - Mutex for thread synchronization
!   UseStoreMethod - TRUE to store without compression, FALSE to use deflate
!
! Returns:
!   0 on success, error code on failure
!--------------------------------------------------------------------
ZipWriterClass.WritePrecompressedToZip PROCEDURE( |
  LONG ZipHandle, *CSTRING ZipEntryName, zip_fileinfo_s zipfi, |
  LONG pCompBuf, ULONG CompSize, ULONG UncSize, ULONG Crc, *IMutex ZipMutex, BYTE UseStoreMethod, <*CSTRING OriginalFilePath>)

Result        LONG,AUTO
CNull         CSTRING(2)
MethodToUse   LONG
HasPassword   BYTE
FileHandle    LONG
ReadBuf       STRING(1048576),AUTO   ! 1MB read buffer
BytesRead     ULONG,AUTO
PasswordPtr   LONG
TotalWritten  ULONG
WindowBits    LONG                   ! Added for compression parameters
MemLevel      LONG                   ! Added for compression parameters
Strategy      LONG                   ! Added for compression parameters
  CODE
  ! Normalize entry name (forward slashes only)
  LOOP WHILE INSTRING('\', ZipEntryName)
    ZipEntryName = SUB(ZipEntryName,1,INSTRING('\',ZipEntryName)-1) & '/' & |
                   SUB(ZipEntryName,INSTRING('\',ZipEntryName)+1,LEN(CLIP(ZipEntryName)))
  END

  ! Decide method: 0 = STORE, 8 = DEFLATED
  IF UseStoreMethod
    MethodToUse = 0
  ELSE
    MethodToUse = CZ_Z_DEFLATED
  END

  HasPassword = CHOOSE(LEN(CLIP(Self.Options.Password)) > 0, TRUE, FALSE)

  !===============================================================
  ! Original file path is no longer required since we're using the buffer directly
  !===============================================================

  !===============================================================
  ! Set compression parameters
  !===============================================================
  WindowBits = 15  ! Standard value for zlib compression
  MemLevel = 8     ! Standard memory level
  Strategy = 0     ! Default strategy
  
  !===============================================================
  ! Open file in ZIP - with or without password
  !===============================================================
  ! Acquire mutex for ZIP file operations
  IF NOT ZipMutex &= NULL
    ZipMutex.Wait()
  END
  
  ! Use the adaptive compression level determined in ProcessFilesThread
  ! Default to balanced compression (level 6)
  IF HasPassword
    Result = SELF.ZipApi.zipOpenNewFileInZip3(ZipHandle, ZipEntryName, zipfi, |
      CNull,0, CNull,0, CNull, |
      MethodToUse, CZ_Z_DEFAULT_LEVEL, 0, |  ! raw=0
      WindowBits, MemLevel, Strategy, Self.Options.Password, CRC)
  ELSE
    Result = SELF.ZipApi.zipOpenNewFileInZip3(ZipHandle, ZipEntryName, zipfi, |
      CNull,0, CNull,0, CNull, |
      MethodToUse, CZ_Z_DEFAULT_LEVEL, 0, |  ! raw=0
      WindowBits, MemLevel, Strategy, CNull, 0)    ! No password
  END

  IF Result <> CZ_ZIP_OK
    Self.Errors.SetError('WritePrecompressedToZip: open failed, Entry=' & CLIP(ZipEntryName), Result)
    IF NOT ZipMutex &= NULL
      ZipMutex.Release()
    END
    RETURN CZ_ZIP_ERR_ADD_FILE
  END

  !===============================================================
  ! Write file data from the buffer that was already read
  !===============================================================
  ! Use the buffer that was already read and passed to this method
  ! instead of reading the file again
  
  Result = SELF.ZipApi.zipWriteInFileInZip(ZipHandle, pCompBuf, CompSize)
  IF Result <> CZ_ZIP_OK
    Self.Errors.SetError('WritePrecompressedToZip: zipWriteInFileInZip failed, Entry=' & CLIP(ZipEntryName) & ' Size=' & CompSize, Result)
    SELF.ZipApi.zipCloseFileInZip(ZipHandle)
    IF NOT ZipMutex &= NULL
      ZipMutex.Release()
    END
    RETURN CZ_ZIP_ERR_FILE_WRITE
  END

  !===============================================================
  ! Close file in ZIP
  !===============================================================
  Result = SELF.ZipApi.zipCloseFileInZip(ZipHandle)
  IF Result <> CZ_ZIP_OK
    Self.Errors.SetError('WritePrecompressedToZip: close failed, Result=' & Result & ' Entry=' & CLIP(ZipEntryName), Result)
    IF NOT ZipMutex &= NULL
      ZipMutex.Release()
    END
    RETURN CZ_ZIP_ERR_FILE_CLOSE
  END

  ! Release mutex
  IF NOT ZipMutex &= NULL
    ZipMutex.Release()
  END

  RETURN 0

  
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
ZipWriterClass.CompressFileToBuffer    PROCEDURE(*CSTRING FileName, *ULONG OutUncSize, *ULONG OutCrc, *ULONG OutCompSize)
FileHandle                          LONG,AUTO
zs                                  LIKE(z_stream_s_type)
Result                              LONG,AUTO
ReadBuf                             STRING(1048576),AUTO     ! 1MB read buffer
BytesRead                           ULONG,AUTO
FlushMode                           LONG,AUTO
ZlibVersion                         CSTRING('1.2.11')
NewBuf                              &STRING   ! temporary pointer for resized buffer
NewCap                              ULONG     ! new capacity

  CODE

  ! Init outputs
  OutUncSize = 0
  OutCrc     = 0
  OutCompSize = 0

  ! Ensure compression buffer exists
  IF Self.ZipCompBuf &= NULL OR Self.ZipCompCap = 0
    Self.ZipCompBuf &= NEW STRING(1048576)  ! 1MB starting capacity
    Self.ZipCompCap = 1048576
    IF Self.ZipCompBuf &= NULL
      Self.Errors.SetError('CompressFileToBuffer: Initial buffer allocation failed (1MB) for ' & CLIP(FileName), CZ_ZIP_ERR_ALLOC)
      RETURN CZ_ZIP_ERR_ALLOC
    END
  END

  ! Open file
  FileHandle = SELF.ZipApi.CreateFile(FileName, CZ_GENERIC_READ, CZ_FILE_SHARE_READ,,CZ_OPEN_EXISTING, 0, 0)
  IF FileHandle = CZ_INVALID_HANDLE_VALUE
    Self.Errors.SetError('CompressFileToBuffer: CreateFile failed for ' & CLIP(FileName), CZ_ZIP_ERR_FILE_OPEN)
    RETURN CZ_ZIP_ERR_FILE_OPEN
  END

  ! Init zlib deflate (raw mode)
  ! Use default compression level (adaptive compression is handled in ProcessFilesThread)
  CLEAR(zs)
  Result = SELF.ZipApi.deflateInit2_(zs, CZ_Z_DEFAULT_LEVEL, CZ_Z_DEFLATED, -15, 8, CZ_Z_DEFAULT_STRATEGY, ZlibVersion, SIZE(zs))
  IF Result <> CZ_Z_OK
    Self.Errors.SetError('CompressFileToBuffer: deflateInit2_ failed', Result)
    SELF.ZipApi.CloseFile(FileHandle)
    RETURN Result
  END

  LOOP
    ! Read from file
    IF SELF.ZipApi.ReadFile(FileHandle, ReadBuf, SIZE(ReadBuf), BytesRead, 0) = 0
      Self.Errors.SetError('CompressFileToBuffer: ReadFile failed file=' & CLIP(FileName) , CZ_ZIP_ERR_FILE_READ)
      SELF.ZipApi.deflateEnd(zs)
      SELF.ZipApi.CloseFile(FileHandle)
      RETURN CZ_ZIP_ERR_FILE_READ
    END

    IF BytesRead = 0
      FlushMode = CZ_Z_FINISH
    ELSE
      OutUncSize += BytesRead
      OutCrc = SELF.ZipApi.crc32(OutCrc, ReadBuf, BytesRead)
      FlushMode = CZ_Z_NO_FLUSH
    END

    zs.next_in  = ADDRESS(ReadBuf)
    zs.avail_in = BytesRead

    LOOP
      IF OutCompSize + 65536 > Self.ZipCompCap
        NewCap = Self.ZipCompCap * 2
        NewBuf &= NEW STRING(NewCap)
        IF NewBuf &= NULL
          Self.Errors.SetError('CompressFileToBuffer: Buffer resize failed, Requested=' & NewCap & ' File=' & CLIP(FileName), CZ_ZIP_ERR_ALLOC)
          SELF.ZipApi.deflateEnd(zs)
          SELF.ZipApi.CloseFile(FileHandle)
          RETURN CZ_ZIP_ERR_ALLOC
        END

        ! Copy existing compressed data to the new buffer
        Self.ZipApi.MemCpy(NewBuf, Self.ZipCompBuf, OutCompSize)

        ! Free old buffer and re-point
        DISPOSE(Self.ZipCompBuf)
        Self.ZipCompBuf &= NewBuf
        Self.ZipCompCap  = NewCap

        COMPILE('TraceOn',czDebugOn=1); SELF.Trace('CompressFileToBuffer: Buffer resized to ' & NewCap & ' bytes for ' & CLIP(FileName)) !TraceOn
      END

      zs.next_out  = ADDRESS(Self.ZipCompBuf) + OutCompSize
      zs.avail_out = Self.ZipCompCap - OutCompSize

      Result = SELF.ZipApi.deflate(ADDRESS(zs), FlushMode)
      OutCompSize += (Self.ZipCompCap - OutCompSize) - zs.avail_out

      IF Result < 0
        Self.Errors.SetError('CompressFileToBuffer: deflate failed File = ' & CLIP(FileName),  Result)
        SELF.ZipApi.deflateEnd(zs)
        SELF.ZipApi.CloseFile(FileHandle)
        RETURN Result
      END

      IF zs.avail_out > 0 AND zs.avail_in = 0
        BREAK
      END
    END

    IF BytesRead = 0
      BREAK
    END
  END

  SELF.ZipApi.deflateEnd(zs)
  SELF.ZipApi.CloseFile(FileHandle)
  RETURN 0

ZipWriterClass.ReadFileToBuffer PROCEDURE(STRING FileName, *STRING BufRef, ULONG MaxSize, *ULONG OutSize, *ULONG OutCrc)
FileHandle  LONG
BytesRead   ULONG,AUTO
czFileName  CSTRING(FILE:MaxFilePath+1)
crc         ULONG
pos         ULONG
  CODE
  OutSize = 0
  OutCrc  = 0
  crc     = 0
  czFileName = FileName

  FileHandle = SELF.ZipApi.CreateFile(czFileName, CZ_GENERIC_READ, CZ_FILE_SHARE_READ,,CZ_OPEN_EXISTING, 0, 0)
  IF FileHandle = CZ_INVALID_HANDLE_VALUE
    Self.Errors.SetError('ReadFileToBuffer: Invalid Handle on CreateFile', CZ_ZIP_ERR_FILE_OPEN)
    RETURN CZ_ZIP_ERR_FILE_OPEN
  END

  pos = 1
  LOOP
    IF SELF.ZipApi.ReadFile(FileHandle, BufRef[pos], MaxSize - OutSize, BytesRead, 0) = 0
      SELF.ZipApi.CloseFile(FileHandle)
      Self.Errors.SetError('ReadFileToBuffer: ReadFile Failed', CZ_ZIP_ERR_FILE_READ)
      RETURN CZ_ZIP_ERR_FILE_READ
    END
    IF BytesRead = 0
      BREAK
    END

    crc     = SELF.ZipApi.crc32(crc, BufRef[pos], BytesRead)
    OutSize += BytesRead
    pos     += BytesRead
    IF OutSize >= MaxSize
      BREAK
    END
  END

  SELF.ZipApi.CloseFile(FileHandle)

  OutCrc  = crc
  Self.Errors.SetError('', CZ_Z_OK)
  RETURN 0


ZipWriterClass.DumpHex  PROCEDURE(LONG pBuffer, LONG pLen)
HexStr      STRING(48)
ByteVal     BYTE,AUTO
HiNibble    BYTE,AUTO
LoNibble    BYTE,AUTO
i           LONG,AUTO
  CODE
  HexStr = ''
  LOOP i = 0 TO CHOOSE(pLen > 16, 15, pLen - 1)
    PEEK(pBuffer + i, ByteVal)  ! read 1 byte
    HiNibble = BAND(BSHIFT(ByteVal, -4), 0Fh)
    LoNibble = BAND(ByteVal, 0Fh)
    HexStr   = CLIP(HexStr) & CHOOSE(HiNibble < 10, CHR(48 + HiNibble), CHR(55 + HiNibble))
    HexStr   = CLIP(HexStr) & CHOOSE(LoNibble < 10, CHR(48 + LoNibble), CHR(55 + LoNibble))
    IF i < pLen - 1
      HexStr = CLIP(HexStr) & ' '
    END
  END
  RETURN HexStr



ZipWriterClass.Trace   PROCEDURE(STRING pmsg)
cmsg                CSTRING(LEN(CLIP(pmsg)) + 1)
  CODE
  ! Only log if debug mode is on
  CMsg = pmsg
  SELF.ZipApi.ODS(CMsg)
