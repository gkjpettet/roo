#tag Class
Protected Class TextObject
Inherits RooInstance
Implements Roo.Dateable
	#tag Method, Flags = &h0
		Sub Constructor(value as String)
		  ' Calling the overridden superclass constructor.
		  super.Constructor(Nil)
		  
		  self.value = value
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoChars() As ArrayObject
		  ' Text.chars
		  ' Converts this Text object's value to its constituent characters and returns them as a new ArrayObject.
		  
		  dim chars() as String
		  dim a as new ArrayObject
		  dim i, limit as Integer
		  
		  chars = self.value.Split("")
		  limit = chars.Ubound
		  for i = 0 to limit
		    ' Remember, each character needs to be converted to a TextObject NOT left as a Xojo String!
		    a.elements.Append(new TextObject(chars(i)))
		  next i
		  
		  return a
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoDefineUTF8(destructive As Boolean) As Variant
		  ' Text.define_utf8  |  Text.define_utf8!
		  ' If destructive then defines this Text object as being UTF-8 encoded and returns this Text object.
		  ' If non-destructive then returns a new Text object with the same value as this Text object but 
		  ' with its encoding defined as UTF-8.
		  ' If Xojo is unable to define the encoding as UTF-8 then we return Nothing.
		  
		  Dim result As String
		  Try
		    result = DefineEncoding(Self.value, Encodings.UTF8)
		  Catch
		    Return New NothingObject
		  End Try
		  
		  If destructive Then
		    Self.value = result
		    Return Self
		  Else
		    Return New TextObject(result)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReverse(destructive as Boolean) As TextObject
		  ' Text.reverse as Text |  Text.reverse! as Text
		  ' Returns a new Text object where the value has been reversed. 
		  ' If `destructive` is True then we also mutate the original value.
		  
		  dim chars() as String = value.Split("")
		  dim result as String
		  dim i, limit as Integer
		  
		  limit = chars.Ubound
		  for i = 0 to limit
		    result = chars(i) + result
		  next i
		  
		  if destructive then value = result
		  
		  return new TextObject(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoSwapCase(destructive as Boolean) As TextObject
		  ' Text.swapcase  |. Text.swapcase!
		  ' Returns a new Text object where the case of each character has been swapped.
		  
		  dim chars() as String = value.Split("")
		  dim result as String
		  dim i, limit, codePoint as Integer
		  
		  limit = chars.Ubound
		  for i = 0 to limit
		    codePoint = Asc(chars(i))
		    select case codePoint
		    case 65 to 90 ' Uppercase character. Add 32 to make it lowercase.
		      result = result + Chr(codePoint + 32)
		    case 97 to 122 ' Lowercase character. Subtract 32 to make it uppercase.
		      result = result + Chr(codePoint - 32)
		    else ' Leave it alone.
		      result = result + chars(i)
		    end select
		  next i
		  
		  value = if(destructive, result, value)
		  
		  return new TextObject(result)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoToDate() As Variant
		  ' Text.to_date as DateTime or Nothing
		  ' If this Text object is in the following formats:
		  ' YYYY-MM-DD HH:MM
		  ' YYYY-MM-DD
		  ' Then this method returns a new DateTime object instantiated to that date and time. If not it 
		  ' returns Nothing.
		  
		  If Self.ToDate = Nil Then
		    Return New NothingObject
		  Else
		    Return New DateTimeObject(Self.ToDate)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name as Token) As Variant
		  ' Override RooInstance.Get().
		  
		  if Lookup.TextMethod(name.lexeme) then return new TextObjectMethod(self, name.lexeme)
		  
		  if Lookup.TextGetter(name.lexeme) then
		    select case name.lexeme
		    case "capitalise"
		      return new TextObject(value.Titlecase)
		    case "capitalise!"
		      value = value.Titlecase
		      return new TextObject(value)
		    case "chars"
		      return DoChars()
		    Case "define_utf8"
		      Return DoDefineUTF8(False)
		    Case "define_utf8!"
		      Return DoDefineUTF8(True)
		    case "empty?"
		      return new BooleanObject(if(value = "", True, False))
		    case "length"
		      return new NumberObject(value.Len)
		    case "lowercase"
		      return new TextObject(value.Lowercase)
		    case "lowercase!"
		      value = value.Lowercase
		      return new TextObject(value)
		    case "lstrip"
		      return new TextObject(value.ToText.TrimLeft)
		    case "lstrip!"
		      value = value.ToText.TrimLeft
		      return new TextObject(value)
		    case "nothing?"
		      return new BooleanObject(False)
		    case "number?"
		      return new BooleanObject(False)
		    case "reverse"
		      return DoReverse(False)
		    case "reverse!"
		      return DoReverse(True)
		    case "rstrip"
		      return new TextObject(value.ToText.TrimRight)
		    case "rstrip!"
		      value = value.ToText.TrimRight
		      return new TextObject(value)
		    case "strip"
		      return new TextObject(value.Trim)
		    case "strip!"
		      value = value.Trim
		      return new TextObject(value)
		    case "swapcase"
		      return DoSwapcase(False)
		    case "swapcase!"
		      return DoSwapCase(True)
		    Case "to_date"
		      Return DoToDate
		    case "to_text"
		      return new TextObject(value)
		    case "type"
		      return new TextObject("Text")
		    case "uppercase"
		      return new TextObject(value.Uppercase)
		    case "uppercase!"
		      value = value.Uppercase
		      return new TextObject(value)
		    end select
		  end if
		  
		  raise new RuntimeError(name, "Text objects have no method named `" + name.lexeme + "`.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name as Token, value as Variant)
		  #pragma Unused name
		  #pragma Unused value
		  
		  ' Override RooInstance.Set
		  ' We want to prevent both the creating of new fields on Text objects and setting their values.
		  raise new RuntimeError(name, "Cannot create or set fields on intrinsic data types " +_ 
		  "(Text." + name.lexeme + ").")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToDate() As Xojo.Core.Date
		  ' Part of the Roo.Dateable interface.
		  ' If possible, convert this text object to a Xojo.Core.Date.
		  ' Text is considered to be a date in the following formats: YYYY-MM-DD HH:MM or YYYY-MM-DD
		  ' If not possible, return Nil.
		  
		  Try
		    Return Xojo.Core.Date.FromText(Self.Value.ToText)
		  Catch err
		    Return Nil
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Part of the Textable interface.
		  
		  return self.value
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		value As String
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
			Name="value"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
