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
; 24, October 2017   : mlf.pb       - Add Thread Safe option
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
  #mfThreadSafeEnable
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
Global Version.s = "1.51 Beta"

Structure File
  FileName.s
  FileNameThread.s
EndStructure

Structure Setup
  CompilDir.s
  Resident.s
  UserLibrary.s
  
  FilePart.s
  FilePath.s
  FileExt.s
  
  PB.File
  ASM.File
  DESC.File
  OBJ.File 
  LIB.File
EndStructure
Global Compil.Setup

;Compilers
Global CompilPB.s      = #PB_Compiler_Home + "Compilers\pbcompiler.exe "
Global CompilOBJ.s     = #PB_Compiler_Home + "Compilers\Fasm.exe "
Global CompilLIB.s     = #PB_Compiler_Home + "Compilers\polib.exe "
Global CompilUSERLIB.s = #PB_Compiler_Home + "sdk\LibraryMaker.exe "
Global CompilFlag      = #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide

;MLF Folder
Global MLFFolder.s = GetCurrentDirectory()

;-Application Summary
Declare   Start()                 ;Fonts, Window and Triggers
Declare   LogMenu()               ;Log Popup Menu (Clear & Copy)
Declare   LogEvent()              ;Log Events  
Declare   ResetWindow()           ;Init and clear Gadget
Declare   ThreadSelect()          ;Check if Thread or Thread Safe Compil
Declare   PBSelect()              ;Select PureBasic file name
Declare   PBCompil()              ;Created ASM file, Parsed and save ASM file and create description (DESC) file 
Declare   OBJCreate()             ;Created OBJ file  
Declare   LIBCreate()             ;Created LIB File if thread enable
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
  ;- 0 Show Window
  
  ;Fonts
  LoadFont(#FontGlobal, "", AdjustFontSize(10))
  LoadFont(#FontH1, "", AdjustFontSize(11))
  SetGadgetFont(#PB_Default, FontID(#FontGlobal))
  
  ;Window
  OpenWindow(#mf, 0, 0, 800, 650, "", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
  WindowBounds(#mf, 390, 400, #PB_Ignore, #PB_Ignore)
  
  ;ToolBar
  ButtonImageGadget(#mfPBSelect, 10, 10, 40, 40, ImageID(PBOpen))
  ButtonImageGadget(#mfPBCompil, 60, 10, 40, 40, ImageID(PBCompil))
  ButtonImageGadget(#mfLIBCreate, 110, 10, 40, 40, ImageID(LIBCompil))
  ButtonImageGadget(#mfLibShow, 160, 10, 40, 40, ImageID(LIBView))  
  
  ;- 0.1 Log Menu PopUp
  If CreatePopupMenu(#mfLogMenu)
    MenuItem(1, m("logclear"))
    MenuItem(2, m("logcopy"))
  EndIf
  
  ;- 0.2 Select lang
  ComboBoxGadget(#mfLang, WindowWidth(#mf) - 90, 15, 80, 22)
  InitLang(#mfLang)
  
  ;Wrapper Panel
  PanelGadget(#mfPanel, 0, 60, WindowWidth(#mf), WindowHeight(#mf) - 60)
  
  ;- 0.3 Panel : Select code PureBasic to be compiled
  AddGadgetItem (#mfPanel, -1, "")
  FrameGadget(#mfPBFrame, 5, 20, WindowWidth(#mf) - 15, 105, "")
  
  ;PureBasic File Name
  ComboBoxGadget(#mfPBCodeName, 20, 50, WindowWidth(#mf) - 45, 22)
  
  ;Optional : Create Resident
  CheckBoxGadget(#mfRESEnable, 20, 90, 80, 24, "Resident")
    
  ;Optional ; Thread
  CheckBoxGadget(#mfThreadEnable, 100, 90, 80, 24, "Thread")
    
  ;Optional ; Thread Safe
  CheckBoxGadget(#mfThreadSafeEnable, 180, 90, 90, 24, "Thread Safe")
  
  ;Optional ; Adjust RET
  CheckBoxGadget(#mfRETAdjustEnable, 280, 90, 100, 24, "Adjust RET")
  SetGadgetState(#mfRETAdjustEnable, #PB_Checkbox_Checked)   
  
  ;Optional ; Delete process directory
  CheckBoxGadget(#mfPROCESSDeleteEnable, 380, 90, 180, 24, "Delete Process directory")
  SetGadgetState(#mfPROCESSDeleteEnable, #PB_Checkbox_Checked)   
  
  ;View console log
  ListViewGadget(#mfLog, 5, 130, WindowWidth(#mf) - 15, 410)
  SetGadgetColor(#mfLog, #PB_Gadget_BackColor, RGB(169, 169, 169))
  ConsoleLog(m("welcome"))
  ConsoleLog("PureBasic version : " + Str(#PB_Compiler_Version) + " " + GetCompilerProcessor())
  ImageGadget(#mfGrip0, GadgetWidth(#mfPanel) - 23, GadgetHeight(#mfPanel) - 47, 15, 15, ImageID(Grip))
  
  ;- 0.4 Panel : View code ASM
  AddGadgetItem (#mfPanel, -1, "")
  TextGadget(#mfASMName, 5, 10, WindowWidth(#mf) - 15, 22, "") 
  SetGadgetFont(#mfASMName, FontID(#FontH1))
  SetGadgetColor(#mfASMName, #PB_Gadget_BackColor, RGB(192, 192, 192))
  EditorGadget(#mfASMEdit, 5, 35, WindowWidth(#mf) - 15, 495)
  SetGadgetColor(#mfASMEdit, #PB_Gadget_BackColor, RGB(211, 211, 211))
  ButtonGadget(#mfASMSave, 5, 535, 80, 22, "")
  ImageGadget(#mfGrip1, GadgetWidth(#mfPanel) - 23, GadgetHeight(#mfPanel) - 47, 15, 15, ImageID(Grip))
  
  ;- 0.5 Panel : View and/or updated code DESC
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
  
  ;- 0.6 Resize gadget (Window, Gadget, Left, Top, Right, Bottom)
  UseLockGadget()
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
  
  ;- 0.7 Triggers
  BindGadgetEvent(#mfLang, @LangChange())           ;Change lang
  BindGadgetEvent(#mfPBSelect, @PBSelect())         ;Select PureBasic code
  BindGadgetEvent(#mfPBCodeName, @PBSelect())       ;Select PureBasic code  
  BindGadgetEvent(#mfPBCompil, @PBCompil())         ;Create ASM file, Parsed and modified ASM file and create description (DESC) file 
  BindGadgetEvent(#mfLIBCreate, @OBJCreate())       ;Create OBJ file and User Libray
  BindGadgetEvent(#mfASMSave, @ASMSave())           ;Save ASM file if the user changes the source  
  BindGadgetEvent(#mfDESCSave, @DESCSave())         ;Save DESC file if the user changes the source
  
  BindGadgetEvent(#mfThreadSafeEnable, @ThreadSelect(), #PB_EventType_LeftClick)
  BindGadgetEvent(#mfThreadEnable, @ThreadSelect(), #PB_EventType_LeftClick) 
  
  BindGadgetEvent(#mfLog, @LogMenu(), #PB_EventType_RightClick) ;Show menu popup
  BindGadgetEvent(#mfLibShow, @LIBShowUserLib())    ;Show user library folder
  
  BindMenuEvent(#mfLogMenu, 1, @LogEvent())
  BindMenuEvent(#mfLogMenu, 2, @LogEvent())
  
  BindEvent(#PB_Event_CloseWindow, @Exit())         ;Exit
  
  ;- 0.8 MLF is launched on the command line
  If CountProgramParameters() 
    Compil\PB\FileName = Trim(ProgramParameter(0))
    AddGadgetItem(#mfPBCodeName, 0, Compil\PB\FileName)
    SetGadgetState(#mfPBCodeName, 0)
    ConsoleLog(Str(CountProgramParameters()))
    ConsoleLog("Receiving the file " + Compil\PB\FileName)
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

;-
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

Procedure ThreadSelect()
  Select EventGadget()
    Case #mfThreadSafeEnable
      SetGadgetState(#mfThreadEnable, #PB_Checkbox_Unchecked)
      
    Case #mfThreadEnable
      SetGadgetState(#mfThreadSafeEnable, #PB_Checkbox_Unchecked)
      
  EndSelect
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
Procedure PBSelect()
  Protected Selector = EventGadget()
  Protected PBPreviousFileName.s = Compil\PB\FileName 
  
  ;- 1 Select PureBasic filename
  If Selector = #mfPBSelect
    Compil\PB\FileName = OpenFileRequester(m("selpbfile"), "", "PureBasic file | *.pb;*.pbi", 0)  
  Else
    Compil\PB\FileName = Trim(GetGadgetItemText(#mfPBCodeName, GetGadgetState(#mfPBCodeName)))
  EndIf
  
  If Compil\PB\FileName <> ""
    ;- 1.1 Setup compil
    Compil\FilePart           = GetFilePart(compil\PB\FileName, #PB_FileSystem_NoExtension)
    Compil\FilePath           = GetPathPart(Compil\PB\FileName)
    Compil\FileExt            = GetExtensionPart(Compil\PB\FileName)
    Compil\UserLibrary        = Compil\FilePart
    Compil\CompilDir          = Compil\FilePart
    
    Compil\PB\FileNameThread  = Compil\FilePath + Compil\FilePart + "_THREAD." + "." + Compil\FileExt
    
    Compil\ASM\FileName       = Compil\FilePart + ".asm"
    Compil\ASM\FileNameThread = Compil\FilePart + "_THREAD.asm"
    
    Compil\DESC\FileName      = Compil\FilePart + ".desc"
    Compil\DESC\FileNameThread= Compil\FilePart + "_THREAD.desc"
    
    Compil\OBJ\FileName       = Compil\FilePart + ".obj"
    Compil\OBJ\FileNameThread = Compil\FilePart + "_THREAD.obj"
    
    Compil\LIB\FileName       = Compil\FilePart + ".lib"
    
    ;Public file
    Compil\Resident           = #PB_Compiler_Home + "Residents\" + Compil\FilePart + ".res"
    Compil\UserLibrary        = #PB_Compiler_Home + "PureLibraries\UserLibraries\" + Compil\FilePart
    ;End Setup
    
    ResetWindow()    
    
    If Selector = #mfPBSelect
      AddGadgetItem(#mfPBCodeName, 0, " " + Compil\PB\FileName)
      SetGadgetState(#mfPBCodeName, 0)
    EndIf
    
    ;Enable compil
    DisableGadget(#mfPBCompil, #False)
    SetGadgetAttribute(#mfPBCompil, #PB_Button_Image, ImageID(PBCompil))
    ConsoleLog(m("run"))
  Else
    compil\PB\FileName = PBPreviousFileName
  EndIf
EndProcedure

;-
;Create ASM file, Parsed and modified ASM file and create description (DESC) file
Procedure PBCompil()
  Protected Compiler, Buffer.s, FileName.s, Token.b, CompilParam.s, PBContent.s, Dim Procedures.s(0), CountProcedures, n, CompilPass = 1
  
  ;- 2 Create ASM File
  
  ;- 2.1 Delete previous library if exist
  FileDelete(Compil\UserLibrary)
  
  ;- 2.2 Delete previous processs directory if exist
  If DeleteDirectory(Compil\CompilDir, "", #PB_FileSystem_Force)
  EndIf
  
  ;- 2.3 Create process work space  
  CreateDirectory(Compil\CompilDir)
  SetCurrentDirectory(Compil\CompilDir)
    
  ;- 2.4 Create RESIDENT if enable  
  If GetGadgetState(#mfRESEnable) = #PB_Checkbox_Checked      
    ;Delete previous resident if exist    
    If FileSize(Compil\Resident) <> -1 ;Resident exist
      If MessageRequester(m("information"), m("residentexist") + #CRLF$ + FileName, #PB_MessageRequester_YesNo | #PB_MessageRequester_Warning) = #PB_MessageRequester_Yes
        FileDelete(Compil\Resident)
        Token = #True
      Else
        Token = #False
      EndIf
    Else
      Token = #True
    EndIf
    
    ;Compil resident
    If Token = #True
      Compiler = RunProgram(CompilPB, #DQUOTE$ + Compil\PB\FileName + #DQUOTE$ + " /RESIDENT " + Compil\Resident, "", CompilFlag)   
      
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
  
  ;- 2.5 Create ASM 
  
  ;- 2.5.1 Case Mode Thread Safe
  If GetGadgetState(#mfThreadEnable) = #PB_Checkbox_Checked
    ConsoleLog("Create " + Compil\PB\FileNameThread)
    ;- 2.5.1.1 Create code pb option _THREAD
    CopyFile(Compil\PB\FileName, Compil\PB\FileNameThread)
    
    ;- 2.5.1.2 Create threaded DLL Procedures
    If ReadFile(0, Compil\PB\FileNameThread)     
      While Eof(0) = 0
        Buffer = ReadString(0)
        If FindString(Buffer, "dll", 0, #PB_String_NoCase)
          Buffer = Normalize(Buffer)
          CountProcedures = ArraySize(Procedures())
          Procedures(CountProcedures) = StringField(StringField(Buffer, 1, "("), 2, " ")
          ReDim Procedures(CountProcedures + 1)
        EndIf
        PBContent + Buffer + #CRLF$
      Wend
      CloseFile(0)
      
      For n = 0 To CountProcedures
        PBContent = ReplaceString(PBContent, Procedures(n), Procedures(n) + "_THREAD") 
      Next
            
      ;- 2.5.1.3 Saves the threaded code
      ;Example : YourCode.pb -> YourCode_THREAD.pb
      CreateFile(0, Compil\PB\FileNameThread)
      WriteString(0, PBContent)
      CloseFile(0)
      
      ;- 2.5.1.4 Two compilations (No Thread and Thread)
      CompilPass = 2      
    EndIf    
  EndIf
  
  ;- 2.5.2 Compile source code
  For n = 1 To CompilPass
    CompilParam = " /UNICODE /COMMENTED "
    
    ;Option Thread if check or ThreadSafe
    If GetGadgetState(#mfThreadSafeEnable) = #PB_Checkbox_Checked Or n = 2
      CompilParam + "/THREAD " 
    EndIf
    
    ;Run compiler 
    ConsoleLog("")
    If n = 1 ;No Thread
      ConsoleLog("Waiting for compile " + Compil\PB\FileName)
      FileName = Compil\PB\FileName
    Else     ;Thread
      ConsoleLog("Waiting for compile " + Compil\PB\FileNameThread)
      FileName = Compil\PB\FileNameThread
    EndIf
    
    Compiler = RunProgram(CompilPB, #DQUOTE$ + FileName + #DQUOTE$ + CompilParam , "", CompilFlag)
    
    ConsoleLog(CompilPB + #DQUOTE$ + FileName + #DQUOTE$ + CompilParam)
    
    If Compiler
      Token = #True
      While ProgramRunning(Compiler)
        If AvailableProgramOutput(Compiler)
          Buffer = ReadProgramString(Compiler)
          If FindString(Buffer, "Error")
            Token = #False
          EndIf
          If Not Bool(FindString(Buffer, "***") Or FindString(Buffer, "PureBasic") Or Trim(Buffer)="" Or FindString(Buffer, "- Feel the ..PuRe.. Power -"))        
            ConsoleLog(Buffer)
          EndIf
        EndIf
      Wend
      CloseProgram(Compiler)
      ;End of compilation
      
      If Token
        ;- 2.5.2.1 Copy RESIDENT to public resident folder
        If GetGadgetState(#mfRESEnable) = #PB_Checkbox_Checked And n = 1  
          CopyFile(Compil\filepart + ".res", Compil\Resident)
        EndIf
        
        If n = 1
          FileName = Compil\ASM\FileName
        Else
          FileName = Compil\ASM\FileNameThread
        EndIf
        
        If FileSize("PureBasic.asm") <> -1 
          If Not CopyFile("PureBasic.asm", FileName)          
            ConsoleLog(m("errordelete") + " " + Filename)
          Else
            ConsoleLog("Rename PureBasic.asm to " + FileName + " done." )       
            
            ;- 2.5.2.2 Extract dependancies & procedures from ASM file
            ;Return Count Public Procedure
            If n = 1
              Analyse(FileName, Compil\PB\FileName)
            Else
              Analyse(FileName, Compil\PB\FileNameThread)
            EndIf
            
            
            ;- 2.5.2.3 Init ASM Editor
            If n = 1
              SetGadgetText(#mfASMName, FileName)
              DisableGadget(#mFASMEdit, #False)
              SetGadgetText(#mFASMEdit, "") ;Clear editor
              If ReadFile(0, Filename, #PB_Ascii)
                While Eof(0) = 0
                  AddGadgetItem(#mfASMEdit, -1, ReadString(0))
                Wend
                CloseFile(0)
              EndIf
            EndIf
            
            ;- 2.5.2.3 Init DESC editor
            If n = 1
              FileName = Compil\ASM\FileName
            Else
              FileName = Compil\ASM\FileNameThread
            EndIf
            
            If n = 1
              If CountPublicProcedure <> 0
                SetGadgetText(#mfDESCName, Compil\DESC\FileName)
                DisableGadget(#mfDESCEdit, #False)
                SetGadgetText(#mfDESCEdit, "") ;Clear editor
                If ReadFile(0, Compil\DESC\FileName)
                  While Eof(0) = 0
                    AddGadgetItem(#mfDESCEdit, -1, ReadString(0))
                  Wend
                  CloseFile(0)
                EndIf
                
                DisableGadget(#mfLIBCreate, #False)
                SetGadgetAttribute(#mfLIBCreate, #PB_Button_Image, ImageID(LIBCompil))    
                
                DisableGadget(#mfASMSave, #False)          
                DisableGadget(#mfDESCSave, #False)
                
              Else
                ;-Upd 16, October 2017 - Add MessageRequester()
                ConsoleLog(m("nopubproc"))
                ConsoleLog(m("userlibdisable"))
                PlaySound(Success)
                MessageRequester(m("information"), m("nopubproc") + #CRLF$ + m("userlibdisable"))
                ;End Upd
              EndIf
            EndIf
            FileDelete("purebasic.exe")
          EndIf 
        EndIf
        If n = CompilPass
                ConsoleLog("You can view the ASM and DESC sources before create your user library")
                PlaySound(Success)
              EndIf
              
      Else
        PlaySound(Error)
        MessageRequester(m("information"), Buffer)
      EndIf 
    EndIf
    
    ;- 2.5.2.4 Delete purebasic file thread
    If n = 2
      DeleteFile(Compil\PB\FileNameThread)
    EndIf
  Next
  
  SetCurrentDirectory(MLFFolder)
  ProcedureReturn Token
EndProcedure

;-
Procedure OBJCreate()
  Protected Compiler
  Protected ASMFilename.s, OBJFileName.s, CompilPass = 1, n 
  
  ;- 3 Create OBJ File
  SetCurrentDirectory(Compil\CompilDir)
  
  ;- 3.1 Case Thread 
  If GetGadgetState(#mfThreadEnable) = #PB_Checkbox_Checked
    CompilPass = 2
  EndIf 
  
  ;- 3.2 Compil
  ConsoleLog("")
  ConsoleLog("Create OBJ File ...")

  For n = 1 To CompilPass
    If n = 1
      ASMFilename.s = #DQUOTE$ + Compil\ASM\FileName + #DQUOTE$
      OBJFileName.s = #DQUOTE$ + Compil\OBJ\FileName + #DQUOTE$
    Else  
      ASMFilename   = #DQUOTE$ + Compil\ASM\FileNameThread + #DQUOTE$ 
      OBJFileName.s = #DQUOTE$ + Compil\OBJ\FileNameThread + #DQUOTE$
    EndIf
    
    Compiler = RunProgram(CompilOBJ, "" + ASMFilename + " " + OBJFileName, "", CompilFlag)
    If Compiler
      While ProgramRunning(Compiler)
        If AvailableProgramOutput(Compiler)
          ConsoleLog(ReadProgramString(Compiler))
        EndIf
      Wend
      CloseProgram(Compiler)
    EndIf
  Next
  
  ConsoleLog("")
  ConsoleLog("Create user library ...")

  ;- 3.3 Create LIB -> LIBCreate()
  If GetGadgetState(#mfThreadEnable) = #PB_Checkbox_Checked
    LIBCreate()  
  EndIf
  
  ;- 3.4 Create user library -> MakeStaticLib()
  MakeStaticLib()
EndProcedure

;-
Procedure LIBCreate()
  Protected Compiler, Buffer.s
  ;- 4 Create lib file if thread compil 
  ;  Thanks to G-Rom for his help
  Compiler = RunProgram(CompilLIB, " /OUT:" + Compil\LIB\FileName + " " + Compil\OBJ\FileName + " " + Compil\OBJ\FileNameThread, "", CompilFlag)
  
  ConsoleLog(CompilLIB + " /OUT:" + Compil\LIB\FileName + " " + Compil\OBJ\FileName + " " + Compil\OBJ\FileNameThread)
  
  If Compiler
    While ProgramRunning(Compiler)
      If AvailableProgramOutput(Compiler)
        Buffer = ReadProgramString(Compiler)
        If Not FindString(Buffer, "warning", 0, #PB_String_NoCase) 
          ConsoleLog(Buffer)
        EndIf
      EndIf
    Wend
    CloseProgram(Compiler)     
  EndIf  
EndProcedure

;-
Procedure MakeStaticLib()  
  Protected Compiler
  Protected DESCFileName.s    = #DQUOTE$ + Compil\DESC\FileName + #DQUOTE$
  Protected OBJFileName.s     = Compil\OBJ\FileName 
  Protected DestinationPath.s = #DQUOTE$ + #PB_Compiler_Home + "PureLibraries\UserLibraries\" + #DQUOTE$
  
  ;- 5 Make Static Lib : Use sdk\LibraryMaker.exe

  ;LibraryMaker can take several arguments in parameter To allow easy scripting:
  ; /ALL                : Process all the .desc files found in the source directory
  ; /COMPRESSED         : Compress the library (much smaller And faster To load, but slower To build)
  ; /To <Directory>     : Destination directory
  ; /CONSTANT MyConstant: Defines a constant For the preprocessor
  ; Example C:\LibraryMaker.exe c:\PureBasicDesc\ /TO C:\PureBasic\PureLibraries\ /ALL /COMPRESSED
  
  SetCurrentDirectory(Compil\CompilDir)
  
  ;- 5.1 Delete previous log
  If FileSize(OBJFileName) <> -1 
    If FileSize("PureLibrariesMaker.log")
      DeleteFile("PureLibrariesMaker.log")
    EndIf
    
    ;-5.2 Compile
    ConsoleLog(CompilUSERLIB + " " + DESCFileName + " /To " + DestinationPath)
    Compiler = RunProgram(CompilUSERLIB, DESCFileName + " /TO " + DestinationPath, "", CompilFlag)
    
    If Compiler
      While ProgramRunning(Compiler)
        If AvailableProgramOutput(Compiler)
          ConsoleLog(ReadProgramString(Compiler))
        EndIf
      Wend
      CloseProgram(Compiler)
      
      CopyFile(Compil\UserLibrary, GetCurrentDirectory() + Compil\FilePart)
      
      ;-5.3 Show log
      If ReadFile(0, "PureLibrariesMaker.log")
        While Eof(0) = 0
          ConsoleLog(ReadString(0))
        Wend    
        CloseFile(0)
      EndIf
      ConsoleLog(m("successlib"))
      PlaySound(Success)
      MessageRequester(m("information"), m("successlib"))
    Else
      ConsoleLog(m("errorlib"))
      PlaySound(Error)
      MessageRequester(m("information"), m("errorlib"))
    EndIf
  Else
    ConsoleLog(m("errorobj"))
    PlaySound(Error)
    MessageRequester(m("information"), m("errorlib"))
  EndIf
  SetCurrentDirectory(MLFFolder)
  
  ;- 5.4 Delete process compile files
  If GetGadgetState(#mfPROCESSDeleteEnable) = #PB_Checkbox_Checked
    If DeleteDirectory(Compil\CompilDir, "", #PB_FileSystem_Force)
    EndIf
  EndIf  
EndProcedure

;-
Procedure LibShowUserLib()
  RunProgram("explorer.exe", #PB_Compiler_Home + "PureLibraries\UserLibraries", "")  
EndProcedure

;-
;Save ASM file if the user changes the source
Procedure ASMSave()
  Protected ASMFileName.s = Compil\ASM\FileName
  Protected ASMContent.s = GetGadgetText(#mfASMEdit)
  
  SetCurrentDirectory(Compil\CompilDir)
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
  Protected DESCFileName.s = Compil\DESC\FileName
  Protected DESCContent.s = GetGadgetText(#mfDESCEdit)
  
  SetCurrentDirectory(Compil\CompilDir)
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

;-
Procedure Exit()  
  End
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 86
; FirstLine = 63
; Folding = --------------
; Markers = 351,354,416
; EnableXP
; EnableAdmin
; Executable = mlf.exe