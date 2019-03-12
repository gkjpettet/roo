#tag Class
Protected Class RooSLFileSystemItem
Inherits RooInstance
Implements RooNativeClass,  RooNativeSettable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  // The FileSystem.Item constructor takes one parameter.
		  Return 1
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(owner As RooSLFileSystem, f As FolderItem)
		  Super.Constructor(Nil) // No metaclass.
		  
		  Self.Owner = owner
		  Self.File = f
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoCount() As RooNumber
		  // FileSystem.Item.count as Number object.
		  
		  If File = Nil Or Not File.Directory Then
		    Return New RooNumber(0)
		  Else
		    Return New RooNumber(File.Count)
		  End If
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoDelete(where As RooToken) As RooBoolean
		  // Deletes this File object's file or folder from the file system.
		  // Returns True if the file/folder was successfully removed, False if not. 
		  // NB: Returning False is not always an error. For instance, the file may not exist on disk already.
		  
		  // Sanity checks.
		  If File = Nil Or Not File.Exists Then Return New RooBoolean(False)
		  
		  // Delete the file.
		  Dim result As Integer = Owner.ReallyDelete(File)
		  Return New RooBoolean(If(result = 0, True, False))
		  
		  Exception err As RooSLFileSystemException
		    // The interpreter prevented deletion of this file. Fire the interpreter's
		    // DeletionPrevented event via its delegate method.
		    Owner.Interpreter.DeletionPreventedDelegate(File, where)
		    // Return False.
		    Return New RooBoolean(False)
		    
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoDirectory() As RooBoolean
		  // FileSystem.Item.directory? as Boolean object.
		  
		  If File = Nil Or Not File.Directory Then
		    Return New RooBoolean(False)
		  Else
		    Return New RooBoolean(True)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoExists() As RooBoolean
		  // FileSystem.Item.exists? as Boolean object.
		  
		  If File <> Nil And File.Exists Then
		    Return New RooBoolean(True)
		  Else
		    Return New RooBoolean(False)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFile() As RooBoolean
		  // FileSystem.Item.file?
		  
		  If File = Nil Or File.Directory Then
		    Return New RooBoolean(False)
		  Else
		    Return New RooBoolean(True)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoName() As Variant
		  // FileSystem.Item.name as Text or Nothing.
		  
		  If File = Nil Then
		    Return New RooNothing
		  Else
		    Return New RooText(File.Name)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoPath() As Variant
		  // FileSystem.Item.path as Text object or Nothing.
		  
		  If File = Nil Then
		    Return New RooNothing
		  Else
		    Return New RooText(File.NativePath)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReadable() As RooBoolean
		  // FileSystem.Item.readable?
		  
		  If File = Nil Or Not File.IsReadable Then
		    Return New RooBoolean(False)
		  Else
		    Return New RooBoolean(True)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReadAll(defineAsUTF8 As Boolean) As Variant
		  // FileSystem.Item.read_all
		  // Returns the contents of this file as Text and then closes the file.
		  // Returns Nothing if the File object's file is invalid.
		  // If defineAsUTF8 is True then we will attempt to define the read bytes as UTF-8 encoded.
		  
		  If Not ValidFile(False) Then Return New RooNothing
		  
		  // Open the file.
		  Dim result As String
		  Dim tin As TextInputStream
		  tin = TextInputStream.Open(File)
		  
		  // Define as UTF-8 if requested.
		  result = tin.ReadAll(If(defineAsUTF8, Encodings.UTF8, Nil))
		  
		  // Close the stream.
		  tin.Close
		  
		  // Return the result.
		  Return New RooText(result)
		  
		  Exception
		    Return New RooNothing
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoWriteable() As RooBoolean
		  // FileSystem.Item.writeable?
		  
		  If File = Nil Or Not File.IsWriteable Then
		    Return New RooBoolean(False)
		  Else
		    Return New RooBoolean(True)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetterWithName(name As RooToken) As Variant
		  // Part of the RooNativeClass interface.
		  
		  If StrComp(name.Lexeme, "count", 0) = 0 Then
		    Return DoCount
		  ElseIf StrComp(name.Lexeme, "delete!", 0) = 0 Then
		    Return DoDelete(name)
		  ElseIf StrComp(name.Lexeme, "directory?", 0) = 0 Then
		    Return DoDirectory
		  ElseIf StrComp(name.Lexeme, "exists?", 0) = 0 Then
		    Return DoExists
		  ElseIf StrComp(name.Lexeme, "file?", 0) = 0 Then
		    Return DoFile
		  ElseIf StrComp(name.Lexeme, "name", 0) = 0 Then
		    Return DoName
		  ElseIf StrComp(name.Lexeme, "path", 0) = 0 Then
		    Return DoPath
		  ElseIf StrComp(name.Lexeme, "read_all", 0) = 0 Then
		    Return DoReadAll(True)
		  ElseIf StrComp(name.Lexeme, "readable?", 0) = 0 Then
		    Return DoReadable
		  ElseIf StrComp(name.Lexeme, "writeable?", 0) = 0 Then
		    Return DoWriteable
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasGetterWithName(name As String) As Boolean
		  // Part of the RooNativeClass interface.
		  
		  Return RooSLCache.FileSystemItemGetters.HasKey(name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasMethodWithName(name As String) As Boolean
		  // Part of the RooNativeClass interface.
		  
		  Return RooSLCache.FileSystemItemMethods.HasKey(name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, args() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  // Create a new FileSystem.Item object instance.
		  // Takes as its parameter the native path to the file.
		  
		  // Ensure the passed parameter has a text representation.
		  Roo.AssertIsStringable(where, args(0))
		  
		  // Get the Roo path as a String.
		  Dim path As String
		  path = Stringable(args(0)).StringValue
		  
		  // Try to convert this Roo path to a FolderItem
		  Self.File = interpreter.RooPathToFolderItem(path, where.File)
		  
		  Return Self
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodWithName(name As RooToken) As Invokable
		  // Part of the RooNativeClass interface.
		  
		  // Return a new instance of a FileSystem.Item object method initialised with the name 
		  // of the method being called. That way, when the returned method is invoked, it will know what operation 
		  // to perform.
		  Return New RooSLFileSystemItemMethod(Self, name.Lexeme)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name As RooToken, value As Variant)
		  // Part of the RooNativeSettable interface.
		  
		  If Strcomp(name.Lexeme, "name", 0) = 0 Then
		    SetName(value, name)
		  ElseIf StrComp(name.Lexeme, "path", 0) = 0 Then
		    SetPath(value, name)
		  Else
		    Raise New RooRuntimeError(name, "The FileSystem.Item object has no property named `" + _
		    name.Lexeme + "`.")
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetName(value As Variant, where As RooToken)
		  // Change the name of this FileSystem.Item object's file to the passed value.
		  
		  Roo.AssertIsStringable(where, value)
		  
		  // Attempt to change the name.
		  Try
		    File.Name = Stringable(value).StringValue
		  Catch err
		    Return
		  End Try
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetPath(value As Variant, where As RooToken)
		  // Set the path of this FileSystem.Item object's file to the passed value.
		  
		  Roo.AssertIsStringable(where, value)
		  
		  Try
		    File = New FolderItem(Stringable(value).StringValue, FolderItem.PathTypeNative)
		  Catch
		    File = Nil
		  End Try
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return If(File = Nil, "Nothing", File.NativePath)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As String
		  // Part of the RooNativeClass interface.
		  
		  Return "FileSystem.Item"
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ValidFile(checkWriteable As Boolean) As Boolean
		  // Makes sure that this FileSystem.Item object has a valid file on disk.
		  // Returns True if it is or False if not.
		  
		  If File = Nil Then Return False
		  If Not File.Exists Then Return False
		  If Not File.IsReadable Then Return False
		  If checkWriteable And Not File.IsWriteable Then Return False
		  
		  Return True
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		File As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		Owner As RooSLFileSystem
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
