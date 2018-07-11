#tag Class
Protected Class RegexLiteralExpr
Inherits Expr
	#tag Method, Flags = &h0
		Function Accept(visitor as ExprVisitor) As Variant
		  return visitor.VisitRegexLiteralExpr(self)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(value as String, where as Token)
		  ' The expression's value will be in the format:
		  ' |SOME REGEX|<options>
		  ' Where <options> is zero or more 'i', 's', 'e', 'u', 'm'. E.g:
		  ' |SOME REGEX|imu
		  
		  self.where = where
		  
		  ' Basic sanity check.
		  if value.Len < 2 or value.Left(1) <> "|" then
		    raise new ParserError(where, "Invalid regex literal format: " + value + ".")
		  end if
		  
		  ' Any options?
		  if value.Right(1) = "|" then ' Nope.
		    pattern = value.Mid(2, value.Len - 2)
		    return
		  end if
		  
		  ' Remove the leading `|`
		  value = value.Right(value.Len - 1)
		  ' Find the trailing slash.
		  dim chars() as String = value.Split("")
		  dim i, upper as Integer
		  upper = chars.Ubound
		  for i = upper downTo 0
		    if chars(i) = "|" then ' Trailing `|`?
		      if i > 0  then
		        ' Edge case check - make sure this hasn't been escaped (e.g: "|hello\|").
		        if chars(i-1) = "\" then raise new ParserError(where, "Invalid regex literal format: " + value + ".")
		        options = value.Right(upper - i)
		        exit
		      end if
		    end if
		  next i
		  
		  ' Remove the options string to get the pattern.
		  pattern = value.Left(value.Len - options.Len - 1)
		  
		  'i', 's', 'e', 'u', 'm'
		  chars = options.Split("")
		  upper = chars.Ubound
		  for i = 0 to upper
		    if StrComp("i", chars(i), 0) = 0 then
		      optionCaseLess = True
		    elseif StrComp("s", chars(i), 0) = 0 then
		      optionDotAll = True
		    elseif StrComp("e", chars(i), 0) = 0 then
		      optionNotEmpty = True
		    elseif StrComp("u", chars(i), 0) = 0 then
		      optionUngreedy = True
		    elseif StrComp("m", chars(i), 0) = 0 then
		      optionMultiline = True
		    else
		      raise new ParserError(where, "invalid regex option `" + chars(i) + "`.")
		    end if
		  next i
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		optionCaseLess As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		optionDotAll As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		optionMultiline As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		optionNotEmpty As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		options As String
	#tag EndProperty

	#tag Property, Flags = &h0
		optionUngreedy As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		pattern As String
	#tag EndProperty

	#tag Property, Flags = &h0
		where As Token
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
		#tag ViewProperty
			Name="pattern"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="optionCaseLess"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="optionDotAll"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="optionMultiline"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="optionNotEmpty"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="options"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="optionUngreedy"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
