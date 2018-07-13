#tag Class
Protected Class RegexObject
Inherits RooInstance
	#tag Method, Flags = &h0
		Sub Constructor(expr as RegexLiteralExpr)
		  ' Calling the overridden superclass constructor.
		  super.Constructor(Nil)
		  
		  pattern = expr.pattern
		  options = expr.options
		  
		  re = new RegExMBS
		  re.CompileOptionCaseLess = expr.optionCaseLess
		  re.CompileOptionDotAll = expr.optionDotAll
		  re.ExecuteOptionNotEmpty = expr.optionNotEmpty
		  re.CompileOptionUngreedy = expr.optionUngreedy
		  re.CompileOptionMultiline = expr.optionMultiline
		  
		  ' Compile the pattern.
		  if not re.Compile(pattern) then
		    raise new RuntimeError(expr.where, "Unable to compile regex pattern: " + self.ToText())
		  end if
		  
		  ' Store any named capture groups in the pattern in a hash map where the key is the name 
		  ' of the group and the value is it's group index in the pattern.
		  namedGroups = new VariantToVariantHashMapMBS(True)
		  groups = new VariantToVariantHashMapMBS(True)
		  dim numNamedGroups as Integer = re.InfoNameCount
		  for i as Integer = 1 to numNamedGroups
		    namedGroups.Value(re.InfoNameEntry(i)) = i
		    groups.Value(i) = Nil
		  next i
		  
		  ' Populate the groups hash map, which stores any regular (non-named) groups.
		  dim numGroups as Integer = re.InfoCaptureCount
		  for i as Integer = 1 to numGroups
		    groups.Value(i) = Nil
		  next i
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name as Token) As Variant
		  ' Override RooInstance.Get().
		  
		  if Lookup.RegexMethod(name.lexeme) then return new RegexObjectMethod(self, name.lexeme)
		  
		  if Lookup.RegexGetter(name.lexeme) then
		    select case name.lexeme
		    case "nothing?"
		      return new BooleanObject(False)
		    case "number?"
		      return new BooleanObject(False)
		    case "to_text"
		      return new TextObject(self.ToText)
		    end select
		  end if
		  
		  raise new RuntimeError(name, "Regex objects have no method named `" + name.lexeme + "`.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name as Token, value as Variant)
		  #pragma Unused name
		  #pragma Unused value
		  
		  ' Override RooInstance.Set
		  ' We want to prevent both the creating of new fields on Regex objects and setting their values.
		  raise new RuntimeError(name, "Cannot create or set fields on intrinsic data types " +_ 
		  "(Regex." + name.lexeme + ").")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Part of the Textable interface.
		  
		  return "|" + pattern + "|" + options
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		groups As VariantToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h0
		namedGroups As VariantToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h0
		options As String
	#tag EndProperty

	#tag Property, Flags = &h0
		pattern As String
	#tag EndProperty

	#tag Property, Flags = &h0
		re As RegExMBS
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
			Name="pattern"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="options"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
