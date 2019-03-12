#tag Class
Protected Class RooSLFileSystemMove
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  Return 3
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(owner As RooSLFileSystem)
		  Self.Owner = owner
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, args() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  // FileSystem.move(source, destination, overwrite as Boolean) as Boolean object
		  // Moves the folder/file at `source` to `destination`.
		  // `source` and `destination` can be either a Text path or a File object.
		  // Returns True if OK, False if unsuccessful.
		  
		  // Should we overwrite?
		  Dim overwrite As Boolean = interpreter.IsTruthy(args(2))
		  
		  // Ensure that `source` is a Stringable or FileSystem.Item object.
		  If Not args(0) IsA RooSLFileSystemItem And Not args(0) IsA Stringable Then
		    Raise New RooRuntimeError(where, "Expected a Text or FileSystem.Item " + _
		    "object parameter for `source`. Instead got " + _
		    Roo.VariantTypeAsString(args(0)) + ".")
		  End If
		  
		  // Get the source FolderItem.
		  Dim source As FolderItem
		  If args(0) IsA RooSLFileSystemItem Then
		    If RooSLFileSystemItem(args(0)).File = Nil Then
		      // Invalid FileSystem.Item `source` object
		      Return New RooBoolean(False)
		    End If
		    source = RooSLFileSystemItem(args(0)).File
		  Else
		    source = interpreter.RooPathToFolderItem(RooText(args(0)).Value, where.File)
		    If source = Nil Then Return New RooBoolean(False) // Invalid path for `source`.
		  End If
		  
		  // OK, we have a valid FolderItem representing the source file/folder. Does it exist?
		  If Not source.Exists Then Return New RooBoolean(False)
		  
		  // Ensure that `destination` is a Stringable or FileSystem.Item object.
		  If Not args(1) IsA RooSLFileSystemItem And Not args(1) IsA Stringable Then
		    Raise New RooRuntimeError(where, "Expected a Text or FileSystem.Item " + _
		    "object parameter for `destination`. Instead got " + _
		    Roo.VariantTypeAsString(args(1)) + ".")
		  End If
		  
		  // Get the destination FolderItem.
		  Dim destination As FolderItem
		  If args(1) IsA RooSLFileSystemItem Then
		    If RooSLFileSystemItem(args(1)).File = Nil Then
		      // Invalid FileSystem.Item `destination` object
		      Return New RooBoolean(False)
		    End If
		    destination = RooSLFileSystemItem(args(1)).File
		  Else
		    destination = interpreter.RooPathToFolderItem(RooText(args(1)).Value, where.File)
		    If destination = Nil Then Return New RooBoolean(False) // Invalid path for `destination`.
		  End If
		  
		  // OK, we have a valid FolderItem representing the destination file/folder. Does it exist?
		  If Not destination.Exists Then Return New RooBoolean(False)
		  
		  // The destination must always be a folder. Check this.
		  If Not destination.Directory Then Return New RooBoolean(False)
		  
		  // We now have FolderItems representing the source and destination. 
		  Return Move(source, destination, overwrite, where)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Move(source As FolderItem, destination As FolderItem, overwrite As Boolean, where As RooToken) As RooBoolean
		  // Internal helper method.
		  // Assumes `source` and `destination` both exist and that `destination` is a folder.
		  
		  // Use this interpreter's FileSystem module to move `source` to `destination`.
		  Dim e As RooSLFileSystem.Error = Owner.Move(source, destination, overwrite)
		  
		  // Return the result.
		  Select Case e
		  Case RooSLFileSystem.Error.None
		    Return New RooBoolean(True)
		  Case RooSLFileSystem.Error.AttemptToDeleteProtectedFolderItem
		    // This move would have resulted in the deletion of a protected 
		    // file or folder. Fire the interpreter's DeletionPrevented event.
		    Owner.Interpreter.DeletionPreventedDelegate(source, where)
		    Return New RooBoolean(False)
		  Else
		    Return New RooBoolean(False)
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<function: FileSystem.move>"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Owner As RooSLFileSystem
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
