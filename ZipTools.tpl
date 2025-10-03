#Template(ZipTools,'Zip Tools - Version 1.40'),Family('cw20'),Family('abc')
#!-----------------------------------------------------------------------------!
#!                                                                             !
#! ZipTools for Clarion                                                        !
#! Copyright (c) 2025 Mark Sarson                                              !
#! Licensed under the MIT License.                                             !
#! See LICENSE file in the project root for full license text.                 !
#!                                                                             !
#!-----------------------------------------------------------------------------!
   #Include('cape01.tpw')
   #Include('cape02.tpw')
#!-----------------------------------------------------------------------------!

#GROUP(%ReadGlobal,%pa,%force)
  #INSERT(%SetFamily)
  #FOR(%applicationTemplate),Where(%applicationTemplate='Activate_ZipTools(ZipTools)')
    #FOR(%applicationTemplateInstance)
      #Context(%application,%applicationTemplateInstance)
        #insert(%ReadClassesPR,'ZipToolsClass.inc',%pa,%force)
        #insert(%ReadClassesPR,'ZipFileUtilitiesClass.inc',%pa,%force)
        #insert(%ReadClassesPR,'ZipApiWrapper.inc',%pa,%force)
        #insert(%ReadClassesPR,'ZipErrorClass.inc',%pa,%force)
        #insert(%ReadClassesPR,'ZipReaderClass.inc',%pa,%force)
        #insert(%ReadClassesPR,'ZipWorkerClass.inc',%pa,%force)
        #insert(%ReadClassesPR,'ZipWriterClass.inc',%pa,%force)
        #insert(%ReadAdditionalIncFiles,%pa,%force)
      #EndContext
    #EndFor
  #EndFor
#!-----------------------------------------------------------------------------!

#SYSTEM
  #EQUATE(%ZipToolsTPLVersion,'1.40')
#!-----------------------------------------------------------------------------!

#Extension(Activate_ZipTools,'Activate ZipTools - Version:1.40'),Application
  #sheet
    #TAB('General')
      #BOXED
        #Image('ZipTools.bmp')
        #Display('ZipTools Library'),at(,90),prop(PROP:FontStyle,700)
        #Display('Version ' & %ZipToolsTPLVersion),prop(PROP:FontStyle,700)
        #Display('(c) 2025 by Mark Sarson')
        #Display('Licensed under the MIT License.')
        #Display('See LICENSE file in the project root for full license text.')
        #Display('github.com/msarson/ZipTools-for-Clarion')
      #ENDBOXED
      #Display()
      #BOXED('Debugging')
        #PROMPT('Disable All ZipTools Features',Check),%NoGloZipTools,At(10)
      #ENDBOXED
    #ENDTAB
    #TAB('Options'),Where(%NoGloZipTools=0)
      #Prompt('Enable Progress Reporting',Check),%ZipProgress,at(10)
      #Prompt('Enable Password Support',Check),%ZipPassword,at(10)
    #ENDTAB
    #TAB('Multi-Dll'),Where(%NoGloZipTools=0)
      #Boxed('')
        #Prompt('This is part of a Multi-DLL program',Check),%MultiDLL,default(%ProgramExtension='DLL'),at(10)
        #Enable(%MultiDLL=1)
          #Enable(%ProgramExtension='DLL')
            #Prompt('Export ZipToolsClass from this DLL',Check),%RootDLL,at(10)
          #EndEnable
        #EndEnable
      #EndBoxed
    #ENDTAB
    #TAB('Classes')
      #Insert(%GlobalDeclareClassesPR)
    #ENDTAB
  #endsheet
#!-----------------------------------------------------------------------------!
#AT(%ShipList)
  #If (%NoGloZipTools=0)
___    ZLIBWAPI.DLL
___    ZLIB1.DLL
  #EndIf
#ENDAT
#!-----------------------------------------------------------------------------!
#AT(%AfterGlobalIncludes),where(%NoGloZipTools=0)
  include('ZipToolsClass.Inc'),ONCE
  #INSERT(%IncludeAdditionalIncFiles)
#ENDAT

#ATStart
  #IF(%NoGloZipTools = 0)
    #INSERT(%ReadGlobal,2,0)
  #ENDIF
#ENDAt

#AtEnd
  #IF(%NoGloZipTools = 0)
    #INSERT(%EndGlobal)
  #ENDIF
#ENDAt

