#tag Class
Protected Class NativeRooModule
Inherits Roo.CustomModule
Implements Roo.Textable
	#tag Method, Flags = &h0
		Function Get(name as Token) As Variant
		  ' Override RooInstance.Get().
		  
		  ' Getters.
		  if StrComp(name.lexeme, "clock", 0) = 0 then
		    return new NumberObject(Microseconds())
		  elseif StrComp(name.lexeme, "version", 0) = 0 then
		    return new TextObject(Str(Roo.VERSION_MAJOR) + "." + _
		    Str(Roo.VERSION_MINOR) + "." + _
		    Str(Roo.VERSION_BUG))
		  end if
		  
		  ' Methods.
		  return super.Get(name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter = Nil) As String
		  ' Part of the Roo.Textable interface.
		  
		  #Pragma Unused interpreter
		  
		  Return "Roo module"
		End Function
	#tag EndMethod


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
			Name="name"
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
End Class
#tag EndClass
