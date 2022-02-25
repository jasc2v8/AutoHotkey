#NoEnv
; #Warn
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
ListLines, Off
; ==================

#Include <AHKEZ>
#Include <Class_CustomObject>
#Include <AHKEZ_UnitTest>
#Include <AHKEZ_Debug>

;** START TEST

T := New UnitTest
T.SetOptions("Debug")
DEBUG := T.GetOption("Debug") ;DEBUG := True

/*
  ;PROPERTIES

  NameValueSeparator

  ;METHODS

  [index]                   ;Return = String at [index]
  Add(String)               ;Return = Index
  AddStrings(StringList)
  Append(String)            ;Return = n/a
  Clear()
  Count()
  Delete(Index)
  IndexOf(String)
  IndexOfName(String)
  LoadFromFile(Filename)
  SaveToFile(Filename)
  Push()
  Pop()
  Sort()
  Value(Name)                ;Return = value part of name-value
  
*/

;T.Assert(A_ScriptName, A_Linenumber, True , v)
 ;T.Assert(A_ScriptName, A_Linenumber, True, False)
 
Test_Strings_Add:
  SL      := New StringList
  SLPairs := New StringList

  array := ["one", "two", "three"]
  ;ListArray(1,"before Add",SL)
  SL.AddStrings(array)
  ListArray(1,"after Add",SL)
  v := SL[1]
  T.Assert(A_ScriptName, A_Linenumber, v, "one")


  arrayPairs  := ["MyClass:C|MyScript.ahk|0001|0", "MyFunction:F|MyScript.ahk|0002|0", "MyGlobal:G|MyScript.ahk|0003|3.14"]
  SLPairs.AddStrings(arrayPairs)
  ;ListArray(1,"after Add to SLPairs",SLPairs)

  SL.LoadFromFile("StringList_String.txt")
  ListArray(1,"SL.LoadFromFile",SL)
  SL.SaveToFile("StringList_String_Save.txt")

  SLPairs.LoadFromFile("StringList_NameValue.txt")
  ListArray(1,"SLPairs.LoadFromFile", SLPairs)
  SLPairs.SaveToFile("StringList_NameValue_Save.txt")


  ;ListArray(1,"before Value",SLPairs)
  v := SLPairs.Value("MyFunction")
  ListVars(1,"Value", v)

  ;SL.CommaText("+HWNDhGUI, +Resize, +AlwaysOnTop")
  ;text := SL.Text()
  ;DB(1,"List", Text)

  ;SL[1] := "one", SL[2] := "two", SL[3] := "three"
  ;MB(0,,SL[1])
  ;Listproperties(1,,SL[1], SL[2], SL[3])

  SL.Push("more")
  ListArray(1,"after Push",SL)

  v := SL.Pop()
  ListArray(1,"after Pop",SL)
  MB(,"Pop", "v=" v)
   
  SL.Add("four")
  ListArray(1,"after Add",SL)


  MB(,"IndexOf", "IndexOf=" SL.IndexOf("two"))

  MB(,"IndexOfName", "IndexOfName=" SLPairs.IndexOfName("MyGlobal"))


  MB(,"Class Properties", "Count=" SL.Count() "`n`nNameValueSeparator=" SL.NameValueSeparator)

  ListArray(1,"before Delete",SL)
  SL.Delete(2)
  ListArray(0,"after Delete?",SL)

  ListArray(0,"before Clear",SL)
  SL.Clear()
  ;SL.Add("five")
  ListArray(0,"after Clear",SL)


  ;SL.NameValueSeparator := "|"
  ;ListVars(1,,SL.IndexOf("two"), SL.Count(), SL.NameValueSeparator)

Test_NAME_VALUE:





  GoSub FreeMemory
  ExitApp

  ; Loop, % SL.Count()
  ; {
  ;   MB(,"List", SL.IndexOf(A_Index))
  ; }

Escape::
FreeMemory:
SL := ""
SLPairs := ""
ExitApp
