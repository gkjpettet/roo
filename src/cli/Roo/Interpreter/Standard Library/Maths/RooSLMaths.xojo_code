#tag Class
Protected Class RooSLMaths
Inherits RooInstance
Implements RooNativeModule
	#tag Method, Flags = &h0
		Function ClassWithName(name As RooToken) As RooNativeClass
		  // Part of the RooNativeModule interface.
		  
		  // The Maths module has no classes.
		  Raise New RooRuntimeError(name, "The Maths module has no class named `" + _
		  name.Lexeme + "`.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  Super.Constructor(Nil)
		  
		  Randomiser = New Random
		  
		  // Create this module's methods.
		  Methods = Roo.CaseSensitiveDictionary
		  Methods.Value("random_int") = New RooSLMathsRandomInt
		  
		  // It's getters.
		  Getters = Roo.CaseSensitiveDictionary
		  Getters.Value("PI") = True
		  Getters.Value("random") = True
		  
		  // Submodules.
		  // None.
		  
		  // Add any classes.
		  // None.
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetterWithName(name As RooToken) As Variant
		  // Overriding RooNativeModule.GetterWithName()
		  
		  If StrComp(name.Lexeme, "PI", 0) = 0 Then
		    Return New RooNumber(kPi)
		  ElseIf StrComp(name.Lexeme, "random", 0) = 0 Then
		    Return New RooNumber(Randomiser.Number)
		  End If
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasClassWithName(name As String) As Boolean
		  // Part of the RooNativeModule interface.
		  
		  #Pragma Unused name
		  
		  // The Maths module has no classes.
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
		  
		  Return Methods.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasModuleWithName(name As String) As Boolean
		  // Part of the RooNativeModule interface.
		  
		  #Pragma Unused name
		  
		  // The Maths module has no submodules.
		  Return False
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodWithName(name As RooToken) As Invokable
		  // Part of the RooNativeModule interface.
		  
		  Return Methods.Value(name.Lexeme)
		  
		  Exception err As KeyNotFoundException
		    Raise New RooRuntimeError(name, "The Maths module has no method named `" + _
		    name.Lexeme + "`.")
		    
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ModuleWithName(name As RooToken) As RooNativeModule
		  // Part of the RooNativeModule interface.
		  
		  // The Maths module has no submodules.
		  
		  Raise New RooRuntimeError(name, "The Maths module has no submodule named `" + _
		  name.Lexeme + "`.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "Maths module"
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

	#tag Property, Flags = &h21
		Private Methods As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Randomiser As Random
	#tag EndProperty


	#tag Constant, Name = kPi, Type = Double, Dynamic = False, Default = \"3.141593", Scope = Private
	#tag EndConstant


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
End Class
#tag EndClass
