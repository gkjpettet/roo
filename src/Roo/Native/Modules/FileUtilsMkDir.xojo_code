#tag Class
Protected Class FileUtilsMkDir
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Part of the Invokable interface.
		  ' Return the number of parameters the `mkdir` function requires.
		  
		  Return 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Roo.Token) As Variant
		  ' FileUtils.mkdir(path) as Text or Nothing.
		  ' Creates a new directory at the specified path. 
		  ' Returns the path to the newly created folder if successful, Nothing if fails.
		  
		  #Pragma Unused interpreter
		  
		  ' Check the passed argument is a text object.
		  If Not arguments(0) IsA TextObject Then
		    Raise New RuntimeError(where, "The FileUtils.mkdir(path) method expects a Text parameter. " + _
		    "Instead got " + VariantType(arguments(0)) + ".")
		  End If
		  Dim path As String = TextObject(arguments(0)).Value
		  
		  ' Convert the passed Roo path to a FolderItem.
		  Dim f As FolderItem = Roo.RooPathToFolderItem(path, where.File)
		  If f = Nil Then
		    Raise New RuntimeError(where, "Invalid path passed to the FileUtils.mkdir(path) function (`" + _
		    path + "`).")
		  End If
		  
		  ' OK, we have a valid FolderItem representing the folder to create. Does it exist?
		  If f.Exists Then
		    ' Just return the path (don't recreate the folder).
		    Return New TextObject(f.RooPath)
		  End If
		  
		  ' Try to create this folder.
		  Try
		    f.CreateAsFolder
		    If f.LastErrorCode <> 0 Then
		      Return New NothingObject
		    Else
		      Return New TextObject(f.RooPath)
		    End If
		  Catch err
		    Return New NothingObject
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Part of the Textable interface.
		  ' Return this function's name.
		  
		  Return "<function: FileUtils.mkdir>"
		End Function
	#tag EndMethod


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
	#tag EndViewBehavior
End Class
#tag EndClass
