!*************************************************************************
! Zip Format Structures
!*************************************************************************
tm_zip_s   GROUP,TYPE
tm_sec      LONG    ! int (32-bit signed)
tm_min      LONG
tm_hour     LONG
tm_mday     LONG
tm_mon      LONG
tm_year     LONG
           END

zip_fileinfo_s GROUP,TYPE
tmz_date       LIKE(tm_zip_s)
dosDate        ULONG
internal_fa    ULONG
external_fa    ULONG
              END




! z_stream structure for zlib compression
z_stream_s_type  GROUP,TYPE
next_in           LONG        ! Pointer to next input byte
avail_in          ULONG       ! Number of bytes available at next_in
total_in          ULONG       ! Total number of input bytes read so far

next_out          LONG        ! Pointer to next output byte
avail_out         ULONG       ! Remaining free space at next_out
total_out         ULONG       ! Total number of bytes output so far

msg               LONG        ! Last error message
state             LONG        ! Internal state
zalloc            LONG        ! Allocation function
zfree             LONG        ! Free function
opaque            LONG        ! Private data object
data_type         LONG        ! Best guess about the data type
adler             ULONG       ! Adler-32 checksum
reserved          ULONG       ! Reserved for future use
               END

!*************************************************************************
! Data Structures
!*************************************************************************
ZipQ                  QUEUE,TYPE
ZipFileName             CSTRING(FILE:MaxFilePath + 1)  ! Full path to the file
version                 ULONG                          ! Version
version_needed          ULONG                          ! Version needed to extract
flag                    ULONG                          ! General purpose bit flag
compression_method      ULONG                          ! Compression method
crc                     STRING(8)                      ! CRC-32 checksum
compressed_size         ULONG                          ! Compressed size
uncompressed_size       ULONG                          ! Uncompressed size
ZipFileDate             LONG                           ! File date
ZipFileTime             LONG                           ! File time
IsFolder               BYTE                           ! 1 if folder, 0 if file

                      END

ZipOptions  GROUP,TYPE
ZipName       CSTRING(FILE:MaxFilePath+1)
Threads       LONG
Password      CSTRING(256)
Overwrite     BYTE       ! 0=Ask to Overwrite, 1=Fail if exists, 2=Overwrite silently, 3=Append
ShowProgress  BYTE       ! TRUE = show progress window, FALSE = run silent
Comment       CSTRING(512)
             END

UnzipOptions  GROUP,TYPE
ZipName        CSTRING(FILE:MaxFilePath+1)  ! input zip
OutputFolder   CSTRING(FILE:MaxFilePath+1)  ! destination folder
Threads        LONG                         ! 0=auto, 1=single-thread
Password       CSTRING(256)                 ! optional, blank = no password
Overwrite      BYTE                         ! 0=Ask, 1=Fail if exists, 2=Overwrite silently
ShowProgress   BYTE                         ! TRUE=show progress window, FALSE=quiet
              END

UnzipFileInfo GROUP,TYPE
version             ULONG
version_needed      ULONG
flag                ULONG
compression_method  ULONG
dosDate             ULONG
crc                 ULONG
compressed_size     ULONG
uncompressed_size   ULONG
size_filename       ULONG
size_file_extra     ULONG
size_file_comment   ULONG
disk_num_start      ULONG
internal_fa         ULONG
external_fa         ULONG
tmu_date            ULONG,DIM(6)   ! [0]=sec, [1]=min, [2]=hour, [3]=day, [4]=month, [5]=year
                END
