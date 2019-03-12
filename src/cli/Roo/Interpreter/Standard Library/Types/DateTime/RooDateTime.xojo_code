#tag Class
Protected Class RooDateTime
Inherits RooInstance
Implements Dateable,  RooNativeClass
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  Raise New RooRuntimeError(New RooToken, "Cannot invoke the native DateTime type.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(value As Xojo.Core.Date)
		  Super.Constructor(Nil) // No metaclass.
		  
		  Self.Value = value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DateValue() As Xojo.Core.Date
		  Return Self.Value
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoLeap() As RooBoolean
		  // DateTime.leap? As Boolean object
		  // Returns True if this DateTime object is a leap year in the Gregorian calendar. False if not.
		  
		  Return New RooBoolean(RooDateTime.IsLeapYear(Value.Year))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoTime() As RooText
		  // DateTime.time As Text object.
		  // Returns (in human-readable form with meridian) this DateTime object's time.
		  // E.g: 9:15 am  or  8:24 pm
		  
		  Dim meridian As String = Roo.MeridiemFromDate(Value)
		  Dim h As String = Str(If(Value.Hour < 13, Value.Hour, Value.Hour - 12))
		  Dim m As String = Roo.TwoDigitMinuteFromDate(Value)
		  
		  Return New RooText(h + ":" + m + " " + meridian)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoToday() As RooBoolean
		  // Returns a new Boolean object that is True if this date is today and False if it's not.
		  
		  Dim today As Xojo.Core.Date = Xojo.Core.Date.Now
		  
		  If Value.Year = today.Year And Value.Month = today.Month And Value.Day = today.Day Then
		    Return New RooBoolean(True)
		  Else
		    Return New RooBoolean(False)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoTomorrow() As RooBoolean
		  // DateTime.tomorrow? As Boolean object.
		  // Returns a new Boolean object - True if this DateTime object is tomorrow, False if not.
		  
		  // Get tomorrow's date.
		  Dim di As New Xojo.Core.DateInterval(0, 0, 1) // 0 years, 0 months, 1 day.
		  Dim tomorrow As Xojo.Core.Date = Xojo.Core.Date.Now + di
		  
		  // Is today's date and tomorrow's date the same year, month and day?
		  If Value.Year = tomorrow.Year And Value.Month = tomorrow.Month And Value.Day = tomorrow.Day Then
		    Return New RooBoolean(True)
		  Else
		    Return New RooBoolean(False)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoYesterday() As RooBoolean
		  // DateTime.yesterday? As Boolean object.
		  // Returns a new Boolean object - True if this DateTime object is yesterday, False if not.
		  
		  // Get yesterday's date.
		  Dim di As New Xojo.Core.DateInterval(0, 0, 1) // 0 years, 0 months, 1 day.
		  Dim yesterday As Xojo.Core.Date = Xojo.Core.Date.Now - di
		  
		  // Is today's date and yesterday's date the same year, month and day?
		  If Value.Year = yesterday.Year And Value.Month = yesterday.Month And Value.Day = yesterday.Day Then
		    Return New RooBoolean(True)
		  Else
		    Return New RooBoolean(False)
		  End If
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetterWithName(name As RooToken) As Variant
		  // Return the result of the requested getter operation.
		  If StrComp(name.Lexeme, "day_name", 0) = 0 Then
		    Return New RooText(Roo.DayNameFromDate(Value))
		  ElseIf StrComp(name.Lexeme, "friday?", 0) = 0 Then
		    Return New RooBoolean(If(Value.DayOfWeek = 6, True, False))
		  ElseIf StrComp(name.Lexeme, "hour", 0) = 0 Then
		    Return New RooNumber(Value.Hour)
		  ElseIf StrComp(name.Lexeme, "leap?", 0) = 0 Then
		    Return DoLeap
		  ElseIf StrComp(name.Lexeme, "long_month", 0) = 0 Then
		    Return New RooText(Roo.LongMonthFromDate(Value))
		  ElseIf StrComp(name.Lexeme, "mday", 0) = 0 Then
		    Return New RooNumber(Value.Day) // The day of the month (1-31)
		  ElseIf StrComp(name.Lexeme, "meridiem", 0) = 0 Then
		    Return New RooText(Roo.MeridiemFromDate(Value))
		  ElseIf StrComp(name.Lexeme, "minute", 0) = 0 Then
		    Return New RooNumber(Value.Minute)
		  ElseIf StrComp(name.Lexeme, "monday?", 0) = 0 Then
		    Return New RooBoolean(If(Value.DayOfWeek = 2, True, False))
		  ElseIf StrComp(name.Lexeme, "month", 0) = 0 Then
		    Return New RooNumber(Value.Month)
		  ElseIf StrComp(name.Lexeme, "nanosecond", 0) = 0 Then
		    Return New RooNumber(Value.Nanosecond)
		  ElseIf StrComp(name.Lexeme, "saturday?", 0) = 0 Then
		    Return New RooBoolean(If(Value.DayOfWeek = 7, True, False))
		  ElseIf StrComp(name.Lexeme, "second", 0) = 0 Then
		    Return New RooNumber(Value.Second)
		  ElseIf StrComp(name.Lexeme, "short_month", 0) = 0 Then
		    Return New RooText(Roo.ShortMonthFromDate(Value))
		  ElseIf StrComp(name.Lexeme, "sunday?", 0) = 0 Then
		    Return New RooBoolean(If(Value.DayOfWeek = 1, True, False))
		  ElseIf StrComp(name.Lexeme, "thursday?", 0) = 0 Then
		    Return New RooBoolean(If(Value.DayOfWeek = 5, True, False))
		  ElseIf StrComp(name.Lexeme, "time", 0) = 0 Then
		    Return DoTime
		  ElseIf StrComp(name.Lexeme, "to_http_header", 0) = 0 Then
		    Return New RooText(ToHTTPHeaderFormat)
		  ElseIf StrComp(name.Lexeme, "today?", 0) = 0 Then
		    Return DoToday
		  ElseIf StrComp(name.Lexeme, "tomorrow?", 0) = 0 Then
		    Return DoTomorrow
		  ElseIf StrComp(name.Lexeme, "tuesday?", 0) = 0 Then
		    Return New RooBoolean(If(Value.DayOfWeek = 3, True, False))
		  ElseIf StrComp(name.Lexeme, "two_digit_hour", 0) = 0 Then
		    Return New RooText(Roo.TwoDigitHourFromDate(Value))
		  ElseIf StrComp(name.Lexeme, "two_digit_minute", 0) = 0 Then
		    Return New RooText(Roo.TwoDigitMinuteFromDate(Value))
		  ElseIf StrComp(name.Lexeme, "two_digit_second", 0) = 0 Then
		    Return New RooText(Roo.TwoDigitSecondFromDate(Value))
		  ElseIf StrComp(name.Lexeme, "unix_time", 0) = 0 Then
		    Return New RooNumber(Roo.DoubleToInteger(Value.SecondsFrom1970))
		  ElseIf StrComp(name.Lexeme, "wday", 0) = 0 Then
		    Return New RooNumber(Value.DayOfWeek) // 1 = Sunday, 7 = Saturday.
		  ElseIf StrComp(name.Lexeme, "wednesday?", 0) = 0 Then
		    Return New RooBoolean(If(Value.DayOfWeek = 4, True, False))
		  ElseIf StrComp(name.Lexeme, "yday", 0) = 0 Then
		    Return New RooNumber(Value.DayOfYear) // Jan 1st = 1.
		  ElseIf StrComp(name.Lexeme, "year", 0) = 0 Then
		    Return New RooNumber(Value.Year)
		  ElseIf StrComp(name.Lexeme, "yesterday?", 0) = 0 Then
		    Return DoYesterday
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasGetterWithName(name As String) As Boolean
		  // Query the global Roo dictionary of DateTime object getters for the existence of a getter 
		  // with the passed name.
		  
		  Return RooSLCache.DateTimeGetters.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasMethodWithName(name As String) As Boolean
		  // Query the global Roo dictionary of DateTime object methods for the existence of a method 
		  // with the passed name.
		  
		  Return RooSLCache.DateTimeMethods.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  #Pragma Unused interpreter
		  #Pragma Unused arguments
		  
		  Raise New RooRuntimeError(where, "Cannot invoke the native DateTime type.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function IsLeapYear(year As Integer) As Boolean
		  // Returns True if `year` is a leap year in the Gregorian calendar. False if not.
		  // Algorithm courtesy of Wikipedia: https://en.wikipedia.org/wiki/Leap_year#Algorithm
		  
		  If (year Mod 4 = 0) And (year Mod 100 <> 0) Or (year Mod 400 = 0) Then
		    Return True
		  Else
		    Return False
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodWithName(name As RooToken) As Invokable
		  // Return a new instance of a DateTime object method initialised with the name of the method 
		  // being called. That way, when the returned method is invoked, it will know what operation 
		  // to perform.
		  Return New RooDateTimeMethod(Self, name.Lexeme)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  Return If(Value = Nil, "Nothing", Value.ToText)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToHTTPHeaderFormat() As String
		  // Returns this DateTime object in a String format that can be used in HTTP headers.
		  // Format: <day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT
		  // As per: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Modified-Since
		  
		  Dim dayName As String = Roo.DayNameFromDate(Value)
		  Dim day As String = Roo.TwoDigitDayFromDate(Value)
		  Dim month As String = Roo.ShortMonthFromDate(Value)
		  Dim year As String = Str(Value.Year)
		  Dim hour As String = Roo.TwoDigitHourFromDate(Value)
		  Dim minute As String = Roo.TwoDigitMinuteFromDate(Value)
		  Dim second As String = Roo.TwoDigitSecondFromDate(Value)
		  
		  Return dayName + ", " + day + " " + month + " " + year + " " + _
		  hour + ":" + minute + ":" + second + " GMT"
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As String
		  Return "DateTime"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Value As Xojo.Core.Date
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
End Class
#tag EndClass
