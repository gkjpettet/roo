#tag Class
Protected Class NumberObject
Inherits RooInstance
Implements Roo.Textable
	#tag Method, Flags = &h0
		Sub Constructor(value as Double)
		  ' Calling the overridden superclass constructor.
		  super.Constructor(Nil)
		  
		  self.value = value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Even() As Boolean
		  ' Returns True if this number object is an even integer.
		  
		  if not IsInteger then return False
		  
		  return if(self.value Mod 2 = 0, True, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name as Token) As Variant
		  ' Override RooInstance.Get().
		  
		  if Lookup.NumberMethod(name.lexeme) then return new NumberObjectMethod(self, name.lexeme)
		  
		  if Lookup.NumberGetter(name.lexeme) then
		    select case name.lexeme
		    case "abs"
		      return new NumberObject(Abs(value))
		    case "acos"
		      return new NumberObject(ACos(value))
		    case "asin"
		      return new NumberObject(ASin(value))
		    case "atan"
		      return new NumberObject(ATan(value))
		    case "ceil"
		      return new NumberObject(Ceil(value))
		    case "cos"
		      return new NumberObject(Cos(value))
		    case "even?"
		      return new BooleanObject(self.Even())
		    case "floor"
		      return new NumberObject(Floor(value))
		    case "integer?"
		      return new BooleanObject(self.IsInteger())
		    case "nothing?"
		      return new BooleanObject(False)
		    case "number?"
		      return new BooleanObject(True)
		    case "odd?"
		      return new BooleanObject(self.Odd())
		    case "round"
		      return new NumberObject(Round(value))
		    case "sign"
		      return new NumberObject(Sign(value))
		    case "sin"
		      return new NumberObject(Sin(value))
		    case "sqrt"
		      return new NumberObject(Sqrt(value))
		    case "tan"
		      return new NumberObject(Tan(value))
		    case "to_degrees"
		      return new NumberObject(value * 57.295779513)
		    case "to_radians"
		      return new NumberObject(value / 57.295779513)
		    case "to_text"
		      return new TextObject(self.ToText())
		    case "type"
		      return new TextObject("Number")
		    end select
		  end if
		  
		  raise new RuntimeError(name, "Number objects have no method named `" + name.lexeme + "`.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsInteger() As Boolean
		  ' Returns True if this number is an integer. False if it's a double.
		  
		  return if(Round(self.value) = self.value, True, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Odd() As Boolean
		  ' Returns True if this number object is an odd integer.
		  
		  if not IsInteger then return False
		  
		  return if(self.value Mod 2 <> 0, True, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name as Token, value as Variant)
		  #pragma Unused name
		  #pragma Unused value
		  
		  ' Override RooInstance.Set
		  ' We want to prevent both the creating of new fields on Number objects and setting their values.
		  raise new RuntimeError(name, "Cannot create or set fields on intrinsic data types " +_ 
		  "(Number." + name.lexeme + ").")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter = Nil) As String
		  ' Part of the Textable interface.
		  
		  #Pragma Unused interpreter
		  
		  If value.IsInteger Then
		    Dim i As Integer = value
		    Return Str(i)
		  Else
		    Return Str(value)
		  End If
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		value As Double
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
			Type="Double"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
