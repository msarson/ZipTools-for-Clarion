!*************************************************************************
! Standard zLib Error Codes
!*************************************************************************
CZ_ZIP_OK             EQUATE(0)       ! No error
CZ_ZIP_EOF            EQUATE(0)       ! End of file
CZ_ZIP_ERRNO          EQUATE(-1)      ! Error number from operating system
CZ_ZIP_PARAMERROR     EQUATE(-102)    ! Parameter error
CZ_ZIP_BADZIPFILE     EQUATE(-103)    ! Bad zip file
CZ_ZIP_INTERNALERROR  EQUATE(-104)    ! Internal error

!*************************************************************************
! Append Status Modes
!*************************************************************************
CZ_ZIP_APPEND_STATUS_CREATE        EQUATE(0)  ! Create a new zip file
CZ_ZIP_APPEND_STATUS_CREATEAFTER   EQUATE(1)  ! Add to existing zip file
CZ_ZIP_APPEND_STATUS_ADDINZIP      EQUATE(2)  ! Add to existing zip entry

!*************************************************************************
! Compression Levels
!*************************************************************************
CZ_Z_NO_COMPRESSION     EQUATE(0)   ! No compression
CZ_Z_BEST_SPEED         EQUATE(1)   ! Best speed
CZ_Z_DEFAULT_LEVEL      EQUATE(6)   ! Default compression level
CZ_Z_BEST_COMPRESSION   EQUATE(9)   ! Best compression

!*************************************************************************
! Compression Methods
!*************************************************************************
CZ_Z_DEFLATED   EQUATE(8)   ! Deflate compression method
CZ_Z_STORE      EQUATE(0)   ! Store files without compression

!*************************************************************************
! Flush Modes
!*************************************************************************
CZ_Z_NO_FLUSH    EQUATE(0)   ! No flush
CZ_Z_SYNC_FLUSH  EQUATE(2)   ! Sync flush
CZ_Z_FULL_FLUSH  EQUATE(3)   ! Full flush
CZ_Z_FINISH      EQUATE(4)   ! Finish flush
CZ_Z_BLOCK       EQUATE(5)   ! Block flush

!*************************************************************************
! Return Codes
!*************************************************************************
CZ_Z_OK             EQUATE(0)    ! Success
CZ_Z_STREAM_END     EQUATE(1)    ! End of stream
CZ_Z_NEED_DICT      EQUATE(2)    ! Dictionary needed
CZ_Z_ERRNO          EQUATE(-1)   ! System error
CZ_Z_STREAM_ERROR   EQUATE(-2)   ! Stream error
CZ_Z_DATA_ERROR     EQUATE(-3)   ! Data error
CZ_Z_MEM_ERROR      EQUATE(-4)   ! Memory error
CZ_Z_BUF_ERROR      EQUATE(-5)   ! Buffer error
CZ_Z_VERSION_ERROR  EQUATE(-6)   ! Version error
CZ_ZIP_ERR_ALLOC    EQUATE(-7)

!*************************************************************************
! Compression Strategies
!*************************************************************************
CZ_Z_FILTERED          EQUATE(1)   ! Filtered
CZ_Z_HUFFMAN_ONLY      EQUATE(2)   ! Huffman only
CZ_Z_RLE               EQUATE(3)   ! RLE
CZ_Z_DEFAULT_STRATEGY  EQUATE(0)   ! Default strategy

!*************************************************************************
! Data Types
!*************************************************************************
CZ_Z_BINARY   EQUATE(0)   ! Binary data
CZ_Z_ASCII    EQUATE(1)   ! ASCII data
CZ_Z_UNKNOWN  EQUATE(2)   ! Unknown data type

!*************************************************************************
! Windows API Equates
!*************************************************************************
CZ_INVALID_HANDLE_VALUE     EQUATE(-1)
CZ_GENERIC_READ             EQUATE(80000000h)   ! 0x80000000
CZ_GENERIC_WRITE            EQUATE(40000000h)   ! 0x40000000
CZ_FILE_SHARE_READ          EQUATE(1h)          ! 0x00000001
CZ_CREATE_ALWAYS            EQUATE(2h)          ! Always create new, overwrite existing
CZ_OPEN_EXISTING            EQUATE(3h)          ! Open only if file exists
CZ_FILE_ATTRIBUTE_NORMAL     EQUATE(80h)        ! 0x00000080
CZ_FILE_ATTRIBUTE_DIRECTORY  EQUATE(10h)        ! 0x00000010

