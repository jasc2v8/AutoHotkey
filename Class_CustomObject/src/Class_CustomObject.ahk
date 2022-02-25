if (!A_IsCompiled && A_LineFile == A_ScriptFullPath) {
  MsgBox % "This file was not #included."
  ExitApp
}
/*
  Version: 2021-03-22_16:15/jasc2v8/rename from Class_StringList

  Title:  Class_CustomObject.ahk
  About:  An AHK Object with custom properties, methods, and functions
  Usage:  #Include <AHKEZ> 
          #Include <Class_CustomObject>
          Obj := New CustomObject
          index := Obj.Add("string")
          index := Obj.Add("Name:value")
  Legal:  Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
  Inspired by:
    AutoHotkey: https://www.autohotkey.com/docs/objects/Object.htm 

  Overview:
    A "Value" is any AHK Object or Variable type
    A CustomObject can be used in two ways:
      1. An array of Values           (Objects or variables with integer indexes)
      2. An array of Key:Value pairs  (Objects or Variables with integer or string Keys)
    It's recommended to use the CustomObject as an Array or Name:Value pairs, not both in the same instance.

  Properties:
    Count                     count of items in the CustomObject with either integer or string indexes
    CaseSensitive             default is False

  Functions and Methods:
    
    [index]                   Obj[index] := Value
                              Value := Obj[index]

    [Key: Value]              Obj[Key] := Value
                              Value := Obj[Key]
                              Obj := {Key: Value}

    Add(Value/Pair)           Add Value or Key:Value to end of the CustomObject
                                Add String, CSV String, Text with LF/CRLF, or array of Strings
                                Return the index of added String
                                AddArray([Array]) ;Values/Pairs
                                AddCSV(CSV) ;Values/Pairs
                                AddPair("Name", "Value")
                                AddString(String)  ;Values/Pairs
                                AddText(String . CRLF) ;Values only
    Append(Value/Pair)        Synonym for Add, but nothing Returned
    Clear()                   Clears all items
    GetText()                 Return all Values or Name:Value pairs as Text . CRLF
    IndexOf(String or Value)  IndexOf(String) Return the integer index of the String
                              IndexOf(Value)  Return the Name index of the Value
    LoadFromFile(Filename)    Loads from text file: String . CRLF
    SaveToFile(Filename)      Saves to text file: String . CRLF or Name:Value . CRLF
    SetText(Text)             Loads from Text variable, see Add() for supported values
    Sort(Ascending := True)   Sorts an integer indexed StringList. Ignores if Name:Value StringList
    Value(Index or "Name")    Value(1) Returns the string value at integer (Index)
                              Value("1") (Index) can be an integer String
                              Value("Name") Returns the Value part of Name:Value pair
                              Value(1) Returns "" if attempt to Integer index a Name:Value pair

    The following are AHK Object built-in methods, hence no duplicate methods in Class_CustomObject:
      https://www.autohotkey.com/docs/objects/Object.htm

    Properties:
      Base                                    See AHK docs

    Methods:
      InsertAt / RemoveAt                     See AHK docs - doesn't leave blanks
      Push / Pop                              To/From end of Object
      Delete                                  See AHK docs - leaves blanks
      MinIndex / MaxIndex / Length / Count    Use .Count property instead - see above and AHK docs
      SetCapacity / GetCapacity               See AHK docs
      GetAddress                              See AHK docs
      _NewEnum                                See AHK docs
      HasKey                                  HasKey(Index) or HasKey("Name")
      Clone                                   See AHK docs - returns a shallow copy of Object

    Functions:
      ObjRawGet                               See AHK docs
      ObjRawSet                               See AHK docs
      ObjGetBase                              See AHK docs
      ObjSetBase                              See AHK docs

*/

#Include <AHKEZ>
;#Include <AHKEZ_Debug>

