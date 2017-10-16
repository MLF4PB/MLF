;==============================================================================
; 
; Project ...... : MLF : Make Library Factory
; Name ......... : mlf.pb 
; Type ......... : Main Code
; Author ....... : falsam
; CreateDate ... : 16, September 2017
; Compiler ..... : PureBasic V5.60 (x86)
; Flags ........ : Unicode/XP-Skin - Administrator Mode
; Subsystem .... : none
; TargetOS ..... : Windows
; License ...... : ?
; Link ......... : https://github.com/MLF4PB/MLF-Alpha/archive/master.zip
; Description .. : 
;
;==============================================================================
; Changelog:
; 23, September 2017 : Catalog.pbi  - Header & German Text added by Bisonte
; 24, September 2017 : Catalog.pbi  - Russian Text add by mestnyi
; 24, September 2017 : Parse.pbi    - Add Normalise() Format procedure name + parameters by GallyHC
; 27, September 2017 : Parse.pbi    - Add toolbar and help for each procedure
; 01, October 2017   : mlf.pb       - MLF command line File + pbcompil.b + libcreate.b 
; 04, October 2017   : mlf.pb       - Add Resident file creation
;                                   - Saved ASM file if the user changes the source
; 06, October 2017   : mlf.pb       - Add lib process folder
; 15, October 2017   : mlf.pb       - Add Adjust RET & Thread
; 16, October 2017   : mlf.pb       - Add MessageRequestion when no public dll
;==============================================================================


EnableExplicit

Enumeration Font
  #FontGlobal  
  #FontH1
EndEnumeration

Enumeration Window
  #mf
EndEnumeration

Enumeration Menu
  #mfLogMenu  
EndEnumeration

Enumeration Gadget
  ;Select the application language 
  #mfLang  
  
  ;Panel
  #mfPanel
  
  ;ToolBar
  #mfPBSelect
  #mfPBCompil
  #mfLIBCreate
  #mfLibShow    
  
  ;Panel 0 - Select purebasic file, compil and create user lib
  #mfPBFrame
  #mfPBCodeName
  #mfRESEnable
  #mfThreadEnable
  #mfRETAdjustEnable
  #mfPROCESSDeleteEnable
  #mfLog
  
  ;Panel 1 - View ASM code
  #mfASMName
  #mfASMEdit
  #mfASMSave
  
  ;Panel 2 - View and update DESC code (Update is optionel)
  #mfDESCName
  #mfDESCEdit
  #mfDESCSave
  
  ;Grip Resize Window
  #mfGrip0
  #mfGrip1
  #mfGrip2
EndEnumeration

;Version
Global Title.s = "MLF"
Global Version.s = "1.39 Beta"

;Current PureBasic file
Global PBFileName.s
Global FilePart.s

;MLF Folder
Global MLFFolder.s = GetCurrentDirectory()

;-Application Summary
Declare   Start()                 ;Fonts, Window and Triggers
Declare   LogMenu()               ;Log Popup Menu (Clear & Copy)
Declare   LogEvent()              ;Log Events  
Declare   ResetWindow()           ;Init and clear Gadget
Declare   PBSelect()              ;Select PureBasic file name
Declare   PBCompil()              ;Created ASM file, Parsed and save ASM file and create description (DESC) file 
Declare   OBJCreate()             ;Created OBJ file         
Declare   MakeStaticLib()         ;Create User libray
Declare   LibShowUserLib()        ;Show user library folder

Declare   ASMSave()               ;Saved ASM file if the user changes the source
Declare   DESCSave()              ;Saved DESC file if the user changes the source 

Declare   LangChange()            ;Changed lang (French, English, Deutch, Russian)
Declare   ConsoleLog(Buffer.s)    ;Updated console log  
Declare.f AdjustFontSize(Size.l)  ;Load a font and adapt it to the DPI
Declare   FileDelete(FileName.s)  ;Delete file
Declare.s GetCompilerProcessor()  ;Return (x86) or (x64)  
Declare   Exit()                  ;Exit

