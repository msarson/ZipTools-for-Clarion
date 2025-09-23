

          PROGRAM
          MAP
            WindowsZipTest()

          END



  INCLUDE('CZIPCLASS.INC'),ONCE
  INCLUDE('KEYCODES.CLW'),ONCE
  


  CODE
  WindowsZipTest()


!!! <summary>
!!! Generated from procedure template - Window
!!! Window
!!! </summary>
WindowsZipTest    PROCEDURE 




ZipClass            CZipClass
FileUtils           FileUtilitiesClass
QZipF               QUEUE(ZipQ).
QDir                QUEUE(FILE:Queue),PRE(QDir).

outputFolder        String(255)
zipStarted          LONG
zipEnded            LONG
zOptions            LIKE(ZipOptions)
uzOptions           LIKE(UnzipOptions)
ResultsText         STRING(10000)
zipFileTemp         STRING(255)
folderPathTemp      STRING(255)
slashPosTemp        LONG
iTemp               LONG
rTemp               LONG
LOCAL:ZipName       CSTRING(256)                          ! 
Local:FolderPath    STRING(255)                           ! folder with file mask "ie c:\temp\*.pdf"
ZFile               STRING(128),AUTO                      ! 
QuickWindow         WINDOW('ZIP Test Interface'),AT(,,500,420),CENTER,GRAY,IMM,AUTO,SYSTEM, |
                      HLP('WindowsZipTest'),FONT('Segoe UI',10,COLOR:Black,FONT:regular, |
                      CHARSET:DEFAULT)
                      SHEET,AT(2,2,496,396),USE(?SHEET1)
                        TAB('Zip Options'),USE(?TAB1)
                          BUTTON('Select Files To Zip'),AT(10,25),USE(?btnSelectFilesToZip)
                          BUTTON('Select Folder To Zip'),AT(100,25),USE(?btnSelectFolderToZip)
                          PROMPT('Zip Name:'),AT(10,50),USE(?LOCAL:ZipName:Prompt)
                          ENTRY(@s255),AT(60,50,224,10),USE(LOCAL:ZipName),REQ
                          BUTTON('ZIP Them'),AT(290,50),USE(?BUTTONZipThem),LEFT
                          STRING(@s128),AT(60,70,224,13),USE(ZFile)
                          GROUP('Compression Options'),AT(10,100,230,80),USE(?GROUP1),BOXED
                            STRING('Using adaptive compression strategy'),AT(20,120,200,10), |
                              USE(?COMPRESSION_INFO)
                            STRING('Automatically selects optimal compression'),AT(20,135,200,10), |
                              USE(?COMPRESSION_INFO2)
                            STRING('based on file type and size'),AT(20,150,200,10),USE(?COMPRESSION_INFO3) |
              
                          END
                          GROUP('Thread Options'),AT(250,100,230,80),USE(?GROUP2),BOXED
                            PROMPT('Number of Threads:'),AT(260,120),USE(?PROMPT2)
                            SPIN(@n2),AT(350,120,40,10),USE(zOptions.Threads),RANGE(1,8)
                          END
                          GROUP('File Options'),AT(10,190,230,80),USE(?GROUP3),BOXED
                            PROMPT('Overwrite Behavior:'),AT(20,210),USE(?PROMPT3)
                            OPTION,AT(120,210,110,60),USE(zOptions.Overwrite),BOXED
                              RADIO('Ask'),AT(125,210),USE(?OPTION2:Radio1),VALUE('0')
                              RADIO('Fail if Exists'),AT(125,225),USE(?OPTION2:Radio2),VALUE('1')
                              RADIO('Overwrite Silently'),AT(125,240),USE(?OPTION2:Radio3),VALUE('2')
                              RADIO('Append'),AT(125,255),USE(?OPTION2:Radio4),VALUE('3')
                            END
                          END
                          GROUP('Security'),AT(250,190,230,80),USE(?GROUP4),BOXED
                            PROMPT('Password:'),AT(260,210),USE(?PROMPT4)
                            ENTRY(@s255),AT(310,210,160,10),USE(zOptions.Password)
                          END
                          GROUP('Other Options'),AT(10,280,470,60),USE(?GROUP5),BOXED
                            PROMPT('Comment:'),AT(20,300),USE(?PROMPT5)
                            ENTRY(@s255),AT(70,300,400,10),USE(zOptions.Comment)
                            CHECK('Show Progress'),AT(20,320),USE(zOptions.ShowProgress),VALUE('1','')
                          END
                        END
                        TAB('Unzip Options'),USE(?TAB2)
                          PROMPT('Zip File:'),AT(10,30),USE(?PROMPT6)
                          ENTRY(@s255),AT(60,30,224,10),USE(uzOptions.ZipName)
                          BUTTON('Browse...'),AT(290,30),USE(?btnBrowseZip)
                          PROMPT('Output Folder:'),AT(10,50),USE(?PROMPT7)
                          ENTRY(@s255),AT(80,50,204,10),USE(uzOptions.OutputFolder)
                          BUTTON('Browse...'),AT(290,50),USE(?btnBrowseFolder)
                          BUTTON('&UNZIP Them'),AT(290,80),USE(?btnUnzip),KEY(CtrlShiftU), |
                            ALRT(CtrlShiftU)
                          GROUP('File Options'),AT(10,110,230,80),USE(?GROUP6),BOXED
                            PROMPT('Overwrite Behavior:'),AT(20,130),USE(?PROMPT8)
                            OPTION,AT(120,130,110,60),USE(uzOptions.Overwrite),BOXED
                              RADIO('Ask'),AT(125,130),USE(?OPTION3:Radio1),VALUE('0')
                              RADIO('Fail if Exists'),AT(125,145),USE(?OPTION3:Radio2),VALUE('1')
                              RADIO('Overwrite Silently'),AT(125,160),USE(?OPTION3:Radio3),VALUE('2')
                            END
                          END
                          GROUP('Security'),AT(250,110,230,80),USE(?GROUP7),BOXED
                            PROMPT('Password:'),AT(260,130),USE(?PROMPT9)
                            ENTRY(@s255),AT(310,130,160,10),USE(uzOptions.Password)
                          END
                          GROUP('Other Options'),AT(10,200,470,60),USE(?GROUP8),BOXED
                            CHECK('Show Progress'),AT(20,220),USE(uzOptions.ShowProgress),VALUE('1','')
                          END
                        END
                        TAB('Results'),USE(?TAB3)
                          TEXT,AT(10,30,480,330),USE(ResultsText),VSCROLL
                        END
                      END
                      BUTTON('Close'),AT(450,400,49,14),USE(?Close),MSG('Cancel Operation'), |
                        FONT(,,,FONT:regular),ICON('wacancel.ico'),TIP('Cancel Operation'),FLAT,LEFT
                    END




  CODE
  OPEN(QuickWindow)
  ACCEPT
    CASE ACCEPTED()
    of ?Close
      Break
    OF ?btnSelectFilesToZip
      UPDATE()
          !Files
      Free(QZipF)
      IF NOT ZipClass.SelectFilesToZip(QZipF) THEN
        Message('No files Selected')
      ELSE
        0{prop:text} = 'Files Selected for zipping Count: ' & RECORDS(QZipF)
        UNHIDE(?BUTTONZipThem)
            
            ! Update results tab with file list
        ResultsText = 'Files selected for zipping:' & '<13,10>'
        LOOP iTemp = 1 TO RECORDS(QZipF)
          GET(QZipF, iTemp)
          ResultsText = ResultsText & QZipF.ZipFileName & '<13,10>'
        END
      END
    OF ?BUTTONZipThem
      UPDATE()
      ! Validate that a zip name has been entered
      IF LOCAL:ZipName = ''
        Message('Please enter a zip name before proceeding', 'Validation Error', ICON:Exclamation)
        SELECT(?LOCAL:ZipName)
        CYCLE
      END
      
      ! Show progress bar
      
      ! Call the ZIPThem routine
      DO ZIPThem
    OF ?btnSelectFolderToZip
      UPDATE()
          !Folder
      Free(QZipF)
      IF NOT ZipClass.SelectFolderToZip(QZipF,false) THEN
        Message('No Folder Selected')
      ELSE
        0{prop:text} = 'Files Selected for zipping Count: ' & RECORDS(QZipF)
        UNHIDE(?BUTTONZipThem)
            
            ! Update results tab with folder info
        ResultsText = 'Folder selected for zipping:' & '<13,10>'
        IF RECORDS(QZipF) > 0
          GET(QZipF, 1)
          folderPathTemp = QZipF.ZipFileName
              ! Extract folder path from first file
          slashPosTemp = INSTRING('\', folderPathTemp, 1, SIZE(folderPathTemp))
          IF slashPosTemp > 0
            folderPathTemp = folderPathTemp[1:slashPosTemp-1]
          END
          ResultsText = ResultsText & 'Folder: ' & folderPathTemp & '<13,10>'
          ResultsText = ResultsText & 'Total files: ' & RECORDS(QZipF) & '<13,10>'
        END
      END
    OF ?btnBrowseZip
      Update()
      zipFileTemp =  FileUtils.SelectFile('Select ZIP File to Extract','ZIP Files|*.zip|All Files|*.*')
      IF zipFileTemp <> ''
        uzOptions.ZipName = zipFileTemp
        ZFile = zipFileTemp
        DISPLAY(uzOptions.ZipName)
      END
          
    OF ?btnBrowseFolder
      UPDATE()
      folderPathTemp = FileUtils.SelectFolder('Select Folder to Extract Zip To','All Files | *.*')
      IF folderPathTemp <> ''
        uzOptions.OutputFolder = folderPathTemp
        Local:FolderPath = folderPathTemp
            !DISPLAY(?uzOptions.OutputFolder)
      END
          
    OF ?btnUnzip
      UPDATE()
      IF uzOptions.ZipName = ''
        Message('No zip file specified')
        CYCLE
      END
      IF uzOptions.OutputFolder = ''
        Local:FolderPath = FileUtils.SelectFolder('Select Folder to Extract Zip To','All Files | *.*')
        uzOptions.OutputFolder = Local:FolderPath
      END
      IF uzOptions.OutputFolder ='' THEN
        Message('No Directory Selected','Error',ICON:Exclamation)
        CYCLE
      END
      
      ! Check if directory exists and offer to create it if not
      IF NOT EXISTS(uzOptions.OutputFolder) THEN
        IF Message('Output directory does not exist. Would you like to create it?', 'Create Directory', ICON:Question, BUTTON:Yes+BUTTON:No, BUTTON:Yes) = BUTTON:Yes
          ! Call CreateDirectoriesFromPath with STRING parameter directly
          IF NOT FileUtils.CreateDirectoriesFromPath(uzOptions.OutputFolder)
            Message('Failed to create directory: ' & uzOptions.OutputFolder, 'Error', ICON:Exclamation)
            CYCLE
          END
        ELSE
          CYCLE
        END
      END
      
      ! Only use ZFile if uzOptions.ZipName is empty
      IF uzOptions.ZipName = ''
        uzOptions.ZipName = CLIP(ZFile)
      END
      
      ! Default values if not set
      IF uzOptions.ShowProgress = 0
        uzOptions.ShowProgress = TRUE
      END
      IF uzOptions.Overwrite = 0
        uzOptions.Overwrite = UZ_OVERWRITE_SILENT
      END
      ! Show progress bar
      
      ! Extract the zip file
      rTemp = ZipClass.ExtractZipFile(uzOptions)
      
      ! Reset progress bar when done
      IF rTemp = 0
        Message('Files Extracted to ' & uzOptions.OutputFolder)
        
        ! Update results tab
        ResultsText = 'UNZIP OPERATION COMPLETED' & |
          '<13,10>Files extracted to: ' & uzOptions.OutputFolder & |
          '<13,10>Zip file: ' & uzOptions.ZipName & |
          '<13,10>Result code: ' & rTemp
      END
      
      ! Reset ZipClass state to prepare for next operation
      ZipClass.Reset()
    END
    CASE EVENT()
    OF EVENT:OpenWindow
   
      
      ! Initialize ZipClass to a clean state
      ZipClass.Reset()
      
      ! Initialize options with defaults
      zOptions.Threads = 8
      ! Compression is now handled adaptively
      zOptions.Overwrite = CZ_ZIP_OVERWRITE_ASK
      zOptions.ShowProgress = TRUE
      
      uzOptions.ShowProgress = TRUE
      uzOptions.Overwrite = UZ_OVERWRITE_SILENT
      
      ResultsText = 'No operations performed yet.'
    END
  END
  

  CLOSE(QuickWindow)
  
!---------------------------------------------------------------------------
DefineListboxStyle    ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------
ZIPThem   ROUTINE
  DATA
totalUncompressedSize   LONG
zipFileSize LONG
compressionRatio    REAL
zipPath CSTRING(256)
zipFileQ    QUEUE(FILE:Queue),PRE(zipQ).
  CODE
  IF RECORDS(QZipF) = 0
    Message('Nothing has been selected to zip')
    EXIT
  END
  SetCursor(CURSOR:Wait)
  IF LOCAL:ZipName <> '' and Records(QZipF) THEN
    ! Calculate total uncompressed size
    !Create DIR if not exist
    
    totalUncompressedSize = 0
    LOOP iTemp = 1 TO RECORDS(QZipF)
      GET(QZipF, iTemp)
      totalUncompressedSize += QZipF.uncompressed_size
    END
    
    zipStarted = CLOCK()
    zOptions.ZipName = LOCAL:ZipName
      ! Default values if not set
      IF zOptions.Threads = 0
        zOptions.Threads = 8
      END
      ! Compression is now handled adaptively
      IF zOptions.Overwrite = 0
        zOptions.Overwrite = CZ_ZIP_OVERWRITE_ASK
      END
      IF zOptions.ShowProgress = 0
        zOptions.ShowProgress = TRUE
      END
      
      ! Show progress bar
      IF ZipClass.CreateZipFile(QZipF, zOptions) = 0
      zFile = zOptions.ZipName
      zipEnded = CLOCK()
      
      ! Get the size of the zip file
      FREE(zipFileQ)
      DIRECTORY(zipFileQ, zOptions.ZipName, ff_:NORMAL)
      IF RECORDS(zipFileQ) > 0
        GET(zipFileQ, 1)
        zipFileSize = zipQ:size
      ELSE
        zipFileSize = 0
      END
      
      ! Calculate compression ratio if uncompressed size is not zero
      IF totalUncompressedSize > 0
        compressionRatio = zipFileSize / totalUncompressedSize * 100
      ELSE
        compressionRatio = 0
      END
      
      Message('Zipped in: ' & FORMAT(zipEnded - zipStarted,@t4))
      
      ! Update results tab with size information
      ResultsText = 'ZIP OPERATION COMPLETED' & |
        '<13,10>Time taken: ' & FORMAT(zipEnded - zipStarted,@t4) & |
        '<13,10>Files processed: ' & RECORDS(QZipF) & |
        '<13,10>Total size before zipping: ' & FORMAT(totalUncompressedSize,@n_11) & ' bytes' & |
        '<13,10>Size after zipping: ' & FORMAT(zipFileSize,@n_11) & ' bytes' & |
        '<13,10>Compression ratio: ' & FORMAT(compressionRatio,@n4.1) & '%' & |
        '<13,10>Zip file: ' & zOptions.ZipName & |
        '<13,10>Using adaptive compression' & |
        '<13,10>Threads used: ' & zOptions.Threads
      unhide(?ZFile)
      DISPLAY(?ZFile)
      
      
      ! Reset progress bar when done
      
      ! Reset ZipClass state to prepare for next operation
      ZipClass.Reset()
    ELSE
      Message(ZipClass.GetErrorMessage(ZipClass.GetErrorCode()),'Error creating ' & zOptions.ZipName,ICON:Exclamation)
    END
        
  END
  SetCursor()
    
  EXIT




