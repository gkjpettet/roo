#tag Class
Protected Class DateTimeObject
Inherits RooClass
Implements Roo.Dateable
	#tag Method, Flags = &h0
		Sub Constructor(value As Xojo.Core.Date)
		  ' Calling the overridden superclass constructor.
		  Super.Constructor(Nil)
		  
		  Self.Value = value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoLeap() As Roo.Objects.BooleanObject
		  ' DateTime.leap? as Boolean object
		  ' Returns True if this DateTime object is a leap year in the Gregorian calendar. False if not.
		  ' Algorithm courtesy of Wikipedia: https://en.wikipedia.org/wiki/Leap_year#Algorithm
		  
		  If (Value.Year Mod 4 = 0) And (Value.Year Mod 100 <> 0) Or (Value.Year Mod 400 = 0) Then
		    Return New BooleanObject(True)
		  Else
		    Return New BooleanObject(False)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DoTime(where As Roo.Token) As Variant
		  ' DateTime.time As Text
		  ' Returns (in human-readable form with meridian) this DateTime object's time.
		  ' E.g: 9:15 am  or  8:24 pm
		  
		  If Self.Value = Nil Then
		    Raise New RuntimeError(where, "Unable to convert DateTime object to time as its internal value is Nil.")
		  End If
		  
		  Dim meridian As String = If(Self.Value.Hour < 12, "AM", "PM")
		  Dim h As String = Str(If(Self.Value.Hour < 13, Self.Value.Hour, Self.Value.Hour - 12))
		  Dim m As String = Self.Value.TwoDigitMinute
		  
		  Return New TextObject(h + ":" + m + " " + meridian)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoToday() As Roo.Objects.BooleanObject
		  ' Returns a new Boolean object that is true if this date is today and False if it's not.
		  
		  If Self.Value = Nil Then Return New BooleanObject(False)
		  
		  Dim today As Xojo.Core.Date = Xojo.Core.Date.Now
		  
		  If Value.Year = today.Year And Value.Month = today.Month And Value.Day = today.Day Then
		    Return New BooleanObject(True)
		  Else
		    Return New BooleanObject(False)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoTomorrow() As Roo.Objects.BooleanObject
		  ' DateTime.tomorrow? as BooleanObject.
		  ' Returns a new Boolean object - True if this DateTime object is tomorrow, False if not.
		  
		  ' Get tomorrow's date.
		  Dim di As New Xojo.Core.DateInterval(0, 0, 1) ' 0 years, 0 months, 1 day.
		  Dim tomorrow As Xojo.Core.Date = Xojo.Core.Date.Now + di
		  
		  ' Are this date and tomorrow's date the same year, month and day?
		  If Value.Year = tomorrow.Year And Value.Month = tomorrow.Month And Value.Day = tomorrow.Day Then
		    Return New BooleanObject(True)
		  Else
		    Return New BooleanObject(False)
		  End if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoYesterday() As Roo.Objects.BooleanObject
		  ' DateTime.yesterday? as BooleanObject.
		  ' Returns a new Boolean object - True if this DateTime object is yesterday, False if not.
		  
		  ' Get yesterday's date.
		  Dim di As New Xojo.Core.DateInterval(0, 0, 1) ' 0 years, 0 months, 1 day.
		  Dim yesterday As Xojo.Core.Date = Xojo.Core.Date.Now - di
		  
		  ' Are this date and yesterday's date the same year, month and day?
		  If Value.Year = yesterday.Year And Value.Month = yesterday.Month And Value.Day = yesterday.Day Then
		    Return New BooleanObject(True)
		  Else
		    Return New BooleanObject(False)
		  End if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name as Token) As Variant
		  ' Override RooInstance.Get().
		  
		  If Lookup.DateTimeMethod(name.lexeme) Then Return New DateTimeObjectMethod(Self, name.lexeme)
		  
		  If Lookup.DateTimeGetter(name.lexeme) Then
		    Select Case name.lexeme
		    Case "two_digit_hour"
		      Return New TextObject(Self.Value.TwoDigitHour)
		    Case "two_digit_minute"
		      Return New TextObject(Self.Value.TwoDigitMinute)
		    Case "two_digit_second"
		      Return New TextObject(Self.Value.TwoDigitSecond)
		    Case "day_name"
		      Return New TextObject(Self.Value.DayName)
		    Case "friday?"
		      Return New BooleanObject(If(Value.DayOfWeek = 6, True, False))
		    Case "hour"
		      Return New NumberObject(Self.Value.Hour)
		    Case "leap?"
		      Return DoLeap
		    Case "long_month"
		      Return New TextObject(Self.Value.LongMonth)
		    Case "mday" ' Returns the day of the month (1-31)
		      Return New NumberObject(Self.Value.Day)
		    Case "meridiem"
		      Return New TextObject(Self.Value.Meridiem)
		    Case "minute"
		      Return New NumberObject(Self.Value.Minute)
		    Case "monday?"
		      Return New BooleanObject(If(Value.DayOfWeek = 2, True, False))
		    Case "month"
		      Return New NumberObject(Self.Value.Month)
		    Case "nanosecond"
		      Return New NumberObject(Self.Value.Nanosecond)
		    Case "nothing?"
		      Return New BooleanObject(False)
		    Case "number?"
		      Return New BooleanObject(False)
		    Case "saturday?"
		      Return New BooleanObject(If(Value.DayOfWeek = 7, True, False))
		    Case "second"
		      Return New NumberObject(Self.Value.Second)
		    Case "short_month"
		      Return New TextObject(Self.Value.ShortMonth)
		    Case "sunday?"
		      Return New BooleanObject(If(Value.DayOfWeek = 1, True, False))
		    Case "thursday?"
		      Return New BooleanObject(If(Value.DayOfWeek = 5, True, False))
		    Case "time"
		      Return DoTime(name)
		    Case "to_http_header"
		      Return New TextObject(ToHTTPHeaderFormat)
		    Case "to_text"
		      If Self.Value = Nil Then
		        Return New TextObject("Nothing")
		      Else
		        Return New TextObject(Self.Value.ToText)
		      End If
		    Case "today?"
		      Return DoToday
		    Case "tomorrow?"
		      Return DoTomorrow
		    Case "tuesday?"
		      Return New BooleanObject(If(Value.DayOfWeek = 3, True, False))
		    Case "type"
		      Return New TextObject("DateTime")
		    Case "unix_time"
		      Return New NumberObject(Self.Value.SecondsFrom1970)
		    Case "wday" ' Returns the day of the week (1 = Sunday, 7 = Saturday)
		      Return New NumberObject(Self.Value.DayOfWeek)
		    Case "wednesday?"
		      Return New BooleanObject(If(Value.DayOfWeek = 4, True, False))
		    Case "yday" ' Returns the day of the year (Jan 1st = 1)
		      Return New NumberObject(Self.Value.DayOfYear)
		    Case "year"
		      Return New NumberObject(Self.Value.Year)
		    Case "yesterday?"
		      Return DoYesterday
		    End Select
		  End If
		  
		  Raise New RuntimeError(name, "DateTime objects have no method named `" + name.lexeme + "`.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name as Roo.Token, value as Variant)
		  ' Override RooInstance.Set
		  
		  #Pragma Unused name
		  #Pragma Unused value
		  
		  ' We want to prevent both the creating of new fields on DateTime objects and setting their values.
		  Raise New RuntimeError(name, "Cannot create or set fields on intrinsic data types " +_ 
		  "(DateTime." + name.lexeme + ").")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToDate() As Xojo.Core.Date
		  ' Part of the Roo.Dateable interface.
		  
		  Return Self.Value
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToHTTPHeaderFormat() As String
		  ' Returns this DateTime object in a Text format that can be used in HTTP headers.
		  ' Format: <day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT
		  ' As per: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Modified-Since
		  
		  Dim dayName As String = Self.Value.DayName
		  Dim day As String = Self.Value.TwoDigitDay
		  Dim month As String = Self.Value.ShortMonth
		  Dim year As String = Self.Value.Year.ToText
		  Dim hour As String = Self.Value.TwoDigitHour
		  Dim minute As String = Self.Value.TwoDigitMinute
		  Dim second As String = Self.Value.TwoDigitSecond
		  
		  Return dayName + ", " + day + " " + month + " " + year + " " + hour + ":" + minute + ":" + second + " GMT" 
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Part of the Textable interface.
		  
		  if self.value = Nil then
		    return "Nothing"
		  else
		    return self.value.ToText
		  end if
		  
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
