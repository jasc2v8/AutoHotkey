/*
  Hotkeys active only if Notepad is active (change to your game title)
  Press Ctrl-r to reset
  Press r to toggle autorun on/off
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

Gosub DoInit
Return

KeyDownTimer:
  Send {%CurrentKey% Down}
  Gosub ShowToolTip
return

ShowToolTip:
  Switch CurrentKey
  {
    Case "" : State := "  OFF  "
    Case "w": State := "FORWARD"
    Case "s": State := "  REVERSE "
  }
  WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_class Notepad
  ToolTipX := WinWidth - 100
  ToolTipY := WinHeight / 10
  ToolTip, % State, % ToolTipX, % ToolTipY
Return

DoInit:
  SetTimer, KeyDownTimer, Off
  TimerOn := False 
  SaveKey := "w"
  CurrentKey := ""
  Gosub ShowToolTip
Return

DoReset:
  Gosub DoInit
  SoundBeep
Return

Escape::
  ToolTip
  ExitApp
Return

#IfWinActive ahk_class Notepad

^r::
  Gosub DoReset
Return

~r::
  AutoRun := !AutoRun
  if (AutoRun) {
    SetTimer, KeyDownTimer, % Duration
    TimerOn := False
    CurrentKey := SaveKey
    Gosub ShowToolTip
  } else {
    Gosub DoInit
  }
Return

~w::
~s::
  if (!AutoRun)
    Return
  CurrentKey := StrReplace(A_ThisHotkey, "~")
  ;Optional depending on your environment: KeyWait, %CurrentKey%, T0.5 
  SetTimer, KeyDownTimer, % (TimerOn:=!TimerOn) ? Duration : "Off"
  Sleep % Duration
  if !TimerOn
    Send {%CurrentKey% Up}
Return

