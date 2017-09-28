# MLF - Make Lib Factory
- Status : Version Beta  
- Pure Basic 5.60+   
- Compilation : [x] Request Administrator mode 

## Description.
MLF is a utility for creating user libraries for the PureBasic language.    
_MLF est un utilitaire de création de librairies utilisateur pour le langage PureBasic._   

![MLD ScreenShot](https://raw.githubusercontent.com/MLF4PB/MLF-Dev/master/include/mlf.jpg)

## How it works ?

Select a PureBasic code containing your procedures.  
_Sélectionnez un code PureBasic contenant vos procédures._

The compile button creates an ASM and DESC file.  
_Le bouton compil crée un fichier ASM et DESC._

The help for each of your procedures is automatically added. You have the possibility to modify the content.  

Example: GetOSName, () - Returns the name of the operating system.  

If this is the case, do not forget to click on the Save button.

_L'aide de chacune de vos procédures est automatiquement ajoutée. Vous avez la possibilité de modifier le contenu._

_Example : GetOSName, () - Returns the name of the operating system._

_Si c'est le cas n'oubliez pas de cliquer sur le bouton Sauver._

Finally, the Make Lib button creates the library in the "_Libraries\UserLibraries_" folder of the PureBasic installation folder.  
_Pour finir, le bouton Make Lib va crée la librairie dans le dossier "Libraries\UserLibraries" du dossier d'installation de PureBasic._

Restart compiler. (IDE : Menu Compiler -> Restart compiler)  
_Redémarrer le compilateur. (IDE : Menu Compilateur -> Redémarrer le compilateur)_

