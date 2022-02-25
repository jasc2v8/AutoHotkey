
/*
  Title:  TreeView_Recurse_Example.ahk
  About:  An example of how to recurse a TreeView: RecurseTreeView()
  Usage:  Run the script to see an example
  Legal:  Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
  Credits to:
    Learning one:
    https://autohotkey.com/board/topic/92863-function-createtreeview/

    robertcollier4
    https://autohotkey.com/board/topic/92147-real-challenge-using-explorers-icon-of-a-file-in-gui/ 

    icuurd12b42
    https://www.autohotkey.com/boards/viewtopic.php?t=36879

  TVList Format: TV Level, Folder or filename.ext
      0001,Folder1
      0002,SubFolder1
      0002,File1.txt
    The icon loaded in the TreeView is the Windows default for the file extension    
*/

#NoEnv
; #Warn
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
ListLines, Off
#SingleInstance, Force

Global IDArray := []

AutoExec_Section:

  SplitPath, A_ScriptFullPath, FileName, Dir, Ext, NameNoExt
  TVFile := Dir "\" NameNoExt "_Save.txt"
  FileDelete, % TVFile

  GuiTitle := "My TreeView"

  ProgressIndex := 0
  ProgressMax := 1000

  Gui, MyGui:New, +Resize
  Gui, Font, s10, Consolas
  Gui, Add, Button, w100, Modify All
  Gui, Add, TreeView, xm w400 h480 Checked vMyTreeView
  Gui, Add, StatusBar
  SB_SetIcon("Shell32.dll", 222) 
  Gui, Add, Progress, w400 h25 cBlue vMyProgress Range0-%ProgressMax%
  Gui, Show, AutoSize, %GuiTitle%

  Folder := "..\Examples\RootFolder" ; A_Desktop

  Gosub LoadTreeView

  Gosub MyGuiButtonModifyAll

Return

RecurseTreeView(ItemID := 0)
{
 	;start with the first child of this item
  ThisItemID:=TV_GetChild(ItemID)
	if(ThisItemID) {
		Loop
		{
      ;push the item at the end of the array
			IDArray.Push(ThisItemID)
			;does this item have any children?
			if(TV_GetChild(ThisItemID))
				RecurseTreeView(ThisItemID)
			;next sibling
			ThisItemID := TV_GetNext(ThisItemID) 
      ;if no more items in this branch then break
			if (not ThisItemID) {	
				break
			}
		}
	}
}

TV_ModifyAll(Option := "Expand")	
{
  Global IDArray
  Gui, MyGui:Default
	GuiControl, -Redraw, MyTreeView
  RecurseTreeView()
  for key, ItemID in IDArray
    TV_Modify(ItemID, Option)
  GuiControl, +Redraw, MyTreeView
}

LoadTreeView:
  if !FileExist(Folder) {
    SoundBeep
    SB_SetText("Not Exist: " Folder)
    Return
  }
  SB_SetText("Loading: " Folder)
  Gosub ShowProgress
  TVList := GetTVList(Folder)
  TV_Load(TVList)
  Gosub HideProgress
  SB_SetText("Ready. Press F1 for Help.")
Return

MyGuiButtonModifyAll:
  ModifyAllFlag := !ModifyAllFlag
  if (ModifyAllFlag) {
    TV_ModifyAll("Expand")
    TV_ModifyAll("Bold")
    TV_ModifyAll("Check")
  } else {
    TV_ModifyAll("-Expand")
    TV_ModifyAll("-Bold")
    TV_ModifyAll("-Check")
  }
Return

MyGuiGuiSize:
  if A_EventInfo = 1
      return
  GuiControl, Move, MyTreeView, % "W" . (A_GuiWidth - 25) . " H" . (A_GuiHeight - 60)
  GuiControl, Move, MyProgress, % "Y" . (A_GuiHeight - 50)
return

HideProgress:
  GuiControl, Hide, MyProgress
Return

ShowProgress:
  GuiControl, Show, MyProgress
Return

IncrementProgress:
  if (ProgressIndex > ProgressMax)
    ProgressIndex := 0
  GuiControl,, MyProgress, % ProgressIndex
  ProgressIndex++
Return

GetTVList(Folder, Level=0)
{
  MyList=
	Level++
	Loop, %Folder%\*.*, 1 ; 1=all files and folders
	{
    Gosub IncrementProgress
		If InStr(FileExist(A_LoopFileFullPath), "D") {
			MyList .= Format("{:04}", Level) "," A_LoopFileName "`n"
			MyList .= GetTVList(A_LoopFileFullPath, Level)
		} Else {
			Files .= Format("{:04}", Level) "," A_LoopFileName "`n"
		}
	}
	MyList .= Files
	Level--
	return MyList
}

IL_Load(TVList) {

  ImageListArray := []
  ImageListID := IL_Create(1,1)

	Loop, parse, TVList, `n, `r
	{

		if (A_LoopField = "")
			continue

    Gosub IncrementProgress

    Split := StrSplit(A_LoopField, ",")
    Level       := Split.1
    Item        := Split.2

    SplitPath, Item , , , ext

    FileAndNumber := GetDefaultIconforExt(ext)

    if (ext = "") {
      IconFile := "shell32.dll"
      IconNumber := 4
    } else if (FileAndNumber = "") {
      IconFile := "shell32.dll"
      IconNumber := 1
    } else {
      Split := StrSplit(FileAndNumber, ",")
      IconFile    := Split.1
      IconNumber  := Split.2
    }

    IconID := "Icon" IL_Add(ImageListID, IconFile, IconNumber)

    if (ImageListArray[ext] =  "")
      ImageListArray[ext] := IconID
	}
  TV_SetImageList(ImageListID)
  Return ImageListArray
}

TV_Load(TVList) {

  ;ListVars

  Gui, MyGui:Default

  GuiControl, -Redraw, MyTreeView

  ImageListArray := IL_Load(TVList)
	ID := []
  ExpandArray := []
  TopLevel=

	Loop, parse, TVList, `n, `r
	{

		if (A_LoopField = "")
			continue

    Gosub IncrementProgress

    Split := StrSplit(A_LoopField, ",")
    Level       := Split.1
    Item        := Split.2

    if (TopLevel = "")
      TopLevel := Level

    SplitPath, Item, , , ext

    IconID := ImageListArray[ext]
 
    if (Level = TopLevel ) {
			ID[Level] := TV_Add(Item, IconID)
    } else {
			ID[Level] := TV_Add(Item, ID[Level-1], IconID)
    }

	}

  ID := ""
  GuiControl, +Redraw, MyTreeView
}

GetDefaultIconforExt(ext) {
    RegRead, ThisExtClass, HKEY_CLASSES_ROOT, .%ext%
    RegRead, ThisExtDefaultIcon, HKEY_CLASSES_ROOT, %ThisExtClass%\DefaultIcon
    ThisExtDefaultIcon := StrReplace(ThisExtDefaultIcon, """")
    if (ThisExtDefaultIcon = "%1")
      ThisExtDefaultIcon := ""
    Return ThisExtDefaultIcon
}

^NumPadAdd::
  TV_ModifyAll("Expand")
Return

^NumPadSub::
  TV_ModifyAll("-Expand")
Return

F1::
  Msg := "Escape = ExitApp`n`nF1 = Help`n`nNumPadAdd = Expand`n`nNumPadSub = -Expand`n`n"
      . "Modify All = Toggle Bold/Check/Expand"
  MsgBox, 0x40, %GuiTitle% Help, % Msg
Return

GuiClose:
GuiEscape:
  Gui, Destroy
  ExitApp
Escape::ExitApp
