!=============================================================
! ZipApiWrapper - DLL bindings for zLib and Windows API
!
! This file contains the declarations for external DLL functions
! used by the ZIP functionality. It separates the low-level API
! bindings from the business logic, providing a clean interface
! to the underlying compression libraries.
!
! Last revision: 23-9-2025
!=============================================================
  include('ZipTypes.inc'),once
  include('ZipErrorClass.inc'),once
_zipApiWrapperPresent_     EQUATE(1)

!*************************************************************************
! zLib Error Code Equates
!*************************************************************************
! Standard zLib error codes
ZIP_OK                          EQUATE(0)      ! No error
ZIP_EOF                         EQUATE(0)      ! End of file
ZIP_ERRNO                       EQUATE(-1)     ! Error number from operating system
ZIP_PARAMERROR                  EQUATE(-102)   ! Parameter error
ZIP_BADZIPFILE                  EQUATE(-103)   ! Bad zip file
ZIP_INTERNALERROR               EQUATE(-104)   ! Internal error

! Append status modes
ZIP_APPEND_STATUS_CREATE        EQUATE(0)      ! Create a new zip file
ZIP_APPEND_STATUS_CREATEAFTER   EQUATE(1)      ! Add to existing zip file
ZIP_APPEND_STATUS_ADDINZIP      EQUATE(2)      ! Add to existing zip entry

!*************************************************************************
! Compression Method and Level Equates
!*************************************************************************
! Compression levels
Z_NO_COMPRESSION                EQUATE(0)      ! No compression
Z_BEST_SPEED                    EQUATE(1)      ! Best speed
Z_DEFAULT_LEVEL                 EQUATE(6)      ! Default compression level
Z_BEST_COMPRESSION              EQUATE(9)      ! Best compression

! Compression methods
Z_DEFLATED                      EQUATE(8)      ! Deflate compression method
Z_STORE                         EQUATE(0)      ! Store files without compression

!*************************************************************************
! zLib Equates
!*************************************************************************
! Flush modes
Z_NO_FLUSH    EQUATE(0)      ! No flush
Z_SYNC_FLUSH  EQUATE(2)      ! Sync flush
Z_FULL_FLUSH  EQUATE(3)      ! Full flush
Z_FINISH      EQUATE(4)      ! Finish flush
Z_BLOCK       EQUATE(5)      ! Block flush

! Return codes
Z_OK          EQUATE(0)      ! Success
Z_STREAM_END  EQUATE(1)      ! End of stream
Z_NEED_DICT   EQUATE(2)      ! Dictionary needed
Z_ERRNO       EQUATE(-1)     ! System error
Z_STREAM_ERROR    EQUATE(-2)     ! Stream error
Z_DATA_ERROR  EQUATE(-3)     ! Data error
Z_MEM_ERROR   EQUATE(-4)     ! Memory error
Z_BUF_ERROR   EQUATE(-5)     ! Buffer error
Z_VERSION_ERROR   EQUATE(-6)     ! Version error

! Compression strategies
Z_FILTERED        EQUATE(1)      ! Filtered
Z_HUFFMAN_ONLY    EQUATE(2)      ! Huffman only
Z_RLE             EQUATE(3)      ! RLE
Z_DEFAULT_STRATEGY    EQUATE(0)      ! Default strategy

! Data types
Z_BINARY      EQUATE(0)      ! Binary data
Z_ASCII       EQUATE(1)      ! ASCII data
Z_UNKNOWN     EQUATE(2)      ! Unknown data type

INVALID_HANDLE_VALUE  EQUATE(-1)

!*************************************************************************
! ZipApiWrapper - Class for DLL bindings
!*************************************************************************
ZipApiWrapper    CLASS(ZipErrorClass),TYPE,MODULE('ZipApiWrapper.clw'),LINK('ZipApiWrapper.clw',_ZIPLinkMode_),DLL(_ZIPDllMode_)
! Constructor and Destructor
Construct               PROCEDURE()
Destruct                PROCEDURE()