Class CustomObject {

  ;PROPERTIES

  Class prop {
    NameValueSeparator := ""
    CaseSensitive := ""
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

  Count
  {
    get {
      return this._Count()
    }
    set {
      ;read-only
    }
  }

  ;INTERNAL HELPER METHODS

  _IsPair(String) {
    Result := False
    if StrContains(String, ":")
      Result := True
    Return Result
  }

  _Count() {
    count := 0
    for k, v in this
      count := A_Index
    Return count
  }

  _GetKey(KeyValue) {
    Return Trim(RegExReplace(KeyValue, "(.*):.*",   "$1"))
  }

  _GetValue(KeyValue) {
    Return Trim(RegExReplace(KeyValue, ".*:(.*)",   "$1"))
  }

  ;CLASS METHODS

  Add(String = "") {

    if IsType(String, "object") {
      ;MB("Add Object[1]: " String[1])
      index := this.AddObj(String)

    } else if StrEndsWith(String, LF) {
      ;MB("Add Text: " String)
      index := this.AddText(String)

    } else if StrContains(String, ",") {
      ;MB("Add CSV: " String)
      index := this.AddCSV(String)
      
    } else if this._IsPair(String){
      ;MB("Add Pair: " String)
      index := this.AddPair(String)

    } else {
      ;MB("Add String: " String)
      index := this.AddString(String)
    }
    
    Return index
  }

  AddArray(Array) {
    For key, value in Array {
      if this._IsPair(value) {
        ObjRawSet(this, this._GetKey(value), this._GetValue(value))
      } else { 
        this.Add(Trim(value))
      }
    }
    Return this.Count
  }

  AddCSV(StringCSV) {
    split := StrSplit(StringCSV, ",")
    for key, value in split {
      if this._IsPair(value) {
        ObjRawSet(this, this._GetKey(value), this._GetValue(value))
      } else { 
        this.Add(Trim(value))
      }
    }
    Return this.Count
  }

  AddObj(ArrayObj) {
    for index, value in ArrayObj
      this[Trim(index)] := Trim(value)
    Return this.Count
  }

  AddString(String) {
    if this._IsPair(String) {
      ObjRawSet(this, this._GetKey(String), this._GetValue(String))
    } else { 
      this.Push(String)
    }
    Return this.Count
  }

  AddText(Text) {
    Text := RTrim(Text, " `r`n")
    Loop, Parse, Text, `n, `r
    {
      this.Push(A_LoopField)
    }
    Return this.Count
  }

  AddPair(Name, Value) {
    ObjRawSet(this, Name, Value)
    Return this.Count
  }

  Append(String) {
    this.Add(String)
  }

  Clear() {
    if (this[1] = "") {
      temp := []
      for key, value in this
        temp[A_Index] := key
      for index, value in temp
        this.Delete(temp[A_Index])
      temp := ""
    } else {
      Loop % this.MaxIndex() {
        this.RemoveAt(this.MaxIndex())
      }
    }
  }

  GetText() {
    text := ""
    for k, v in this
      text .= v . NL
    Return text
  }

  IndexOf(String) {    
    For key, value in this {
      if (!this.prop.CaseSensitive) {
        value  := StrUpper(value)
        String := StrUpper(String)
      }
      if (value == String) {
        Return key
      }
    }
    Return 0
  }

  ;In:  Array[index] or Object[key, value] or Object[key, Object[key, value]]
  ;Out: List key, values
  List(Option = "", Title = "") {
    LE := (Option > 0) ? "`n`n" : "`n"
    vOut := ""
    if (this[1] = "") {
      for key, value in this {
        count := A_Index
        if IsType(value, "object") {
          for k, v in value
            if !IsEmpty(v)
   	          vOut .= "Key=" k LE "Value=" v . LE          
          vOut := "Key1=" key LE vOut LE
          MB(Option, Title, vOut)
          vOut=
        } else {
	        vOut .= "Key=" key LE "Value=" this.Item[key] . LE
          MB(Option, Title, "Keys=" this.count LE vOut)
        }        
      }
    } else {
      for key, value in this
        vOut .= "Key=" key LE "Value=" value . LE
      MB(Option, Title, "Keys=" this.count LE vOut)
    }
  }

  ;In:  Object[key, Object[key, value]]
  ;Out: List key, values
  ListKeyObj(Option = "", Title = "", MaxKeys = "") {
    LE := (Option > 0) ? "`n`n" : "`n"
    MaxKeys := MaxKeys = "" ? this.Count : MaxKeys
    VOut=
    for ObjKey, ObjValue in this
    {
      for key, value in ObjValue
      {
        if !IsEmpty(value)
   	      vOut .= "Key=" key LE "Value=" value . LE
      }
      vOut := "Key=" ObjKey LE vOut LE
      MB(Option, Title, "Keys=" this.count LE vOut)
    }
  }

  ;In:  Object[key,value]
  ;Out: List key, values
  ListObj(Option = "", Title = "", MaxKeys = "") {
    LE := (Option > 0) ? "`n`n" : "`n"
    MaxKeys := MaxKeys = "" ? this.Count : MaxKeys
    VOut=
      for key, value in this
      {
        if !IsEmpty(value)
   	      vOut .= "Key=" key LE "Value=" value . LE
      }
      MB(Option, Title, "Keys=" this.count LE vOut)
  }

  LoadFromFile(Filename) {
    TextBuffer := FileRead(Filename)
    this.Clear()
    Loop, Parse, TextBuffer, `n, `r
    {
      if (A_LoopField != "")
        this.AddText(A_LoopField)
    }
    TextBuffer := ""
  }

  SaveToFile(Filename) {
    TextBuffer := ""
    for key, value in this
      TextBuffer .= key . ":" . value . "`r`n"
    FileWrite(TextBuffer, Filename, OverWrite := True)
    TextBuffer := ""
  }

  SetText(Text) {
    this.Clear()
    index := this.AddText(Text)
    Return index
  }

  Sort(Ascending := True) {
    if (this[1] = "")
      Return
    for index, value in this
      list .= value "|"
    list := SubStr(list,1,-1)
    Sort, list, % "D|" (Ascending ? "" : " R") (this.prop.CaseSensitive ? " C" : "")
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
    Return this[Name]
  }

  __New(Value := "") {
    this.CaseSensitive := False
    if !IsEmpty(Value)
      this.Add(Value)
  }

  __Destroy() {
    this.Clear()
    this := ""
  }

} ; End_Class_CustomObject
