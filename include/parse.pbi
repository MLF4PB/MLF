;-=============================================================================
; 
; Project ...... : Make Library Factory
; Name ......... : parse.pbi
; Type ......... : Include
; Author ....... : falsam
; CreateDate ... : 16, September 2017
; Compiler ..... : PureBasic V5.60 (x86)
; Flags ........ : Unicode/XP-Skin
; Subsystem .... : none
; TargetOS ..... : Windows
; License ...... : ?
; Link ......... : https://github.com/MLF4PB/MLF-Alpha/archive/master.zip
; Description .. : Parse ASM (Extract dependancies & procedures and create DESC File)
;
;==============================================================================
; Changelog:
; 27, September 2017 : Added help for each procedure.
;==============================================================================

EnableExplicit

;
Global EnumHeader.s, EnumDependancies.s, EnumProcess.s, EnumProcedures.s, Finalyse.b
Global ProcedureName.s, ProcedureHelp.s, cr = #True, n
Global CountPublicProcedure.i

Structure NewProcedure
  Line.s          ;Example : ; ProcedureDLL StoreMessage(Buffer.s)    
  Name.s          ;Example : StoreMessage (Procedure Name)
  ASMName.s       ;Example : _Procedure2   
  Help.s          ;Example : Adds a message in the queue
  ReturnValue.s   ;Example : ; ProcedureReturn Buffer
  Public.b        
EndStructure

Declare   Analyse(ASMFileName.s)
Declare   Parse(Name.s, Buffer.s, Help.s)
Declare.s Normalize(Buffer.s)

