/*
  Hotkeys active only if Notepad is active (change to your game title)
  Press w to autorun forward
  Press s to autorun backward
  press w or s again to stop

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

~w::

  SetTimer, sKey, Off
  sT := False
  
  SetTimer, wKey, % (wT:=!wT) ? Duration : "Off"
  Sleep % Duration
  if !wT
    Send {w Up}
return

~s::

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

