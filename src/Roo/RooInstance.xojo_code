#tag Class
Protected Class RooInstance
Implements Textable
	#tag Method, Flags = &h1
		Protected Function ArrayElementAtIndex(theArray As Roo.Objects.ArrayObject, where As Roo.Token) As Variant
		  ' Takes an array object and (if possible) returns the element specified by this instance's 
		  ' `IndexOrKey` property (set by the Interpreter.VisitGetExpr method.
		  ' Raises a runtime error if there's a problem.
		  
		  ' Make sure that index is a Number object.
		  If Not IndexOrKey IsA Roo.Objects.NumberObject Then
		    Raise New RuntimeError(where, "Invalid array index. Expected a Number object. Instead got `" + _
		    VariantType(IndexOrKey) + "`.")
		  End If
		  
		  ' And an integer.
		  If Not Roo.Objects.NumberObject(IndexOrKey).IsInteger Then
		    Raise New RuntimeError(where,   "Invalid array index. Expected an integer. Instead got `" + _
		    Str(Roo.Objects.NumberObject(IndexOrKey).Value) + "`.")
		  End If
		  
		  Try
		    Return theArray.Elements(Roo.Objects.NumberObject(IndexOrKey).Value)
		  Catch err
		    Raise New RuntimeError(where, "Invalid array index: `" + _
		    Str(Roo.Objects.NumberObject(IndexOrKey).Value) + "`.")
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(klass as RooClass)
		  Self.klass = klass
		  fields = New StringToVariantHashMapMBS(True)
		  Self.IndexOrKey = Nil
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name As Roo.Token) As Variant
		  ' Return the requested property value if this instance has a property with the requested name.
		  If fields.HasKey(name.lexeme) Then
		    If indexOrKey <> Nil Then
		      ' This property is either an array or a hash object.
		      Dim prop As Variant = fields.Value(name.lexeme)
		      If prop IsA Roo.Objects.ArrayObject Then
		        ' This property is an array. Return the element at the specified index.
		        Return ArrayElementAtIndex(prop, name)
		      ElseIf prop IsA Roo.Objects.HashObject Then
		        ' This property is a hash. Return the value of the specified key.
		        Return HashValueForKey(prop)
		      Else
		        Raise New RuntimeError(name, "You are treating `" + name.lexeme + "` like an array " + _
		        "or hash but it is not one.")
		      End If
		    Else
		      Return fields.Value(name.lexeme)
		    End If
		  End If
		  
		  ' We need to handle lookup differently if this instance a native module or a native class.
		  If Self IsA RooModule And RooModule(Self).isNative Then
		    Dim m As Variant = Self.klass.FindNativeMethod(name.lexeme)
		    If m <> Nil Then
		      Return m
		    Else
		      Raise New RuntimeError(name, "Undefined property `" + name.lexeme + "` on " + self.ToText + ".")
		    End If
		  ElseIf Self IsA RooClass And RooClass(Self).isNative Then
		    Return Self.klass.Get(name)
		  end if
		  
		  ' ===========================================================================================
		  ' Handle the generic object getters and methods.
		  ' ===========================================================================================
		  ' Getters
		  if StrComp(name.lexeme, "nothing?", 0) = 0 then
		    return if(self.klass isA NothingObject, new BooleanObject(True), new BooleanObject(False))
		  elseif StrComp(name.lexeme, "to_text", 0) = 0 then
		    return if(self.klass = Nil, new TextObject("No text representation"), new TextObject(self.ToText))
		  elseif StrComp(name.lexeme, "type", 0) = 0 then
		    if self.klass <> Nil then
		      return new TextObject(self.klass.name)
		    else
		      return new TextObject(self.ToText)
		    end if
		  end if
		  ' Methods
		  if StrComp(name.lexeme, "responds_to?", 0) = 0 then
		    return new GenericObjectRespondsToMethod(self)
		  end if
		  ' ===========================================================================================
		  
		  ' When looking up a property on an instance, if we don’t find a matching field, we look for a 
		  ' method with that name on the instance’s class. If found, we return that. 
		  dim method as RooFunction = self.klass.FindMethod(self, name.lexeme)
		  if method <> Nil then return method
		  
		  #pragma BreakOnExceptions False
		  raise new RuntimeError(name, "Undefined property `" + name.lexeme + "` on " + self.ToText + ".")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HashValueForKey(hash As Roo.Objects.HashObject) As Variant
		  ' Returns the value of the specified key (this instance's `IndexOrKey` property, set by the 
		  ' interpreter in its VisitGetExpr method) for the passed Hash object.
		  
		  Return hash.GetValue(IndexOrKey)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name as Token, value as Variant)
		  ' Set the value of the named field to the passed value. If there is no field with this name, create one.
		  self.fields.Value(name.lexeme) = value
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  return "<" + klass.name + " instance>"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		#tag Note
			Key:   Property name (String)
			Value: Property Value
		#tag EndNote
		fields As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h0
		IndexOrKey As Variant
	#tag EndProperty

	#tag Property, Flags = &h0
		isNative As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		klass As RooClass
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
		#tag ViewProperty
			Name="isNative"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
