#tag Class
Protected Class RooNothing
Inherits RooInstance
Implements  RooNativeClass
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  Raise New RooRuntimeError(New RooToken, "Cannot invoke Nothing.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  Super.Constructor(Nil)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetterWithName(name As RooToken) As Variant
		  // Nothing objects have no getters (apart from inherited generic ones).
		  
		  #Pragma Unused name
		  
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasGetterWithName(name As String) As Boolean
		  // Nothing objects have no getters (apart from the inherited generic object ones).
		  
		  #Pragma Unused name
		  
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasMethodWithName(name As String) As Boolean
		  // Nothing objects have no methods (apart from the inherited generic object ones).
		  
		  #Pragma Unused name
		  
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  #Pragma Unused interpreter
		  #Pragma Unused arguments
		  
		  Raise New RooRuntimeError(where, "Cannot invoke Nothing.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodWithName(name As RooToken) As Invokable
		  // Nothing objects have no methods (apart from inherited generic ones).
		  
		  #Pragma Unused name
		  
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  Return "Nothing"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As String
		  Return "Nothing"
		End Function
	#tag EndMethod


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
