#tag Module
Protected Module RooSLCache
	#tag Method, Flags = &h1
		Protected Sub Initialise()
		  If mInitialised Then Return
		  
		  // Generic object getters and methods.
		  InitialiseGenericGetters
		  InitialiseGenericMethods
		  
		  // Array object getters and methods.
		  InitialiseArrayGetters
		  InitialiseArrayMethods
		  
		  // DateTime object getters and methods.
		  InitialiseDateTimeGetters
		  InitialiseDateTimeMethods
		  
		  // Hash object getters and methods.
		  InitialiseHashGetters
		  InitialiseHashMethods
		  
		  // Number object getters and methods.
		  InitialiseNumberGetters
		  InitialiseNumberMethods
		  
		  // Regex object getters and methods.
		  InitialiseRegexGetters
		  InitialiseRegexMethods
		  
		  // RegexMatch object getters and methods.
		  InitialiseRegexMatchGetters
		  InitialiseRegexMatchMethods
		  
		  // Text object getters and methods.
		  InitialiseTextGetters
		  InitialiseTextMethods
		  
		  // FileSystem module.
		  // FileSystem.Item object getters and methods.
		  InitialiseFileSystemItemGetters
		  InitialiseFileSystemItemMethods
		  
		  // HTTP module.
		  // HTTP.Request object getters.
		  InitialiseHTTPRequestGetters
		  // HTTP.Response object getters.
		  InitialiseHTTPResponseGetters
		  
		  mInitialised = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseArrayGetters()
		  ArrayGetters = Roo.CaseSensitiveDictionary
		  
		  ArrayGetters.Value("empty?") = True
		  ArrayGetters.Value("length") = True
		  ArrayGetters.Value("pop!") = True
		  ArrayGetters.Value("reverse!") = True
		  ArrayGetters.Value("shuffle!") = True
		  ArrayGetters.Value("unique") = True
		  ArrayGetters.Value("unique!") = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseArrayMethods()
		  // The key is the name of the Array object method. The value is the arity of the method.
		  
		  ArrayMethods = Roo.CaseSensitiveDictionary
		  
		  ArrayMethods.Value("contains?") = 1
		  ArrayMethods.Value("delete_at!") = 1
		  ArrayMethods.Value("each") = Array(1, 2)
		  ArrayMethods.Value("each_index") = Array(1, 2)
		  ArrayMethods.Value("fetch") = 2
		  ArrayMethods.Value("find") = 1
		  ArrayMethods.Value("first") = Array(0, 1)
		  ArrayMethods.Value("first!") = Array(0, 1)
		  ArrayMethods.Value("insert!") = 2
		  ArrayMethods.Value("join") = Array(0, 1)
		  ArrayMethods.Value("keep") = Array(1, 2)
		  ArrayMethods.Value("keep!") = Array(1, 2)
		  ArrayMethods.Value("last") = Array(0, 1)
		  ArrayMethods.Value("map") = Array(1, 2)
		  ArrayMethods.Value("map!") = Array(1, 2)
		  ArrayMethods.Value("push!") = 1
		  ArrayMethods.Value("reject") = Array(1, 2)
		  ArrayMethods.Value("reject!") = Array(1, 2)
		  ArrayMethods.Value("shift!") = Array(0, 1)
		  ArrayMethods.Value("slice") = Array(1, 2)
		  ArrayMethods.Value("slice!") = Array(1, 2)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseDateTimeGetters()
		  DateTimeGetters = Roo.CaseSensitiveDictionary
		  
		  DateTimeGetters.Value("day_name") = True
		  DateTimeGetters.Value("friday?") = True
		  DateTimeGetters.Value("hour") = True
		  DateTimeGetters.Value("leap?") = True
		  DateTimeGetters.Value("long_month") = True
		  DateTimeGetters.Value("mday") = True
		  DateTimeGetters.Value("meridiem") = True
		  DateTimeGetters.Value("minute") = True
		  DateTimeGetters.Value("monday?") = True
		  DateTimeGetters.Value("month") = True
		  DateTimeGetters.Value("nanosecond") = True
		  DateTimeGetters.Value("saturday?") = True
		  DateTimeGetters.Value("second") = True
		  DateTimeGetters.Value("short_month") = True
		  DateTimeGetters.Value("sunday?") = True
		  DateTimeGetters.Value("thursday?") = True
		  DateTimeGetters.Value("time") = True
		  DateTimeGetters.Value("to_http_header") = True
		  DateTimeGetters.Value("today?") = True
		  DateTimeGetters.Value("tomorrow?") = True
		  DateTimeGetters.Value("tuesday?") = True
		  DateTimeGetters.Value("two_digit_hour") = True
		  DateTimeGetters.Value("two_digit_minute") = True
		  DateTimeGetters.Value("two_digit_second") = True
		  DateTimeGetters.Value("unix_time") = True
		  DateTimeGetters.Value("wday") = True
		  DateTimeGetters.Value("wednesday?") = True
		  DateTimeGetters.Value("yday") = True
		  DateTimeGetters.Value("year") = True
		  DateTimeGetters.Value("yesterday?") = True
		  DateTimeGetters.Value("") = True
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseDateTimeMethods()
		  // The key is the name of the DateTime object method. The value is the arity of the method.
		  
		  DateTimeMethods = Roo.CaseSensitiveDictionary
		  
		  DateTimeMethods.Value("add_days") = 1
		  DateTimeMethods.Value("add_hours") = 1
		  DateTimeMethods.Value("add_months") = 1 
		  DateTimeMethods.Value("add_nanoseconds") = 1
		  DateTimeMethods.Value("add_seconds") = 1
		  DateTimeMethods.Value("add_years") = 1
		  DateTimeMethods.Value("sub_days") = 1
		  DateTimeMethods.Value("sub_hours") = 1
		  DateTimeMethods.Value("sub_months") = 1
		  DateTimeMethods.Value("sub_nanoseconds") = 1
		  DateTimeMethods.Value("sub_seconds") = 1
		  DateTimeMethods.Value("sub_years") = 1
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseFileSystemItemGetters()
		  FileSystemItemGetters = Roo.CaseSensitiveDictionary
		  
		  FileSystemItemGetters.Value("count") = True
		  FileSystemItemGetters.Value("delete!") = True
		  FileSystemItemGetters.Value("directory?") = True
		  FileSystemItemGetters.Value("exists?") = True
		  FileSystemItemGetters.Value("file?") = True
		  FileSystemItemGetters.Value("name") = True
		  FileSystemItemGetters.Value("path") = True
		  FileSystemItemGetters.Value("read_all") = True
		  FileSystemItemGetters.Value("readable?") = True
		  FileSystemItemGetters.Value("writeable?") = True
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseFileSystemItemMethods()
		  FileSystemItemMethods = Roo.CaseSensitiveDictionary
		  
		  FileSystemItemMethods.Value("append") = 1
		  FileSystemItemMethods.Value("append_line") = 1
		  FileSystemItemMethods.Value("copy_to") = 2
		  FileSystemItemMethods.Value("each_char") = Array(1, 2)
		  FileSystemItemMethods.Value("each_line") = Array(1, 2)
		  FileSystemItemMethods.Value("move_to") = 2
		  FileSystemItemMethods.Value("write") = 1
		  FileSystemItemMethods.Value("write_line") = 1
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseGenericGetters()
		  GenericGetters = Roo.CaseSensitiveDictionary
		  
		  GenericGetters.Value("nothing?") = True
		  GenericGetters.Value("number?") = True
		  GenericGetters.Value("to_text") = True
		  GenericGetters.Value("type") = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseGenericMethods()
		  // The key is the name of the generic object method. The value is the arity of the method.
		  
		  GenericMethods = Roo.CaseSensitiveDictionary
		  
		  GenericMethods.Value("responds_to?") = 1
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseHashGetters()
		  HashGetters = Roo.CaseSensitiveDictionary
		  
		  HashGetters.Value("clear!") = True
		  HashGetters.Value("invert") = True
		  HashGetters.Value("invert!") = True
		  HashGetters.Value("keys") = True
		  HashGetters.Value("length") = True
		  HashGetters.Value("values") = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseHashMethods()
		  // The key is the name of the Hash object method. The value is the arity of the method.
		  
		  HashMethods = Roo.CaseSensitiveDictionary
		  
		  HashMethods.Value("delete!") = 1
		  HashMethods.Value("each") = Array(1, 2)
		  HashMethods.Value("each_key") = Array(1, 2)
		  HashMethods.Value("each_value") = Array(1, 2)
		  HashMethods.Value("fetch") = 2
		  HashMethods.Value("fetch_values") = 1
		  HashMethods.Value("has_key?") = 1
		  HashMethods.Value("has_value?") = 1
		  HashMethods.Value("keep") = Array(1, 2)
		  HashMethods.Value("keep!") = Array(1, 2)
		  HashMethods.Value("merge") = Array(1, 2)
		  HashMethods.Value("merge!") = Array(1, 2)
		  HashMethods.Value("reject") = Array(1, 2)
		  HashMethods.Value("reject!") = Array(1, 2)
		  HashMethods.Value("value") = 1
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseHTTPRequestGetters()
		  HTTPRequestGetters = Roo.CaseSensitiveDictionary
		  
		  HTTPRequestGetters.Value("content") = True
		  HTTPRequestGetters.Value("content_type") = True
		  HTTPRequestGetters.Value("cookies") = True
		  HTTPRequestGetters.Value("headers") = True
		  HTTPRequestGetters.Value("host") = True
		  HTTPRequestGetters.Value("if_modified_since") = True
		  HTTPRequestGetters.Value("method") = True
		  HTTPRequestGetters.Value("referer") = True
		  HTTPRequestGetters.Value("send") = True
		  HTTPRequestGetters.Value("timeout") = True
		  HTTPRequestGetters.Value("url") = True
		  HTTPRequestGetters.Value("user_agent") = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseHTTPResponseGetters()
		  HTTPResponseGetters = Roo.CaseSensitiveDictionary
		  
		  HTTPResponseGetters.Value("content") = True
		  HTTPResponseGetters.Value("content_disposition") = True
		  HTTPResponseGetters.Value("content_encoding") = True
		  HTTPResponseGetters.Value("content_length") = True
		  HTTPResponseGetters.Value("content_type") = True
		  HTTPResponseGetters.Value("cookies") = True
		  HTTPResponseGetters.Value("headers") = True
		  HTTPResponseGetters.Value("last_modified") = True
		  HTTPResponseGetters.Value("location") = True
		  HTTPResponseGetters.Value("status") = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseNumberGetters()
		  NumberGetters = Roo.CaseSensitiveDictionary
		  
		  NumberGetters.Value("abs") = True
		  NumberGetters.Value("acos") = True
		  NumberGetters.Value("asin") = True
		  NumberGetters.Value("atan") = True
		  NumberGetters.Value("ceil") = True
		  NumberGetters.Value("cos") = True
		  NumberGetters.Value("digits") = True
		  NumberGetters.Value("even?") = True
		  NumberGetters.Value("floor") = True
		  NumberGetters.Value("integer?") = True
		  NumberGetters.Value("odd?") = True
		  NumberGetters.Value("round") = True
		  NumberGetters.Value("sign") = True
		  NumberGetters.Value("sin") = True
		  NumberGetters.Value("sqrt") = True
		  NumberGetters.Value("tan") = True
		  NumberGetters.Value("to_degrees") = True
		  NumberGetters.Value("to_radians") = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseNumberMethods()
		  // The key is the name of the Number object method. The value is the arity of the method.
		  
		  NumberMethods = Roo.CaseSensitiveDictionary
		  
		  NumberMethods.Value("each_digit") = Array(1, 2)
		  NumberMethods.Value("ends_with?") = 1
		  NumberMethods.Value("starts_with?") = 1
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseRegexGetters()
		  RegexGetters = Roo.CaseSensitiveDictionary
		  
		  RegexGetters.Value("case_sensitive") = True
		  RegexGetters.Value("dot_matches_all") = True
		  RegexGetters.Value("greedy") = True
		  RegexGetters.Value("match_empty") = True
		  RegexGetters.Value("multiline") = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseRegexMatchGetters()
		  RegexMatchGetters = Roo.CaseSensitiveDictionary
		  
		  RegexMatchGetters.Value("groups") = True
		  RegexMatchGetters.Value("length") = True
		  RegexMatchGetters.Value("start") = True
		  RegexMatchGetters.Value("value") = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseRegexMatchMethods()
		  // The key is the name of the RegexMatch object method. The value is the arity of the method.
		  
		  RegexMatchMethods = Roo.CaseSensitiveDictionary
		  
		  RegexMatchMethods.Value("group") = 1
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseRegexMethods()
		  // The key is the name of the Regex object method. The value is the arity of the method.
		  
		  RegexMethods = Roo.CaseSensitiveDictionary
		  
		  RegexMethods.Value("first_match") = Array(1, 2)
		  RegexMethods.Value("match") = Array(1, 2) 
		  RegexMethods.Value("matches?") = 1
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseTextGetters()
		  TextGetters = Roo.CaseSensitiveDictionary
		  
		  TextGetters.Value("capitalise") = True
		  TextGetters.Value("capitalise!") = True
		  TextGetters.Value("chars") = True
		  TextGetters.Value("define_utf8") = True
		  TextGetters.Value("define_utf8!") = True
		  TextGetters.Value("empty?") = True
		  TextGetters.Value("length") = True
		  TextGetters.Value("lowercase") = True
		  TextGetters.Value("lowercase!") = True
		  TextGetters.Value("lstrip") = True
		  TextGetters.Value("lstrip!") = True
		  TextGetters.Value("reverse") = True
		  TextGetters.Value("reverse!") = True
		  TextGetters.Value("rstrip") = True
		  TextGetters.Value("rstrip!") = True
		  TextGetters.Value("strip") = True
		  TextGetters.Value("strip!") = True
		  TextGetters.Value("swapcase") = True
		  TextGetters.Value("swapcase!") = True
		  TextGetters.Value("to_date") = True
		  TextGetters.Value("to_number") = True
		  TextGetters.Value("uppercase") = True
		  TextGetters.Value("uppercase!") = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseTextMethods()
		  // The key is the name of the Text object method. The value is the arity of the method.
		  
		  TextMethods = Roo.CaseSensitiveDictionary
		  
		  TextMethods.Value("each_char") = Array(1, 2)
		  TextMethods.Value("ends_with?") = 1
		  TextMethods.Value("first_match") = Array(1, 2)
		  TextMethods.Value("include?") = 1
		  TextMethods.Value("index") = 1
		  TextMethods.Value("lpad") = Array(1, 2)
		  TextMethods.Value("lpad!") = Array(1, 2)
		  TextMethods.Value("match") = Array(1, 2)
		  TextMethods.Value("matches?") = 1
		  TextMethods.Value("replace_all") = 2
		  TextMethods.Value("replace_all!") = 2
		  TextMethods.Value("replace_first") = 2
		  TextMethods.Value("replace_first!") = 2
		  TextMethods.Value("rpad") = Array(1, 2)
		  TextMethods.Value("rpad!") = Array(1, 2)
		  TextMethods.Value("slice") = Array(1, 2)
		  TextMethods.Value("slice!") = Array(1, 2)
		  TextMethods.Value("starts_with?") = 1
		  
		End Sub
	#tag EndMethod


	#tag Note, Name = About
		Roo Standard Library (SL) Cache
		-------------------------------
		This module provides a cache of the available getters and methods on Roo's built-in types.
		We do this rather than have the types themselves do it because it means we only need to 
		maintain two dictionaries for each class (one for their getters and one for their methods) rather 
		than have two dictionaries in memory for every instance of each type. 
		
	#tag EndNote


	#tag Property, Flags = &h1
		#tag Note
			Key = name of Array getter
			Value = True
		#tag EndNote
		Protected ArrayGetters As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Key = name of Array method
			Value = method Arity (either an Integer or an Integer Array)
		#tag EndNote
		Protected ArrayMethods As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Key = name of DateTime getter
			Value = True
		#tag EndNote
		Protected DateTimeGetters As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Key = name of DateTime method
			Value = method Arity (either an Integer or an Integer Array)
		#tag EndNote
		Protected DateTimeMethods As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected FileSystemItemGetters As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected FileSystemItemMethods As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected GenericGetters As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected GenericMethods As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Key = name of Hash getter
			Value = True
		#tag EndNote
		Protected HashGetters As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Key = name of Hash method
			Value = method Arity (either an Integer or an Integer Array)
		#tag EndNote
		Protected HashMethods As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected HTTPRequestGetters As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected HTTPResponseGetters As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mInitialised As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected NumberGetters As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Key = name of Number method
			Value = method Arity (either an Integer or an Integer Array)
		#tag EndNote
		Protected NumberMethods As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Key = name of Regex getter
			Value = True
		#tag EndNote
		Protected RegexGetters As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Key = name of RegexMatch getter
			Value = True
		#tag EndNote
		Protected RegexMatchGetters As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Key = name of RegexMatch method
			Value = method Arity (either an Integer or an Integer Array)
		#tag EndNote
		Protected RegexMatchMethods As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Key = name of Regex method
			Value = method Arity (either an Integer or an Integer Array)
		#tag EndNote
		Protected RegexMethods As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Key = name of Text getter
			Value = True
		#tag EndNote
		Protected TextGetters As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Key = name of Text method
			Value = method Arity (either an Integer or an Integer Array)
		#tag EndNote
		Protected TextMethods As Xojo.Core.Dictionary
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
