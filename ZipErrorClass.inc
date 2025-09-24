!=============================================================
! ZipErrorClass - Centralized error handling for ZIP operations
!
! This class centralizes error handling and error messages for all ZIP operations,
! eliminating duplication across the various ZIP wrapper classes. It provides
! consistent error reporting and translation of error codes to human-readable
! messages.
!
! Last revision: 23-9-2025
!=============================================================
    INCLUDE('ZipEquates.inc'),ONCE

!*************************************************************************
! ZipErrorClass - Class for centralized ZIP error handling
!*************************************************************************
ZipErrorClass   CLASS,TYPE,THREAD,MODULE('ZipErrorClass.clw'),LINK('ZipErrorClass.clw',_ZIPLinkMode_),DLL(_ZIPDllMode_)
zErrCode        LONG              ! Last error code

! Error handling methods
! Legacy method signature (kept for reference)
! SetError        PROCEDURE(LONG Code)

! Current error handling methods
SetError        PROCEDURE(STRING Prefix,LONG Code),VIRTUAL  ! Set error with context prefix
GetErrorCode    PROCEDURE(),LONG                    ! Get current error code
GetErrorMessage PROCEDURE(<LONG Code>),STRING,VIRTUAL       ! Get message for error code
GetzError       PROCEDURE(),STRING                  ! Legacy error method for compatibility
TraceError      PROCEDURE(<String prefix>),PRIVATE  ! Internal error tracing
               END