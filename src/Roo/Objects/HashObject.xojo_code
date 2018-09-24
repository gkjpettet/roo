#tag Class
Protected Class HashObject
Inherits RooInstance
Implements Roo.Textable
	#tag Method, Flags = &h0
		Sub Constructor()
		  ' Calling the overridden superclass constructor.
		  super.Constructor(Nil)
		  
		  self.map = new VariantToVariantHashMapMBS
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(map as VariantToVariantHashMapMBS)
		  ' Calling the overridden superclass constructor.
		  super.Constructor(Nil)
		  
		  self.map = map
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoInvert(destructive as Boolean) As HashObject
		  ' Hash.invert as HashObject
		  ' Hash.invert! as HashObject
		  ' Returns a new hash object created using this hash's values as keys and the keys as values.
		  ' If a key with the same value already exists in the hash then the last one encountered will be used with 
		  ' earlier values being discarded.
		  
		  dim newHash as new HashObject
		  dim newValue, oldValue as Variant
		  
		  dim i as VariantToVariantHashMapIteratorMBS = map.first
		  dim e as VariantToVariantHashMapIteratorMBS = map.last
		  
		  while i.isNotEqual(e)
		    newValue = i.Key
		    oldValue = i.Value
		    
		    ' Remember that text, number and boolean keys are stored as literal values, not their runtime 
		    ' object representations. We will need to convert them to Roo classes once they are converted to values.
		    select case newValue.Type
		    case Variant.TypeString
		      newValue = new TextObject(newValue)
		    case Variant.TypeDouble
		      newValue = new NumberObject(newValue)
		    case Variant.TypeBoolean
		      newValue = new BooleanObject(newValue)
		    end select
		    
		    newHash.map.Value(oldValue) = newValue
		    
		    i.MoveNext()
		  wend
		  
		  if destructive then map = newHash.map.Clone()
		  
		  return newHash
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoKeys() As ArrayObject
		  ' Hash.keys as Array
		  ' Returns the keys of this hash object as an array object.
		  
		  dim i as VariantToVariantHashMapIteratorMBS = map.first
		  dim e as VariantToVariantHashMapIteratorMBS = map.last
		  
		  dim a as new ArrayObject
		  
		  while i.isNotEqual(e)
		    if i.Key.Type = Variant.TypeString then
		      a.elements.Append(new TextObject(i.Key))
		    elseif i.Key.Type = Variant.TypeDouble then
		      a.elements.Append(new NumberObject(i.Key))
		    elseif i.Key.Type = Variant.TypeBoolean then
		      a.elements.Append(new BooleanObject(i.Key))
		    else
		      a.elements.Append(i.Key)
		    end if
		    i.MoveNext()
		  wend
		  
		  return a
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoValues() As ArrayObject
		  ' Hash.values as Array
		  ' Returns the values of this hash as an array object.
		  
		  dim i as VariantToVariantHashMapIteratorMBS = map.first
		  dim e as VariantToVariantHashMapIteratorMBS = map.last
		  
		  dim a as new ArrayObject
		  
		  while i.isNotEqual(e)
		    if i.Value.Type = Variant.TypeString then
		      a.elements.Append(new TextObject(i.Value))
		    elseif i.Value.Type = Variant.TypeDouble then
		      a.elements.Append(new NumberObject(i.Value))
		    elseif i.Value.Type = Variant.TypeBoolean then
		      a.elements.Append(new BooleanObject(i.Value))
		    else
		      a.elements.Append(i.Value)
		    end if
		    i.MoveNext()
		  wend
		  
		  return a
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name as Token) As Variant
		  ' Override RooInstance.Get().
		  
		  if Lookup.HashMethod(name.lexeme) then return new HashObjectMethod(self, name.lexeme)
		  
		  if Lookup.HashGetter(name.lexeme) then
		    select case name.lexeme
		    case "clear!"
		      map = new VariantToVariantHashMapMBS(True)
		      return self
		    case "invert"
		      return DoInvert(False)
		    case "invert!"
		      return DoInvert(True)
		    case "keys"
		      return DoKeys()
		    case "length"
		      return new NumberObject(map.Count)
		    case "nothing?"
		      return new BooleanObject(False)
		    case "number?"
		      return new BooleanObject(False)
		    case "to_text"
		      return new TextObject(self.ToText)
		    case "type"
		      return new TextObject("Hash")
		    case "values"
		      return DoValues()
		    end select
		  end if
		  
		  raise new RuntimeError(name, "Hash objects have no method named `" + name.lexeme + "`.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetValue(keyObject as Variant) As Variant
		  ' Returns the value of the specified key. If `key` does not exist in this Hash then we return Nothing.
		  
		  if not self.HasKey(keyObject) then return new NothingObject
		  
		  dim key as Variant
		  
		  if map.HasKey(keyObject) then
		    return map.Value(keyObject)
		  elseif keyObject isA TextObject then
		    key = TextObject(keyObject).value
		  elseif keyObject isA NumberObject then
		    key = NumberObject(keyObject).value
		  elseif keyObject isA BooleanObject then
		    key = BooleanObject(keyObject).value
		  end if
		  
		  return map.Value(key)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasKey(obj as Variant) As Boolean
		  ' Returns True if this Hash contains the specified key. 
		  
		  dim key as Variant
		  
		  if obj = Nil then return False
		  
		  if map.HasKey(obj) then
		    return True
		  elseif obj isA TextObject then
		    key = TextObject(obj).value
		  elseif obj isA NumberObject then
		    key = NumberObject(obj).value
		  elseif obj isA BooleanObject then
		    key = BooleanObject(obj).value
		  end if
		  
		  return map.HasKey(key)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasValue(what as Variant) As Boolean
		  ' Returns True if this Hash contains the specified value. 
		  
		  dim i as VariantToVariantHashMapIteratorMBS = map.first
		  dim e as VariantToVariantHashMapIteratorMBS = map.last
		  
		  while i.isNotEqual(e)
		    if i.Value = what then return True
		    if i.Value isA NothingObject and what isA NothingObject then return True
		    if what isA TextObject and i.Value isA TextObject then
		      if TextObject(i.Value).value = TextObject(what).value then return True
		    end if
		    if what isA NumberObject and i.Value isA NumberObject then
		      if NumberObject(i.Value).value = NumberObject(what).value then return True
		    end if
		    if what isA BooleanObject and i.Value isA BooleanObject then
		      if BooleanObject(i.Value).value = BooleanObject(what).value then return True
		    end if
		    i.MoveNext()
		  wend
		  
		  return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name as Token, value as Variant)
		  #Pragma Unused name
		  #Pragma Unused value
		  
		  ' Override RooInstance.Set
		  ' We want to prevent both the creating of new fields on Hash objects and setting their values.
		  Raise New RuntimeError(name, "Cannot create or set fields on intrinsic data types " +_ 
		  "(Hash." + name.Lexeme + ").")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter = Nil) As String
		  ' Part of the Textable interface.
		  
		  #Pragma Unused interpreter
		  
		  Dim k, v, t, QUOTE As String
		  Dim d As Double
		  
		  QUOTE = """"
		  
		  t = "{"
		  
		  Dim i As VariantToVariantHashMapIteratorMBS = map.first
		  Dim e As VariantToVariantHashMapIteratorMBS = map.last
		  
		  While i.isNotEqual(e)
		    ' Key as text.
		    If i.Key IsA TextObject Then
		      k = QUOTE + TextObject(i.Key).value + QUOTE
		    ElseIf i.Key.Type = Variant.TypeString Then
		      k = QUOTE + i.Key.StringValue + QUOTE
		    ElseIf i.Key IsA NumberObject Then
		      d = NumberObject(i.Key).value
		      k = If(d.IsInteger, d.ToInteger.ToText, d.ToText)
		    ElseIf i.Key IsA Textable Then
		      k = Textable(i.Key).ToText
		    ElseIf i.Key.Type = Variant.TypeDouble Then
		      k = DoubleToString(i.Key)
		    Else
		      k = i.Key.StringValue
		    End If
		    
		    ' Value as text.
		    If i.Value IsA TextObject Then
		      v = QUOTE + TextObject(i.Value).value + QUOTE
		    ElseIf i.Value IsA NumberObject Then
		      d = NumberObject(i.Value).value
		      v = If(d.IsInteger, d.ToInteger.ToText, d.ToText)
		    Else
		      v = Textable(i.Value).ToText
		    End If
		    
		    t = t + k + " => " + v + ", "
		    i.MoveNext()
		  Wend
		  
		  t = t.Trim()
		  
		  If t.Right(1) = "," Then t = t.Left(t.Len - 1)
		  
		  Return t + "}"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		map As VariantToVariantHashMapMBS
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
