#tag Class
Protected Class RooInstance
Implements Textable
	#tag Method, Flags = &h0
		Sub Constructor(klass as RooClass)
		  self.klass = klass
		  fields = new StringToVariantHashMapMBS(True)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name as Roo.Token) As Variant
		  ' Return the requested property value if this instance has a property with the requested name.
		  if fields.HasKey(name.lexeme) then return fields.Value(name.lexeme)
		  
		  ' We need to handle lookup differently if this instance a native module or a native class.
		  if self isA RooModule and RooModule(self).isNative then
		    dim m as Variant = self.klass.FindNativeMethod(name.lexeme)
		    if m <> Nil then
		      return m
		    else
		      #pragma BreakOnExceptions False
		      raise new RuntimeError(name, "Undefined property `" + name.lexeme + "` on " + self.ToText + ".")
		    end if
		  elseif self isA RooClass and RooClass(self).isNative then
		    return self.klass.Get(name)
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
