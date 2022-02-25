/*
  Title:  TreeView_FileBrowser_Single.ahk
  About:  An example of a TreeView File Browser in a single pane
          Features simplified Save/Load format for unlimited TreeView Levels
          Includes icons and options: bold, check, expand
  Usage:  Run the script to see an example
          Press F1 for Help
          Press Save, then Clear, then Load
          Examine the saved text file
  Legal:  Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
  Credits to:
    Learning one:
    https://autohotkey.com/board/topic/92863-function-createtreeview/

    robertcollier4
    https://autohotkey.com/board/topic/92147-real-challenge-using-explorers-icon-of-a-file-in-gui/ 

    icuurd12b42
    https://www.autohotkey.com/boards/viewtopic.php?t=36879

  Save/Load Format: TreeView_FileBrowser_Single_Save_Example.txt
  (indents manually added below for clarity)

    "Level, Folder or filename.ext, ItemID, Options"
      0001,Level1A,BCE
        0002,Level2,BCE
          0003,Level3,BCE
            0004,Level4,BCE
              0005,Level5,BCE
                0006,Level6,BCE
                  0007,Level6.txt,BC
                0006,Level5.txt,BC
              0005,Level4.txt,BC
            0004,Level3.txt,BC
          0003,Level2.txt,BC
        0002,Level1.txt,BC
      0001,Level1B,BCE
        0002,Level2,BCE
          0003,Level3,BCE
            0004,Level3.txt,BC
          0003,Level2.txt,BC
        0002,Level1.txt,BC
      0001,Level1C,BCE
        0002,Level2,BCE
          0003,Level3,BCE
            0004,Level3.txt,BC
          0003,Level2.txt,BC
        0002,Level1.txt,BC
      0001,Root.txt,BC

    The icon loaded in the TreeView is the Windows default for the file extension  
*/

#NoEnv
; #Warn
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
ListLines, Off
#SingleInstance, Force

Global TVArray := []
Global SBReadyText := "Ready. Press F1 for Help."
Global ModifyAllFlag := False

AutoExec_Section:

  SplitPath, A_ScriptFullPath, FileName, Dir, Ext, NameNoExt
  TVFile := Dir "\" NameNoExt "_Save.txt"
  FileDelete, % TVFile

  GuiTitle := "My TreeView Single Pane"

  ProgressIndex := 0
  ProgressMax := 1000

  Gui, MyGui:New, +Resize
  Gui, Font, s10, Consolas
  Gui, Add, Button, w80, Save Tree
  Gui, Add, Button, x+m w80, Clear
  Gui, Add, Button, x+m w80, Load Tree
  Gui, Add, Button, x+m w100, Load Folder
  Gui, Add, Button, x+m w100, Modify All
  Gui, Add, TreeView, xm w400 h480 Checked vMyTreeView
  Gui, Add, StatusBar
  SB_SetIcon("Shell32.dll", 222) 
  Gui, Add, Progress, w400 h25 cBlue vMyProgress Range0-%ProgressMax%
  Gui, Show, AutoSize, %GuiTitle%

  Folder := "..\Examples\RootFolder" ; A_Desktop

  Gosub LoadTreeView

  Gosub MyGuiButtonModifyAll

Return

TV_ModifyAll(Option := "Expand")	
{
  Global TVArray
  Gui, MyGui:Default
	GuiControl, -Redraw, MyTreeView
  for key, Value in TVArray {
    Split := StrSplit(Value, ",")
    Level   := Split.1 ;not used
    File    := Split.2 ;not used
    ItemID  := Split.3 ;used
    Options := Split.4 ;not used
	  TV_Modify(ItemID, Option)
  }
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
  SB_SetText(SBReadyText)
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

MyGuiButtonSaveTree:
  Global IDArray
  Gui, MyGui:Default
  MyList=
  for key, Value in TVArray {
    Split := StrSplit(Value, ",")
    Level       := Split.1
    Item        := Split.2
    ItemID      := Split.3

    Options=
    Options .= TV_Get(ItemID, "B") ? "B" : ""
    Options .= TV_Get(ItemID, "C") ? "C" : ""
    Options .= TV_Get(ItemID, "E") ? "E" : ""

    MyList .= Level "," Item "," Options "`n"
  }
  FileDelete, % TVFile
  FileAppend, % MyList, % TVFile
  SB_SetText("Saved to: " TVFile)
Return

MyGuiButtonClear:
  if !FileExist(TVFile) {
    SoundBeep
    SB_SetText("Please SAVE before clearing.")
    Return
  }
  TV_Delete()
  SB_SetText(SBReadyText)
Return

MyGuiButtonLoadTree:
  if !FileExist(TVFile) {
    SoundBeep
    SB_SetText("Please SAVE before LOADing.")
    Return
  }
  SB_SetText("Loading: " Folder)
  FileRead, TVList, % TVFile
  ProgressIndex := 0
  Gosub ShowProgress
  TV_Delete()
  TV_Load(TVList)
  Gosub HideProgress
  SB_SetText(SBReadyText)
Return

MyGuiButtonLoadFolder:
  Gui, +OwnDialogs
  FileSelectFolder, Folder, *%A_ScriptDir%, (1+4), Choose Folder
  if !FileExist(Folder)
    Return
  TV_Delete()
  TVList=
  Gosub LoadTreeView
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

;In:  Folder to recurse
;Out: Level, Filename
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

;In:  Level, Filename.exe
;Out: ImageListArray[ext] := IconID
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

;In:  Level, Item, Options
;Out: Level, Item, ItemID, Options
TV_Load(TVList) {
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
    Options     := Split.3

    if (TopLevel = "")
      TopLevel := Level

    SplitPath, Item, , , ext

    IconID := ImageListArray[ext]
 
    if (Level = TopLevel ) {
			ID[Level] := TV_Add(Item, IconID)
    } else {
			ID[Level] := TV_Add(Item, ID[Level-1], IconID)
    }

    Loop, Parse, Options
    {
      Switch A_LoopField
      {
        Case "B":
          Option := "Bold"
        Case "C":
          Option := "Check"
        Case "E":
          ExpandArray.Push(ID[Level])
        Default:
          Option := ""
      }
      TV_Modify(ID[Level], Option)
    }

    for key, ItemID in ExpandArray
      TV_Modify(ItemID, "Expand")
    
    TVArray.Push(Level "," Item "," ID[Level] "," Option)
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
  . "Save Tree = Save to File`n`nClear = Clear TreeView`n`nLoad Tree = Load from File`n`n"
  . "Load Folder = Select Folder to load in TreeView`n`n"
  . "Modify All = Toggle Bold/Check/Expand"
  MsgBox, 0x40, %GuiTitle% Help, % Msg
Return

GuiClose:
GuiEscape:
  Gui, Destroy
  ExitApp
Escape::ExitApp
