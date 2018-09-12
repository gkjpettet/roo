#tag Module
Protected Module JSON
	#tag Method, Flags = &h21
		Private Function Escape() As Text
		  Dim char As Text = GetChar
		  
		  Select Case char
		  Case """", "\", "/"
		    Return char
		  Case "b"
		    Return Text.FromUnicodeCodepoint(8)
		  Case "f"
		    Return Text.FromUnicodeCodepoint(12)
		  Case "n"
		    Return Text.FromUnicodeCodepoint(10)
		  Case "r"
		    Return Text.FromUnicodeCodepoint(13)
		  Case "t"
		    Return Text.FromUnicodeCodepoint(9)
		  Case "u"
		    Dim unicode As Text = "&h"
		    For i As Integer = 1 to 4
		      char = GetChar
		      If char = "" Then
		        Raise New UnsupportedFormatException
		      Else
		        unicode = unicode + char
		      End If
		    Next i
		    Return Text.FromUnicodeCodepoint(Val(unicode))
		  End Select
		  
		  Exception err
		    Raise New UnsupportedFormatException
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EscapeSpecialCharacters(s As String) As String
		  Return s.ReplaceAll("\","\\") _
		  .ReplaceAll("/","\/") _
		  .ReplaceAll("""","\""") _
		  .ReplaceAll(chr(8),"\b") _
		  .ReplaceAll(chr(12),"\f") _
		  .ReplaceAll(chr(10),"\n") _
		  .ReplaceAll(chr(13),"\r") _
		  .ReplaceAll(chr(9),"\t")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetChar() As Text
		  ' Returns the character at the current pointer position and increments the pointer.
		  
		  Dim char As Text = jsonText.Mid(pointer, 1)
		  
		  pointer =  pointer + 1
		  
		  Return char
		  
		  Exception err
		    Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Initialise()
		  kCarriageReturn = Chr(13).ToText
		  kLineFeed = Chr(10).ToText
		  kSpace = " "
		  kTab = Chr(9).ToText
		  kQuote = """"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Parse(t As Text) As Variant
		  ' Takes JSON as Xojo Text and parses it into a Roo data structure (an array or a Hash).
		  ' If invalid JSON then return Nothing.
		  
		  If not mInitialised Then Initialise
		  
		  pointer = 0
		  jsonText = t
		  SkipWhiteSpace
		  
		  Dim char As Text = GetChar
		  If char = "{" Then
		    pointer = pointer - 1
		    Return ParseObject
		  ElseIf char = "[" Then
		    pointer = pointer - 1
		    Return ParseArray
		  Else
		    Return New NothingObject
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseArray() As Roo.Objects.ArrayObject
		  Dim result As New Roo.Objects.ArrayObject
		  
		  Dim char As Text = GetChar
		  
		  If char <> "[" Then Raise New UnsupportedFormatException
		  
		  ' Check for an empty array.
		  SkipWhiteSpace
		  If GetChar = "]" Then
		    Return result
		  Else
		    pointer = pointer - 1
		  End If
		  
		  Do
		    SkipWhiteSpace
		    
		    result.elements.Append(ParseValue)
		    SkipWhiteSpace
		    
		    char = GetChar
		    If char = "]" Then
		      Return result
		    ElseIf char = "," Then
		      ' Keep looping.
		    Else
		      Raise New UnsupportedFormatException
		    End If
		  Loop
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseNumber() As Double
		  Dim number As Text
		  
		  Dim char As Text = GetChar
		  If char = "-" Then
		    number = "-"
		    char = GetChar
		  End If
		  
		  Select Case char
		  Case "0"
		    Select Case GetChar
		    Case "."
		      GoTo gDecimalPart
		    Case "e"
		      GoTo gExponentPart
		    Else
		      pointer = pointer - 1
		      GoTo gFinish
		    End Select
		  Case "1", "2", "3", "4", "5", "6", "7", "8", "9"
		    number = number + char
		    GoTo gIntegerPart
		  Else
		    Raise New UnsupportedFormatException
		  End Select
		  
		  gIntegerPart:
		  char = GetChar
		  Select Case char
		  Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
		    number = number + char
		    GoTo gIntegerPart
		  Case "."
		    number = number + char
		    GoTo gDecimalPart
		  Case "e", "E"
		    number = number + char
		    GoTo gExponentPart
		  Else
		    pointer = pointer - 1
		    GoTo gFinish
		  End Select
		  
		  gDecimalPart:
		  char = GetChar
		  Select Case char
		  Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
		    number = number + char
		  Else
		    Raise New UnsupportedFormatException
		  End Select
		  
		  gContinueDecimal:
		  char = GetChar
		  Select Case char
		  Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
		    number = number + char
		    GoTo gContinueDecimal
		  Case "e", "E"
		    GoTo gExponentPart
		  Else
		    pointer = pointer - 1
		    GoTo gFinish
		  End Select
		  
		  gExponentPart:
		  char = GetChar
		  Select Case char
		  Case "+", "-"
		    number = number + char
		  Else
		    pointer = pointer - 1
		  End Select
		  
		  gContinueExponent:
		  char = GetChar
		  Select Case char
		  Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
		    number = number + char
		  Else
		    pointer = pointer - 1
		  End Select
		  
		  gFinish:
		  Return Double.FromText(number)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseNumberObject() As Roo.Objects.NumberObject
		  Try
		    Return New NumberObject(ParseNumber)
		  Catch err
		    Raise New UnsupportedFormatException
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseObject() As Variant
		  Dim hash As New Roo.Objects.HashObject
		  
		  Dim char As Text = GetChar
		  
		  If char <> "{" Then Return New NothingObject
		  
		  ' Empty object?
		  SkipWhiteSpace
		  If GetChar = "}" Then
		    Return hash
		  Else
		    ' Rewind the pointer.
		    pointer = pointer - 1
		  End If
		  
		  Do
		    ' Get the key.
		    SkipWhiteSpace
		    Dim key As String = ParseText
		    
		    ' Check for a separator.
		    SkipWhiteSpace
		    If GetChar <> ":" Then Return New NothingObject
		    
		    ' Get the value.
		    SkipWhiteSpace
		    Dim value As Variant = ParseValue
		    
		    ' Add this key/value pair to this hash.
		    hash.Map.Value(key) = value
		    
		    SkipWhiteSpace
		    char = GetChar
		    If char = "," Then
		      ' Keep looping
		    ElseIf char = "}" Then
		      Return hash
		    Else
		      Return New NothingObject
		    End If
		  Loop
		  
		  Exception err
		    Return New NothingObject
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseText() As Text
		  Dim result As Text
		  
		  Dim char As Text = GetChar
		  
		  ' Make sure we encounter a double quote first.
		  If char <> kQuote Then Raise New UnsupportedFormatException
		  
		  Do
		    char = GetChar
		    Select Case char
		    Case kQuote
		      Return result
		    Case "\"
		      result = result + Escape
		    Case ""
		      ' End of input.
		      Return result
		    Else
		      result = result + char
		    End Select
		  Loop
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseTextObject() As Roo.Objects.TextObject
		  Try
		    Return New TextObject(ParseText)
		  Catch err
		    Raise New UnsupportedFormatException
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseValue() As Variant
		  ' Boolean?
		  Try
		    Dim tmp As Text = jsonText.Mid(pointer, 4)
		    Select Case tmp
		    Case "true"
		      Return New BooleanObject(True)
		    Case "fals"
		      Try
		        If jsonText.Mid(pointer + 4, 1) = "e" Then Return New BooleanObject(False)
		      Catch err
		        ' Ignore.
		      End Try
		    Case "null"
		      Return New NothingObject
		    End Select
		  Catch err
		    ' Ignore.
		  End Try
		  
		  Dim char As Text = GetChar
		  Select Case char
		  Case "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
		    ' Rewind the pointer.
		    pointer = pointer - 1
		    Return ParseNumberObject
		  Case """"
		    ' Rewind the pointer.
		    pointer = pointer - 1
		    Return ParseTextObject
		  Case "{"
		    ' Rewind the pointer.
		    pointer = pointer - 1
		    Return ParseObject
		  Case "["
		    ' Rewind the pointer.
		    pointer = pointer - 1
		    Return ParseArray
		  Else
		    Raise New UnsupportedFormatException
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Serialise(v As Variant) As String
		  ' Takes a value and converts it to a JSON String.
		  
		  Dim result As String
		  
		  If v IsA Roo.Objects.HashObject Then
		    result = SerialiseHash(v)
		  ElseIf v IsA Roo.Objects.ArrayObject Then
		    result = SerialiseArray(v)
		  ElseIf v IsA Textable Then
		    result = EscapeSpecialCharacters(Textable(v).ToText)
		  Else
		    result = EscapeSpecialCharacters(v.StringValue)
		  End If
		  
		  If result.Right(1) = "," Then result = result.Left(result.Len - 1)
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SerialiseArray(a As Roo.Objects.ArrayObject) As String
		  Dim buffer As String
		  
		  ' Empty array?
		  If a.elements.Ubound < 0 Then Return "[]"
		  
		  buffer = buffer + "["
		  Dim limit As Integer = a.Elements.Ubound
		  For i As Integer = 0 To limit
		    
		    buffer = buffer + Serialise(a.Elements(i))
		    
		    If i < limit Then buffer = buffer + ","
		    
		  Next i
		  
		  buffer = buffer + "]"
		  
		  Return buffer
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SerialiseHash(h As Roo.Objects.HashObject) As String
		  Dim buffer As String
		  
		  ' Empty hash?
		  If h.Map.Count = 0 Then Return "{}"
		  
		  Dim i As VariantToVariantHashMapIteratorMBS = h.Map.First
		  Dim e As VariantToVariantHashMapIteratorMBS = h.Map.Last
		  
		  buffer = buffer + "{"
		  While i.isNotEqual(e)
		    
		    buffer = buffer + """" + EscapeSpecialCharacters(i.Key) + """:"
		    buffer = buffer + Serialise(i.Value) + ","
		    
		    i.MoveNext
		  Wend
		  
		  If buffer.Right(1) = "," Then buffer = buffer.Left(buffer.Len - 1)
		  
		  buffer = buffer + "}"
		  
		  Return buffer
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SkipWhiteSpace()
		  Do
		    Select Case GetChar
		    Case kCarriageReturn, kLineFeed, kSpace, kTab
		      ' Keep consuming the whitespace.
		    Else
		      ' Rewind the pointer and exit.
		      pointer = pointer - 1
		      Return
		    End Select
		  Loop
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private jsonText As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private kCarriageReturn As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private kLineFeed As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private kQuote As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private kSpace As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private kTab As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mInitialised As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pointer As Integer
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
End Module
#tag EndModule
