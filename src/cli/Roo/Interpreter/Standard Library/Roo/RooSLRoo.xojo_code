#tag Class
Protected Class RooSLRoo
Inherits RooInstance
Implements RooNativeModule
	#tag Method, Flags = &h0
		Function ClassWithName(name As RooToken) As RooNativeClass
		  // Part of the RooNativeModule interface.
		  
		  #Pragma Unused name
		  
		  // The Roo module has no classes. Should not be called...
		  Raise New RooRuntimeError(name, "The Roo module has no classes.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  // Calling the overridden superclass constructor.
		  Super.Constructor(Nil)
		  
		  // Add getters.
		  Getters = Roo.CaseSensitiveDictionary
		  Getters.Value("clock") = True
		  Getters.Value("version") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetterWithName(name As RooToken) As Variant
		  // Part of the RooNativeModule interface.
		  
		  If StrComp(name.Lexeme, "clock", 0) = 0 Then
		    Return New RooNumber(Microseconds)
		  ElseIf StrComp(name.Lexeme, "version", 0) = 0 Then
		    Return New RooText(Roo.Version)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasClassWithName(name As String) As Boolean
		  // Part of the RooNativeModule interface.
		  
		  #Pragma Unused name
		  
		  // The Roo module has no classes.
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasGetterWithName(name As String) As Boolean
		  // Part of the RooNativeModule interface.
		  
		  Return Getters.HasKey(name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasMethodWithName(name As String) As Boolean
		  // Part of the RooNativeModule interface.
		  
		  #Pragma Unused name
		  
		  // The Roo module has no methods.
		  Return False
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasModuleWithName(name As String) As Boolean
		  // Part of the RooNativeModule interface.
		  
		  #Pragma Unused name
		  
		  // The Roo module has no submodules.
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodWithName(name As RooToken) As Invokable
		  // Part of the RooNativeModule interface.
		  
		  #Pragma Unused name
		  
		  // The Roo module has no methods. This should never be called...
		  Raise New RooRuntimeError(name, "The Roo module has no methods.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ModuleWithName(name As RooToken) As RooNativeModule
		  // Part of the RooNativeModule interface.
		  
		  #Pragma Unused name
		  
		  // The Roo module has no submodules. Should not be called...
		  Raise New RooRuntimeError(name, "The Roo module has no submodules.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "Roo Module"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As String
		  // Part of the RooNativeModule interface.
		  
		  Return "Module"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Getters As Xojo.Core.Dictionary
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
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
