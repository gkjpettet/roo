#tag Class
Protected Class FileUtilsCopy
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Part of the Invokable interface.
		  ' Return the number of parameters the `copy` function requires.
		  
		  Return 3
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoCopy(source As FolderItem, destination As FolderItem, overwrite As Boolean) As Roo.Objects.BooleanObject
		  ' Assumes `source` and `destination` both exist and that `destination` is a folder.
		  
		  Using FileSystem
		  
		  ' Use our FileSystem module to robustly copy `source` to `destination`.
		  Dim e As Error = source.CopyTo(destination, overwrite)
		  
		  If e = Roo.FileSystem.Error.None Then
		    Return New BooleanObject(True)
		  Else
		    Return New BooleanObject(False)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Roo.Interpreter, arguments() as Variant, where as Roo.Token) As Variant
		  ' FileUtils.copy(source, destination, overwrite as Boolean) as Boolean.
		  ' Copies the folder/file at `source` to `destination`
		  ' `source` and `destination` can be either a Text path or a File object.
		  ' Returns True if OK, False if unsuccessful.
		  
		  ' Should we overwrite?
		  Dim overwrite As Boolean = interpreter.IsTruthy(arguments(2))
		  
		  ' Check the first and second arguments are Text or File objects.
		  If Not arguments(0) IsA TextObject And Not arguments(0) IsA FileObject Then
		    Raise New RuntimeError(where, "The FileUtils.copy(source, destination, overwrite) method " + _
		    "expects a Text or File object parameter for `source`. Instead got " + _
		    VariantType(arguments(0)) + ".")
		  End If
		  Dim source As FolderItem
		  If arguments(0) IsA FileObject Then
		    If FileObject(arguments(0)).File = Nil Then
		      Raise New RuntimeError(where, "Invalid source File passed to the " + _
		      "FileUtils.copy(source, destination, overwrite) method.")
		    End If
		    source = FileObject(arguments(0)).File
		  Else
		    source = Roo.RooPathToFolderItem(TextObject(arguments(0)).Value, where.File)
		    If source = Nil Then
		      Raise New RuntimeError(where, "Invalid source path passed to the " + _
		      "FileUtils.copy(source, destination, overwrite) method.")
		    End If
		  End If
		  
		  ' OK, we have a valid FolderItem representing the source file/folder. Does it exist?
		  If Not source.Exists Then Return New BooleanObject(False)
		  
		  If Not arguments(1) IsA TextObject And Not arguments(1) IsA FileObject Then
		    Raise New RuntimeError(where, "The FileUtils.copy(source, destination, overwrite) method " + _
		    "expects a Text or File object parameter for `destination`. Instead got " + _
		    VariantType(arguments(1)) + ".")
		  End If
		  Dim destination As FolderItem
		  If arguments(1) IsA FileObject Then
		    If FileObject(arguments(1)).File = Nil Then
		      Raise New RuntimeError(where, "Invalid destination File passed to the " + _
		      "FileUtils.copy(source, destination, overwrite) method.")
		    End If
		    destination = FileObject(arguments(1)).File
		  Else
		    destination = Roo.RooPathToFolderItem(TextObject(arguments(1)).Value, where.File)
		    If destination = Nil Then
		      Raise New RuntimeError(where, "Invalid destination path (" + _
		      TextObject(arguments(1)).Value + ") passed to the " + _
		      "FileUtils.copy(source, destination, overwrite) method.")
		    End If
		  End If
		  
		  ' Make sure that the destination exists.
		  If Not destination.Exists Then
		    Raise New RuntimeError(where, "Invalid destination passed to the " + _
		    "FileUtils.copy(source, destination, overwrite) method. The destination does not exist.")
		  End If
		  
		  ' The destination must always be a folder. Check this.
		  If Not destination.Directory Then
		    Raise New RuntimeError(where, "Invalid destination passed to the " + _
		    "FileUtils.copy(source, destination, overwrite) method. The destination must be a folder.")
		  End If
		  
		  ' Use our helper method to actually do the copy.
		  Return DoCopy(source, destination, overwrite)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter = Nil) As String
		  ' Part of the Textable interface.
		  ' Return this function's name.
		  
		  #Pragma Unused interpreter
		  
		  Return "<function: FileUtils.copy>"
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
