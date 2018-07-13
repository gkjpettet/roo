#tag Class
Protected Class MatchInfoObject
Inherits RooInstance
	#tag Method, Flags = &h0
		Sub Constructor(start as Integer, finish as Integer, value as String)
		  ' Calling the overridden superclass constructor.
		  super.Constructor(Nil)
		  
		  self.start = start
		  self.finish = finish
		  self.value = value
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name as Token) As Variant
		  ' Override RooInstance.Get().
		  
		  if Lookup.MatchInfoMethod(name.lexeme) then return new MatchInfoObjectMethod(self, name.lexeme)
		  
		  if Lookup.MatchInfoGetter(name.lexeme) then
		    select case name.lexeme
		    case "finish"
		      return new NumberObject(self.finish)
		    case "nothing?"
		      return new BooleanObject(False)
		    case "number?"
		      return new BooleanObject(False)
		    case "start"
		      return new NumberObject(self.start)
		    case "to_text"
		      return new TextObject(self.ToText)
		    case "value"
		      return new TextObject(self.value)
		    end select
		  end if
		  
		  raise new RuntimeError(name, "MatchInfo objects have no method named `" + name.lexeme + "`.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name as Token, value as Variant)
		  #pragma Unused name
		  #pragma Unused value
		  
		  ' Override RooInstance.Set
		  ' We want to prevent both the creating of new fields on Regex objects and setting their values.
		  raise new RuntimeError(name, "Cannot create or set fields on intrinsic data types " +_ 
		  "(MatchInfo." + name.lexeme + ").")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  return "<MatchInfoObject instance>"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		finish As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		start As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		value As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="finish"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
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
			Name="start"
			Group="Behavior"
			Type="Integer"
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
		#tag ViewProperty
			Name="value"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
