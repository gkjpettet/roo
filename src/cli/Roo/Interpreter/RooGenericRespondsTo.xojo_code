#tag Class
Protected Class RooGenericRespondsTo
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // object.responds_to?(what) As Boolean
		  
		  // Takes a single parameter.
		  Return 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(owner As Variant)
		  Self.Owner = owner
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  // Does the owner respond to the queried field name?
		  
		  #Pragma Unused interpreter
		  
		  If Owner = Nil Then Return New RooBoolean(False)
		  
		  // Get the field name.
		  Dim name As String = Stringable(arguments(0)).StringValue
		  
		  // Generic getter or method?
		  If RooSLCache.GenericGetters.HasKey(name) Or RooSLCache.GenericMethods.HasKey(name) Then
		    Return New RooBoolean(True)
		  End If
		  
		  // Determine if there is a getter or method with this name on the owner.
		  If Owner IsA RooNativeClass Then
		    
		    Dim c As RooNativeClass = RooNativeClass(Owner)
		    Return New RooBoolean( c.HasGetterWithName(name) Or c.HasMethodWithName(name) )
		    
		  ElseIf Owner IsA RooNativeModule Then
		    
		    Dim m As RooNativeModule = RooNativeModule(Owner)
		    Return New RooBoolean( m.HasGetterWithName(name) Or m.HasMethodWithName(name) )
		    
		  ElseIf Owner IsA RooInstance Then
		    
		    Dim i As RooInstance = RooInstance(Owner)
		    If i.Fields.HasKey(name) Then Return New RooBoolean(True)
		    If i.Klass = Nil Then Return New RooBoolean(False)
		    Return New RooBoolean(If(i.Klass.FindMethod(Owner, name) = Nil, False, True))
		    
		  Else
		    Raise New RooRuntimeError(where, "Internal error. " + _
		    "Received a non-instance in RooGenericRespondsTo.Invoke.")
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<method: responds_to?>"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Owner As Variant
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
