/*
  Title:  TreeView_FileBrowser_Double.ahk
  About:  An example of a TreeView File Browser in a double pane
  Usage:  Run the script to see an example
          Press F1 for Help
  Legal:  Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
  Credits to:
    Learning one:
    https://autohotkey.com/board/topic/92863-function-createtreeview/

    robertcollier4
    https://autohotkey.com/board/topic/92147-real-challenge-using-explorers-icon-of-a-file-in-gui/ 

    icuurd12b42: Treeview Branch Item Recursion Loop
    https://www.autohotkey.com/boards/viewtopic.php?t=36879

    animeaime
    https://autohotkey.com/board/topic/39659-func-autobyteformat-convert-bytes-to-byteskbmbgbtb/

  Save/Load Format: TreeView_FileBrowser_Single_Save_Example.txt
  (indents manually added below for clarity)

    "Level, Folder or filename.ext, ItemID, Options"
      0001,Level1A,61662592,BCE
        0002,Level2,61662368,BCE
          0003,Level3,61665728,BCE
            0004,Level4,61662816,BCE
              0005,Level5,61663824,BCE
                0006,Level6,61665616,BCE
                  0007,Level6.txt,61665280,BC
                0006,Level5.txt,61662704,BC
              0005,Level4.txt,61663376,BC
            0004,Level3.txt,61664496,BC
          0003,Level2.txt,61662480,BC
        0002,Level1.txt,61663488,BC
      0001,Level1B,61661920,BCE
        0002,Level2,61663712,BCE
          0003,Level3,61665056,BCE
            0004,Level3.txt,61664048,BC
          0003,Level2.txt,61665504,BC
        0002,Level1.txt,61662928,BC
      0001,Level1C,61663040,BCE
        0002,Level2,61664272,BCE
          0003,Level3,61664608,BCE
            0004,Level3.txt,61664832,BC
          0003,Level2.txt,61664720,BC
        0002,Level1.txt,61664944,BC
      0001,Root.txt,61766672,BC

    The icon loaded in the TreeView is the Windows default for the file extension    
*/

#NoEnv
; #Warn
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
ListLines, Off
#SingleInstance, Force

AutoExec_Section:

  Global SelectedFullPath
  Global ImageListID, ImageListArray

  ;The following folder will be the root folder for the TreeView.
  ;Note that loading might take a long time if an entire drive such as C:\ is specified
  TreeRoot := "..\Examples\RootFolder" ; A_Desktop

  TreeViewWidth := 180
  ListViewWidth := TreeViewWidth * 4.1

  GuiTitle := "My TreeView Double Pane"

  Gui +Resize
  Gui, Font, , Consolas
  Gui, Add, TreeView, vMyTreeView r20 w%TreeViewWidth% gMyTreeViewHandler ImageList%ImageListID%
  Gui, Add, ListView, vMyListView r20 w%ListViewWidth% gMyListViewHandler x+10, Name|     Modified|     Size
  Gui, Add, StatusBar
  SB_SetParts(80, 80)
  SB_SetIcon("Shell32.dll", 222)

  SplashTextOn, 200, 50, , Loading Files...

  TVList := GetTVList(TreeRoot)
  TV_Load(TVList)

  SplashTextOff

  Gui, Show,, %GuiTitle%
Return

GetTVList(Folder, Level=0)
{
  MyList=
 Level++
 Loop, %Folder%\*.*, 1 ; 1=all files and folders
 {
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

  GuiControl, -Redraw, MyTreeView

  ImageListArray := IL_Load(TVList)

  ID := []

  Loop, parse, TVList, `n, `r
  {

    if (A_LoopField = "")
    continue

    Split := StrSplit(A_LoopField, ",")
    Level       := Split.1
    Item        := Split.2

    SplitPath, Item, , , ext

    ;show folders only
    if (ext != "")
      Continue

    IconID := ImageListArray[ext]

    if (Level = 1 ) {
      ID[Level] := TV_Add(Item, 0, IconID)
    } else {
      ID[Level] := TV_Add(Item, ID[Level-1], IconID)
    }
  }
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

;converts Size (in bytes) to byte(s)/KB/MB/GB/TB (uses best option)
;decimalPlaces is the number of decimal places to round
FormatFileSize(size, decimalPlaces = 2)
{
  static size1 = "KB", size2 = "MB", size3 = "GB", size4 = "TB"
  sizeIndex := 0
  while (size >= 1024)
  {
    sizeIndex++
    size /= 1024.0
    if (sizeIndex = 4)
      break
  }
  v := (sizeIndex = 0) ? size " byte" . (size != 1 ? "s" : "") : round(size, decimalPlaces) . " " . size%sizeIndex%
  Return Format("{:10}", v)
}

MyListViewHandler:
  if (A_GuiEvent = "DoubleClick")
  {
    LV_GetText(Filename, A_EventInfo)
    ;ToolTip You double-clicked row number %A_EventInfo%. Text: "%RowText%"
    FileFullPath := SelectedFullPath "\" Filename
    if FileExist(FileFullPath)
      RunWait % FileFullPath
  }
Return

MyTreeViewHandler:
  if (A_GuiEvent != "S")
      return
  ; First determine the full path of the selected folder:
  TV_GetText(SelectedItemText, A_EventInfo)
  ParentID := A_EventInfo
  ; Build the full path to the selected folder.
  Loop
  {
    ParentID := TV_GetParent(ParentID)
    if not ParentID  ; No more ancestors.
      break
    TV_GetText(ParentText, ParentID)
    SelectedItemText := ParentText "\" SelectedItemText
  }
  SelectedFullPath := TreeRoot "\" SelectedItemText

  ; Put the files into the ListView:
  LV_SetImageList(ImageListID)
  LV_Delete()
  GuiControl, -Redraw, MyListView
  FileCount := 0
  TotalSize := 0
  Loop %SelectedFullPath%\*.*  ; Omit folders so that only files are shown in the ListView.
  {
    FormatTime, Date, A_LoopFileTimeModified, M/d/y h:m tt
    SplitPath, A_LoopFileName, , , ext
    IconID := ImageListArray[ext]
    LV_Add(IconID, A_LoopFileName, Format("{:20}", Date), FormatFileSize(A_LoopFileSize))
    FileCount += 1
    TotalSize += A_LoopFileSize
  }
  Loop, 3
    LV_ModifyCol(A_Index, "AutoHdr")

  GuiControl, +Redraw, MyListView

  SB_SetText(FileCount . " files", 1)
  SB_SetText(FormatFileSize(TotalSize), 2)
  SB_SetText(SelectedFullPath, 3)
Return

GuiSize:
if (A_EventInfo = 1)
    return
GuiControl, Move, MyTreeView, % "H" . (A_GuiHeight - 30)
GuiControl, Move, MyListView, % "H" . (A_GuiHeight - 30) . " W" . (A_GuiWidth - TreeViewWidth - 30)
return

GuiClose:
ExitApp

Escape::ExitApp