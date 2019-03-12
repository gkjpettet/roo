#tag Class
Protected Class RooSLFileSystemMkDir
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  Return 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, args() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  // FileSystem.mkdir(path) as Text or Nothing.
		  // Creates a new directory at the specified path. 
		  // Returns the path to the newly created folder if successful, Nothing if fails.
		  
		  ' Check the passed argument is a text object.
		  Roo.AssertIsStringable(where, args(0))
		  Dim path As String = Stringable(args(0)).StringValue
		  
		  // Convert the passed Roo path to a FolderItem.
		  Dim f As FolderItem = interpreter.RooPathToFolderItem(path, where.File)
		  If f = Nil Then
		    Raise New RooRuntimeError(where, "Invalid path passed to the FileSystem.mkdir(path) function (`" + _
		    path + "`).")
		  End If
		  
		  // We have a valid FolderItem representing the folder to create.
		  // If it already exists we'll just return the path. No need to recreate it.
		  If f.Exists Then Return New RooText(Roo.FolderItemToRooPath(f))
		  
		  // Try to create this folder.
		  f.CreateAsFolder
		  If f.LastErrorCode <> 0 Then
		    Return New RooNothing
		  Else
		    Return New RooText(Roo.FolderItemToRooPath(f))
		  End If
		  
		  Exception err
		    Return New RooNothing
		    
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<function: FileSystem.mkdir>"
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
