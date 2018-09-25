#tag Class
Protected Class File
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Return the number of parameters the function requires.
		  
		  return 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Roo.Token) As Variant
		  ' Create a new File object instance.
		  ' Takes as its parameter the native path to the file.
		  
		  #Pragma Unused interpreter
		  
		  ' Check a valid path argument has been passed.
		  If Not arguments(0) IsA Textable Then
		    Raise New RuntimeError(where, "The parameter passed to the File method must have a " + _
		    "text representation.")
		  End If
		  
		  ' Get the Roo path as a String.
		  Dim path As String
		  If arguments(0) IsA Roo.Objects.TextObject Then
		    path = Roo.Objects.TextObject(arguments(0)).value
		  Else
		    path = Textable(arguments(0)).ToText(interpreter)
		  End If
		  
		  ' Convert this Roo path to a FolderItem
		  Dim f As FolderItem = Roo.RooPathToFolderItem(path, where.File)
		  
		  ' Create the new FileObject and return it.
		  Return New Roo.Objects.FileObject(f)
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter) As String
		  ' Return this function's name.
		  
		  #Pragma Unused interpreter
		  
		  Return "<function: File>"
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
