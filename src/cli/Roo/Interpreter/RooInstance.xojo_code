#tag Class
Protected Class RooInstance
Implements Stringable
	#tag Method, Flags = &h1
		Protected Function ArrayElementAtIndex(a As RooArray, where As RooToken) As Variant
		  // Takes an array object and (if possible) returns the element specified by this instance's 
		  // `IndexOrKey` property (set by the Interpreter.VisitGetExpr method).
		  // Raises a runtime error if there's a problem.
		  
		  // Make sure that index is a Number object.
		  If Not IndexOrKey IsA RooNumber Then
		    Raise New RooRuntimeError(where, "Invalid array index. Expected a Number object. Instead got `" + _
		    Roo.VariantTypeAsString(IndexOrKey) + "`.")
		  End If
		  
		  ' Make sure the index Number object is an integer.
		  If Not Roo.IsInteger(RooNumber(IndexOrKey).Value) Then
		    Raise New RooRuntimeError(where, "Invalid array index. Expected an integer. Instead got `" + _
		    Str(RooNumber(IndexOrKey).Value) + "`.")
		  End If
		  
		  Try
		    Return a.Elements(RooNumber(IndexOrKey).Value)
		  Catch err
		    Raise New RooRuntimeError(where, "Invalid array index: `" + _
		    Str(RooNumber(IndexOrKey).Value) + "`.")
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(klass As RooClass)
		  Self.Klass = klass
		  Self.Fields = Roo.CaseSensitiveDictionary
		  Self.IndexOrKey = Nil
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GenericGet(name As RooToken) As Variant
		  // Generic object getters.
		  // Remember, if you add more getters here you MUST add them to RooSLCache.GenericGetters as well.
		  If StrComp(name.Lexeme, "nothing?", 0) = 0 Then
		    If Klass <> Nil Then
		      Return If(Klass IsA RooNothing, New RooBoolean(True), New RooBoolean(False))
		    Else
		      Return If(Self IsA RooNothing, New RooBoolean(True), New RooBoolean(False))
		    End If
		  ElseIf StrComp(name.Lexeme, "number?", 0) = 0 Then
		    If Klass <> Nil Then
		      Return If(Klass IsA RooNumber, New RooBoolean(True), New RooBoolean(False))
		    Else
		      Return If(Self IsA RooNumber, New RooBoolean(True), New RooBoolean(False))
		    End If
		  ElseIf StrComp(name.Lexeme, "to_text", 0) = 0 Then
		    If Klass <> Nil Then
		      // Check to see if this class has provided an override for the to_text getter.
		      Dim method As RooFunction = Klass.FindMethod(Self, name.Lexeme)
		      If method <> Nil Then
		        Return method
		      Else
		        Return New RooText(StringValue)
		      End If
		    Else
		      // Not a custom class.
		      Return New RooText(StringValue)
		    End If
		  ElseIf StrComp(name.Lexeme, "type", 0) = 0 Then
		    If Self IsA RooNativeClass Then
		      Return New RooText(RooNativeClass(Self).Type)
		    ElseIf Self IsA RooNativeModule Then
		      Return New RooText(RooNativeModule(Self).Type)
		    Else
		      Return New RooText(Klass.Name)
		    End If
		  End If
		  
		  // Generic object methods.
		  // Remember, if you add more methods here you MUST add them to RooSLCache.GenericMethods as well.
		  If StrComp(name.Lexeme, "responds_to?", 0) = 0 Then
		    Return New RooGenericRespondsTo(Self)
		  End If
		  
		  // Unrecognised generic method.
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name As RooToken) As Variant
		  // Is this a get request for a generic object getter or method?
		  Dim result As Variant = GenericGet(name)
		  If result <> Nil Then Return result
		  
		  // Handle get requests differently for native types and classes.
		  If Self IsA RooNativeClass Then
		    If RooNativeClass(Self).HasGetterWithName(name.Lexeme) Then Return RooNativeClass(Self).GetterWithName(name)
		    If RooNativeClass(Self).HasMethodWithName(name.Lexeme) Then Return RooNativeClass(Self).MethodWithName(name)
		    // This native class doesn't have the requested getter or method.
		    Raise New RooRuntimeError(name, "Undefined property `" + _
		    name.Lexeme + "` on " + RooNativeClass(Self).Type + " object.")
		  End If
		  
		  // Handle get requests differently for native modules.
		  If Self IsA RooNativeModule Then
		    If RooNativeModule(Self).HasModuleWithName(name.Lexeme) Then Return RooNativeModule(Self).ModuleWithName(name)
		    If RooNativeModule(Self).HasClassWithName(name.Lexeme) Then Return RooNativeModule(Self).ClassWithName(name)
		    If RooNativeModule(Self).HasGetterWithName(name.Lexeme) Then Return RooNativeModule(Self).GetterWithName(name)
		    If RooNativeModule(Self).HasMethodWithName(name.Lexeme) Then Return RooNativeModule(Self).MethodWithName(name)
		    // This native module doesn't have the requested field.
		    Raise New RooRuntimeError(name, "Undefined field `" + _
		    name.Lexeme + "` on " + Stringable(Self).StringValue)
		  End If
		  
		  // Return the requested property value if this instance has a property with the requested name.
		  If Fields.HasKey(name.Lexeme) Then
		    If IndexOrKey <> Nil Then
		      // This property is either an array or a hash object.
		      Dim prop As Variant = Fields.Value(name.Lexeme)
		      If prop IsA RooArray Then
		        // Return the element at the specified index.
		        Return ArrayElementAtIndex(prop, name)
		      ElseIf prop IsA RooHash Then
		        // Return the value of the specified key.
		        Return HashValueForKey(prop)
		      Else
		        Raise New RooRuntimeError(name, "You are treating `" + name.Lexeme + "` like an array " + _
		        "or hash but it's not one.")
		      End If
		    Else
		      Return Fields.Value(name.Lexeme)
		    End If
		  End If
		  
		  // When looking up a property on an instance, if we don’t find a matching field, we look for a 
		  // method with that name on the instance’s class. If found, we return that. 
		  Dim method As RooFunction = Klass.FindMethod(Self, name.Lexeme)
		  If method <> Nil Then Return method
		  
		  Raise New RooRuntimeError(name, "Undefined property `" + _
		  name.Lexeme + "` on " + StringValue + ".")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HashValueForKey(hash As RooHash) As Variant
		  // Returns the value of the specified hash key (this instance's `IndexOrKey` property, set by the 
		  // interpreter in its VisitGetExpr method) for the passed Hash object.
		  
		  Return hash.GetValue(IndexOrKey)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name As RooToken, value As Variant)
		  // Set the value of the named field to the passed value. 
		  // If there is no field with this name, create one.
		  Fields.Value(name.Lexeme) = value
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  // Should be overridden by subclasses.
		  
		  If Klass <> Nil Then
		    // Custom class. Has it defined an overriding to_text getter?
		    Dim override As RooFunction = Klass.FindMethod(Self, "to_text")
		    If override <> Nil Then 
		      Dim funcArgs() As Variant
		      Dim overrideResult As Variant = override.Invoke(Klass.interpreter, funcArgs, New RooToken) // HACK.
		      Return Stringable(overrideResult).StringValue
		    Else
		      // This custom class has not defined an override for the `to_text` getter.
		      Return "<" + Klass.Name + " instance>"
		    End If
		    
		  Else
		    Return "<instance>"
		  End If
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		#tag Note
			Key:   Property name (String)
			Value: Property Value
		#tag EndNote
		Fields As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		IndexOrKey As Variant
	#tag EndProperty

	#tag Property, Flags = &h0
		Klass As RooClass
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