#AT(%DllExportList),Where(%programExtension = 'DLL' and %RootDLL=1 and %MultiDll=1 and %NoGloZipTools=0)
#insert(%ExportClassesPR,'ZipToolsClass.inc')
#insert(%ExportClassesPR,'ZipFileUtilitiesClass.inc')
#insert(%ExportClassesPR,'ZipApiWrapper.inc')
#insert(%ExportClassesPR,'ZipErrorClass.inc')
#insert(%ExportClassesPR,'ZipReaderClass.inc')
#!insert(%ExportClassesPR,'ZipWorkerClass.inc')
#insert(%ExportClassesPR,'ZipWriterClass.inc')
#insert(%ExportAdditionalIncFiles)
#ENDAT


#AT(%CustomGlobalDeclarations),where(%NoGloZipTools=0)
#PROJECT('None(zlibwapi.dll), CopyToOutputDirectory=Always')
#PROJECT('None(zlib1.dll), CopyToOutputDirectory=Always')
#INSERT(%Defines,1,'_ZIPLinkMode_','_ZIPDllMode_',%MultiDLL,%RootDll)
#ENDAT

#AT(%mpDefineAll),where(%NoGloZipTools=0)
#INSERT(%Defines,2,'_ZIPLinkMode_','_ZIPDllMode_',%MultiDLL,%RootDll)
#ENDAT

#AT(%mpDefineAll7),where(%NoGloZipTools=0)
#INSERT(%Defines,3,'_ZIPLinkMode_','_ZIPDllMode_',%MultiDLL,%RootDll)
#ENDAT

#AT(%BeforeGlobalIncludes),where(%NoGloZipTools=0)
ZipTools:TemplateVersion equate('%ZipToolsTPLVersion')
#endat

#!#################################################################################################
#! End of GLOBAL EXTENSION
#!#################################################################################################

#Extension(ZipToolsLocal,'ZipTools Local Extension'),Description(' [ZipTools] ' & %ZipObject & ' (' &%ZipClassName&  ')'),PROCEDURE,Multi,req(Activate_ZipTools(ZipTools))
  #Sheet
    #PREPARE
      #INSERT(%ReadGlobal,3,0)
    #ENDPREPARE
    #tab('General')
      #BOXED
        #Image('ZipTools.bmp')
        #Display('ZipTools Library'),at(,90),prop(PROP:FontStyle,700)
        #Display('Version ' & %ZipToolsTPLVersion),prop(PROP:FontStyle,700)
        #Display('(c) 2025 by Mark Sarson')
        #Display('Licensed under the MIT License.')
        #Display('See LICENSE file in the project root for full license text.')
        #Display('github.com/msarson/ZipTools-for-Clarion')
      #ENDBOXED
      #Display()
      #Boxed('Debugging')
        #Prompt('Do Not Generate This Object',check),%NoZip,at(10)
      #EndBoxed
      #Display()
      #boxed('Options'),section
        #PROMPT('Object Name:',@S255),%ZipObject,Req,default('ThisZip' & %ActiveTemplateInstance)
        #prompt('Class Name:',@s255),%ZipClassName,req,default('ZipToolsClass')
      #ENDBOXED
    #endtab
  #EndSheet
#!-----------------------------------------------------------------------------!

#atstart
  #if(%NoGloZipTools=0 and %NoZip=0)
    #insert(%AtStartInitialisation)
    #insert(%AddObjectPR,%ZipClassName,%ZipObject,'Local Objects')
  #endIf
#endat

#AT(%LocalDataClasses),where(%NoGloZipTools=0 and %NoZip=0)
#INSERT(%GenerateClassDeclaration,%ZipClassName,%ZipObject,'Local Objects','ZipTools Objects')
#ENDAT

#AT(%DataSection),where(%ProcedureTemplate = 'Source' and %Family = 'cw20' and %NoGloZipTools=0 and %NoZip=0)
#insert(%GenerateClassDeclaration,%ZipClassName,%ZipObject,'Local Objects','ZipTools Objects')
#EndAt

#AT(%LocalProcedures),where(%NoGloZipTools=0 and %NoZip=0)
#INSERT(%GenerateMethods,%ZipClassName,%ZipObject,'Local Objects','ZipTools Objects')
#ENDAT

#AT(%dMethodCodeSection,%ActiveTemplate & %ActiveTemplateInstance,%eMethodID),priority(5000),DESCRIPTION('Parent Call')
#INSERT(%ParentCall)
#ENDAT
