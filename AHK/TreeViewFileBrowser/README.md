# TreeViewFileBrowser

An example for AHK_L v1

# Scripts
TreeView_FileBrowser_Single.ahk   - Single pane, folders and file    
TreeView_FileBrowser_Double.ahk   - Double pane, folders on left, files on right    
TreeView_Recurse_Example.ahk      - RecurseTreeView()  

## About
Examples of a TreeView File Browser
Features simplified Save/Load format for unlimited TreeView Levels  
Includes icons and options: bold, check, expand  

## Usage
Run the script to see an example: Single pane, folders and file    
Press F1 for Help  
Press Save, then Clear, then Load  
Examine the saved text file  

## Legal
Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>

## Credits
Learning one:  
https://autohotkey.com/board/topic/92863-function-createtreeview/  

robertcollier4:  
https://autohotkey.com/board/topic/92147-real-challenge-using-explorers-icon-of-a-file-in-gui/ 

icuurd12b42: Treeview Branch Item Recursion Loop  
https://www.autohotkey.com/boards/viewtopic.php?t=36879  

animeaime  
https://autohotkey.com/board/topic/39659-func-autobyteformat-convert-bytes-to-byteskbmbgbtb/

##  Save/Load Format
See: TreeView_FileBrowser_Single_Save_Example.txt  
(indents manually added below for clarity)  

    "Level, Folder or filename.ext, ItemID, Options"

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