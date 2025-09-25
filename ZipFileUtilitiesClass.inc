    INCLUDE('ZipTypes.inc'),ONCE
    INCLUDE('ZipEquates.inc'),ONCE
    INCLUDE('ZipAPIWrapper.inc'),ONCE
    INCLUDE('ZipStringUtilsClass.inc'),ONCE

ZipFileUtilitiesClass   CLASS,TYPE,MODULE('ZipFileUtilitiesClass.clw'),LINK('ZipFileUtilitiesClass.clw',_ZIPLinkMode_),DLL(_ZIPDllMode_)
ZipApi          &ZipAPIWrapper  ! Reference to the ZIP API wrapper
StringUtils     &ZipStringUtilsClass  ! Reference to the string utilities class
!------------------------
CONSTRUCT      PROCEDURE()
DESTRUCT       PROCEDURE()
CreateDirectoriesFromPath   PROCEDURE(STRING DirectoryPath),PROC,BOOL,VIRTUAL
FileNameOnly    PROCEDURE(<STRING fPath>),STRING
GetFileExtension   PROCEDURE(STRING FileName),STRING
PathOnly        PROCEDURE(<STRING fPath>),STRING
SelectFiles    PROCEDURE(*ZipQueueType FileQueue),BOOL,VIRTUAL
SelectZipFolder   PROCEDURE(*ZipQueueType FileQueue, BYTE IncludeBaseFolder=TRUE, *CSTRING BaseFolder),BOOL,VIRTUAL
SelectFolder    PROCEDURE(String Title, String FileTypeSelection),STRING,VIRTUAL
SelectFile     PROCEDURE(String Title, String FileTypeSelection),STRING,VIRTUAL
ScanFolderRecursively   PROCEDURE(*CSTRING FolderPath, *ZipQueueType FileQueue, <*CSTRING BasePath>, *CSTRING BaseFolder),LONG,PROC,PRIVATE
   END


  !for the 'ZipFileUtilitiesClass.clw'