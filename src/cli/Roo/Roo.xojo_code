#tag Module
Protected Module Roo
	#tag Method, Flags = &h1
		Protected Sub AssertAreIntegers(where As RooToken, ParamArray operands As Variant)
		  // Check that the passed operands are integer RooNumbers. If any aren't, raise an error.
		  
		  For Each operand As Variant In operands
		    If operand IsA RooNumber = False Then
		      Dim type As String
		      If operand IsA RooNativeClass Then
		        type = RooNativeClass(operand).Type + " object"
		      ElseIf operand IsA RooNativeModule Then
		        type = "module"
		      Else
		        type = Stringable(operand).StringValue
		      End If
		      Raise New RooRuntimeError(where, "Expected a number operand but got " + type)
		    Else
		      If Not IsInteger(RooNumber(operand).Value) Then
		        Raise New RooRuntimeError(where, "Expected an integer operand but got a double")
		      End If
		    End If
		  Next operand
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AssertAreNumbers(where As RooToken, ParamArray operands As Variant)
		  // Asserts that the passed operands are RooNumbers. If any aren't, raise an error.
		  
		  For Each operand As Variant In operands
		    If operand IsA RooNumber = False Then
		      Raise New RooRuntimeError(where, "Expected a number operand.")
		    End If
		  Next operand
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AssertArePositiveIntegers(where As RooToken, ParamArray operands As Variant)
		  // Asserts that the passed operands are positive integer RooNumbers. If any aren't, raise an error.
		  
		  For Each operand As Variant In operands
		    If operand IsA RooNumber = False Then
		      Dim type As String
		      If operand IsA RooNativeClass Then
		        type = RooNativeClass(operand).Type + " object"
		      ElseIf operand IsA RooNativeModule Then
		        type = "module"
		      Else
		        type = Stringable(operand).StringValue
		      End If
		      Raise New RooRuntimeError(where, "Expected a number operand but got " + type + ".")
		    Else
		      If Not IsInteger(RooNumber(operand).Value) Then
		        Raise New RooRuntimeError(where, "Expected an integer operand but got a double.")
		      Else
		        If RooNumber(operand).Value < 0 Then
		          Raise New RooRuntimeError(where, "Expected a positive integer operand but got a negative one.")
		        End If
		      End If
		    End If
		  Next operand
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AssertAreTextObjects(where As RooToken, ParamArray operands As Variant)
		  // Asserts that the passed operands are RooText objects. If any aren't, raise an error.
		  
		  For Each operand As Variant In operands
		    If operand IsA RooText = False Then
		      Raise New RooRuntimeError(where, "Expected a Text object operand.")
		    End If
		  Next operand
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AssertIsArray(where As RooToken, operand As Variant)
		  // Checks that the passed operand is an Array object. Raises an error if it isn't.
		  
		  If operand IsA RooArray = False Then
		    Raise New RooRuntimeError(where, "Expected an array operand.")
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AssertIsBoolean(where As RooToken, operand As Variant)
		  // Checks that the passed operand is a Roo Boolean object. Raises an error if it doesn't.
		  
		  If operand IsA RooBoolean = False Then
		    Raise New RooRuntimeError(where, "Expected a Boolean operand.")
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AssertIsHash(where As RooToken, operand As Variant)
		  // Checks that the passed operand is a Hash object Raises an error if it doesn't.
		  
		  If operand IsA RooHash = False Then
		    Raise New RooRuntimeError(where, "Expected an array operand.")
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AssertIsInteger(where As RooToken, operand As Variant)
		  // Checks that the passed operand is an integer RooNumber. If any not, raise an error.
		  
		  If operand IsA RooNumber = False Then
		    Dim type As String
		    If operand IsA RooNativeClass Then
		      type = RooNativeClass(operand).Type + " object"
		    ElseIf operand IsA RooNativeModule Then
		      type = "module"
		    Else
		      type = Stringable(operand).StringValue
		    End If
		    Raise New RooRuntimeError(where, "Expected a number operand but got " + type)
		  End If
		  
		  If Not IsInteger(RooNumber(operand).Value) Then
		    Raise New RooRuntimeError(where, "Expected an integer operand but got a double")
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AssertIsInvokable(where As RooToken, operand As Variant)
		  // Checks that the passed operand adheres to the Invokable interface. Raises an error if it doesn't.
		  
		  If operand IsA Invokable = False Then
		    Raise New RooRuntimeError(where, "Expected an invokable operand.")
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AssertIsPositiveInteger(where As RooToken, operand As Variant)
		  // Asserts that the passed operand is positive integer RooNumber. If any not, raise an error.
		  
		  If operand IsA RooNumber = False Then
		    Dim type As String
		    If operand IsA RooNativeClass Then
		      type = RooNativeClass(operand).Type + " object"
		    ElseIf operand IsA RooNativeModule Then
		      type = "module"
		    Else
		      type = Stringable(operand).StringValue
		    End If
		    Raise New RooRuntimeError(where, "Expected a number operand but got " + type + ".")
		  End If
		  
		  If Not IsInteger(RooNumber(operand).Value) Then
		    Raise New RooRuntimeError(where, "Expected an integer operand but got a double.")
		  Else
		    If RooNumber(operand).Value < 0 Then
		      Raise New RooRuntimeError(where, "Expected a positive integer operand but got a negative one.")
		    End If
		  End If
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AssertIsRegex(where As RooToken, operand As Variant)
		  // Checks that the passed operand is a Regex object. Raises an error if it isn't.
		  
		  If operand IsA RooRegex = False Then
		    Raise New RooRuntimeError(where, "Expected a Regex operand.")
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AssertIsStringable(where As RooToken, operand As Variant)
		  // Checks that the passed operand adheres to the Stringable interface. Raises an error if it doesn't.
		  
		  If operand IsA Stringable = False Then
		    Raise New RooRuntimeError(where, "Expected an object with a text representation.")
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AssertIsTextObject(where As RooToken, operand As Variant)
		  // Checks that the passed operand is a Roo Boolean object. Raises an error if it doesn't.
		  
		  If operand IsA RooText = False Then
		    Raise New RooRuntimeError(where, "Expected a Text operand.")
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function AutoType(a As Auto) As Roo.ObjectType
		  If a = Nil Then Return ObjectType.XojoNil
		  
		  Dim ti As Xojo.Introspection.TypeInfo = Xojo.Introspection.GetType(a)
		  
		  If ti.IsArray Then Return ObjectType.XojoArray
		  
		  Select Case ti.FullName
		  Case "String"
		    Return ObjectType.XojoString
		  Case "Text"
		    Return ObjectType.XojoText
		  Case "Int64", "Int32", "Int16", "Int8", "UInt64", "UInt32", "UInt16", "UInt8"
		    Return ObjectType.XojoInteger
		  Case "Boolean"
		    Return ObjectType.XojoBoolean
		  Case "Double"
		    Return ObjectType.XojoDouble
		  Case "RooArray"
		    Return ObjectType.RooArray
		  Case "RooBoolean"
		    Return ObjectType.RooBoolean
		  Case "RooDateTime"
		    Return ObjectType.RooDateTime
		  Case "RooHash"
		    Return ObjectType.RooHash
		  Case "RooNothing"
		    Return ObjectType.RooNothing
		  Case "RooNumber"
		    Return ObjectType.RooNumber
		  Case "RooText"
		    Return ObjectType.RooText
		  Case "Xojo.Core.Dictionary"
		    Return If(IsCaseSensitive(a), ObjectType.XojoCaseSensitiveDictionary, ObjectType.XojoModernDictionary)
		  Case "Xojo.Core.Date"
		    Return ObjectType.XojoDate
		  Case "Dictionary"
		    Return ObjectType.XojoClassicDictionary
		  Else
		    Return ObjectType.Unknown
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CaseSensitiveDictionary() As Xojo.Core.Dictionary
		  // Returns a new Xojo.Core.Dictionary that is case-sensitive.
		  // Exploits a bug (feature?) of Xojo.Data.ParseJSON that returns a case-sensitive dictionary.
		  Return Xojo.Data.ParseJSON("{}")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function DayNameFromDate(d As Xojo.Core.Date) As String
		  // Returns the name of the passed Xojo Date object (1 = Sunday, 7 = Saturday). 
		  
		  Select Case d.DayOfWeek
		  Case 1
		    Return "Sunday"
		  Case 2
		    Return "Monday"
		  Case 3
		    Return "Tuesday"
		  Case 4
		    Return "Wednesday"
		  Case 5
		    Return "Thursday"
		  Case 6
		    Return "Friday"
		  Case 7
		    Return "Saturday"
		  Else
		    Return ""
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function DoubleToInteger(d As Double) As Integer
		  // Returns this double as an integer.
		  Dim i As Integer = d
		  Return i
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function FolderItemToRooPath(f As FolderItem) As String
		  // Returns this FolderItem's path as a Roo path. A Roo path is essentially a UNIX path.
		  
		  If f = Nil Then Return ""
		  
		  Dim tmp As New FolderItem(f.NativePath, FolderItem.PathTypeNative)
		  
		  Dim path As String
		  Do
		    If tmp.Parent <> Nil Then
		      path = "/" + tmp.Name + path
		      tmp = tmp.Parent
		    Else
		      Exit
		    End If
		  Loop
		  
		  Return path
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Initialise()
		  If mInitialised Then Return
		  
		  RooSLCache.Initialise
		  
		  mInitialised = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsCaseSensitive(d As Xojo.Core.Dictionary) As Boolean
		  // Returns True if the passed Dictionary is case-sensitive.
		  
		  // Add a random lowercase text value.
		  Dim test As Text = "±§,./abc"
		  d.Value(test) = ""
		  
		  // Query the dictionary with the uppercase variant of the random text.
		  // If the dictionary believes this is present then this can't be a case-sensitive dictionary.
		  Dim result As Boolean = Not d.HasKey(test.Uppercase)
		  
		  // Remove the random key we added.
		  d.Remove(test)
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsInteger(d As Double) As Boolean
		  // Returns True if d is an integer. False if it's a double.
		  
		  Return If(Round(d) = d, True, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LongMonthFromDate(d As Xojo.Core.Date) As String
		  // Returns the passed Xojo Date's month in human-readable form.
		  // E.g: 1 --> "January"
		  
		  Select Case d.Month
		  Case 1
		    Return "January"
		  Case 2
		    Return "February"
		  Case 3
		    Return "March"
		  Case 4
		    Return "April"
		  Case 5
		    Return "May"
		  Case 6
		    Return "June"
		  Case 7
		    Return "July"
		  Case 8
		    Return "August"
		  Case 9
		    Return "September"
		  Case 10
		    Return "October"
		  Case 11
		    Return "November"
		  Case 12
		    Return "December"
		  Else
		    Return ""
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LongMonthFromInteger(i As Integer) As String
		  // Takes an integer month value (1 to 12) and returns it as a month String value.
		  // E.g: 1 --> "January"
		  
		  Select Case i
		  Case 1
		    Return "January"
		  Case 2
		    Return "February"
		  Case 3
		    Return "March"
		  Case 4
		    Return "April"
		  Case 5
		    Return "May"
		  Case 6
		    Return "June"
		  Case 7
		    Return "July"
		  Case 8
		    Return "August"
		  Case 9
		    Return "September"
		  Case 10
		    Return "October"
		  Case 11
		    Return "November"
		  Case 12
		    Return "December"
		  Else
		    Return ""
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function MeridiemFromDate(d As Xojo.Core.Date) As String
		  // Returns the passed Xojo Date's meridiem
		  
		  Return If(d.Hour < 12, "AM", "PM")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ShortMonthFromDate(d As Xojo.Core.Date) As String
		  // Returns the passed Xojo Date's month as a three character month.
		  // E.g: 1 --> "Jan"
		  
		  Select Case d.Month
		  Case 1
		    Return "Jan"
		  Case 2
		    Return "Feb"
		  Case 3
		    Return "Mar"
		  Case 4
		    Return "Apr"
		  Case 5
		    Return "May"
		  Case 6
		    Return "Jun"
		  Case 7
		    Return "Jul"
		  Case 8
		    Return "Aug"
		  Case 9
		    Return "Sep"
		  Case 10
		    Return "Oct"
		  Case 11
		    Return "Nov"
		  Case 12
		    Return "Dec"
		  Else
		    Return ""
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function TwoDigitDayFromDate(d As Xojo.Core.Date) As String
		  // Returns the passed Xojo Date's day value as a two digit String.
		  // E.g: 1 --> "01"
		  
		  If d.Day < 10 Then
		    Return "0" + Str(d.Day)
		  Else
		    Return Str(d.Day)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function TwoDigitHourFromDate(d As Xojo.Core.Date) As String
		  // Returns the passed Xojo Date's hour value as a two digit String.
		  // E.g: 1 --> "01"
		  
		  If d.Hour < 10 Then
		    Return "0" + Str(d.Hour)
		  Else
		    Return Str(d.Hour)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function TwoDigitMinuteFromDate(d As Xojo.Core.Date) As String
		  // Returns the passed Xojo Date's minute value as a two digit String.
		  // E.g: 1 --> "01"
		  
		  If d.Minute < 10 Then
		    Return "0" + Str(d.Minute)
		  Else
		    Return Str(d.Minute)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function TwoDigitSecondFromDate(d As Xojo.Core.Date) As String
		  // Returns the passed Xojo Date's second value as a two digit String.
		  // E.g: 1 --> "01"
		  
		  If d.Second < 10 Then
		    Return "0" + Str(d.Second)
		  Else
		    Return Str(d.Second)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function VariantTypeAsString(v As Variant) As String
		  Dim type As ObjectType = AutoType(v)
		  
		  Select Case type
		  Case ObjectType.RooArray
		    Return "RooArray"
		  Case ObjectType.RooBoolean
		    Return "RooBoolean"
		  Case ObjectType.RooDateTime
		    Return "RooDateTime"
		  Case ObjectType.RooHash
		    Return "RooHash"
		  Case ObjectType.RooNothing
		    Return "RooNothing"
		  Case ObjectType.RooNumber
		    Return "RooNumber"
		  Case ObjectType.RooText
		    Return "RooText"
		  Case ObjectType.Unknown
		    Return "Unknown"
		  Case ObjectType.XojoArray
		    Return "Xojo Array"
		  Case ObjectType.XojoBoolean
		    Return "Xojo Boolean"
		  Case ObjectType.XojoCaseSensitiveDictionary
		    Return "Xojo Case Sensitive Dictionary"
		  Case ObjectType.XojoClassicDictionary
		    Return "Xojo Classic Dictionary"
		  Case ObjectType.XojoDate
		    Return "Xojo Date"
		  Case ObjectType.XojoDouble
		    Return "Xojo Double"
		  Case ObjectType.XojoInteger
		    Return "Xojo Integer"
		  Case ObjectType.XojoModernDictionary
		    Return "Xojo Modern Dictionary"
		  Case ObjectType.XojoNil
		    Return "Nil"
		  Case ObjectType.XojoObject
		    Return "Xojo Object"
		  Case ObjectType.XojoString
		    Return "Xojo String"
		  Case ObjectType.XojoText
		    Return "Xojo Text"
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Version() As String
		  Return Str(kVersionMajor) + "." + Str(kVersionMinor) + "." + Str(kVersionBug)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function XojoDictionaryToRooHash(d As Xojo.Core.Dictionary) As RooHash
		  // Converts the passed Xojo dictionary to a Roo hash object.
		  
		  If d = Nil Or d.Count = 0 Then Return New RooHash
		  
		  Dim h As New RooHash
		  Dim value As Variant
		  
		  For Each entry As Xojo.Core.DictionaryEntry In d
		    Select Case Roo.AutoType(entry.Value)
		    Case Roo.ObjectType.XojoString, Roo.ObjectType.XojoText
		      value = New RooText(entry.Value)
		    Case Roo.ObjectType.XojoDouble, Roo.ObjectType.XojoInteger
		      value = New RooNumber(entry.Value)
		    Case Roo.ObjectType.XojoBoolean
		      value = New RooBoolean(entry.Value)
		    Else
		      value = entry.Value
		    End Select
		    
		    h.Dict.Value(entry.Key) = value
		  Next entry
		  
		  Return h
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mInitialised As Boolean = False
	#tag EndProperty


	#tag Constant, Name = kVersionBug, Type = Double, Dynamic = False, Default = \"0", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kVersionMajor, Type = Double, Dynamic = False, Default = \"3", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kVersionMinor, Type = Double, Dynamic = False, Default = \"0", Scope = Protected
	#tag EndConstant


	#tag Enum, Name = ObjectType, Flags = &h1
		RooArray
		  RooBoolean
		  RooDateTime
		  RooHash
		  RooNothing
		  RooNumber
		  RooText
		  XojoArray
		  XojoBoolean
		  XojoCaseSensitiveDictionary
		  XojoClassicDictionary
		  XojoDate
		  XojoDouble
		  XojoInteger
		  XojoModernDictionary
		  XojoObject
		  XojoNil
		  XojoString
		  XojoText
		Unknown
	#tag EndEnum

	#tag Enum, Name = TokenType, Type = Integer, Flags = &h1
		AMPERSAND
		  AND_KEYWORD
		  ARROW
		  BANG
		  BOOLEAN
		  BREAK_KEYWORD
		  CARET
		  CLASS_KEYWORD
		  COLON
		  COMMA
		  DEDENT
		  DEF_KEYWORD
		  DOT
		  ELSE_KEYWORD
		  EQUAL
		  EQUAL_EQUAL
		  EOF
		  ERROR
		  EXIT_KEYWORD
		  FOR_KEYWORD
		  GREATER
		  GREATER_EQUAL
		  GREATER_GREATER
		  IDENTIFIER
		  IF_KEYWORD
		  INDENT
		  LCURLY
		  LESS
		  LESS_EQUAL
		  LESS_LESS
		  LPAREN
		  LSQUARE
		  MINUS
		  MINUS_EQUAL
		  MINUS_MINUS
		  MODULE_KEYWORD
		  NOT_EQUAL
		  NOT_KEYWORD
		  NOTHING
		  NUMBER
		  OR_KEYWORD
		  PASS_KEYWORD
		  PERCENT
		  PERCENT_EQUAL
		  PIPE
		  PLUS
		  PLUS_EQUAL
		  PLUS_PLUS
		  QUERY
		  QUIT_KEYWORD
		  RCURLY
		  REQUIRE_KEYWORD
		  RETURN_KEYWORD
		  RPAREN
		  RSQUARE
		  SELF_KEYWORD
		  SLASH
		  SLASH_EQUAL
		  STAR_EQUAL
		  STAR
		  STATIC_KEYWORD
		  SUPER_KEYWORD
		  TERMINATOR
		  TEXT
		  TILDE
		  VAR
		WHILE_KEYWORD
	#tag EndEnum


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
