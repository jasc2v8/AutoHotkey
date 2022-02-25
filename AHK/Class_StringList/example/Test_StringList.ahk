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
#Include <AHKEZ_UnitTest>

T := New UnitTest
T.SetOption("Debug")

StringCaseSense, Off ; default is Off

Test_Init:
  String        := "Stallion"
  StringPair    := "Pony: Horse"

  Array         := ["one", "two", "three"]
  ArrayPair     := ["one:Dell", "two:IBM", "three:HPE"]

  ArrayCSV      := "Six, One, Two, Three, Nine"
  ArrayCSVPair  := "Sixty: Six, Seventy: Seven, Eighty: Eight"

  ArrayObj1     := {"Three": "Apple", "One": "Banana", "Two": "Cherry"}
  ArrayObj2     := Object("Six", "Apple", "Four", "Banana", "Five", "Cherry")

  ArrayText     := "Ten" . NL . "Eleven" . NL . "Twelve" . NL
  ArrayTextPair := "Not supported because text may contain colons" . NL

Test_Add_Array:
  SL := ""
  SL := New StringList
  index := SL.Add(Array)
  ;ListArray(1,"Add Array", SL)
  T.Assert(A_ScriptName, A_LineNumber, SL[2], "two")
  T.Assert(A_ScriptName, A_LineNumber, index, 3)

  SL := ""
  SL := New StringList
  index := SL.Add(ArrayPair)
  ;ListArray(1,"Add ArrayPair, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL["three"], "hpe")
  T.Assert(A_ScriptName, A_LineNumber, index, 3)

Test_Add_CSV:
  SL := ""
  SL := New StringList
  index := SL.Add(ArrayCSV)
  ;ListArray(1,"Add Array CSV, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL[5], "nine")
  T.Assert(A_ScriptName, A_LineNumber, index, 5)

  SL := ""
  SL := New StringList
  index := SL.Add(ArrayCSVPair)
  ;ListArray(1,"Add Array CSV, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL["eighty"], "eight")
  T.Assert(A_ScriptName, A_LineNumber, index, 3)

Test_Add_Object:
  SL := ""
  SL := New StringList
  index := SL.Add(ArrayObj1)
  ;ListArray(1,"Add ArrayObj1, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL["one"], "banana")
  T.Assert(A_ScriptName, A_LineNumber, index, 3)

  SL := ""
  SL := New StringList
  index := SL.AddObj(ArrayObj2)
  ;ListArray(1,"Add ArrayObj2, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL["six"], "apple")
  T.Assert(A_ScriptName, A_LineNumber, index, 3)

  Test_Add_String:

  SL := ""
  SL := New StringList
  index := SL.Add(String)
  ;ListArray(1,"Add String, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL[1], "stallion")
  T.Assert(A_ScriptName, A_LineNumber, index, 1)

  SL := ""
  SL := New StringList
  index := SL.Add(StringPair)
  ;ListArray(1,"Add StringPair, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL["pony"], "horse")
  T.Assert(A_ScriptName, A_LineNumber, index, 1)

Test_Add_Text:
  SL := ""
  SL := New StringList
  index := SL.Add(ArrayText)
  ;ListArray(1,"Add ArrayText", SL)
  T.Assert(A_ScriptName, A_LineNumber, SL[2], "eleven")
  T.Assert(A_ScriptName, A_LineNumber, index, 3)

  SL := ""
  SL := New StringList
  index := SL.Add(ArrayTextPair)
  ;ListArray(1,"Add TextPair, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL[1], RTrim(ArrayTextPair, " `r`n"))
  T.Assert(A_ScriptName, A_LineNumber, index, 1)

Test_Clear:
  ;ListArray(1,"Before Clear", SL)
  SL.Clear()
  ;ListArray(1,"After Clear, Count=" SL.Count(), SL)
  T.Assert(A_ScriptName, A_LineNumber, SL.Count(), 0)

Test_Delete:
  SL := ""
  SL := New StringList
  Loop, 5
  {
    SL.Add("Item " A_Index)
  }
  ;ListArray(1,"Before Delete Count=" SL.Count, SL)
  SL.Delete(3)
  ;ListArray(1,"After Delete Count=" SL.Count, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL.Count(), 4)

  ;Delete not valid for Object, use RemoveAt
  SL := ""
  SL := New StringList
  SL.Add(ArrayObj1)
  ListArray(1,"Before Delete Count=" SL.Count, SL)
  SL.Delete("two")
  ListArray(1,"After Delete Count=" SL.Count, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL.Count(), 3)
  

  Gosub FreeMemory
  Return

  SL := ""
  ListVars(1, "Count Obj", SL.Count(), SL.Length(), SL.MinIndex(), SL.MaxIndex(), SL.GetCapacity(), SL.GetCount())
  ListVars(1, "Count Obj Property", SL.Count)
  temp := []
  for k, v in SL
    temp.Push(v)
  ListVars(1, "Count Temp", temp.Count(), temp.Length(), temp.MinIndex(), temp.MaxIndex(), temp.GetCapacity())
  temp := ""

  SL := New StringList
  SL.Add(Array)
  ListVars(1, "Count Array", SL.Count(), SL.Length(), SL.MinIndex(), SL.MaxIndex(), SL.GetCapacity(), SL.GetCount())
  ListVars(1, "Count Array Property", SL.Count)

  ExitApp
  
  
  ;ListArray(1,"ObjRawSet", Array)  
  ;ObjRawSet(SL, "Ten", "Mustang")
  ;ListArray(1,"AddObj", SL)






SL.AddString("One")
SL.AddString("Three")
index := SL.Add("Four")
T.Assert(A_ScriptName, A_LineNumber, SL[2], "Three")
T.Assert(A_ScriptName, A_LineNumber, index, 3)

ListArray(1,"AddString", SL)
ListVars(1,"AddString Index", index)

;Delete removes key-value pairs, but leave blanks in the array
;RemoveAt removes values with integer keys, and doesn't leave blanks
Array := Object("One", "Apple", "Two", "Banana", "Three", "Cherry")
Array.Delete("two")
ListArray(1,"Delete", Array)
for k, v in Array
  MB("key: ," k ", value: " v )

Loop, 4
{
  MB("Loop: " A_Index ": " Array[A_Index])
}

;Array := {"3": "Apple", "1": "Banana", "2": "Cherry"}
;Array := {3: "Apple", 1: "Banana", 2: "Cherry"}
Array := {"Three": "Apple", "One": "Banana", "Two": "Cherry"}

;dups overwrite previous
Array := {"Three": "Apple", "One": "Banana", "Two": "Cherry", "One": "Grape"}

ObjRawSet(Array, "Ten", "Mustang")
ListArray(1,"ObjRawSet", Array)

;the array is auto sorted by key
for k, v in Array
  MB(,"for", k ", " v )

ListArray(1,"Before Sort", Array)
;sort is for numeric keys
;if you sort an array with string keys, they are replace by numeric keys
_Sort(Array)
ListArray(1,"After Sort", Array)

Array.Push("New Item")
ListArray(1,"Push", Array)

item := Array.Pop()
ListArray(1,"Pop", Array)
ListVars(1,"Pop", item)


Array := {"One": "Apple", "Two": "Banana", "Three": "Cherry"}
Array := Object("One", "Apple", "Two", "Banana", "Three", "Cherry")
Array := {1: "Apple", 2: "Banana", 3: "Cherry"}
ListArray(1,, Array)

Value := Array["Two"]
Value := Array[2]
MB(,"Value", Value)

;MB(,"HasKey", Array1.HasKey("three"))
MB(,"HasKey", Array.HasKey(3))

;MB(,"ObjRawGet", ObjRawGet(Array, "Three"))
MB(,"ObjRawGet", ObjRawGet(Array, 3))

ListArray(1,"Array", Array)
MB(,"Count", Array.Count())

;Array.Delete("three")
Array.Delete(3)
ListArray(1,"Delete", Array)

MB(,"Count", Array.Count())
MB(,"GetCapacity", Array.GetCapacity())


Array1 := ""
Array2 := ""
ExitApp

SL := New StringList
SL.AddObj(Array)
ListArray(1,"AddObj", Array)
MB(,"Obj 1", SL[1])
MB(,"Obj 2", SL["Two"])
MB(,"Obj 3", SL[3])
MB(,"Obj ?", SL[7])
MB(,"HasKey", SL.HasKey(3))

Value := ObjRawGet(SL, "Two")
MB(,"Value", Value)

s := "Apple" := "1:Apple"
s := "Apple, Banana, Cherry" := "1:Apple, 2:Banana, 3:Cherry"
s := "One:Apple, Two:Banana, Three:Cherry"
csv := "One", "Apple", "Two", "Banana" := "1:One, 2:Apple, 3:Two, 4:Banana"

f := "MyFunction:F|9999|0"

Array := Object("MyFunction", "F|9999|0", "Two", "Banana", "Three", ":Cherry")
Array := {"One": "Apple", "Two": "Banana", "Three": "Cherry"}
ListArray(1,, Array)

Array := Object("One", "Apple", "Two", "Banana", "Three", "Cherry")
ListArray(1,, Array)


;Gosub Example_Init

SL := New StringList
SL.Add(["Four:Apple", "Five:Banana", "Six:Cherry"])
ListArray(1,, SL)

;MB(,"NameIndex 1", SL.NameIndex["four"])
;MB(,"NameIndex 2", SL.NameIndex["five"])
;MB(,"NameIndex 3", SL.NameIndex["six"])

;no ListArray(1,, SL.NameIndex)
SL.Delete(2)
ListArray(1,"after delete 2", SL)
;ListArray(1,"name index", SL.NameIndex)
MB(,"NameIndex 1", SL.NameIndex["four"])
MB(,"NameIndex 2", SL.NameIndex["five"])
MB(,"NameIndex 3", SL.NameIndex["six"])
MB(,"NameIndex ?", SL.NameIndex["seven"])

ExitApp

text := FileRead(A_ScriptFullPath)
SL := New StringList
index := SL.SetText(text)
ListArray(1,, SL)
ListVars(1,,index)

SL.Clear()
index := SL.Push("start")
;SL.AddText(text)
;SL.Add(text)
ListArray(1,, SL)
ListVars(1,"push",index)
String := SL.Pop()
ListArray(1,, SL)
ListVars(1,"pop",String)

v := SL.GetText()
ListVars(1,,v)

SL := New StringList
SL.AddPair("One", "Chevy")
SL.AddPair("Two:Buick")
ListArray(1,, SL)
ListArray(1,, SL.prop.NameIndex)

ExitApp

text := "The rain in Spain" . NL
if StrContains(text, NL)
  MB("contains NL")
if StrEndsWith(text, NL)
  MB("endswith NL")

SL := New StringList
SL.NameIndex[1] := "One"
SL.NameIndex[2] := "Two"
SL.NameIndex[3] := "Three"
MB(,,SL.NameIndex[1])
MB(,,SL.NameIndex[2])
MB(,,SL.NameIndex[3])
ListArray(1,, SL.prop.NameIndex)

SL.AddPair("One", "Fig")
SL.AddPair("Two", "Grapefruit")
SL.AddPair("Three", "Watermelon")
ListArray(1,, SL)
ListArray(1,, SL.prop.NameIndex)
n := SL.IndexOfName("Two")
v := SL[n]
w := SL.IndexOf("Watermelon")
ListVars(1,,n,v, w)


SL.Add("Six,One,Two,Three,Nine")
SL.AddCSV("Six,One,Two,Three,Nine")




ListArray(1,"Before Sort", SL)
SL.Sort(Ascending := True)
ListArray(1,"After Sort", SL)
SL.Sort(Ascending := False)
ListArray(1,"After Sort", SL)

temp := []
temp := SL
ListArray(1,"temp", temp)

SL := New StringList("Six,One,Two,Three,Nine")
ListArray(1,"Before Sort", SL)
SL.SortArray(SL)
ListArray(1,"After Sort", SL)


SLSorted := SL.Sort()
ListArray(1,"After Sort", SLSorted)


SL := New StringList
i1 := SL.Add("One,Two,Three,Nine")
i2 := SL.Add(["Four:Apple", "Five:Banana", "Six:Cherry"])
i3 := SL.Add("One Two Three Nine")
i4 := SL.Add("Seven:7, Five:Banana, Eight:8")
i5 := SL.Add(["Nine:9", "Five:Banana", "Ten:10"])
i6 := SL.Add("DUPLICATES:, One, Two, Three, Nine")
SL.Append("Twenty:20, Twenty:21")
SL.Push("Thirty:30")
ListArray(1,"SL.Add()", SL)
ListVars(1,"INDEXES", i1, i2, i3, i4, i5, i6)
SL.Pop()
ListArray(1,"SL.Pop()", SL)
SL.Sort()
ListVars(1,"SORT", SL[1], SL[2], SL[3], SL[4], SL[5], SL[6])
ListArray(1,"SL.Sort()", SL)
ListVars(1,"Value()", SL.Value("Six"))

SL := New StringList
ListArray(1,"after Add String", SL)
SL := New StringList(["Four:Apple", "Five:Banana", "Six:Cherry"])
ListArray(1,"after Add String", SL)
SL := ""
SL := New StringList("One,Two,Three,Nine")
ListArray(1,"after Add String", SL)
SL := ""
SL := New StringList("Name:Value")
ListArray(1,"after Add String", SL)



SL := ""
SL := New StringList
SL.Add("One,Two,Three,Nine")
SL.AddArray(["Four:Apple", "Five:Banana", "Six:Cherry"])
SL.AddCSV("One,Two,Three,Nine")
SL.AddCSV("Seven:7, Five:Banana, Eight:8")
SL.AddArray(["Nine:9", "Five:Banana", "Ten:10"])
;SL := New StringList("One")
;SL := New StringList(["One", "Two", "Three"])
ListArray(1,"after Adds", SL)


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

  _Sort(ByRef Array, Ascending := True) {
    for index, value in Array
      list .= value "|"
    list := SubStr(list,1,-1)
    Sort, list, % "D|" (Ascending ? "" : " R") ; (this.CaseSensitive ? " C" : "")
    temp := []
    loop, parse, list, |
    {
      if (A_LoopField != "")
        temp.Insert(A_LoopField)
    }
    Array := ""
    Array := temp
    temp := ""
  }

Escape::
FreeMemory:
T := ""
SL := ""
ExitApp
