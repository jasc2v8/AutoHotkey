if (!A_IsCompiled && A_LineFile == A_ScriptFullPath) {
  MsgBox % "This file was not #included."
  ExitApp
}
/*
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
    A StringList is a one-dimensional array of strings without a line terminator (no CRLF)
    The StringList may contain a mix of either:
      - String, e.g. StringList[1] := "Apple"
      - String formatted as Name:Value, e.g. StringList[1] := "One:Apple"

  Properties:
    NameValueSeparator        ;default is colon ":"

  Methods:
    [index]                   ;Return = String or Name:Value at [index]
    Add(String or String[])   ;Add String or array of Strings (StringList)
                              ;If String, dups allowed
                              ;If Name:Value, dups not allowed
                              ;Return = index of added string
    Append(String)            ;Return = none
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
    Value(Key)  
*/

#Include <AHKEZ>
#Include <AHKEZ_Debug>

Class StringList {

  ;PROPERTIES

  Class properties {
    NVS := ""
    CaseSensitive := ""
  }

  CaseSensitive[]
  {
    get {
      return this.properties.CaseSensitive
    }
    set {
      this.properties.CaseSensitive := value
    }
  }

  NameValueSeparator[]
  {
    get {
      return this.properties.NVS
    }
    set {
      this.properties.NVS := value
    }
  }

  ;METHODS
  AddCSV(StringCSV) {
    split := StrSplit(StringCSV, ",")
    for key, value in split
      this.Add(Trim(value))
  }

  AddArray(Array) {
    For key, value in Array
      this.Add(Trim(value))
  }

  Add(String) {
    if StrContains(String, this.properties.NVS) And this.IndexOf(String) ;no dups if Name:Value
      Return
    index := this.Length() + 1
    this[index] := String
    Return index
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
    temp := []
    for k, v in this
      if (k != Index)
        temp[A_Index] := v
    this.Clear()
    this.AddStrings(temp)
    temp := ""
  }

  IndexOf(String) {
    For key, value in this {

      if (!this.CaseSensitive) {
        value  := StrUpper(value)
        String := StrUpper(String)
      }

      if (value == String) {
      ;ListVars(1,,String, key, value, this.CaseSensitive)


        Return key
      }
    }
    Return 0
  }

  IndexOfName(String) {
    For index, NameValue in this {
      name := RegExReplace(NameValue, "(.*)" this.properties.NVS ".*", "$1")

      ;ListVars(1,,String, index, value, name, this.properties.CaseSensitive)

      if (!this.properties.CaseSensitive) {
        name   := StrUpper(name)
        String := StrUpper(String)
      }
      if (name == String)
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
    v := this[this.MaxIndex()]
    this.RemoveAt(this.MaxIndex())
    Return v
  }

  Push(String) {
    this.Add(String)
  }

  SaveToFile(Filename) {
    TextBuffer := ""
    for k, v in this
      TextBuffer .= v . "`n"
    FileWrite(TextBuffer, Filename, OverWrite := True)
    TextBuffer := ""
  }

  Sort() {
    temp := []
    for k, v in this
      temp[RegExReplace(v, "\s")] := v
    this := []
    for k, v in temp
          this[A_Index] := v
    temp := ""
    ;return Array
  }

  Value(Key) {
    ;Return RegExReplace(this[this.IndexOfName(Key)], ".*:(.*)", "$1")
    Return RegExReplace(this[this.IndexOfName(Key)], ".*" this.properties.NVS "(.*)", "$1")
  }

  ; Text(String) { ; get/set
  ;   if StrIsEmpty(Text) {
  ;     Return this.StringList
  ;   } else {
  ;     this.StringList := Trim(Text)
  ;   }
  ; }

  __New(String = "") {
    this.properties.CaseSensitive := False
    this.properties.NVS := ":"
    if !IsEmpty(String)
      this.Add(String)
  }

  __Destroy() {
  }

} ; End_Class_StringList
