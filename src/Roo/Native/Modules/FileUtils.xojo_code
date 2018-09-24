#tag Class
Protected Class FileUtils
Inherits Roo.CustomModule
Implements Roo.Textable
	#tag Method, Flags = &h21
		Private Function DoCwd(where As Roo.Token, textMode As Boolean) As Variant
		  ' FileUtils.cwd as File or Nothing
		  ' FileUtils.cwd_path as Text or Nothing
		  ' Returns the current working directory (cwd) as either a Roo formatted path (textMode = True) 
		  ' or a File object (textMode = False).
		  ' If Roo is executing a script then the cwd will be the folder containing the script file.
		  ' If Roo is in REPL mode or simply interpreting direct String input then cwd will be Nothing.
		  
		  If where.File = Nil Then
		    Return New NothingObject
		  Else
		    If where.File.Parent <> Nil Then
		      If textMode Then
		        Return New TextObject(where.File.Parent.RooPath)
		      Else
		        Return New FileObject(New FolderItem(where.File.Parent.NativePath, FolderItem.PathTypeNative))
		      End If
		    Else
		      Return New NothingObject
		    End If
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name as Roo.Token) As Variant
		  ' Override RooInstance.Get().
		  
		  ' Getters.
		  If StrComp(name.lexeme, "cwd", 0) = 0 Then
		    Return DoCwd(name, False)
		  ElseIf StrComp(name.lexeme, "cwd_path", 0) = 0 Then
		    Return DoCwd(name, True)
		  End If
		  
		  ' Methods.
		  Return Super.Get(name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter = Nil) As String
		  ' Part of the Roo.Textable interface.
		  
		  #Pragma Unused interpreter
		  
		  Return "FileUtils module"
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
			Name="name"
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
