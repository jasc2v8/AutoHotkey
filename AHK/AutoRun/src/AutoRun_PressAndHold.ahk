/*
	Overview
  --------
	w/s/a/d = forward/backward/left/right
	Press w and hold for 2 seconds to autorun forward
	Press s and hold for 2 seconds to autorun backward
  Press w or s to stop autorun
  Press Space to Toggle Autorun On/Off
	
*/

#NoEnv
; #Warn
SendMode Input ;system dependent
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
ListLines, Off
#SingleInstance, Force
#KeyHistory, 0
#Persistent

#IfWinActive ahk_class Notepad

;AutoRun Toggle On/Off
~Space::
  AutoRunEnabled := !AutoRunEnabled
  KeyWait, Space, T0.5  ;Wait for key to be physically released.
  Send {%MyKey% Up}
  if (AutoRunEnabled) {
    State := "AutoRun"
    SoundBeep, 250
    SoundBeep, 350
  } else {
    State := "  OFF  "
    Looping := False
    SoundBeep, 350
    SoundBeep, 250
  }
  GoSub ShowToolTipAutoRun
Return

~w::
~s::

  if (Looping) {
    Send {%MyKey% Up}
    Looping := False
    SoundBeep, 250
    Return
  }
  
  MyKey:=StrReplace(A_ThisHotkey, "~")

 	KeyWait, % MyKey, T2  ; 2 seconds 
	if (ErrorLevel) {
  
    Looping := True
    
    SoundBeep, 250
    SoundBeep, 250
    
    if (MyKey = "w") {
      State := "Forward"
    } else {
      State := "Reverse"
    }
      
    Gosub ShowToolTipAutoRun
      
    While (Looping)
    {
      Send {%MyKey% Down}
      Sleep 100
    }
    Send {%MyKey% Up}
    State := "PAUSED"
    GoSub ShowToolTipAutoRun
  }
Return

ShowToolTipAutoRun:
  WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_class Notepad
  ToolTipX := WinWidth - 100
  ToolTipY := WinHeight / 10
  ToolTip, % State, % ToolTipX, % ToolTipY
Return

Escape::ExitApp