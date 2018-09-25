#tag Class
Protected Class RegexMatchObject
Inherits RooInstance
Implements Roo.Textable
	#tag Method, Flags = &h0
		Sub AddValueForGroupNumber(group as Integer, info as MatchInfoObject)
		  ' Stores the passed MatchInfo object as the value for the specified group.
		  
		  groups.Value(group) = info
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddValueForNamedGroup(groupName as String, info as MatchInfoObject)
		  ' Stores the passed MatchInfo object as the value for the specified named group.
		  
		  namedGroups.Value(groupName) = info
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(info as MatchInfoObject)
		  ' Calling the overridden superclass constructor.
		  super.Constructor(Nil)
		  
		  self.namedGroups = new VariantToVariantHashMapMBS(True)
		  self.groups = new VariantToVariantHashMapMBS(True)
		  self.info = info
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoCaptures() As ArrayObject
		  ' RegexMatch.captures as Array
		  ' Returns an array comprised of the value of each numbered capture group where captures(0) is group 1's 
		  ' value, captures(1) is group 2's value, etc.
		  ' Returns an empty array if there are no capture groups.
		  
		  dim captures as new ArrayObject
		  
		  ' Any captures to return?
		  if self.groups.Count = 0 then return captures
		  
		  ' Add each capture group value to the return array
		  dim i as VariantToVariantHashMapIteratorMBS = self.groups.first
		  dim e as VariantToVariantHashMapIteratorMBS = self.groups.last
		  
		  redim captures.elements(self.groups.Count-1)
		  while i.isNotEqual(e)
		    captures.elements(i.Key.IntegerValue - 1) = new TextObject(MatchInfoObject(i.Value).value)
		    i.MoveNext()
		  wend
		  
		  return captures
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name as Token) As Variant
		  ' Override RooInstance.Get().
		  
		  If Lookup.RegexMatchMethod(name.Lexeme) Then Return New RegexMatchObjectMethod(Self, name.Lexeme)
		  
		  If Lookup.RegexMatchGetter(name.Lexeme) Then
		    Select Case name.Lexeme
		    Case "captures"
		      Return DoCaptures()
		    Case "finish"
		      Return New NumberObject(info.finish)
		    Case "nothing?"
		      Return New BooleanObject(False)
		    Case "number?"
		      Return New BooleanObject(False)
		    Case "start"
		      Return New NumberObject(info.start)
		    Case "to_text"
		      Return New TextObject(Self.ToText(Nil))
		    Case "type"
		      Return New TextObject("RegexMatch")
		    Case "value"
		      Return New TextObject(info.value)
		    End Select
		  End If
		  
		  Raise New RuntimeError(name, "RegexMatch objects have no method named `" + name.lexeme + "`.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name as Token, value as Variant)
		  #pragma Unused name
		  #pragma Unused value
		  
		  ' Override RooInstance.Set
		  ' We want to prevent both the creating of new fields on RegexMatch objects and setting their values.
		  raise new RuntimeError(name, "Cannot create or set fields on intrinsic data types " +_ 
		  "(RegexMatch." + name.lexeme + ").")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter) As String
		  ' Part of the Roo.Textable interface.
		  
		  #Pragma Unused interpreter
		  
		  Return "<RegexMatch instance>"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		groups As VariantToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h0
		info As MatchInfoObject
	#tag EndProperty

	#tag Property, Flags = &h0
		namedGroups As VariantToVariantHashMapMBS
	#tag EndProperty


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
