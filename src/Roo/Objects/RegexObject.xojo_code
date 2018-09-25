#tag Class
Protected Class RegexObject
Inherits RooInstance
Implements Roo.Textable
	#tag Method, Flags = &h0
		Sub Constructor(expr as RegexLiteralExpr)
		  ' Calling the overridden superclass constructor.
		  Super.Constructor(Nil)
		  
		  pattern = expr.pattern
		  options = expr.options
		  
		  re = New RegExMBS
		  re.CompileOptionCaseLess = expr.optionCaseLess
		  re.CompileOptionDotAll = expr.optionDotAll
		  re.ExecuteOptionNotEmpty = expr.optionNotEmpty
		  re.CompileOptionUngreedy = expr.optionUngreedy
		  re.CompileOptionMultiline = expr.optionMultiline
		  
		  ' Compile the pattern.
		  If Not re.Compile(pattern) Then
		    Raise New RuntimeError(expr.where, "Unable to compile regex pattern: " + Self.ToText(Nil))
		  End If
		  
		  ' Store any named capture groups in the pattern in a hash map where the key is the name
		  ' of the group and the value is it's group index in the pattern.
		  namedGroups = New VariantToVariantHashMapMBS(True)
		  groups = New VariantToVariantHashMapMBS(True)
		  Dim numNamedGroups As Integer = re.InfoNameCount
		  For i As Integer = 1 To numNamedGroups
		    namedGroups.Value(re.InfoNameEntry(i)) = i
		    groups.Value(i) = Nil
		  Next i
		  
		  ' Populate the groups hash map, which stores any regular (non-named) groups.
		  Dim numGroups As Integer = re.InfoCaptureCount
		  For i As Integer = 1 To numGroups
		    groups.Value(i) = Nil
		  Next i
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name as Token) As Variant
		  ' Override RooInstance.Get().
		  
		  If Lookup.RegexMethod(name.Lexeme) Then Return New RegexObjectMethod(Self, name.Lexeme)
		  
		  If Lookup.RegexGetter(name.Lexeme) Then
		    Select Case name.Lexeme
		    Case "nothing?"
		      Return New BooleanObject(False)
		    Case "number?"
		      Return New BooleanObject(False)
		    Case "to_text"
		      Return New TextObject(Self.ToText(Nil))
		    Case "type"
		      Return New TextObject("Regex")
		    End Select
		  End If
		  
		  Raise New RuntimeError(name, "Regex objects have no method named `" + name.lexeme + "`.")
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
		Function ToText(interpreter As Roo.Interpreter) As String
		  ' Part of the Textable interface.
		  
		  #Pragma Unused interpreter
		  
		  Return "|" + pattern + "|" + options
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
