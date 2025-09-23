    INCLUDE('ZipTypes.inc'),ONCE
    INCLUDE('ZipEquates.inc'),ONCE
    INCLUDE('ZipAPIWrapper.inc'),ONCE

FileUtilitiesClass   CLASS,TYPE,MODULE('FileUtilitiesClass.clw'),LINK('FileUtilitiesClass.clw',_ZIPLinkMode_),DLL(_ZIPDllMode_)
ZipApi          &ZipAPIWrapper  ! Reference to the ZIP API wrapper
!------------------------
CONSTRUCT      PROCEDURE()
DESTRUCT       PROCEDURE()
CreateDirectoriesFromPath   PROCEDURE(STRING DirectoryPath),PROC,BOOL
FileNameOnly    PROCEDURE(<STRING fPath>),STRING
GetFileExtension   PROCEDURE(STRING FileName),STRING
PathOnly        PROCEDURE(<STRING fPath>),STRING
SelectFiles    PROCEDURE(*ZipQ FileQueue),BOOL
SelectZipFolder   PROCEDURE(*ZipQ FileQueue, BYTE IncludeBaseFolder=TRUE, *CSTRING BaseFolder),BOOL
SelectFolder    PROCEDURE(String Title, String FileTypeSelection),STRING
SelectFile     PROCEDURE(String Title, String FileTypeSelection),STRING
ScanFolderRecursively   PROCEDURE(*CSTRING FolderPath, *ZipQ FileQueue, <*CSTRING BasePath>, *CSTRING BaseFolder),LONG,PROC,PRIVATE
   END



  !for the 'FileUtilitiesClass.clw'
