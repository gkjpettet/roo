#tag Module
Protected Module Lookup
	#tag Method, Flags = &h1
		Protected Function ArrayGetter(name as String) As Boolean
		  ' Returns True if the ArrayObject responds to a getter with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return arrayObjGetters.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ArrayMethod(name as String) As Boolean
		  ' Returns True if the ArrayObject responds to a method with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return arrayObjMethods.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function BooleanGetter(name as String) As Boolean
		  ' Returns True if the BooleanObject responds to a getter with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return booleanObjGetters.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function BooleanMethod(name as String) As Boolean
		  ' Returns True if the BooleanObject responds to a method with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return booleanObjMethods.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineArrayGetters()
		  ' Define the Array object getters.
		  
		  arrayObjGetters = new StringToVariantHashMapMBS(True)
		  arrayObjGetters.Value("empty?") = True
		  arrayObjGetters.Value("length") = True
		  arrayObjGetters.Value("pop") = True
		  arrayObjGetters.Value("nothing?") = True
		  arrayObjGetters.Value("number?") = True
		  arrayObjGetters.Value("reverse!") = True
		  arrayObjGetters.Value("shuffle!") = True
		  arrayObjGetters.Value("to_text") = True
		  arrayObjGetters.Value("type") = True
		  arrayObjGetters.Value("unique") = True
		  arrayObjGetters.Value("unique!") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineArrayMethods()
		  ' Define the Array object methods.
		  
		  arrayObjMethods = new StringToVariantHashMapMBS(True)
		  arrayObjMethods.Value("contains?") = True
		  arrayObjMethods.Value("delete_at!") = True
		  arrayObjMethods.Value("each") = True
		  arrayObjMethods.Value("each_index") = True
		  arrayObjMethods.Value("fetch") = True
		  arrayObjMethods.Value("find") = True
		  arrayObjMethods.Value("first") = True
		  arrayObjMethods.Value("insert!") = True
		  arrayObjMethods.Value("join") = True
		  arrayObjMethods.Value("keep") = True
		  arrayObjMethods.Value("keep!") = True
		  arrayObjMethods.Value("last") = True
		  arrayObjMethods.Value("map") = True
		  arrayObjMethods.Value("map!") = True
		  arrayObjMethods.Value("push") = True
		  arrayObjMethods.Value("reject") = True
		  arrayObjMethods.Value("reject!") = True
		  arrayObjMethods.Value("responds_to?") = True
		  arrayObjMethods.Value("shift!") = True
		  arrayObjMethods.Value("slice") = True
		  arrayObjMethods.Value("slice!") = True
		  arrayObjMethods.Value("take") = True
		  arrayObjMethods.Value("take!") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineBooleanGetters()
		  ' Define the Boolean object getters.
		  
		  booleanObjGetters = new StringToVariantHashMapMBS(True)
		  booleanObjGetters.Value("nothing?") = True
		  booleanObjGetters.Value("number?") = True
		  booleanObjGetters.Value("to_text") = True
		  booleanObjGetters.Value("type") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineBooleanMethods()
		  ' Define the Boolean object methods.
		  
		  booleanObjMethods = new StringToVariantHashMapMBS(True)
		  booleanObjMethods.Value("responds_to?") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineFileGetters()
		  ' Define the File object getters.
		  
		  fileObjGetters = new StringToVariantHashMapMBS(True)
		  fileObjGetters.Value("count") = True
		  fileObjGetters.Value("directory?") = True
		  fileObjGetters.Value("exists?") = True
		  fileObjGetters.Value("file?") = True
		  fileObjGetters.Value("name") = True
		  fileObjGetters.Value("nothing?") = True
		  fileObjGetters.Value("number?") = True
		  fileObjGetters.Value("path") = True
		  fileObjGetters.Value("readable?") = True
		  fileObjGetters.Value("to_text") = True
		  fileObjGetters.Value("type") = True
		  fileObjGetters.Value("writeable?") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineFileMethods()
		  ' Define the File object methods.
		  
		  fileObjMethods = new StringToVariantHashMapMBS(True)
		  fileObjMethods.Value("responds_to?") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineHashGetters()
		  ' Define the Hash object getters.
		  
		  hashObjGetters = new StringToVariantHashMapMBS(True)
		  hashObjGetters.Value("clear!") = True
		  hashObjGetters.Value("invert") = True
		  hashObjGetters.Value("invert!") = True
		  hashObjGetters.Value("keys") = True
		  hashObjGetters.Value("length") = True
		  hashObjGetters.Value("nothing?") = True
		  hashObjGetters.Value("number?") = True
		  hashObjGetters.Value("to_text") = True
		  hashObjGetters.Value("type") = True
		  hashObjGetters.Value("values") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineHashMethods()
		  ' Define the Hash object methods.
		  
		  hashObjMethods = new StringToVariantHashMapMBS(True)
		  hashObjMethods.Value("delete!") = True
		  hashObjMethods.Value("each") = True
		  hashObjMethods.Value("each_key") = True
		  hashObjMethods.Value("each_value") = True
		  hashObjMethods.Value("fetch") = True
		  hashObjMethods.Value("fetch_values") = True
		  hashObjMethods.Value("has_key?") = True
		  hashObjMethods.Value("has_value?") = True
		  hashObjMethods.Value("keep") = True
		  hashObjMethods.Value("keep!") = True
		  hashObjMethods.Value("merge") = True
		  hashObjMethods.Value("merge!") = True
		  hashObjMethods.Value("reject") = True
		  hashObjMethods.Value("reject!") = True
		  hashObjMethods.Value("responds_to?") = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineMatchInfoGetters()
		  ' Define the MatchInfo object getters.
		  
		  matchInfoObjGetters = new StringToVariantHashMapMBS(True)
		  matchInfoObjGetters.Value("finish") = True
		  matchInfoObjGetters.Value("nothing?") = True
		  matchInfoObjGetters.Value("number?") = True
		  matchInfoObjGetters.Value("start") = True
		  matchInfoObjGetters.Value("to_text") = True
		  matchInfoObjGetters.Value("type") = True
		  matchInfoObjGetters.Value("value") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineMatchInfoMethods()
		  ' Define the MatchInfo object methods.
		  
		  matchInfoObjMethods = new StringToVariantHashMapMBS(True)
		  matchInfoObjMethods.Value("responds_to?") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineNothingGetters()
		  ' Define the Nothing object getters.
		  
		  nothingObjGetters = new StringToVariantHashMapMBS(True)
		  nothingObjGetters.Value("nothing?") = True
		  nothingObjGetters.Value("number?") = True
		  nothingObjGetters.Value("to_text") = True
		  nothingObjGetters.Value("type") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineNothingMethods()
		  ' Define the Nothing object methods.
		  
		  nothingObjMethods = new StringToVariantHashMapMBS(True)
		  nothingObjMethods.Value("responds_to?") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineNumberGetters()
		  ' Define the Number object getters.
		  
		  numberObjGetters = new StringToVariantHashMapMBS(True)
		  numberObjGetters.Value("abs") = True
		  numberObjGetters.Value("acos") = True
		  numberObjGetters.Value("asin") = True
		  numberObjGetters.Value("atan") = True
		  numberObjGetters.Value("ceil") = True
		  numberObjGetters.Value("cos") = True
		  numberObjGetters.Value("even?") = True
		  numberObjGetters.Value("floor") = True
		  numberObjGetters.Value("integer?") = True
		  numberObjGetters.Value("nothing?") = True
		  numberObjGetters.Value("number?") = True
		  numberObjGetters.Value("odd?") = True
		  numberObjGetters.Value("round") = True
		  numberObjGetters.Value("sign") = True
		  numberObjGetters.Value("sin") = True
		  numberObjGetters.Value("sqrt") = True
		  numberObjGetters.Value("tan") = True
		  numberObjGetters.Value("to_degrees") = True
		  numberObjGetters.Value("to_radians") = True
		  numberObjGetters.Value("to_text") = True
		  numberObjGetters.Value("type") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineNumberMethods()
		  ' Define the Number object methods.
		  
		  numberObjMethods = new StringToVariantHashMapMBS(True)
		  numberObjMethods.Value("responds_to?") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineRegexGetters()
		  ' Define the regex object getters.
		  
		  regexObjGetters = new StringToVariantHashMapMBS(True)
		  regexObjGetters.Value("nothing?") = True
		  regexObjGetters.Value("number?") = True
		  regexObjGetters.Value("to_text") = True
		  regexObjGetters.Value("type") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineRegexMatchGetters()
		  ' Define the RegexMatch object getters.
		  
		  regexMatchObjGetters = new StringToVariantHashMapMBS(True)
		  regexMatchObjGetters.Value("captures") = True
		  regexMatchObjGetters.Value("finish") = True
		  regexMatchObjGetters.Value("nothing?") = True
		  regexMatchObjGetters.Value("number?") = True
		  regexMatchObjGetters.Value("start") = True
		  regexMatchObjGetters.Value("to_text") = True
		  regexMatchObjGetters.Value("type") = True
		  regexMatchObjGetters.Value("value") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineRegexMatchMethods()
		  ' Define the RegexMatch object methods.
		  
		  regexMatchObjMethods = new StringToVariantHashMapMBS(True)
		  regexMatchObjMethods.Value("group") = True
		  regexMatchObjMethods.Value("name") = True
		  regexMatchObjMethods.Value("responds_to?") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineRegexMethods()
		  ' Define the regex object methods.
		  
		  regexObjMethods = new StringToVariantHashMapMBS(True)
		  regexObjMethods.Value("match") = True
		  regexObjMethods.Value("matches?") = True
		  regexObjMethods.Value("responds_to?") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineRegexResultGetters()
		  ' Define the RegexResult object getters.
		  
		  regexResultObjGetters = new StringToVariantHashMapMBS(True)
		  regexResultObjGetters.Value("first_match") = True
		  regexResultObjGetters.Value("length") = True
		  regexResultObjGetters.Value("matches") = True
		  regexResultObjGetters.Value("nothing?") = True
		  regexResultObjGetters.Value("number?") = True
		  regexResultObjGetters.Value("to_text") = True
		  regexResultObjGetters.Value("type") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineRegexResultMethods()
		  ' Define the RegexResult object methods.
		  
		  regexResultObjMethods = new StringToVariantHashMapMBS(True)
		  regexResultObjMethods.Value("match") = True
		  regexResultObjMethods.Value("responds_to?") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineTextGetters()
		  ' Define the Text object getters.
		  
		  textObjGetters = new StringToVariantHashMapMBS(True)
		  textObjGetters.Value("capitalise") = True
		  textObjGetters.Value("capitalise!") = True
		  textObjGetters.Value("chars") = True
		  textObjGetters.Value("empty?") = True
		  textObjGetters.Value("length") = True
		  textObjGetters.Value("lowercase") = True
		  textObjGetters.Value("lowercase!") = True
		  textObjGetters.Value("lstrip") = True
		  textObjGetters.Value("lstrip!") = True
		  textObjGetters.Value("nothing?") = True
		  textObjGetters.Value("number?") = True
		  textObjGetters.Value("reverse") = True
		  textObjGetters.Value("reverse!") = True
		  textObjGetters.Value("rstrip") = True
		  textObjGetters.Value("rstrip!") = True
		  textObjGetters.Value("strip") = True
		  textObjGetters.Value("strip!") = True
		  textObjGetters.Value("swapcase") = True
		  textObjGetters.Value("swapcase!") = True
		  textObjGetters.Value("to_text") = True
		  textObjGetters.Value("type") = True
		  textObjGetters.Value("uppercase") = True
		  textObjGetters.Value("uppercase!") = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineTextMethods()
		  ' Define the Text object methods.
		  
		  textObjMethods = new StringToVariantHashMapMBS(True)
		  
		  textObjMethods.Value("ends_with?") = True
		  textObjMethods.Value("include?") = True
		  textObjMethods.Value("index") = True
		  textObjMethods.Value("match") = True
		  textObjMethods.Value("matches?") = True
		  textObjMethods.Value("replace_all") = True
		  textObjMethods.Value("replace_all!") = True
		  textObjMethods.Value("replace_first") = True
		  textObjMethods.Value("replace_first!") = True
		  textObjMethods.Value("responds_to?") = True
		  textObjMethods.Value("slice") = True
		  textObjMethods.Value("slice!") = True
		  textObjMethods.Value("starts_with?") = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function FileGetter(name as String) As Boolean
		  ' Returns True if the FileObject responds to a getter with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return fileObjGetters.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function FileMethod(name as String) As Boolean
		  ' Returns True if the FileObject responds to a method with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return fileObjMethods.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HashGetter(name as String) As Boolean
		  ' Returns True if the HashObject responds to a getter with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return hashObjGetters.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HashMethod(name as String) As Boolean
		  ' Returns True if the HashObject responds to a method with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return hashObjMethods.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Initialise()
		  DefineArrayGetters()
		  DefineArrayMethods()
		  
		  DefineBooleanGetters()
		  DefineBooleanMethods()
		  
		  DefineHashGetters()
		  DefineHashMethods()
		  
		  DefineFileGetters()
		  DefineFileMethods()
		  
		  DefineNothingGetters()
		  DefineNothingMethods()
		  
		  DefineNumberGetters()
		  DefineNumberMethods()
		  
		  DefineRegexGetters()
		  DefineRegexMethods()
		  
		  DefineRegexMatchGetters()
		  DefineRegexMatchMethods()
		  
		  DefineRegexResultGetters()
		  DefineRegexResultMethods()
		  
		  DefineMatchInfoGetters()
		  DefineMatchInfoMethods()
		  
		  DefineTextGetters()
		  DefineTextMethods()
		  
		  initialised = True
		  
		  
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function MatchInfoGetter(name as String) As Boolean
		  ' Returns True if the MatchInfo object responds to a getter with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return matchInfoObjGetters.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function MatchInfoMethod(name as String) As Boolean
		  ' Returns True if the MatchInfo object responds to a method with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return matchInfoObjMethods.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function NothingGetter(name as String) As Boolean
		  ' Returns True if the NothingObject responds to a getter with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return nothingObjGetters.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function NothingMethod(name as String) As Boolean
		  ' Returns True if the NothingObject responds to a method with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return nothingObjMethods.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function NumberGetter(name as String) As Boolean
		  ' Returns True if the Number object responds to a getter with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return numberObjGetters.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function NumberMethod(name as String) As Boolean
		  ' Returns True if the Number Object responds to a method with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return numberObjMethods.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function RegexGetter(name as String) As Boolean
		  ' Returns True if the RegexObject responds to a getter with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return regexObjGetters.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function RegexMatchGetter(name as String) As Boolean
		  ' Returns True if the RegexMatchObject responds to a getter with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return regexMatchObjGetters.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function RegexMatchMethod(name as String) As Boolean
		  ' Returns True if the RegexMatchObject responds to a method with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return regexMatchObjMethods.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function RegexMethod(name as String) As Boolean
		  ' Returns True if the RegexObject responds to a method with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return regexObjMethods.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function RegexResultGetter(name as String) As Boolean
		  ' Returns True if the RegexResult object responds to a getter with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return regexResultObjGetters.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function RegexResultMethod(name as String) As Boolean
		  ' Returns True if the RegexResult object responds to a method with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return regexResultObjMethods.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function TextGetter(name as String) As Boolean
		  ' Returns True if the TextObject responds to a getter with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return textObjGetters.Lookup(name, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function TextMethod(name as String) As Boolean
		  ' Returns True if the TextObject responds to a method with the passed name.
		  
		  if not initialised then Initialise()
		  
		  return textObjMethods.Lookup(name, False)
		End Function
	#tag EndMethod


	#tag Note, Name = About
		This module contains methods which report whether or not a built-in data type (e.g: Array, Text, etc) 
		responds to a named method or property. Using a module provides a performance boost as we don't have to 
		define each method and property that an object responds to during its construction.
		
	#tag EndNote


	#tag Property, Flags = &h21
		Private arrayObjGetters As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private arrayObjMethods As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private booleanObjGetters As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private booleanObjMethods As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private fileObjGetters As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private fileObjMethods As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private hashObjGetters As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private hashObjMethods As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private initialised As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		Private matchInfoObjGetters As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private matchInfoObjMethods As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private nothingObjGetters As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private nothingObjMethods As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private numberObjGetters As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private numberObjMethods As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private regexMatchObjGetters As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private regexMatchObjMethods As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private regexObjGetters As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private regexObjMethods As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private regexResultObjGetters As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private regexResultObjMethods As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private textObjGetters As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h21
		Private textObjMethods As StringToVariantHashMapMBS
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
