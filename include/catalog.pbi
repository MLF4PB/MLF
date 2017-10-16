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


#MLF_MaxLanguage = 3 ; 0 Based (0,1,2,4)

; 0 = FR, 1 = EN, 2 = DE, 4 = RU
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
EndWith 

AddMapElement(Catalog(), "welcome")
With Catalog()
  \Translate(0) = "Bienvenue à bord."
  \Translate(1) = "Welcome aboard."
  \Translate(2) = "Wilkommen."
  \Translate(3) = "Добро пожаловать на борт." 
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
EndWith 

AddMapElement(Catalog(), "selpbfile")
With Catalog()
  \Translate(0) = "Sélectionnez le code PureBasic à compiler."
  \Translate(1) = "Select the code PureBasic to be compiled." 
  \Translate(2) = "Wähle den zu kompilierenden Quellcode aus." 
  \Translate(3) = "Выберите исходный код PB для компиляции."
EndWith 

AddMapElement(Catalog(), "pbselect")
With Catalog()
  \Translate(0) = "Selectionner"
  \Translate(1) = "Select"
  \Translate(2) = "Wähle"
  \Translate(3) = "Выбрать" 
EndWith 

AddMapElement(Catalog(), "pbcompil")
With Catalog()
  \Translate(0) = "Compiler"
  \Translate(1) = "Compil"
  \Translate(2) = "Kompiliere"
  \Translate(3) = "Компилировать" 
EndWith 

AddMapElement(Catalog(), "libcreate")
With Catalog()
  \Translate(0) = "Créer bibliothéque"
  \Translate(1) = "Create library"
  \Translate(2) = "Erstelle Bibliothek"
  \Translate(3) = "Создать библиотеку" 
EndWith 

AddMapElement(Catalog(), "libshow")
With Catalog()
  \Translate(0) = "Voir bibliothéques"
  \Translate(1) = "Show libraries"
  \Translate(2) = "Zeige Bibliotheken"
  \Translate(3) = "Просмотр библиотек" 
EndWith 


;Panel : View code ASM
AddMapElement(Catalog(), "panviewasm")
With Catalog()
  \Translate(0) = "Voir source ASM"
  \Translate(1) = "View ASM source"
  \Translate(2) = "Zeige ASM Code"
  \Translate(3) = "Посмотреть ASM исходник" 
EndWith 

;Panel : View and/or updated code DESC
AddMapElement(Catalog(), "panviewdesc")
With Catalog()
  \Translate(0) = "Voir source DESC"
  \Translate(1) = "View DESC source" 
  \Translate(2) = "Zeige DESC Code"
  \Translate(3) = "Посмотреть DESC исходник" 
EndWith 

AddMapElement(Catalog(), "save")
With Catalog()
  \Translate(0) = "Sauver"
  \Translate(1) = "Save" 
  \Translate(2) = "Speichern"
  \Translate(3) = "Сохранить" 
EndWith 

AddMapElement(Catalog(), "errorasm")
With Catalog()
  \Translate(0) = "Impossible de créer le fichier ASM."
  \Translate(1) = "Failed to create ASM file." 
  \Translate(2) = "Erstellung der ASM Datei fehlgeschlagen."
  \Translate(3) = "Не удалось создать файл ASM."  
EndWith 

AddMapElement(Catalog(), "successasm")
With Catalog()
  \Translate(0) = "Création du fichier ASM, terminée."
  \Translate(1) = "Create ASM file completed."
  \Translate(2) = "Erstellung der ASM Datei."
  \Translate(3) = "Создание файла ASM, завершено."   
EndWith 

AddMapElement(Catalog(), "errordesc")
With Catalog()
  \Translate(0) = "Impossible de créer le fichier de description."
  \Translate(1) = "Failed to create description file." 
  \Translate(2) = "Erstellung der DESC Datei fehlgeschlagen."
  \Translate(3) = "Не удалось создать файл DESC." 
EndWith 

AddMapElement(Catalog(), "successdesc")
With Catalog()
  \Translate(0) = "Création du fichier le description, terminée."
  \Translate(1) = "Create description file completed."
  \Translate(2) = "Erstellung der DESC Datei."
  \Translate(3) = "Создание файла DESC, завершено."   
EndWith 

