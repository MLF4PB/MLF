;-=============================================================================
; 
; Project ...... : Make Library Factory
; Name ......... : catalog.pbi
; Type ......... : Translation Include
; Author ....... : falsam
; CreateDate ... : 16, September 2017
; Compiler ..... : PureBasic V5.60 (x86)
; Flags ........ : Unicode/XP-Skin
; Subsystem .... : none
; TargetOS ..... : Windows
; License ...... : ?
; Link ......... : https://github.com/MLF4PB/MLF-Alpha/archive/master.zip
; Description .. : Catalog Include to translate gui - text
;
;==============================================================================
; Changelog:
; 23, September 2017 : Header & German Text added by Bisonte
; 24, Septemner 2017 : Russian Text add by mestnyi
;==============================================================================


#MLF_MaxLanguage = 4 ; 0 Based (0,1,2,4,5)

; 0 = FR, 1 = EN, 2 = DE, 4 = RU,5 = CN
Global Lang = 0

Structure NewMessage
  Array Translate.s(#MLF_MaxLanguage)
EndStructure

Global NewMap Catalog.NewMessage()

AddMapElement(Catalog(), "title")
With Catalog()
  \Translate(0) = Title + " version " + Version + " - " + " Création d'une bibliothèque de fonctions utilisateur"
  \Translate(1) = Title + " version " + Version + " - " + " Creating a user library"
  \Translate(2) = Title + " version " + Version + " - " + " Erstelle eine Bibliothek"
  \Translate(3) = Title + " версия "  + Version + " - " + " Создание пользовательской библиотеки" 
  \Translate(4) = Title + " 版本 " + Version + " - " + " 创建用户库"
EndWith 

AddMapElement(Catalog(), "welcome")
With Catalog()
  \Translate(0) = "Bienvenue à bord."
  \Translate(1) = "Welcome aboard."
  \Translate(2) = "Wilkommen."
  \Translate(3) = "Добро пожаловать на борт." 
  \Translate(4) = "欢迎使用."
EndWith 


AddMapElement(Catalog(), "run")
With Catalog()
  \Translate(0) = "Cliquez sur le bouton de compilation."
  \Translate(1) = "Click the compile button."
  \Translate(2) = "Klicken Sie auf die Schaltfläche zum Kompilieren."
  \Translate(3) = "Нажмите на кнопку компилировать." 
EndWith 

;Panel : Select code PureBasic to be compiled
AddMapElement(Catalog(), "pancompil")
With Catalog()
  \Translate(0) = "Compiler un code PureBasic"
  \Translate(1) = "Compile a PureBasic code"
  \Translate(2) = "Kompiliere einen Quellcode"
  \Translate(3) = "Компилировать в код PB"  
  \Translate(4) = "编译一个PureBasic代码"
EndWith 

AddMapElement(Catalog(), "selpbfile")
With Catalog()
  \Translate(0) = "Sélectionnez le code PureBasic à compiler."
  \Translate(1) = "Select the code PureBasic to be compiled." 
  \Translate(2) = "Wähle den zu kompilierenden Quellcode aus." 
  \Translate(3) = "Выберите исходный код PB для компиляции."
  \Translate(4) = "选择代码PureBasic将其编译." 
EndWith 

AddMapElement(Catalog(), "pbselect")
With Catalog()
  \Translate(0) = "Selectionner"
  \Translate(1) = "Select"
  \Translate(2) = "Wähle"
  \Translate(3) = "Выбрать" 
  \Translate(4) = "选择"
EndWith 

AddMapElement(Catalog(), "pbcompil")
With Catalog()
  \Translate(0) = "Compiler"
  \Translate(1) = "Compil"
  \Translate(2) = "Kompiliere"
  \Translate(3) = "Компилировать" 
  \Translate(4) = "编译"
EndWith 

AddMapElement(Catalog(), "libcreate")
With Catalog()
  \Translate(0) = "Créer bibliothéque"
  \Translate(1) = "Create library"
  \Translate(2) = "Erstelle Bibliothek"
  \Translate(3) = "Создать библиотеку" 
  \Translate(4) = "创建库"
EndWith 

AddMapElement(Catalog(), "libshow")
With Catalog()
  \Translate(0) = "Voir bibliothéques"
  \Translate(1) = "Show libraries"
  \Translate(2) = "Zeige Bibliotheken"
  \Translate(3) = "Просмотр библиотек" 
  \Translate(4) = "显示库"
EndWith 


;Panel : View code ASM
AddMapElement(Catalog(), "panviewasm")
With Catalog()
  \Translate(0) = "Voir source ASM"
  \Translate(1) = "View ASM source"
  \Translate(2) = "Zeige ASM Code"
  \Translate(3) = "Посмотреть ASM исходник" 
  \Translate(4) = "查看汇编源码"
EndWith 

;Panel : View and/or updated code DESC
AddMapElement(Catalog(), "panviewdesc")
With Catalog()
  \Translate(0) = "Voir source DESC"
  \Translate(1) = "View DESC source" 
  \Translate(2) = "Zeige DESC Code"
  \Translate(3) = "Посмотреть DESC исходник" 
  \Translate(4) = "查看DESC源码" 
EndWith 

AddMapElement(Catalog(), "save")
With Catalog()
  \Translate(0) = "Sauver"
  \Translate(1) = "Save" 
  \Translate(2) = "Speichern"
  \Translate(3) = "Сохранить" 
  \Translate(4) = "源码" 
EndWith 

AddMapElement(Catalog(), "errorasm")
With Catalog()
  \Translate(0) = "Impossible de créer le fichier ASM."
  \Translate(1) = "Failed to create ASM file." 
  \Translate(2) = "Erstellung der ASM Datei fehlgeschlagen."
  \Translate(3) = "Не удалось создать файл ASM." 
  \Translate(4) = "创建汇编文件失败."   
EndWith 

AddMapElement(Catalog(), "successasm")
With Catalog()
  \Translate(0) = "Création du fichier le description, terminée."
  \Translate(1) = "Create description file completed."
  \Translate(2) = "Erstellung der ASM Datei."
  \Translate(3) = "Создание файла ASM, завершено."   
  \Translate(4) = "创建汇编文件完成."
EndWith 

AddMapElement(Catalog(), "errordesc")
With Catalog()
  \Translate(0) = "Impossible de créer le fichier de description."
  \Translate(1) = "Failed to create description file." 
  \Translate(2) = "Erstellung der DESC Datei fehlgeschlagen."
  \Translate(3) = "Не удалось создать файл DESC." 
  \Translate(4) = "创建描述文件失败." 
  
EndWith 

AddMapElement(Catalog(), "successdesc")
With Catalog()
  \Translate(0) = "Création du fichier le description, terminée."
  \Translate(1) = "Create description file completed."
  \Translate(2) = "Erstellung der DESC Datei."
  \Translate(3) = "Создание файла DESC, завершено."   
  \Translate(4) = "创建描述文件完成."
EndWith 

AddMapElement(Catalog(), "libexist")
With Catalog()
  \Translate(0) = "Supprimer la librairie si existante et relancer le compilateur."
  \Translate(1) = "Remove the library if it exists and restart the compiler." 
  \Translate(2) = "Ersetze die Bibliothek (falls sie existiert) und starte den Kompiler neu."
  \Translate(3) = "Удалите библиотеку, если она существует, и перезапустите компилятор." 
  \Translate(4) = "如果此库存在则移除并重启编译器." 
  
EndWith 

AddMapElement(Catalog(), "errorlib")
With Catalog()
  \Translate(0) = "Impossible de créer la librairie."
  \Translate(1) = "Unable to create library." 
  \Translate(2) = "Konnte Bibliothek nicht erstellen."
  \Translate(3) = "Невозможно создать библиотеку." 
  \Translate(4) = "无法创建库."   
EndWith 

AddMapElement(Catalog(), "errorobj")
With Catalog()
  \Translate(0) = "Une erreur c'est produite durant la compilation du fichier assembleur."
  \Translate(1) = "An error occurred during the compilation of the assembler file." 
  \Translate(2) = "Beim Kompilieren der Assemblerdatei ist ein Fehler aufgetreten."
  \Translate(3) = "Произошла ошибка во время компиляции файла ассемблера" 
  \Translate(4) = "编译汇编文件期间发生错误." 
EndWith 

AddMapElement(Catalog(), "successlib")
With Catalog()
  \Translate(0) = "Création de la librairie terminée."
  \Translate(1) = "Create library completed."
  \Translate(2) = "Bibliothek erstellt."
  \Translate(3) = "Создание библиотеки, завершено." 
  \Translate(4) = "库创建完成."
EndWith 

AddMapElement(Catalog(), "errordelete")
With Catalog()
  \Translate(0) = "Imposssible de supprimer le fichier"
  \Translate(1) = "Unable to delete file"
  \Translate(2) = "Datei konnte nicht gelöscht werden"
  \Translate(3) = "Не удалось удалить файл" 
  \Translate(4) = "无法删除文件"
EndWith 

AddMapElement(Catalog(), "logclear")
With Catalog()
  \Translate(0) = "Effacer le rapport"
  \Translate(1) = "Clear log"
  \Translate(2) = "Berricht löschen"
  \Translate(3) = "Удалить отчёт" 
  \Translate(4) = "清理日志"
EndWith 

AddMapElement(Catalog(), "logcopy")
With Catalog()
  \Translate(0) = "Copier le rapport"
  \Translate(1) = "Copy log"
  \Translate(2) = "Berricht kopieren"
  \Translate(3) = "Копия отчёта" 
  \Translate(4) = "复制日志"
EndWith 

AddMapElement(Catalog(), "information")
With Catalog()
  \Translate(0) = "MLF : Information"
  \Translate(1) = "MLF : Information"
  \Translate(2) = "MLF : Informationen"
  \Translate(3) = "MLF : информация" 
  \Translate(4) = "MLF : 信息"
EndWith 

AddMapElement(Catalog(), "residentexist")
With Catalog()
  \Translate(0) = "Confirmez vous la suppression du resident"
  \Translate(1) = "Confirm the deletion of the resident"
  \Translate(2) = "Bestätigen Sie das Löschen des Residenten"
  \Translate(3) = "Подтвердить удаление резидента" 
  \Translate(4) = "确认删除"
EndWith 

Procedure InitLang(Gadget)
  AddGadgetItem(Gadget, -1, "Français")
  AddGadgetItem(Gadget, -1, "English")
  AddGadgetItem(Gadget, -1, "Deutsch")
  AddGadgetItem(Gadget, -1, "Russian")
  AddGadgetItem(Gadget, -1, "简体中文")
  SetGadgetState(Gadget, Lang)
EndProcedure

Procedure SetLang(Value)
  Lang = Value  
EndProcedure

Procedure.s m(Key.s)
  ProcedureReturn Catalog(key)\Translate(Lang)
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 252
; FirstLine = 200
; Folding = -
; EnableXP