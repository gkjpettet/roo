#tag Class
Protected Class FileUtilsDelete
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Part of the Invokable interface.
		  ' Return the number of parameters the `copy` function requires.
		  
		  Return 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoDelete(what As FolderItem) As Roo.Objects.BooleanObject
		  ' Internal helper method to delete the passed file or folder using our cross-platform 
		  ' FileSystem.ReallyDelete method.
		  
		  Using FileSystem
		  
		  If what.ReallyDelete = 0 Then
		    Return New BooleanObject(True)
		  Else
		    Return New BooleanObject(False)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Roo.Interpreter, arguments() as Variant, where as Roo.Token) As Variant
		  ' FileUtils.delete(source) as Boolean.
		  ' Delete the specified file or folder.
		  ' Returns True if OK, False if unsuccessful.
		  
		  #Pragma Unused interpreter
		  
		  ' Check the argument is either a Text or File object.
		  If Not arguments(0) IsA TextObject And Not arguments(0) IsA FileObject Then
		    Raise New RuntimeError(where, "The FileUtils.delete(what) method " + _
		    "expects a Text or File object parameter for `what`. Instead got " + _
		    VariantType(arguments(0)) + ".")
		  End If
		  Dim what As FolderItem
		  If arguments(0) IsA FileObject Then
		    If FileObject(arguments(0)).File = Nil Then
		      Raise New RuntimeError(where, "Invalid File passed to the FileUtils.delete(what) method.")
		    End If
		    what = FileObject(arguments(0)).File
		  Else
		    what = Roo.RooPathToFolderItem(TextObject(arguments(0)).Value, where.File)
		    If what = Nil Then
		      Raise New RuntimeError(where, "Invalid file path passed to the FileUtils.delete(what) method.")
		    End If
		  End If
		  
		  ' OK, we have a valid FolderItem representing what to delete. Does it exist?
		  If Not what.Exists Then Return New BooleanObject(False) ' Nothing to do.
		  
		  ' Use our helper method to actually do the copy.
		  Return DoDelete(what)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter) As String
		  ' Part of the Textable interface.
		  ' Return this function's name.
		  
		  #Pragma Unused interpreter
		  
		  Return "<function: FileUtils.delete>"
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
