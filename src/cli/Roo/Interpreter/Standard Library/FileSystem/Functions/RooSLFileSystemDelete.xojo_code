#tag Class
Protected Class RooSLFileSystemDelete
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  Return 1
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(owner As RooSLFileSystem)
		  Self.Owner = owner
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Delete(what As FolderItem, where As RooToken) As RooBoolean
		  // Internal helper method.
		  
		  // Delete the file.
		  Dim result As Integer = Owner.ReallyDelete(what)
		  Return New RooBoolean(If(result = 0, True, False))
		  
		  Exception err As RooSLFileSystemException
		    // The interpreter prevented deletion of this file or folder. Fire the interpreter's
		    // DeletionPrevented event via its delegate method.
		    Owner.Interpreter.DeletionPreventedDelegate(what, where)
		    // Return False.
		    Return New RooBoolean(False)
		    
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, args() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  // FileSystem.delete(what) as Boolean.
		  // Delete the specified file or folder.
		  // Returns True if OK, False if unsuccessful.
		  
		  // Ensure that `what` is a Text or File object.
		  If Not args(0) IsA RooSLFileSystemItem And Not args(0) IsA Stringable Then
		    Raise New RooRuntimeError(where, "Expected a Text or FileSystem.Item " + _
		    "object parameter for `what`. Instead got " + _
		    Roo.VariantTypeAsString(args(0)) + ".")
		  End If
		  
		  // Get the `what` FolderItem.
		  Dim what As FolderItem
		  If args(0) IsA RooSLFileSystemItem Then
		    If RooSLFileSystemItem(args(0)).File = Nil Then
		      // Invalid FileSystem.Item object parameter.
		      Return New RooBoolean(False)
		    End If
		    what = RooSLFileSystemItem(args(0)).File
		  Else
		    what = interpreter.RooPathToFolderItem(RooText(args(0)).Value, where.File)
		    If what = Nil Then Return New RooBoolean(False) // Invalid deletion path.
		  End If
		  
		  // OK, we have a valid FolderItem representing the file/folder to delete. Does it exist?
		  If Not what.Exists Then Return New RooBoolean(False) // Nothing to do.
		  
		  // We now have a valid reference to the FolderItem to delete.
		  Return Delete(what, where)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<function: FileSystem.delete>"
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
