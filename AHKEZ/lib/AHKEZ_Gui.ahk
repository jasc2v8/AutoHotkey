;02-20-2021:13:27
/*
	Title:  Static_Gui.ahk
  About:  The standard Gui library for AHKEZ
  Usage:  #Include <AHKEZ> 
          #Include<Static_Gui>
	Legal:  Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
  Notes:
  1.  The objectives for the AHK EZ Gui functions in Static_Gui is to:
        Implement function wrappers for all Gui commands
        Minimize the confusion when to use variable or %variable%
  2.  All AHKEZ Gui calls pass options in a variadic (args*)
        Variadic args are explained at https://www.autohotkey.com/docs/Functions.htm#Variadic
        The challenge is to pass variables in the same context and scope of the caller function
        "y120" can be passed but "xGX" can't because the variable GX can't be inside quotes
        Also, the variable GX is in the scope of the caller function, but not in the Gui() function
        If you extracted the letters "GX" and tried to use that variable it would return empty ""
  3.  The syntax for AHKEZ Gui functions is:
        Assume:                 GX := 80, GW := 800
        V1 Command Syntax:      Gui, SubCommand, Value1, Value2, Value3
        V1 Command Example:     Gui, Show, AutoSize x%GX% y120 w%GW% h400, %Title%
      	EZ Function Syntax:     Gui(args*)
      	EZ Function Equivalent: Gui("Show",	"AutoSize", "x",	GX,	"y120",	"w",	GW,	"h400", Title)
          The commas are required to separate items for use in the variadic (args*)
          "Show" and "AutoSize" are literal text, not variables, and require quotes inside parenthesis
          Variables will be de-referenced and their values will be concatenated with the previous string
          GX is a variable name with the value 80 in the example above
          "x", GX is concatenated and dereferenced and passed as x80
          "y120" is passed as the letter "y" with the value 120 or y120
          "w", GW is passed as w800
          Title is a variable which doesn't require percent signs because it's used inside parenthesis
  4.  EZ Gui functions are designed for simple Guis. Complex Guis may not work as expected.

*/

#Include <AHKEZ>
#Include <AHKEZ_DEBUG>

Global DEBUG := 0

;Gui, [GuiName], SubCommand [, Value1, Value2, Value3]

Gui(SubCommand = "New", Value1 = "", Value2 = "", Value3 = "") {

  ;MsgBox, 0, STOP, STOP

  ;match gui options first char
  Static GuiOptNeedle := "iS)(*UCP)([x|y|w|h|c|r|s|q]\d{1})(?<!c0x)"

  ;if "GuiName:" found, combine with SubCommand
  ; calling code must add trailing colon ":", to the GuiName eg:
  ; Static GuiName := "DEBUG:"
  pos := StrContains(Subcommand, ":")
  Subcommand := Trim(Subcommand)
  if (pos) {
    GuiCommand := SubStr(Subcommand, 1, pos) . SubStr(Subcommand, pos + 1)
  } else {
    GuiCommand := Subcommand
  }

  ;MB(0,,">" GuiCommand "<")

  ;DB(1, "GUI CALL", SubCommand, GuiCommand, Value1, Value3, Value3)

	;Gui, Add, ControlType , Options, Text
  ;Gui, SubCommand, Value1, Value2, Value3
  if StrEndsWith(SubCommand, "Add") {
    controlType := value1
    options := "+HWNDhID " RegExReplace(Value2, GuiOptNeedle, " $1")
    text := Value3

    ;DB(1,"STOP! Add", subCommand, controlType, options, Text)

    Gui, %subCommand%, %controlType%, %options%, %text%
    Return hID
  }

	;Gui, Color, WindowColor(Default, HtmlName, RGB, % var), ControlColor(Default, HtmlName, RGB, % var)
  ;Gui, SubCommand, Value1, Value2, Value3
  if StrEndsWith(SubCommand, "Color") {

    Static StripLeading_C_Needle := "iS)(*UCP)^c?(.*)"

    ;Gui, Color doesn't support a leading "c" for colors, strip off if present
    windowColor  := RegExReplace(Trim(Value1), StripLeading_C_Needle, "$1")
    controlColor := RegExReplace(Value2, StripLeading_C_Needle, "$1")
    
    ;DB(1,"STOP! Color", subCommand, windowColor, controlColor)

    Gui, %subCommand%, %windowColor%, %controlColor%
    Return
  }

  ;Gui, Font, Options(cswq), FontName
  ;Gui, SubCommand, Value1, Value2, Value3
  if StrEndsWith(SubCommand, "Font") {
    Options := RegExReplace(Value1, GuiOptNeedle, " $1") ;note A_Space . "$1"
    FontName := Value2

    ;DB(1,"STOP! Font", SubCommand, Options, FontName)

    Gui, %SubCommand%, %Options%, %FontName%
    Return
  }

  ;Gui, GuiName:New, Options, Title
  ;Gui, SubCommand, Value1, Value2, Value3
  if StrEndsWith(SubCommand, "New") {
    Options := "+HWNDhID " RegExReplace(Value1, GuiOptNeedle, " $1") ;note A_Space . "$1"
    Title := Value2
    
    ;DB(1,"STOP! New", SubCommand, Options, Title)

    Gui, %GuiCommand%, %Options%, %Title%
    Return hID

  }

  ;Gui, Show, Options, Title
  ;Gui, SubCommand , Value1, Value2, Value3
  if StrEndsWith(SubCommand, "Show") {
    Options := RegExReplace(Value1, GuiOptNeedle, " $1") ;note A_Space . "$1"

    ;DB(1,"STOP! Show", subCommand, options, title)

    Gui, %subCommand%, %options%, %Title%

    Return
  }

  Static GuiSubCommands := "Cancel,Destroy,Flash,Hide,Margin,Minimize,Maximize,Menu,Restore,Submit"
  ;Gui, SubCommand , Value1, Value2, Value3
  if StrContains(GuiSubCommands, SubCommand) {
  ;if SubCommand in GuiSubCommands
  ;{

    ;MB(0, "STOP!", "GuiSubCommands")
    ;ListVars(1,"STOP! OTHER SubCommands", subCommand, Value1, Value2, Value3)
    ;MB(0, "STOP!", "GuiSubCommands")

    Gui, %subCommand%, %Value1%, %Value2%, %Value3%

    Return
  }

  ;Gui, +/-Option1 +/-Option2 ...
  ;Gui, SubCommand , Value1, Value2, Value3

    ;no gui options with first char to match
    ;Options here are all strings, eg: "+E0x40000 -Theme +Owner"
    options := SubCommand

    ;DB(0,"STOP! +/-Options", options)

    Gui, %options%

} ; End_Gui()
