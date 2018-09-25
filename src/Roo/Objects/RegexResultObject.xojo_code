#tag Class
Protected Class RegexResultObject
Inherits RooInstance
Implements Roo.Textable
	#tag Method, Flags = &h0
		Sub Constructor()
		  ' Calling the overridden superclass constructor.
		  super.Constructor(Nil)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMatches() As ArrayObject
		  ' RegexResult.matches as Array
		  ' Returns all matches for this search as an array of RegexMatch objects.
		  
		  dim a as new ArrayObject
		  
		  dim limit as Integer = matches.Ubound
		  for i as Integer = 0 to limit
		    a.elements.Append(matches(i))
		  next i
		  
		  return a
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name as Token) As Variant
		  ' Override RooInstance.Get().
		  
		  if Lookup.RegexResultMethod(name.lexeme) then return new RegexResultObjectMethod(self, name.lexeme)
		  
		  if Lookup.RegexResultGetter(name.lexeme) then
		    select case name.lexeme
		    case "first_match" ' Returns the first RegexMatch object or Nothing if there are no matches.
		      if matches.Ubound >= 0 then
		        return matches(0)
		      else
		        return new NothingObject
		      end if
		    case "length"
		      return new NumberObject(self.matches.Ubound + 1)
		    case "matches"
		      return DoMatches()
		    case "nothing?"
		      return new BooleanObject(False)
		    case "number?"
		      return new BooleanObject(False)
		    case "to_text"
		      return new TextObject(self.ToText(Nil))
		    case "type"
		      return new TextObject("RegexResult")
		    end select
		  end if
		  
		  raise new RuntimeError(name, "RegexResult objects have no method named `" + name.lexeme + "`.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name as Token, value as Variant)
		  #pragma Unused name
		  #pragma Unused value
		  
		  ' Override RooInstance.Set
		  ' We want to prevent both the creating of new fields on Regex objects and setting their values.
		  raise new RuntimeError(name, "Cannot create or set fields on intrinsic data types " +_ 
		  "(RegexResult." + name.lexeme + ").")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter) As String
		  ' Part of the Roo.Textable interface.
		  
		  #Pragma Unused interpreter
		  
		  Return "<RegexResult instance>"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		matches() As RegexMatchObject
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