;Analyse ASM file name
Procedure Analyse(ASMFileName.s)
  Protected ASMContent.s, ASMCountDependancies, ASMLineStartDependancies = 7, ASMCurrentLine
  Protected DESCFileName.s, DESCContent.s, DESCHelpFileName.s = "HelpFileName" 
  Protected Buffer.s, Token, RET4Token, JMPToken    
  Protected NewList ASMExtract.NewProcedure()
  
  ;- 1 Create New ASM file 
  If ReadFile(0, ASMFileName) 
    
    ;- 1.0 ASM Procedures become public
    While Eof(0) = 0
      Buffer = ReadString(0)
      
      If FindString(Buffer, "; procedure", 0, #PB_String_NoCase) And Not FindString(Buffer, "; procedurereturn", 0, #PB_String_NoCase)
        Token       = #True
        RET4Token = #False
        JMPToken    = #False
        If FindString(LCase(Buffer), "dll.s") Or FindString(LCase(Buffer), "dll$")
          RET4Token = #True
        Else
          RET4Token = #False          
        EndIf
        
        ;Format procedure : ProcedureDLL    StoreMessage  ( Buffer.s ) => ; ProcedureDLL StoreMessage(Buffer.s)        
        Buffer = Normalize(Buffer)
        
        AddElement(ASMExtract())
        ASMExtract()\Line = Buffer
        ASMExtract()\Name = StringField(StringField(Buffer, 3, " "), 1, "(")
        
        ASMContent + Buffer + #CRLF$
        
        ;Insert "public PB_YourProcedure()" and "PB_YourProcedure" after the comment line "; ProcedureDLL Yourprocedure"
        
        ;. Example of a PureBasic code
        ;  ProcedureDLL Reset()
        ;     Global n  = 10  
        ;  EndProcedure
        
        ;. Assembler file after compilation
        ;  ; ProcedureDLL Reset()
        ;  _Procedure0:
        ;  PS0=4
        ;  ;Global n  = 10  
        ;  MOV    dword [v_n],10
        ;  ; EndProcedure        
        
        ;Extract real name of the procedure 
        ProcedureName = StringField(StringField(Buffer, 3, " "), 1, "(")
        
        ASMContent + "public PB_" + ProcedureName + #CRLF$
        ASMContent + "PB_" + ProcedureName + ":"+ #CRLF$
        ;. Assembler file after updating procedure names
        ;  ;  ProcedureDLL Reset()
        ;  public PB_Reset
        ;  PB_Reset:
        ;  PS0=4
        ;  ; Global n  = 10  
        ;  MOV    dword [v_n],10
        ;  ; EndProcedure
        
      Else
        
        If Token = #False 
          ;-1.0.1-BugFix RET + 4 
          CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
            
            If RET4Token = #True ;This is a ProcedureDLL.s or ProcedureDLL$ 
              If JMPToken = #True And Trim(Buffer) = "RET"
                Buffer + " + 4"
                RET4Token = #False
                JMPToken = #False
              EndIf
                            
              If FindString(LCase(Buffer), "; endprocedure")
                JMPToken = #True
              EndIf
            EndIf
          CompilerEndIf
          ;End BugFix
          
          ASMContent + Buffer + #CRLF$
        Else
          ASMExtract()\ASMName = RemoveString(Buffer, ":") ;Example _Procedure2
          Token = #False
        EndIf
      EndIf
    Wend
    CloseFile(0)
    
    ;- 1.1 Replaces all _ProcedureX with the real names of procedures 
    ;Example CALL  _Procedure0 => CALL  PB_Reset
    ForEach ASMExtract()
      ASMContent = ReplaceString(ASMContent, ASMExtract()\ASMName, "PB_" + ASMExtract()\Name)   
    Next
    
    ;- 1.2 Save new ASM file
    ConsoleLog("Save the assembler file " + ASMFileName)
    If CreateFile(0, ASMFileName)
      WriteString(0, ASMContent)
      CloseFile(0)
    EndIf  
  EndIf
  
  
  ;-
  ;- 2 Create DESC Header
  
  ;The commands available in a Pure Basic Library are described in a file, called 'LibraryName.Desc'
  ;   Inside, you can put every commands, which langage you've
  ;   used To code your library, And more. Every line beginning by a semi-column ';'
  ;   is considered As a comment (like in PureBasic).
  
  EnumHeader = "ASM" + #CRLF$   ; Langage used to code the library: ASM or C
  EnumHeader + "0" + #CRLF$     ; Number of windows DLL than the library need
  EnumHeader + "OBJ" + #CRLF$   ; Library type (Can be OBJ or LIB).  
  
  EnumDependancies = ""         ; Enumeration of dependencies.
  EnumProcess = ""              ; Enumeration attach & detach process
  EnumProcedures = ""           ; Enumeration of procedures.
  Finalyse = #False
  
  ;- 2.0 Extract and count dependancies (Number of PureBasic library needed by the library.)
  If ReadFile(0, ASMFileName) 
    While Eof(0) = 0
      Buffer = ReadString(0)
      If FindString(Buffer, "; :System", 0, #PB_String_NoCase)
        Break
      Else
        If ASMCurrentLine >= ASMLineStartDependancies
          ASMCountDependancies + 1
          EnumDependancies + Mid(Buffer, 3) + #CRLF$
        EndIf
      EndIf
      ASMCurrentLine + 1
    Wend
    CloseFile(0)
  EndIf
  
  ;- 2.1 Extract procedures from ASM file and sort by name
  ClearList(ASMExtract())
  If ReadFile(0, ASMFileName) 
    While Eof(0) = 0
      Buffer = ReadString(0)
      If FindString(Buffer, "; ProcedureDLL", 0, #PB_String_NoCase)
        AddElement(ASMExtract())
        ASMExtract()\Line = Buffer
        Token = #True
      EndIf 
      If FindString(Buffer, "; ProcedureReturn", 0, #PB_String_NoCase) And Token = #True
        ASMExtract()\ReturnValue = Buffer
      EndIf
    Wend
    CloseFile(0)
    SortStructuredList(ASMExtract(), #PB_Sort_Descending, OffsetOf(NewProcedure\Line), #PB_String)
    
    Buffer = ""
    ForEach ASMExtract()
      ProcedureName = StringField(StringField(ASMExtract()\Line, 3, " "), 1, "(")
      cr = #True
      While cr <> 0
        cr = #False
        For n = 1 To 10
          If FindString(ReverseString(ProcedureName), Mid("1234567890", n,1))
            ProcedureName = LSet(ProcedureName, Len(ProcedureName)-1)
            cr = #True
          EndIf
        Next
      Wend
      ASMExtract()\Name = ProcedureName
      
      If ASMExtract()\Name <> Buffer
        Buffer = ASMExtract()\Name
        ASMExtract()\Public = #True
      Else
        ASMExtract()\Public = #False
      EndIf
    Next
    
    SortStructuredList(ASMExtract(), #PB_Sort_Ascending, OffsetOf(NewProcedure\Line), #PB_String)
    
    CountPublicProcedure = ListSize(ASMExtract())
    
    ;- 2.2 Search AttachProcess() and DetachProcess()
    ForEach(ASMExtract())
      Select LCase(ASMExtract()\Name)
        Case "attachprocess"
          EnumProcess + ASMExtract()\Name + #CRLF$ + "InitFunction" + #CRLF$ + #CRLF$
          ASMExtract()\Public = #False
          
        Case "detachprocess"
          EnumProcess + ASMExtract()\Name + #CRLF$ + "EndFunction" + #CRLF$
          ASMExtract()\Public = #False
      EndSelect
    Next
    
    ;- 2.3 Extract IDE Help from PureBasic filename
    ForEach(ASMExtract())
      If ASMExtract()\Public = #True 
        ReadFile(0, PBFileName)    
        While Eof(0) = 0
          Buffer = ReadString(0)
          If FindString(Buffer, "ProcedureDLL", 0, #PB_String_NoCase) And  FindString(Buffer, ASMExtract()\Name) 
            ProcedureHelp = Trim(StringField(Buffer, 2, ";-"))
            If ProcedureHelp = ""
              ProcedureHelp = "IDE help is not defined"
            EndIf
            ASMExtract()\Help = ProcedureHelp
            Break 
          EndIf
        Wend
        CloseFile(0)       
        Parse(ASMExtract()\Name, ASMExtract()\Line, ASMExtract()\Help)
      EndIf      
    Next
    
    ;- 2.4 Create DESC content filename
    DESCContent = EnumHeader + Str(ASMCountDependancies) + #CRLF$ + #CRLF$ +
                  "; " + Str(ASMCountDependancies) + " Dependancies " + #CRLF$ +
                  EnumDependancies + #CRLF$ +
                  "; Your help file" + #CRLF$ +
                  DESCHelpFileName + #CRLF$ + #CRLF$ +
                  "; Procedure summary" + #CRLF$ +
                  EnumProcess + #CRLF$  +
                  EnumProcedures
    
    ;- 2.5 Save DESC file
    If CountPublicProcedure <> 0
      DESCFileName = GetFilePart(ASMFileName, #PB_FileSystem_NoExtension) + ".desc"
      ConsoleLog("Save description file  " + DESCFileName)
      If CreateFile(0, DESCFileName)
        WriteString(0, DESCContent)
        CloseFile(0) 
      EndIf
    EndIf 
  EndIf 
EndProcedure

;-
Procedure Parse(Name.s, Buffer.s, Help.s)  
  ;- 3 Parse the parameters of each procedure
  Protected ProcedureType.s       ;Type .s, .i, .... 
  Protected ProcedureParameters.s ;(Buffer$, Position.i
  Protected ProcedureParametersEnd.s ;]]])
  Protected Parameter.s, n
  Protected DefaultValue.b        ;Parameter has a default value
  Protected CountParameters, CurrentParameter.i       
  Protected CommentProcedure.s = Buffer
  
  ConsoleLog("- Parse : " + Buffer)
  Buffer = Mid(Buffer, 3)
  Select LCase(StringField(StringField(Buffer, 1, " "), 1, "."))
    Case "proceduredll", "procedurecdll", "proceduredll$", "procedurecdll$"
      
      ;- 3.0 Parse procedure type
      Select  LCase(StringField(StringField(Buffer, 1, " "), 2, "."))
        Case "b"
          ProcedureType =  "Byte | StdCall"
          
        Case "i", "l"  
          ProcedureType =  "Long | StdCall"
          
        Case "f"
          ProcedureType =  "Float | StdCall"
          
        Case "d"
          ProcedureType =  "Double | StdCall"
          
        Case "f"
          ProcedureType =  "Float | StdCall"
          
        Case "q"
          ProcedureType = "Quad | StdCall"
          
        Case "s"
          ProcedureType = "String | StdCall | Unicode | Cdecl"
          
        Case "w"
          ProcedureType = "Word | StdCall"
          
        Default
          If FindString(Buffer, "$")
            ProcedureType = "String | StdCall | Unicode | Cdecl"
          Else
            ProcedureType = "Long | StdCall"
          EndIf
      EndSelect
      
      ;- 3.1 Procedure without Parameter
      If CountString(Buffer, Name+"()") = #True
        CountParameters = 0
      Else
        CountParameters = CountString(Buffer, ", ") + 1
      EndIf
      
      ;- 3.2 Remove "ProcedureDLL"
      Buffer = Trim(Mid(Buffer, Len(Trim(StringField(Buffer, 1, " ")))+1))
      
      EnumProcedures + CommentProcedure + #CRLF$ + Name + ", "
      
      ;- 3.3 Parse each Parameter
      
      ;Parameter type (Code : Coce done, ? : No test, Bug : Bad result)
      ; Byte: The parameter will be a byte (1 byte)
      ; Word: The parameter will be a word (2 bytes)
      ; Long: The parameter will be a long (4 bytes)
      ; String: The parameter will be a string (see below For an explaination of string handling)
      ; Quad: The parameter will be a quad (8 bytes)
      ; Float: The parameter will be a float (4 bytes)
      ; Double: The parameter will be a double (8 bytes)
      ; Any: The parameter can be anything (the compiler won't check the type)
      ; Array: The parameter will be an Array. It will have To be passed like: Array()
      ; LinkedList: The parameter will be an linkedlist. It will have To be passed like: List()
      
      ;Remove first bracket and last bracket
      ProcedureParameters =  Mid(Buffer, FindString(Buffer, "(") + 1)
      Buffer = Mid(ProcedureParameters, 0, Len(ProcedureParameters) - 1)
      ProcedureParameters = "("
      
      If CountParameters <> 0
        For n = 1 To CountString(Buffer, ",") + 1
          Parameter = Trim(StringField(Buffer, n, ", "))
          CurrentParameter + 1
          If FindString(Parameter, "=")
            Parameter = Trim(StringField(Parameter, 1, "="))
            DefaultValue = #True
          EndIf
          Select LCase(StringField(Parameter, 2, "."))
            Case "b"
              If DefaultValue
                EnumProcedures + "[Byte], "
              Else
                EnumProcedures + "Byte, "
              EndIf
              
            Case "i", "l"
              If DefaultValue
                EnumProcedures + "[Long], "
              Else
                EnumProcedures + "Long, "
              EndIf
              
            Case "d"
              If DefaultValue
                EnumProcedures + "[Double], "
              Else
                EnumProcedures + "Double, "
              EndIf
              
            Case "f"
              If DefaultValue
                EnumProcedures + "[Float], "
              Else
                EnumProcedures + "Float, "
              EndIf
              
            Case "q"
              If DefaultValue
                EnumProcedures + "[Quad], "
              Else
                EnumProcedures + "Quad, "
              EndIf
              
            Case "w"
              If DefaultValue
                EnumProcedures + "[Word], "
              Else
                EnumProcedures + "Word, "
              EndIf
              
            Case "s"
              If DefaultValue
                EnumProcedures + "[String], "
              Else
                EnumProcedures + "String, "
              EndIf
              
            Default
              If FindString(Parameter, "$")
                If DefaultValue
                  EnumProcedures + "[String], "
                Else
                  EnumProcedures + "String, "
                EndIf
                
              ElseIf FindString(Parameter, "Array", 0, #PB_String_NoCase)
                If DefaultValue
                  EnumProcedures + "[Array], "
                Else
                  EnumProcedures + "Array, "
                EndIf
                
              ElseIf FindString(Parameter, "List", 0, #PB_String_NoCase)
                If DefaultValue
                  EnumProcedures + "[LinkedList], "
                Else
                  EnumProcedures + "LinkedList, "
                EndIf
                
                ;ElseIf Not FindString(ProcedureType, "none", 0, #PB_String_NoCase)
                ;  EnumProcedures + "Long, "
              Else
                If DefaultValue
                  EnumProcedures + "[Long], "
                Else
                  EnumProcedures + "Long, "
                EndIf
                
              EndIf
          EndSelect
          
          If CurrentParameter = 1
            If DefaultValue
              ProcedureParameters + "[" + Parameter
              ProcedureParametersEnd + "]"
            Else
              ProcedureParameters + Parameter
            EndIf
          Else
            If DefaultValue 
              ProcedureParameters + " [, " + Parameter
              ProcedureParametersEnd + "]"
            Else
              ProcedureParameters + " , " + Parameter
            EndIf
          EndIf
        Next
        
        DefaultValue = #False
      EndIf 
      Finalyse = #True
      
    Case "procedurereturn"
      Finalyse = #False
  EndSelect
  
  ;Finalyse
  If Finalyse = #True
    ;Add flag 'Unicode' if a parameter is a string     
    If FindString(EnumProcedures, "String") And Not FindString(ProcedureType, "Unicode")
      ProcedureType + " | Unicode"
    EndIf
    
    ProcedureParameters + ProcedureParametersEnd + ")"
    
    EnumProcedures + ProcedureParameters + " - " + Help + #CRLF$  +
                     ProcedureType + #CRLF$ + #CRLF$
  EndIf
EndProcedure

;-
;Format procedure by GallyHC
Procedure.s Normalize(Buffer.s)
  Protected i
  Protected bblock.b, bspace.b
  Protected stemps.s, result.s
  
  For i=1 To Len(Buffer)
    stemps = Mid(Buffer, i, 1)
    If stemps = ~"\""
      bblock = (bblock + 1) % 2
    EndIf
    If bblock = #True
      result + stemps
    Else
      If bspace = #False Or stemps <> " "
        result + stemps
        If i < Len(Buffer)
          If stemps = "," And Mid(Buffer, i + 1, 1) <> " "
            result + " "
          EndIf
        EndIf
        bspace = #False
      EndIf
      If stemps = " "
        bspace = #True
      EndIf
    EndIf
  Next i
  result = ReplaceString(result, " , ", " ,")
  result = ReplaceString(result, " ,", ", ")
  result = ReplaceString(result, " (", "(")
  result = ReplaceString(result, "( ", "(")
  result = ReplaceString(result, " )", ")")
  ProcedureReturn result
EndProcedure

; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 326
; FirstLine = 304
; Folding = ---------
; EnableXP