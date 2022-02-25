#NoEnv
; #Warn
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
ListLines, Off
; ==================

#Include <AHKEZ>
;#Include <Class_StringList>
#Include %A_ScriptDir%\..\src\Class_StringList.ahk

#Include <AHKEZ_Debug>

;Gosub Example_Init

SL := New StringList
SL.Add("One,Two,Three,Nine")
SL.AddArray(["Four:Apple", "Five:Banana", "Six:Cherry"])
SL.AddCSV("One,Two,Three,Nine")
SL.AddCSV("Seven:7, Five:Banana, Eight:8")
SL.AddArray(["Nine:9", "Five:Banana", "Ten:10"])
;SL := New StringList("One")
;SL := New StringList(["One", "Two", "Three"])
ListArray(1,"after Add String", SL)


;CaseSensitive default = False
MB(,"Property", "CaseSensitive=" SL.CaseSensitive)
MB(,"IndexOf", "IndexOf=" SL.IndexOf("two"))

SL.CaseSensitive := True
MB(,"Property", "CaseSensitive=" SL.CaseSensitive)
MB(,"IndexOf", "IndexOf=" SL.IndexOf("three"))


Gosub FreeMemory
;Return

Gosub Example_Init
Gosub Example_Add
Gosub Example_FromFile1
Gosub Example_FromFile2
Gosub Example_Dups_String
Gosub Example_Dups_Array
Gosub FreeMemory
Return

;T.Assert(A_ScriptName, A_Linenumber, True , v)
 ;T.Assert(A_ScriptName, A_Linenumber, True, False)
Example_Init:
  SL      := New StringList
  array := ["One", "Two", "Three"]
  arrayPairs  := ["Four:Apple", "Five:Banana", "Six:Cherry"]
Return

Example_Dups_String:
  SL := ""
  SL := New StringList
  SL.Add("One:Apple")
  SL.Add("Two:Banana")
  SL.Add("Two:Banana")
  SL.Add("Three:Cherry")
  SL.Add("Four:Date")
  ListArray(1,"If String then Dups Allowed",SL)

  SL := ""
  SL := New StringList
  SL.AddString("One")
  SL.AddString("Two")
  SL.AddString("Two")
  SL.AddString("Three")
  SL.AddString("Four")
  ListArray(1,"If String then Dups Allowed",SL)
return

Example_Dups_Array:
  SL := ""
  SL := New StringList(["One", "Two", "Two", "Three"])
  SL.Add("Two")
  SL.Add("Four")
  ListArray(1,"If String then Dups Allowed",SL)

  SL := ""
  SL := New StringList(["Four:Apple", "Five:Banana", "Six:Cherry"])
  SL.Add("Five:Banana")
  SL.Add("Six:Date")
  ListArray(1,"If Name:Value then Dups Not Allowed",SL)

Return

Example_Add:
  ListArray(1,"before Add String",SL)
  SL.Add("My String 1"), SL.Add("My String 2"), SL.Add("My String 3")
  n := SL.Add("My String 4")
  MB("index=" n)
  ListArray(1,"after Add String", SL)

  ListArray(1,"before Add Array",SL)
  SL.Add(array)
  ListArray(1,"after Add Array", SL)

  ListArray(1,"before Add Name:Value Pairs",SL)
  SL.Add(arrayPairs)
  ListArray(1,"after Add Name:Value Pairs", SL)
Return

Example_FromFile1:
  if SL.Count() = 0
    MB(0x10, "ERROR NO DATA", "Run Example_Add first.")

  SL.SaveToFile("SaveToFile.txt")
  SL.Clear()
  ListArray(1,"Before LoadFromFile",SL)
  SL.LoadFromFile("SaveToFile.txt")
  ListArray(1,"After LoadFromFile",SL)
Return

Example_FromFile2:
  SL.LoadFromFile("String.txt")
  ListArray(1,"SL.LoadFromFile",SL)
  SL.SaveToFile("String_Save.txt")

  SLPairs.LoadFromFile("NameValue.txt")
  ListArray(1,"SLPairs.LoadFromFile", SLPairs)
  SLPairs.SaveToFile("NameValue_Save.txt")
Return



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
