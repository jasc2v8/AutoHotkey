/*
  Hotkeys active only if Notepad is active (change to your game title)
  Press w to autorun forward
  Press s to autorun backward
  Press w or s again to stop
  Press r to toggle autorun on/off

*/
#NoEnv
; #Warn
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
ListLines, Off
#SingleInstance, Force
#KeyHistory, 0

Duration := 33

#IfWinActive ahk_class Notepad

~r::
  AutoRun := !AutoRun
  if (!AutoRun) {
    SetTimer, wKey, Off
    wT := False
    SetTimer, sKey, Off
    sT := False
  }
Return

~w::

  if (!AutoRun)
    Return
  
  SetTimer, sKey, Off
  sT := False
  
  SetTimer, wKey, % (wT:=!wT) ? Duration : "Off"
  Sleep % Duration
  if !wT
    Send {w Up}
return

~s::
  if (!AutoRun)
    Return
    
  SetTimer, wKey, Off
  wT := False
  
  SetTimer, sKey, % (sT:=!sT) ? Duration : "Off"
  Sleep % Duration
  if !sT
    Send {s Up}
return

wKey:
  Send {w Down}
return

sKey:
    Send {s Down}
return

Escape::ExitApp