AddMapElement(Catalog(), "libexist")
With Catalog()
  \Translate(0) = "Supprimer la librairie si existante et relancer le compilateur."
  \Translate(1) = "Remove the library if it exists and restart the compiler." 
  \Translate(2) = "Ersetze die Bibliothek (falls sie existiert) und starte den Kompiler neu."
  \Translate(3) = "Удалите библиотеку, если она существует, и перезапустите компилятор." 
EndWith 

AddMapElement(Catalog(), "errorlib")
With Catalog()
  \Translate(0) = "Impossible de créer la librairie."
  \Translate(1) = "Unable to create library." 
  \Translate(2) = "Konnte Bibliothek nicht erstellen."
  \Translate(3) = "Невозможно создать библиотеку." 
EndWith 

AddMapElement(Catalog(), "errorobj")
With Catalog()
  \Translate(0) = "FASM : Une erreur c'est produite durant la compilation du fichier assembleur."
  \Translate(1) = "FASM : An error occurred during the compilation of the assembler file." 
  \Translate(2) = "FASM : Beim Kompilieren der Assemblerdatei ist ein Fehler aufgetreten."
  \Translate(3) = "FASM : Произошла ошибка во время компиляции файла ассемблера" 
EndWith 

AddMapElement(Catalog(), "successlib")
With Catalog()
  \Translate(0) = "Création de la librairie terminée."
  \Translate(1) = "Create library completed."
  \Translate(2) = "Bibliothek erstellt."
  \Translate(3) = "Создание библиотеки, завершено." 
EndWith 

AddMapElement(Catalog(), "nopubproc")
With Catalog()
  \Translate(0) = "Il n' y a pas de procédure publique."
  \Translate(1) = "There is no public procedure."
  \Translate(2) = "Es gibt keine öffentliche Prozedur."
  \Translate(3) = "Тут нет общественной процедуры." 
EndWith 

AddMapElement(Catalog(), "userlibdisable")
With Catalog()
  \Translate(0) = "Création de bibliothèque utilisateur désactivée."
  \Translate(1) = "User library creation disabled."
  \Translate(2) = "Erstellung einer Benutzerbibliothek ist deaktiviert."
  \Translate(3) = "Отключено создание пользовательской библиотеки." 
EndWith 

AddMapElement(Catalog(), "errordelete")
With Catalog()
  \Translate(0) = "Imposssible de supprimer le fichier"
  \Translate(1) = "Unable to delete file"
  \Translate(2) = "Datei konnte nicht gelöscht werden"
  \Translate(3) = "Не удалось удалить файл" 
EndWith 

AddMapElement(Catalog(), "logclear")
With Catalog()
  \Translate(0) = "Effacer le rapport"
  \Translate(1) = "Clear log"
  \Translate(2) = "Berricht löschen"
  \Translate(3) = "Удалить отчёт" 
EndWith 

AddMapElement(Catalog(), "logcopy")
With Catalog()
  \Translate(0) = "Copier le rapport"
  \Translate(1) = "Copy log"
  \Translate(2) = "Berricht kopieren"
  \Translate(3) = "Копия отчёта" 
EndWith 

AddMapElement(Catalog(), "information")
With Catalog()
  \Translate(0) = "MLF : Information"
  \Translate(1) = "MLF : Information"
  \Translate(2) = "MLF : Informationen"
  \Translate(3) = "MLF : информация" 
EndWith 

AddMapElement(Catalog(), "residentexist")
With Catalog()
  \Translate(0) = "Confirmez vous la suppression du resident"
  \Translate(1) = "Confirm the deletion of the resident"
  \Translate(2) = "Bestätigen Sie das Löschen des Residenten"
  \Translate(3) = "Подтвердить удаление резидента" 
EndWith 

Procedure InitLang(Gadget)
  AddGadgetItem(Gadget, -1, "Français")
  AddGadgetItem(Gadget, -1, "English")
  AddGadgetItem(Gadget, -1, "Deutsch")
  AddGadgetItem(Gadget, -1, "Russian")
  SetGadgetState(Gadget, Lang)
EndProcedure

Procedure SetLang(Value)
  Lang = Value  
EndProcedure

Procedure.s m(Key.s)
  ProcedureReturn Catalog(key)\Translate(Lang)
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 190
; FirstLine = 170
; Folding = -
; EnableXP