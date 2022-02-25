if (!A_IsCompiled && A_LineFile == A_ScriptFullPath) {
  MsgBox % "This file was not #included."
  ExitApp
}
/*

  StringList
    Add(String, CSV, Array, List?)
    AddPair(Name, Value)

    IndexOf(String or :Value)
    IndexOfName(Name)

    Delete(Index)     ;delete SL[Index] and NameIndex[Index]
    DeleteName(Name)  ;NameIndex[Name] and SL[Index]

    Value(Name)

    Name:Value          ;easy to rebuild index after sort
    NameIndex[Name]


  StringArray       "this is a line of text"
  GetText           "this is a line of text" . NL

  StringArrayIndex  (Name, Value)  ("Name,Value")  NameIndex[] : ValueArray[]
  StringArrayPairs  (Name, Value)  ("Name,Value")  NameIndex[] : ValueArray[]
  StringPairs       (Name, Value)  ("Name,Value")  NameIndex[] : ValueArray[]

	Title:  Class_StringList.ahk
  About:  An object to manage a list of strings
  Usage:  #Include <AHKEZ> 
          #Include <Class_StringList>
	Legal:  Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
  Notes:
  Inspired by:
    FreePascal: https://www.freepascal.org/docs-html/rtl/classes/tstringlist.html
    Delphi:     http://docwiki.embarcadero.com/Libraries/Sydney/en/System.Classes.TStringList_Methods
    Java:       https://processing.github.io/processing-javadocs/core/index.html?processing/data/StringList.html

  To Use:
    SL := New StringList
    index := Add("string")
    index := Add("name:value")

  Overview:
    A StringList can be used in two ways:
      1. An array for Strings
      2. An array for Name:Value pairs
    All Strings and Name:Value pairs are stored without a line terminator (no CRLF)
    An array of Strings:
      - A one-dimensional array of Strings
    An array for Name:Value pairs
      - Two one-dimensional arrays in one container - one array, one indexed array:
      - 1. array of string Values
      - 2. array of string Names that is indexed to the array of Values for fast lookup
    Note that the same array is used for Strings and Values, the Names index is a separate array
    It is recommended to use as Strings or Name:Value pairs, not both in the same instance
    The StringList may contain a mix of either:
      - String      e.g. StringList[1] := "Apple"
      - Name:Value  e.g. StringList[2] := "Banana", IndexOfName("Banana") = 1

  Properties:
    CaseSensitive             ;default is False
    NameValueSeparator        ;default is colon ":"

  Methods:
    [index]                   ;Return String or Name:Value at [index]
    Add(String)               ;Add String, CSV String, Text with CRLF, or array of Strings (StringList)
                              ;If String, dups allowed
                              ;If Name:Value, dups not allowed
                              ;Return = index of added string
    AddArray([Array])
    AddCSV(CSV)
    AddString(String)
    AddText(String . CRLF)   ; String . CRLF

    Append(String)            ;Return = none
    Clear()
    Count()
    Delete(Index)
    GetText()                 ; String or Name:Value . CRLF
    IndexOf(String)
    IndexOfName(String)
    LoadFromFile(Filename)
    SaveToFile(Filename)
    SetText(Text)
    Push()
    Pop()
    Sort()
    Value(Key)

  Class_StringListIndexed()
    Add(Name, Value) {
      index := this.AddPair(Name, Value)
      NameIndex[Name] := index
      Return index
    }

    Two Arrays:
    [Names]                   [Values]
    KeyIndex["One"] := 1      SL[1] := "Apple"

    IndexOf(Name)

    Is Value in List?
    
*/

#Include <AHKEZ>
#Include <AHKEZ_Debug>

