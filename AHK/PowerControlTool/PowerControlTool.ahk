/*
  Power Control Tool
  Gui with buttons to:
    Sleep, Sign-Out Shutdown
    Restart, Restart to UEFI, Restart to PE
    Display Off, Settings, Cancel
*/

#NoEnv
; #Warn
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
ListLines, Off
#SingleInstance, Force
#Persistent

GuiTitle := "Power Control Tool v1"

;@Ahk2Exe-SetDescription %A_ScriptName~\.[^\.]+$~%
;@Ahk2Exe-SetProductName %A_ScriptName~\.[^\.]+$~%
;@Ahk2Exe-SetVersion 1.0.0.0

; Tray Menu
Menu, Tray, Add
Menu, Tray, Add, Gui Show, DoCreateGui
Menu, Tray, Default, Gui Show
Menu, Tray, Click, 1
Gosub, DoCreateGui
Return

; Hot Key to reload script: Ctrl-Alt-Shift-Delete

^!+Del::
Reload
SoundBeep
return

; Functions

DoCreateGui:
Gui, New, -MaximizeBox -MinimizeBox, %GuiTitle%
Gui, Font, s14
Gui, Add, Button, w150 xm, Sleep
Gui, Add, Button, w150 x+m, Sign-Out
Gui, Add, Button, w150 x+m, Shutdown
Gui, Add, Button, w150 y+10 xm, Restart
Gui, Add, Button, w150 x+m, Restart to UEFI
Gui, Add, Button, w150 x+m, Restart to RE
Gui, Add, Button, w150 y+10 xm , Display Off
Gui, Add, Button, w150 x+m, Settings
Gui, Add, Button, w150 x+m, Cancel
Gui, Show
Return

ButtonDisplayOff:
  MsgBox 0x24, %GuiTitle%, Display Off - Are you sure?
  IfMsgBox No
    Return
  SendMessage,0x112,0xF170,2,,Program Manager
Return

ButtonSettings:
  RunWait "ms-settings:powersleep"
Return

ButtonSleep:
  MsgBox 0x24, %GuiTitle%, Sleep - Are you sure?
  IfMsgBox No
    Return
  Gui, Hide
  DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
Return

ButtonSign-Out:
  MsgBox 0x24, %GuiTitle%, Sign-Out - Are you sure?
  IfMsgBox No
    Return
  Gui, Hide
  Shutdown, 0 ;0 = Logoff, 1 = Shutdown, 2 = Reboot, 4 = Force, 8 = Power down
Return

ButtonShutdown:
  MsgBox 0x24, %GuiTitle%, Shutdown - Are you sure?
  IfMsgBox No
    Return
  Gui, Hide
  Shutdown, 1+4 ;0 = Logoff, 1 = Shutdown, 2 = Reboot, 4 = Force, 8 = Power down
Return

ButtonRestart:
  MsgBox 0x24, %GuiTitle%, Restart - Are you sure?
  IfMsgBox No
    Return
  Gui, Hide
  Shutdown, 2+4 ;0 = Logoff, 1 = Shutdown, 2 = Reboot, 4 = Force, 8 = Power down
Return

ButtonRestartToUEFI:
  if A_IsAdmin {
    MsgBox 0x24, %GuiTitle%, Restart to UEFI  - Are you sure?
    IfMsgBox No
      Return
    Run, %ComSpec% /c "shutdown.exe /r /t 0 /fw"
    ExitApp
  }

  MsgBox 0x21, %GuiTitle%, Press OK to Restart as Admin`n`nThen Press the [Restart to UEFI] Button again. ;OK, Cancel
  IfMsgBox Cancel
    Return
  Run *RunAs "%A_ScriptFullPath%" /restart
  ExitApp
Return

ButtonRestartToRE:
  MsgBox 0x24, %GuiTitle%, Restart to Recovery Environment - Are you sure?
  IfMsgBox No
    Return
  Gui, Hide
  RunWait, %ComSpec% /c shutdown.exe /r /o /t 0
Return

ButtonCancel:
  Gui, Hide
Return

Escape::ExitApp