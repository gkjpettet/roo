#tag Class
Protected Class File
Implements  Roo.Invokable,  Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Return the number of parameters the function requires.
		  
		  return 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Token) As Variant
		  ' Create a new File object instance.
		  ' Takes as its parameter the native path to the file.
		  
		  #pragma Unused interpreter
		  
		  if not arguments(0) isA Textable then
		    raise new RuntimeError(where, "The parameter passed to the File method must have a " + _
		    "text representation.")
		  end if
		  
		  dim path as String
		  if arguments(0) isA Roo.Objects.TextObject then
		    path = Roo.Objects.TextObject(arguments(0)).value
		  else
		    path = Textable(arguments(0)).ToText
		  end if
		  
		  dim file as Roo.Objects.FileObject
		  dim f as FolderItem
		  try
		    f = new FolderItem(path, FolderItem.PathTypeNative)
		    file = new Roo.Objects.FileObject(f)
		  catch
		    file = new Roo.Objects.FileObject(Nil)
		  end try
		  
		  return file
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Return this function's name.
		  
		  return "<function: input>"
		End Function
	#tag EndMethod


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