Class StringList {

  ;PROPERTIES

  Class prop {
    NameValueSeparator := ""
    CaseSensitive := ""
    NameIndex := []
  }

  CaseSensitive
  {
    get {
      return this.prop.CaseSensitive
    }
    set {
      this.prop.CaseSensitive := value
    }
  }

  NameIndex[index]
  {
    get {
      return this.prop.NameIndex[index]
    }
    set {
      this.prop.NameIndex[index] := value
    }
  }

  NameValueSeparator
  {
    get {
      return this.prop.NameValueSeparator
    }
    set {
      this.prop.NameValueSeparator := value
    }
  }

  ;METHODS

  ; Name  := RegExReplace(Name, "(.*)" this.NameValueSeparator ".*",   "$1")
  ; Value := RegExReplace(Name, ".*"   this.NameValueSeparator "(.*)", "$1")

  Add(String = "") {
    if !IsEmpty(String) {
      if IsType(String, "object") {
        index := this.AddArray(String)
      } else if StrEndsWith(String, NL) {
        index := this.AddText(String)
      } else if StrContains(String, this.NameValueSeparator) {
        index := this.AddPair(String)
      } else if StrContains(String, ",") {
        index := this.AddCSV(String)
      } else {
        index := this.AddString(String)
      }
    }
    Return index
  }

  AddArray(Array) {
    For key, value in Array
      index := this.Add(Trim(value))
    Return index
  }

  AddCSV(StringCSV) {
    split := StrSplit(StringCSV, ",")
    for key, value in split
      index := this.Add(Trim(value))
    Return index
  }

  AddString(String) {
    if StrContains(String, this.NameValueSeparator) And this.IndexOf(String) ;no dups if Name:Value
      Return
    index := this.Length() + 1
    this[index] := String
    Return index
  }

  AddText(Text) {
    Loop, Parse, Text, `n, `r
    {
      String := A_LoopField
      if StrContains(String, this.NameValueSeparator) And this.IndexOf(String) ;no dups if Name:Value
        Continue
      index := this.Length() + 1
      this[index] := String
    }
    Return index
  }

  AddPair(Name, Value = "") { ;if Name is Name:Value, ignore Value if present
    if StrContains(Name, this.NameValueSeparator) {
      Pair := Trim(Name)
    } else {
      Pair := Trim(Name) . this.NameValueSeparator . Trim(Value)
    }
    Name := RegExReplace(Pair, "(.*)" this.NameValueSeparator ".*",   "$1")
    if this.NameIndex[Name] ;no dups if Name:Value
      Return
    index := this.AddString(Pair)
    this.NameIndex[Name] := index
    Return index
  }

  IndexOfName(Name) {
    if (!this.CaseSensitive) {
      Name := StrUpper(Name)
    }
    Return this.NameIndex[Name]
  }

  Append(String) {
    this.Add(String)
  }

  Clear() {
    Loop % this.MaxIndex() {
      this.RemoveAt(this.MaxIndex())
    }
  }

  Count() {
    Return this.Length()
  }

  Delete(Index) {

    /*

    1:[six:cherry]
    2:[six:apple]
    3:[six:banana]
    
    NameIndex 
    [apple]:2
    [banana]:3
    [cherry]:1
    */

    value := this[Index]

    this.RemoveAt(Index)

    ;this.prop.NameIndex.RemoveAt(value)
     ListArray(1,"delete", this.prop.NameIndex)
    ; temp.RemoveAt(3)
    ; ListArray(1,"delete-temp", temp)
  ;   mb(,"six", temp["six"])
  ;   mb(,"len", temp.MaxIndex())

    temp := []
    for k, v in this.prop.NameIndex
      if (v != Index)
        temp[k] := A_Index

     ListArray(1,"delete-temp", temp)

  ;   temp.RemoveAt(Index)

  ;   ListArray(1,"delete-temp-after", temp)

     this.prop.NameIndex := temp
     ;this.prop.NameIndex.AddStrings(temp)
     temp := ""
  }

  GetText() {
    text := ""
    for k, v in this
      text .= v . NL
    Return text
  }

  IndexOf(aValue) {
    For key, value in this {

      if (!this.CaseSensitive) {
        value  := StrUpper(value)
        aValue := StrUpper(aValue)
      }

      if (value == aValue) {
      ;ListVars(1,,String, key, value, this.CaseSensitive)


        Return key
      }
    }
    Return 0
  }

  IndexOfName_OG(aName) {
    For index, NameValue in this {
      name := RegExReplace(NameValue, "(.*)" this.NameValueSeparator ".*", "$1")

      ;ListVars(1,,String, index, value, name, this.CaseSensitive)

      if (!this.CaseSensitive) {
        name   := StrUpper(name)
        aName := StrUpper(aName)
      }
      if (name == aName)
        Return index
    }
    Return 0
  }

  LoadFromFile(Filename) {
    TextBuffer := FileRead(Filename)
    ;TextBuffer := SubStr(TextBuffer, 1, -2)
    this.Clear()
    Loop, Parse, TextBuffer, `n, `r
    {
      if (A_LoopField != "")
        this.Append(A_LoopField)
    }
    TextBuffer := ""
  }

  Pop() {
    String := this[this.MaxIndex()]
    this.RemoveAt(this.MaxIndex())
    Return String
  }

  Push(String) {
    index := this.Add(String)
    Return index
  }

  SaveToFile(Filename) {
    TextBuffer := ""
    for k, v in this
      TextBuffer .= v . "`n"
    FileWrite(TextBuffer, Filename, OverWrite := True)
    TextBuffer := ""
  }

  SetText(Text) {
    this.Clear()
    index := this.AddText(Text)
    Return index
  }

  Sort(Ascending := True) {
    for index, value in this
      list .= value "|"
    list := SubStr(list,1,-1)
    Sort, list, % "D|" (Ascending ? "" : " R") (this.CaseSensitive ? " C" : "")
    temp := []
    loop, parse, list, |
    {
      if (A_LoopField != "")
        temp.Insert(A_LoopField)
    }
    this.Clear()
    this.AddArray(temp)
    temp := ""
  }

  Value(Name) {
    ;Return RegExReplace(this[this.IndexOfName(Key)], ".*:(.*)", "$1")
    Return RegExReplace(this[this.IndexOfName(Name)], ".*" this.NameValueSeparator "(.*)", "$1")
  }

  __New(String = "") {
    this.CaseSensitive := False
    this.NameValueSeparator := ":"
    if !IsEmpty(String) {
      this.AddArray(String)
    }
  }

  __Destroy() {
    this.Clear()
    this := ""
  }

} ; End_Class_StringList
