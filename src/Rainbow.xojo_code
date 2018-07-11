#tag Module
Protected Module Rainbow
	#tag Method, Flags = &h1
		Protected Function Bold(phrase as String) As String
		  Return Formatted(phrase, True)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Colourise(phrase as String, foreColor as Rainbow.Colour, backColor as Rainbow.Colour=Rainbow.Colour.Default) As String
		  return Rainbow.Formatted(phrase, False, False, foreColor, backColor)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Formatted(phrase as String, bold as Boolean=False, underline as Boolean=False, foreColor as Rainbow.Colour=Colour.default, backColor as Rainbow.Colour=Colour.default) As String
		  ' chrb(27) is ESC
		  
		  ' Console text colours aren't supported in the Windows Command Prompt.
		  #if TargetWindows
		    return phrase
		  #endif
		  
		  dim fc, bc, b, u as String
		  
		  select case foreColor
		  case Colour.black
		    fc = FG_BLACK
		  case Colour.blue
		    fc = FG_BLUE
		  case Colour.cyan
		    fc = FG_CYAN
		  case Colour.green
		    fc = FG_GREEN
		  case Colour.magenta
		    fc = FG_MAGENTA
		  case Colour.red
		    fc = FG_RED
		  case Colour.white
		    fc = FG_WHITE
		  case Colour.yellow
		    fc = FG_YELLOW
		  case else
		    fc = FG_DEFAULT
		  end select
		  
		  select case backColor
		  case Colour.black
		    bc = BG_BLACK
		  case Colour.blue
		    bc = BG_BLUE
		  case Colour.cyan
		    bc = BG_CYAN
		  case Colour.green
		    bc = BG_GREEN
		  case Colour.magenta
		    bc = BG_MAGENTA
		  case Colour.red
		    bc = BG_RED
		  case Colour.white
		    bc = BG_WHITE
		  case Colour.yellow
		    bc = BG_YELLOW
		  case else
		    bc = BG_DEFAULT
		  end select
		  
		  b = if(bold, BOLD_ON, BOLD_OFF)
		  
		  u = if(underline, UNDERLINE_ON, UNDERLINE_OFF)
		  
		  return chrb(27) + "[" + fc + ";" + bc + ";" + b + ";" + u + "m"  + phrase + chrb(27) + "[0m"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Underlined(phrase as String) As String
		  return Formatted(phrase, False, True)
		End Function
	#tag EndMethod


	#tag Note, Name = About
		This is a simple module for formatting the appearance of strings output to the console.
		
		Essentially a wrapper for the ANSI escape code sequences:
		https://en.wikipedia.org/wiki/ANSI_escape_code#graphics
		
		Thanks to this StackOverflow QA:
		http://stackoverflow.com/questions/2616906/how-do-i-output-coloured-text-to-a-linux-terminal
		
		Xojo thread credit:
		https://forum.xojo.com/28644-coloured-text-in-the-terminal-from-a-console-app
		
	#tag EndNote


	#tag Constant, Name = BG_BLACK, Type = Text, Dynamic = False, Default = \"40", Scope = Private
	#tag EndConstant

	#tag Constant, Name = BG_BLUE, Type = String, Dynamic = False, Default = \"44", Scope = Private
	#tag EndConstant

	#tag Constant, Name = BG_CYAN, Type = String, Dynamic = False, Default = \"46", Scope = Private
	#tag EndConstant

	#tag Constant, Name = BG_DEFAULT, Type = String, Dynamic = False, Default = \"49", Scope = Private
	#tag EndConstant

	#tag Constant, Name = BG_GREEN, Type = String, Dynamic = False, Default = \"42", Scope = Private
	#tag EndConstant

	#tag Constant, Name = BG_MAGENTA, Type = String, Dynamic = False, Default = \"45", Scope = Private
	#tag EndConstant

	#tag Constant, Name = BG_RED, Type = String, Dynamic = False, Default = \"41", Scope = Private
	#tag EndConstant

	#tag Constant, Name = BG_WHITE, Type = String, Dynamic = False, Default = \"47", Scope = Private
	#tag EndConstant

	#tag Constant, Name = BG_YELLOW, Type = String, Dynamic = False, Default = \"43", Scope = Private
	#tag EndConstant

	#tag Constant, Name = BOLD_OFF, Type = String, Dynamic = False, Default = \"22", Scope = Private
	#tag EndConstant

	#tag Constant, Name = BOLD_ON, Type = String, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = FG_BLACK, Type = String, Dynamic = False, Default = \"30", Scope = Private
	#tag EndConstant

	#tag Constant, Name = FG_BLUE, Type = String, Dynamic = False, Default = \"34", Scope = Private
	#tag EndConstant

	#tag Constant, Name = FG_CYAN, Type = String, Dynamic = False, Default = \"36", Scope = Private
	#tag EndConstant

	#tag Constant, Name = FG_DEFAULT, Type = String, Dynamic = False, Default = \"39", Scope = Private
	#tag EndConstant

	#tag Constant, Name = FG_GREEN, Type = String, Dynamic = False, Default = \"32", Scope = Private
	#tag EndConstant

	#tag Constant, Name = FG_MAGENTA, Type = String, Dynamic = False, Default = \"35", Scope = Private
	#tag EndConstant

	#tag Constant, Name = FG_RED, Type = String, Dynamic = False, Default = \"31", Scope = Private
	#tag EndConstant

	#tag Constant, Name = FG_WHITE, Type = String, Dynamic = False, Default = \"37", Scope = Private
	#tag EndConstant

	#tag Constant, Name = FG_YELLOW, Type = String, Dynamic = False, Default = \"33", Scope = Private
	#tag EndConstant

	#tag Constant, Name = UNDERLINE_OFF, Type = String, Dynamic = False, Default = \"24", Scope = Private
	#tag EndConstant

	#tag Constant, Name = UNDERLINE_ON, Type = String, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant

	#tag Constant, Name = VERSION, Type = Text, Dynamic = False, Default = \"0.2", Scope = Protected
	#tag EndConstant


	#tag Enum, Name = Colour, Type = Integer, Flags = &h0
		black
		  blue
		  cyan
		  green
		  magenta
		  red
		  white
		  yellow
		default
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