! ZIP API (minizip-style functions from zlib for creating and manipulating ZIP files)
zipOpen                 PROCEDURE(*CSTRING ZipFileName, LONG appendmode),LONG
zipWriteInFileInZip     PROCEDURE(LONG zipHandle, LONG pBuf, ULONG len),LONG,PROC
zipCloseFileInZipRaw    PROCEDURE(LONG zipFile, LONG uncompressed_size, ULONG crc32),LONG,PROC
zipCloseFileInZip       PROCEDURE(LONG zipFile),LONG,PROC
zipClose                PROCEDURE(LONG zipFile, *CSTRING global_comment),LONG,PROC
zipOpenNewFileInZip     PROCEDURE(LONG zipFile, *CSTRING filename, *zip_fileinfo_s zipfi, *CSTRING extrafield_local, LONG size_extrafield_local, *CSTRING extrafield_global, LONG size_extrafield_global, *CSTRING comment, LONG method, LONG level),LONG
zipOpenNewFileInZip2    PROCEDURE( |
                            LONG zipFile, *CSTRING filename, *zip_fileinfo_s zipfi, |
                            *CSTRING extrafield_local, ULONG size_extrafield_local, |
                            *CSTRING extrafield_global, ULONG size_extrafield_global, |
                            *CSTRING comment, LONG method, LONG level, LONG raw, |
                            LONG windowBits, LONG memLevel, LONG strategy),LONG
zipOpenNewFileInZip3 PROCEDURE( |
    LONG zipFile, *CSTRING filename, *zip_fileinfo_s zipfi, |
    *CSTRING extrafield_local, LONG size_extrafield_local, |
    *CSTRING extrafield_global, LONG size_extrafield_global, |
    *CSTRING comment, LONG method, LONG level, LONG raw, |
    LONG windowBits, LONG memLevel, LONG strategy, |
    *CSTRING password, ULONG crcForCrypting),LONG        | !CRC32 of uncompressed data (required if password)


! UNZIP API (functions for extracting and reading ZIP files)
unzOpen                 PROCEDURE(*CSTRING ZipFileName),LONG
unzClose                PROCEDURE(LONG unzFile),LONG,PROC
unzGoToFirstFile        PROCEDURE(LONG unzFile),LONG
unzGoToNextFile         PROCEDURE(LONG unzFile),LONG
unzOpenCurrentFilePassword PROCEDURE(LONG unzFile, *CSTRING password),LONG
unzGetCurrentFileInfo PROCEDURE( |
    LONG unzFile, *UnzipFileInfo pfile_info, *CSTRING filename, ULONG filenameBufferSize, |
    <LONG extraField>, ULONG extraFieldBufferSize, <LONG comment>, ULONG commentBufferSize),LONG
unzOpenCurrentFile      PROCEDURE(LONG unzFile),LONG
unzReadCurrentFile      PROCEDURE(LONG unzFile, *STRING buf, ULONG len),LONG
unzCloseCurrentFile     PROCEDURE(LONG unzFile),LONG,PROC

! ZLIB CORE COMPRESSION API (low-level compression functions)
deflateInit2_           PROCEDURE(*STRING strm, LONG level, LONG method, LONG windowBits, LONG memLevel, LONG strategy, *CSTRING version, LONG stream_size),LONG
deflate                 PROCEDURE(LONG strm, LONG flush),LONG
deflateEnd              PROCEDURE(*STRING strm),LONG,PROC
crc32                   PROCEDURE(ULONG crc, *STRING buf, ULONG len),ULONG

! WINDOWS API CALLS (file system and process operations)
CreateFile              PROCEDURE(*CSTRING lpFileName, ULONG dwDesiredAccess, ULONG dwShareMode, <*?>, ULONG dwCreationDisposition, ULONG dwFlagsAndAttributes, UNSIGNED hTemplateFile),LONG
WriteFile               PROCEDURE(UNSIGNED hFile, *STRING lpBuffer, ULONG nNumberOfBytesToWrite, *ULONG lpNumberOfBytesWritten, <*?>),BOOL,PROC
ReadFile            PROCEDURE(UNSIGNED hFile, *STRING lpBuffer, ULONG nNumberOfBytesToRead, *ULONG lpNumberOfBytesRead, LONG lpOverlapped),BOOL
CloseFile               PROCEDURE(UNSIGNED hObject),BOOL,PROC
GetLastError            PROCEDURE(),ULONG
CreateDirectory         PROCEDURE(*CSTRING lpPathName),BOOL
DeleteFile              PROCEDURE(*CSTRING lpFileName),BOOL
GetCurrentDirectory     PROCEDURE(ULONG nBufferLength, *CSTRING lpBuffer),ULONG,PROC
ODS                     PROCEDURE(*CSTRING lpOutputString)
WaitForThread           PROCEDURE(LONG ThreadID),LONG
Sleep                   PROCEDURE(ULONG dwMilliseconds)
GetFileSize             PROCEDURE(*LONG hFile),ULONG
FlushFileBuffers    PROCEDURE(LONG hFile),BOOL
MemCpy              PROCEDURE(*STRING Dest,*STRING Source,LONG nCount),LONG,PROC
! Debug and utility methods
Trace            PROCEDURE(STRING Message)  ! Output debug message
                       END