;-Include
IncludePath "include"
IncludeFile "catalog.pbi"         ;Lang
IncludeFile "parse.pbi"           ;Parse ASM (Extract dependancies and procedures and create DESC File)
IncludeFile "media.pbi"           ;Media image and sound 
IncludeFile "LockResize.pbi"      ;Automatically resize the elements of a form.

Start()

Procedure Start()  
  ;Fonts
  LoadFont(#FontGlobal, "", AdjustFontSize(10))
  LoadFont(#FontH1, "", AdjustFontSize(11))
  SetGadgetFont(#PB_Default, FontID(#FontGlobal))
  
  ;Window
  UseLockGadget()
  OpenWindow(#mf, 0, 0, 800, 650, "", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
  WindowBounds(#mf, 390, 400, #PB_Ignore, #PB_Ignore)
  
  ;ToolBar
  ButtonImageGadget(#mfPBSelect, 10, 10, 40, 40, ImageID(PBOpen))
  ButtonImageGadget(#mfPBCompil, 60, 10, 40, 40, ImageID(PBCompil))
  ButtonImageGadget(#mfLIBCreate, 110, 10, 40, 40, ImageID(LIBCompil))
  ButtonImageGadget(#mfLibShow, 160, 10, 40, 40, ImageID(LIBView))  
  
  ;Log Menu PopUp
  If CreatePopupMenu(#mfLogMenu)
    MenuItem(1, m("logclear"))
    MenuItem(2, m("logcopy"))
  EndIf
  
  ;Select lang
  ComboBoxGadget(#mfLang, WindowWidth(#mf) - 90, 15, 80, 22)
  InitLang(#mfLang)
  
  ;Wrapper Panel
  PanelGadget(#mfPanel, 0, 60, WindowWidth(#mf), WindowHeight(#mf) - 60)
  
  ;Panel : Select code PureBasic to be compiled
  AddGadgetItem (#mfPanel, -1, "")
  FrameGadget(#mfPBFrame, 5, 20, WindowWidth(#mf) - 15, 105, "")
  
  ;PureBasic File Name
  ComboBoxGadget(#mfPBCodeName, 20, 50, WindowWidth(#mf) - 45, 22)
  
  ;Optional : Create Resident
  CheckBoxGadget(#mfRESEnable, 20, 90, 100, 24, "Resident")
  
  ;Optional ; ThreadSafe
  CheckBoxGadget(#mfThreadEnable, 130, 90, 100, 24, "Thread")
  
  ;Optional ; Adjust RET
  CheckBoxGadget(#mfRETAdjustEnable, 240, 90, 100, 24, "Adjust RET")
  SetGadgetState(#mfRETAdjustEnable, #PB_Checkbox_Checked)   
  
  ;Optional ; Delete process directory
  CheckBoxGadget(#mfPROCESSDeleteEnable, 350, 90, 200, 24, "Delete Process directory")
  SetGadgetState(#mfPROCESSDeleteEnable, #PB_Checkbox_Checked)  
    
  ;View console log
  ListViewGadget(#mfLog, 5, 130, WindowWidth(#mf) - 15, 410)
  SetGadgetColor(#mfLog, #PB_Gadget_BackColor, RGB(169, 169, 169))
  ConsoleLog(m("welcome"))
  ConsoleLog("PureBasic version : " + Str(#PB_Compiler_Version) + " " + GetCompilerProcessor())
  ImageGadget(#mfGrip0, GadgetWidth(#mfPanel) - 23, GadgetHeight(#mfPanel) - 47, 15, 15, ImageID(Grip))
  
  ;Panel : View code ASM
  AddGadgetItem (#mfPanel, -1, "")
  TextGadget(#mfASMName, 5, 10, WindowWidth(#mf) - 15, 22, "") 
  SetGadgetFont(#mfASMName, FontID(#FontH1))
  SetGadgetColor(#mfASMName, #PB_Gadget_BackColor, RGB(192, 192, 192))
  EditorGadget(#mfASMEdit, 5, 35, WindowWidth(#mf) - 15, 495)
  SetGadgetColor(#mfASMEdit, #PB_Gadget_BackColor, RGB(211, 211, 211))
  ButtonGadget(#mfASMSave, 5, 535, 80, 22, "")
  ImageGadget(#mfGrip1, GadgetWidth(#mfPanel) - 23, GadgetHeight(#mfPanel) - 47, 15, 15, ImageID(Grip))
  
  ;Panel : View and/or updated code DESC
  AddGadgetItem(#mfPanel, -1, "")
  TextGadget(#mfDESCName, 5, 10, WindowWidth(#mf) - 15, 22, "") 
  SetGadgetFont(#mfDESCName, FontID(#FontH1))
  SetGadgetColor(#mfDESCName, #PB_Gadget_BackColor, RGB(192, 192, 192))
  EditorGadget(#mfDESCEdit, 5, 35, WindowWidth(#mf) - 15, 495)
  SetGadgetColor(#mfDESCEdit, #PB_Gadget_BackColor, RGB(211, 211, 211))
  ButtonGadget(#mfDESCSave, 5, 535, 80, 22, "")
  ImageGadget(#mfGrip2, GadgetWidth(#mfPanel) - 23, GadgetHeight(#mfPanel) - 47, 15, 15, ImageID(Grip))
  
  CloseGadgetList()
  ;End Wrapper Panel
  
  LangChange()  ;Displays window labels
  ResetWindow() ;Clear gadgets
  
  ;Resize gadget (Window, Gadget, Left, Top, Right, Bottom)
  LockGadget(#mf, #mfLang, #False, #True, #True, #False)
  LockGadget(#mf, #mfPanel, #True, #True, #True, #True)
  LockGadget(#mf, #mfPBFrame, #True, #True, #True, #False)
  LockGadget(#mf, #mfPBCodeName, #True, #True, #True, #False)
  LockGadget(#mf, #mfLog, #True, #True, #True, #True)
  LockGadget(#mf, #mfASMName, #True, #True, #True, #False)
  LockGadget(#mf, #mfASMEdit, #True, #True, #True, #True)
  LockGadget(#mf, #mfASMSave, #True, #False, #False, #True) 
  LockGadget(#mf, #mfDESCName, #True, #True, #True, #False)
  LockGadget(#mf, #mfDESCEdit, #True, #True, #True, #True)
  LockGadget(#mf, #mfDESCSave, #True, #False, #False, #True) 
  LockGadget(#mf, #mfGrip0, #False, #False, #True, #True) 
  LockGadget(#mf, #mfGrip1, #False, #False, #True, #True) 
  LockGadget(#mf, #mfGrip2, #False, #False, #True, #True) 
  
  ;Triggers
  BindGadgetEvent(#mfLang, @LangChange())           ;Change lang
  BindGadgetEvent(#mfPBSelect, @PBSelect())         ;Select PureBasic code
  BindGadgetEvent(#mfPBCodeName, @PBSelect())       ;Select PureBasic code  
  BindGadgetEvent(#mfPBCompil, @PBCompil())         ;Create ASM file, Parsed and modified ASM file and create description (DESC) file 
  BindGadgetEvent(#mfLIBCreate, @OBJCreate())       ;Create OBJ file and User Libray
  BindGadgetEvent(#mfASMSave, @ASMSave())           ;Save ASM file if the user changes the source  
  BindGadgetEvent(#mfDESCSave, @DESCSave())         ;Save DESC file if the user changes the source
  BindGadgetEvent(#mfLog, @LogMenu(), #PB_EventType_RightClick)
  BindGadgetEvent(#mfLibShow, @LIBShowUserLib())    ;Show user library folder
  
  BindMenuEvent(#mfLogMenu, 1, @LogEvent())
  BindMenuEvent(#mfLogMenu, 2, @LogEvent())
  
  BindEvent(#PB_Event_CloseWindow, @Exit())         ;Exit
  
  ;-MLF is launched on the command line
  If CountProgramParameters() 
    PBFileName = Trim(ProgramParameter(0))
    AddGadgetItem(#mfPBCodeName, 0, PBFileName)
    SetGadgetState(#mfPBCodeName, 0)
    ConsoleLog(Str(CountProgramParameters()))
    ConsoleLog("Receiving the file " + PBFileName)
    PBSelect()
    
    If Val(ProgramParameter(1)) = #True
      If PBCompil() And Val(ProgramParameter(2)) = #True
        MakeStaticLib()
      EndIf
    EndIf
  EndIf
  
  ;Loop
  Repeat : WaitWindowEvent() : ForEver
EndProcedure

Procedure ResetWindow()
  DisableGadget(#mfPBCompil, #True)
  SetGadgetAttribute(#mfPBCompil, #PB_Button_Image, ImageID(PBCompild))
  
  DisableGadget(#mfLIBCreate, #True)
  SetGadgetAttribute(#mfLIBCreate, #PB_Button_Image, ImageID(LIBCompild))
  
  DisableGadget(#mfASMEdit, #True)
  SetGadgetText(#mfASMName, "")
  SetGadgetText(#mfASMEdit, "")
  DisableGadget(#mfASMSave, #True)
  
  DisableGadget(#mfDESCEdit, #True)
  SetGadgetText(#mfDESCName, "")
  SetGadgetText(#mfDESCEdit, "")
  DisableGadget(#mfDESCSave, #True)
EndProcedure

;Log Menu
Procedure LogMenu()
  DisplayPopupMenu(0, WindowID(0))   
EndProcedure

Procedure LogEvent()
  Protected n, Buffer.s
  
  Select EventMenu()
    Case 1 ;Clear Log
      ClearGadgetItems(#mfLog)
      
    Case 2 ;Log Copy
      For n = 0 To CountGadgetItems(#mfLog) - 1
        Buffer + GetGadgetItemText(#mfLog, n) + #CRLF$
      Next
      SetClipboardText(Buffer)
  EndSelect
EndProcedure

;-
;Select PureBasic filename
Procedure PBSelect()
  Protected Selector = EventGadget()
  Protected PBPreviousFileName.s = PBFileName
  
  If Selector = #mfPBSelect
    PBFileName = OpenFileRequester(m("selpbfile"), "", "PureBasic file | *.pb;*.pbi", 0)  
  Else
    PBFileName = Trim(GetGadgetItemText(#mfPBCodeName, GetGadgetState(#mfPBCodeName)))
  EndIf
  
  If PBFileName <> ""
    FilePart = GetFilePart(PBFileName, #PB_FileSystem_NoExtension)
    ResetWindow()    
    
    If Selector = #mfPBSelect
      AddGadgetItem(#mfPBCodeName, 0, " " + PBFileName)
      SetGadgetState(#mfPBCodeName, 0)
    EndIf
    
    DisableGadget(#mfPBCompil, #False)
    SetGadgetAttribute(#mfPBCompil, #PB_Button_Image, ImageID(PBCompil))
    ConsoleLog(m("run"))
  Else
    PBFileName = PBPreviousFileName
  EndIf
EndProcedure

;Create ASM file, Parsed and modified ASM file and create description (DESC) file
Procedure PBCompil()
  Protected Compiler, Buffer.s, FileName.s, Token.b, CompilParam.s, PBWorkFileName.s
  
  ;Create compilation work space
  CreateDirectory(FilePart)
  SetCurrentDirectory(FilePart)
  
  ;Delete previous PureBasic.exe file if exist
  FileDelete("PureBasic.exe")
  
  ;Delete previous PureBasic.asm file if exist
  FileDelete("PureBasic.asm")
  
  ;Delete previous PureLibrariesMaker.log if exist
  FileDelete("PureLibrariesMaker.log")
  
  ;Delete YOUR previous ASM Files if exist
  FileDelete(FilePart + ".asm")
  
  ;Delete previous PureBasic.desc file if exist
  FileDelete(FilePart + ".desc")
  
  ;Delete previous library if exist
  FileDelete(#PB_Compiler_Home + "PureLibraries\UserLibraries\" + FilePart)
  
  ;Compile PB (Create resident if enable and ASM) 
  ConsoleLog("Waiting for compile ...")
  
  ;PBWorkFileName = GetCurrentDirectory() + Filepart + ".pb"    
  ;CopyFile(PBFileName, PBWorkFileName)
  ;PBFileName = PBWorkFileName
  
  ;-Create RESIDENT  
  If GetGadgetState(#mfRESEnable) = #PB_Checkbox_Checked   
    ;Delete previous resident if exist
    FileName = #PB_Compiler_Home + "Residents\" + FilePart + ".res" 
    
    If FileSize(FileName) <> -1 ;File exist
      If MessageRequester(m("information"), m("residentexist") + #CRLF$ + FileName, #PB_MessageRequester_YesNo | #PB_MessageRequester_Warning) = #PB_MessageRequester_Yes
        FileDelete(FileName)
        Token = #True
      Else
        Token = #False
      EndIf
    Else
      Token = #True
    EndIf
    
    If Token = #True
      Compiler = RunProgram(#PB_Compiler_Home + "Compilers\pbcompiler.exe", #DQUOTE$ + PBFileName + #DQUOTE$ + " /RESIDENT " + FilePart + ".res" + #DQUOTE$, "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)   
      
      If Compiler
        Token = #True
        While ProgramRunning(Compiler)
          If AvailableProgramOutput(Compiler)
            Buffer = ReadProgramString(Compiler)
            If FindString(Buffer, "Error")
              Token = #False
            EndIf
            If Not Bool(FindString(Buffer, "***") Or FindString(Buffer, "PureBasic"))        
              ConsoleLog(Buffer)
            EndIf          
          EndIf
        Wend
        CloseProgram(Compiler)
      EndIf 
    EndIf
  EndIf
  
  ;-Create ASM
  CompilParam = " /COMMENTED "
  
  If GetGadgetState(#mfThreadEnable) = #PB_Checkbox_Checked
    CompilParam + " /THREAD "
  EndIf
  
  Compiler = RunProgram(#PB_Compiler_Home + "Compilers\pbcompiler.exe", #DQUOTE$ + PBFileName + #DQUOTE$ + CompilParam , "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If Compiler
    Token = #True
    While ProgramRunning(Compiler)
      If AvailableProgramOutput(Compiler)
        Buffer = ReadProgramString(Compiler)
        If FindString(Buffer, "Error")
          Token = #False
        EndIf
        If Not Bool(FindString(Buffer, "***") Or FindString(Buffer, "PureBasic"))        
          ConsoleLog(Buffer)
        EndIf
      EndIf
    Wend
    CloseProgram(Compiler)
    
    If Token
      If GetGadgetState(#mfRESEnable) = #PB_Checkbox_Checked   
        CopyFile(filepart + ".res", #PB_Compiler_Home + "\Residents\" + FilePart + ".res")
      EndIf
      
      FileName = FilePart + ".asm"
      
      ;if resident file, then the ASM file does not exist.
      If FileSize("PureBasic.asm") <> -1          
        If Not RenameFile("PureBasic.asm", Filename)          
          ConsoleLog(m("errordelete") + " " + Filename)
        Else
          ConsoleLog("Rename PureBasic.asm to " + FileName + " done." )       
                    CopyFile(FileName, "PureBasic.asm")

          ;Extract dependancies & procedures from ASM file and create DESC File
          ;Return Count Public Procedure 
          Analyse(FileName)
          
          ;Init ASM Editor
          SetGadgetText(#mfASMName, FileName)
          DisableGadget(#mFASMEdit, #False)
          SetGadgetText(#mFASMEdit, "") ;Clear editor
          If ReadFile(0, Filename, #PB_Ascii)
            While Eof(0) = 0
              AddGadgetItem(#mfASMEdit, -1, ReadString(0))
            Wend
            CloseFile(0)
          EndIf
          
          ;Init DESC editor
          If CountPublicProcedure <> 0
            FileName = FilePart + ".desc"
            SetGadgetText(#mfDESCName, FileName)
            DisableGadget(#mfDESCEdit, #False)
            SetGadgetText(#mfDESCEdit, "") ;Clear editor
            If ReadFile(0, Filename)
              While Eof(0) = 0
                AddGadgetItem(#mfDESCEdit, -1, ReadString(0))
              Wend
              CloseFile(0)
            EndIf
            
            DisableGadget(#mfLIBCreate, #False)
            SetGadgetAttribute(#mfLIBCreate, #PB_Button_Image, ImageID(LIBCompil))    
            
            DisableGadget(#mfASMSave, #False)          
            DisableGadget(#mfDESCSave, #False)
            
            ConsoleLog("You can view the ASM and DESC sources before create your user library")
            PlaySound(Success)
          Else
            ;-Upd 16, October 2017 - Add MessageRequester()
            ConsoleLog("There is no public procedure.")
            ConsoleLog("User library creation disabled.")
            PlaySound(Success)
            MessageRequester(m("information"), m("nopubproc") + #CRLF$ + m("userlibdisable"))
            ;End Upd
          EndIf           
          FileDelete("purebasic.exe")
        EndIf 
      EndIf
    Else
      PlaySound(Error)
      MessageRequester(m("information"), Buffer)
    EndIf 
  EndIf
  SetCurrentDirectory(MLFFolder)
  ProcedureReturn Token
EndProcedure

;Create OBJ File : Use fasm.exe
Procedure OBJCreate()
  Protected Compiler
  Protected ASMFilename.s = #DQUOTE$ + FilePart + ".asm" + #DQUOTE$
  Protected OBJFileName.s = #DQUOTE$ + FilePart + ".obj" + #DQUOTE$
  
  SetCurrentDirectory(FilePart)
  
  Compiler = RunProgram(#PB_Compiler_Home + "Compilers\Fasm.exe", "" + ASMFilename + " " + OBJFileName, "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If Compiler
    While ProgramRunning(Compiler)
      If AvailableProgramOutput(Compiler)
        ConsoleLog(ReadProgramString(Compiler))
      EndIf
    Wend
    CloseProgram(Compiler) 
    
    ;Create user library
    MakeStaticLib()
  EndIf
EndProcedure

;Make Static Lib : Use sdk\LibraryMaker.exe

;LibraryMaker can take several arguments in parameter To allow easy scripting:
; /ALL                : Process all the .desc files found in the source directory
; /COMPRESSED         : Compress the library (much smaller And faster To load, but slower To build)
; /To <Directory>     : Destination directory
; /CONSTANT MyConstant: Defines a constant For the preprocessor
; Example C:\LibraryMaker.exe c:\PureBasicDesc\ /TO C:\PureBasic\PureLibraries\ /ALL /COMPRESSED
Procedure MakeStaticLib()  
  Protected Compiler
  Protected SourcePath.s      = #DQUOTE$ + FilePart + ".Desc" + #DQUOTE$
  Protected OBJPath.s         = FilePart + ".obj" 
  Protected DestinationPath.s = #DQUOTE$ + #PB_Compiler_Home + "PureLibraries\UserLibraries\" + #DQUOTE$
  
  If FileSize(OBJPath) <> -1 
    Compiler = RunProgram(#PB_Compiler_Home + "sdk\LibraryMaker.exe ", SourcePath + " /TO " + DestinationPath, "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
    
    If Compiler
      While ProgramRunning(Compiler)
        If AvailableProgramOutput(Compiler)
          ConsoleLog(ReadProgramString(Compiler))
        EndIf
      Wend
      CloseProgram(Compiler)
      If ReadFile(0, "PureLibrariesMaker.log")
        While Eof(0) = 0
          ConsoleLog(ReadString(0))
        Wend    
        CloseFile(0)
      EndIf
      ConsoleLog(m("successlib"))
      PlaySound(Success)
    Else
      ConsoleLog(m("errorlib"))
      PlaySound(Error)
    EndIf
  Else
    ConsoleLog(m("errorobj"))
    PlaySound(Error)
  EndIf
  SetCurrentDirectory(MLFFolder)
  
  ;- Delete process compile files
  If GetGadgetState(#mfPROCESSDeleteEnable) = #PB_Checkbox_Checked
    If DeleteDirectory(FilePart, "", #PB_FileSystem_Force)
    EndIf
  EndIf
EndProcedure

;Show User libraries
Procedure LibShowUserLib()
  RunProgram("explorer.exe", #PB_Compiler_Home + "PureLibraries\UserLibraries", "")  
EndProcedure

;-
;Save ASM file if the user changes the source
Procedure ASMSave()
  Protected ASMFileName.s = FilePart + ".asm"
  Protected ASMContent.s = GetGadgetText(#mfASMEdit)
  
  SetCurrentDirectory(FilePart)
  If CreateFile(0, ASMFileName)
    If WriteString(0, ASMContent)
      ConsoleLog(m("successasm"))
      MessageRequester(m("informaton"), m("successasm"))
    Else
      ConsoleLog(m("errorasm"))
      MessageRequester(m("informaton"), m("errorasm"))
    EndIf
    CloseFile(0)
  EndIf  
  SetCurrentDirectory(MLFFolder)  
EndProcedure

;Save DESC file if the user changes the source
Procedure DESCSave()
  Protected DESCFileName.s = FilePart + ".desc"
  Protected DESCContent.s = GetGadgetText(#mfDESCEdit)
  
  SetCurrentDirectory(FilePart)
  If CreateFile(0, DESCFileName)
    If WriteString(0, DESCContent)
      ConsoleLog(m("successdesc"))
      MessageRequester(m("informaton"), m("successdesc"))
    Else
      ConsoleLog(m("errordesc"))
      MessageRequester(m("informaton"), m("errordesc"))
    EndIf
    CloseFile(0)
  EndIf  
  SetCurrentDirectory(MLFFolder)
EndProcedure

;-
;-Tools
Procedure LangChange()
  SetLang(GetGadgetState(#mfLang))
  SetWindowTitle(#mf, m("title"))
  SetGadgetItemText(#mfPanel, 0, m("pancompil"))
  SetGadgetText(#mfPBFrame, m("selpbfile"))
  GadgetToolTip(#mfPBSelect, m("pbselect"))
  GadgetToolTip(#mfPBCompil, m("pbcompil"))
  GadgetToolTip(#mfLIBCreate, m("libcreate"))
  GadgetToolTip(#mfLibShow, m("libshow"))  
  SetGadgetItemText(#mfPanel, 1, m("panviewasm"))
  SetGadgetItemText(#mfPanel, 2, m("panviewdesc"))
  SetGadgetText(#mfASMSave, m("save"))
  SetGadgetText(#mfDESCSave, m("save"))
  SetMenuItemText(#mfLogMenu, 1, m("logclear"))
  SetMenuItemText(#mfLogMenu, 2, m("logcopy"))
EndProcedure

Procedure ConsoleLog(Buffer.s)
  Protected TimeStamp.s = "[" + FormatDate("%hh:%ii:%ss", Date()) + "]  "
  
  AddGadgetItem(#mfLog, -1, TimeStamp + Buffer)
  SetGadgetState(#mfLog, CountGadgetItems(#mfLog) -1)
EndProcedure

Procedure.f AdjustFontSize(Size.l)
  Define lPpp.l = GetDeviceCaps_(GetDC_(#Null), #LOGPIXELSX)
  ProcedureReturn (Size * 96) / lPpp
EndProcedure

Procedure FileDelete(FileName.s)
  If FileSize(FileName) <> -1
    ConsoleLog("Delete " + Filename + " ...")
    If Not DeleteFile(FileName, #PB_FileSystem_Force)
      ConsoleLog(m("errordelete") + " " + Filename)
    EndIf
  EndIf
EndProcedure

Procedure.s GetCompilerProcessor()
  If #PB_Compiler_Processor = #PB_Processor_x86
    ProcedureReturn "(x86)"
  Else
    ProcedureReturn "(x64)"
  EndIf  
EndProcedure

;-The end
Procedure Exit()  
  End
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 85
; Folding = ----------
; Markers = 305
; EnableXP
; EnableAdmin
; Executable = mlf.exe