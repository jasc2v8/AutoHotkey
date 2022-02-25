#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance, Force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
; ==================

#Include <AHKEZ>

/*
	Name:		class_TestUnit
	About:	Simple test framework for AutHotkey V1
	Notes:	Instantiated as a class:
					T := New TestUnit(ScriptName, Options)
*/

Class TestUnit {

	;SN = The script name from which the Assert was called
	;LN = The script line number from which the Assert was called
	;IS = The result "is"
	;SB = The result "should be"

		;__New(ScriptName = "", Options = "") { ;no need for this?

		__New(Options = "") {

			;no whitespace allowed IsIn() Matchlist: https://regex101.com/r/7Fe7zA/1
			Options := RegExReplace(Options, "(\s*[,|\s]\s*)", ",")
			
			this.IniFile := JoinPath(A_Temp, "TestUnit.ini")
			this.LogFile := JoinPath(A_Temp, "TestUnit.log")

			this.ErrorCount := 0
			this.StartTick := 0
			this.NL := "`r`n"

			/*
				Options must be implicit else no changes
				Run_Tests will set OptLog, OptMsg
				Test_Script won't change options unless implicit
			*/

			this.OptLog := IniRead(this.IniFile, "OPTIONS", "OptLog", True)
			this.OptMsg := IniRead(this.IniFile, "OPTIONS", "OptMsg", True)

			this.OptLog := IfIn("-Log", Options) ? False : this.OptLog
			this.OptMsg := IfIn("-Msg", Options) ? False : this.OptLog

			;MB(0,"NEW", "this.OptLog =" this.OptLog ", LogFile=" this.LogFile)

			IniWrite(this.OptLog, this.IniFile, "OPTIONS", "OptLog")
			IniWrite(this.OptMsg, this.IniFile, "OPTIONS", "OptMsg")

		}
	
	Run(ScriptFileList) {

		;MB(0,"RUN", ScriptFileList)

		this.Begin(ScriptFileList, True)

		;MB(0,"RUN return", ScriptFileList)

	}

	Begin(ScriptFileList, EndFlag := False) {

		;MB(0,"BEGIN", ScriptFileList)

		if (this.OptLog)
			this.OpenLog()
	
		Loop, Parse, ScriptFileList, `n, `r
		{
			if StrIsEmpty(A_LoopField)
				Continue

			;MB(0,"RUN", A_LoopField)

			;TODO change to absolute path if run_tests can choose folder?
			RunWait(JoinPath(A_ScriptDir, A_LoopField))
		}
		if (EndFlag)
			this.End()
	}

	End(Text = "End Tests") {
		if (this.OptLog)
			this.CloseLog()
		if (this.opt,Msg) And !StrIsEmpty(Text)
			MB(0x40, Text)
	}

	Log(Text) {		
		if (this.OptLog)
			FileAppend(Text . this.NL, this.LogFile)
	}
	
	OpenLog() {
		;OpenLog(LogFile := this.LogFile) {
		if (this.OptLog) {
			FileDelete(this.IniFile)
			FileDelete(this.LogFile)
			this.Log("Start Time : " . FormatTime(A_Now, "yyyy-MM-dd_HH:mm:ss"), True)
			;IniWrite(this.ErrorCount, this.IniFile, "DEFAULT", "ERROR_COUNT")
		}
		this.StartTick := A_TickCount
	}
	
	CloseLog() {
		if (this.OptLog) {
			this.Log("End Time   : " . FormatTime(A_Now, "yyyy-MM-dd_HH:mm:ss"), True)
			this.Log("Elapsed    : " . A_TickCount - this.StartTick . " ms", True )
			;n := IniRead(this.IniFile, "DEFAULT", "ERROR_COUNT", -1)
			;this.Log("Error Count: " n)
			List := IniRead(this.IniFile, "ASSERT_FAIL")
			List := StrReplace(List,"=")
			if StrIsEmpty(List)
				this.Log("FAIL List  : NONE")
			if !StrIsEmpty(List)
				this.Log("FAIL List  :" this.NL List)
			List := IniRead(this.IniFile, "ASSERT_PASS")
			List := StrReplace(List,"=")
			if !StrIsEmpty(List)
				this.Log("PASS List  :" this.NL List)
		}
	}

	EditLog() {
		if (this.OptLog) {
			RunWait(this.LogFile)
		}
	}

	Assert(SN, LN, IS, SB) {
		msg := Join(2, A_Space) "Assert: " . FormatTime(A_Now, "yyyy-MM-dd_HH:mm:ss") . ", " . SN
		if (IS != SB) {
			this.ErrorCount++
			v := ""
			. "Script Name:`n" SN Join(2,this.NL)
			. "Line Number:`n" LN Join(2,this.NL)
			. "Result Is:`n" IS Join(2,this.NL)
			. "Result Should Be:`n"Join(2,this.NL)
			if (this.OptMsg)
				MsgBox 0, TestUnit FAIL, %v%
			if (this.OptLog) {
				IniWrite(, this.IniFile, "ASSERT_FAIL", "_" SN "_" LN)
			}
		} else {
			if (this.OptLog)
				IniWrite(, this.IniFile, "ASSERT_PASS", "_" SN)
		}
	}
	
	Exist(Text := "") {
		if !StrIsEmpty(Text)
			MB(0x40, "Class TestUnit Exists", Text)
		Return True
	}
}