!*************************************************************************
! ZipFileManager Error Codes
!*************************************************************************
CZ_ZIP_ERR_CREATE        EQUATE(-1001)  ! Failed to create ZIP
CZ_ZIP_ERR_FILE_EXISTS   EQUATE(-1002)  ! File already exists
CZ_ZIP_ERR_ADD_FILE      EQUATE(-1003)  ! Failed while adding file to ZIP
CZ_ZIP_ERR_FILE_OPEN     EQUATE(-1004)  ! Failed to open file
CZ_ZIP_ERR_FILE_CLOSE    EQUATE(-1005)  ! Failed to close file
CZ_ZIP_ERR_FILE_READ     EQUATE(-1006)  ! Failed to read file
CZ_ZIP_ERR_FILE_WRITE    EQUATE(-1007)  ! Failed to write file

!*************************************************************************
! Extended Clarion-zLib Error Codes
!*************************************************************************
CZ_ZIP_ERR_FILE_OPEN2          EQUATE(-201)   ! Error opening file
CZ_ZIP_ERR_FILE_READ2          EQUATE(-202)   ! Error reading file
CZ_ZIP_ERR_FILE_WRITE2         EQUATE(-203)   ! Error writing file
CZ_ZIP_ERR_FILE_CLOSE2         EQUATE(-204)   ! Error closing file
CZ_ZIP_ERR_MEMORY              EQUATE(-205)   ! Memory allocation error
CZ_ZIP_ERR_EXTRACT             EQUATE(-206)   ! Error during extraction
CZ_ZIP_ERR_CREATE2             EQUATE(-207)   ! Error creating zip
CZ_ZIP_ERR_ADD_FILE2           EQUATE(-208)   ! Error adding file to zip
CZ_ZIP_ERR_INVALID_PARAMETER   EQUATE(-209)   ! Invalid parameter
CZ_ZIP_ERR_FILE_EXISTS2        EQUATE(-210)   ! File exists and user chose not to overwrite
CZ_ZIP_ERR_INTERNAL            EQUATE(-211)   ! Internal error in compression process

!*************************************************************************
! Thread Notification Codes
!*************************************************************************
CZ_ZIP_NOTIFY:ThreadComplete    EQUATE(1001)  ! Thread has completed processing
CZ_ZIP_NOTIFY:ThreadProgress    EQUATE(1002)  ! Thread has processed a file
CZ_ZIP_NOTIFY:ThreadError       EQUATE(1003)  ! Thread has encountered an error
CZ_ZIP_NOTIFY:ThreadInitFailed  EQUATE(4)     ! Thread failed to initialize properly

!*************************************************************************
! Legacy Error Codes (Backward Compatibility)
!*************************************************************************
CZ_InputFileError     EQUATE(1001)
CZ_OutputFileError    EQUATE(1002)
CZ_OutOfMemoryError   EQUATE(1003)

!*************************************************************************
! Compression Levels
!*************************************************************************
CZ_Z_COMPRESSION_NONE        EQUATE(0)   ! No compression (STORE)
CZ_Z_COMPRESSION_SPEED       EQUATE(1)   ! Best speed
CZ_Z_COMPRESSION_DEFAULT     EQUATE(6)   ! Balanced default (zlib default)
CZ_Z_COMPRESSION_BEST        EQUATE(9)   ! Best compression ratio

!*************************************************************************
! Overwrite handling options
!*************************************************************************
CZ_ZIP_OVERWRITE_ASK        EQUATE(0)  ! Ask user before overwriting
CZ_ZIP_OVERWRITE_FAIL       EQUATE(1)  ! Fail if file exists
CZ_ZIP_OVERWRITE_SILENT     EQUATE(2)  ! Overwrite silently
CZ_ZIP_OVERWRITE_APPEND     EQUATE(3)  ! Append to existing zip (not yet implemented)

!====================================
! Unzip Overwrite behaviour
!====================================
UZ_OVERWRITE_ASK         EQUATE(0)  ! Prompt user if file exists
UZ_OVERWRITE_FAIL        EQUATE(1)  ! Skip file if it exists
UZ_OVERWRITE_SILENT      EQUATE(2)  ! Overwrite existing files without asking

CZ_END_OF_LIST  EQUATE(-100)

CZ_NULL       EQUATE(0)
CZ_TRACEON    EQUATE(1)
