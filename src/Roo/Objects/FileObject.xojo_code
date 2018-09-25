#tag Class
Protected Class FileObject
Inherits RooClass
Implements Roo.Textable
	#tag Method, Flags = &h0
		Function CheckInteger(value As Variant, shouldBePositive As Boolean = False) As Boolean
		  ' Helper method.
		  ' Returns True if the passed value is an integer NumberObject.
		  ' If the optional `shouldBePositive` parameter is True then we also check to make sure that `value` 
		  ' is positive.
		  
		  If Not value IsA NumberObject Or Not NumberObject(value).IsInteger Then Return False
		  
		  Return If(shouldBePositive And NumberObject(value).value >= 0, True, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(file as FolderItem)
		  ' Calling the overridden superclass constructor.
		  super.Constructor(Nil)
		  
		  self.file = file
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoClose() As Variant
		  ' File.close
		  
		  If Bin <> Nil Then Bin.Close
		  If Tin <> Nil Then Tin.Close
		  
		  Closed = True
		  
		  Return New NothingObject
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoCount() As Roo.Objects.NumberObject
		  ' File.count as NumberObject.
		  
		  if self.file = Nil or not self.file.Directory then
		    return new NumberObject(0)
		  else
		    return new NumberObject(self.file.Count)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoDelete() As Roo.Objects.BooleanObject
		  ' Deletes this File object's file or folder from the file system.
		  ' Returns True if the file/folder was successfully removed, False if not. 
		  ' NB: Returning False is not always an error. For instance, the file may not exist on disk already.
		  
		  Using FileSystem
		  
		  ' Sanity check.
		  If Self.File = Nil Or Not Self.File.Exists Then Return New BooleanObject(False)
		  
		  If Self.File.ReallyDelete = 0 Then
		    Return New BooleanObject(True)
		  Else
		    Return New BooleanObject(False)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoDirectory() As Roo.Objects.BooleanObject
		  ' File.directory? as BooleanObject
		  
		  if self.file = Nil then return new BooleanObject(False)
		  
		  return new BooleanObject(self.file.Directory)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoExists() As Roo.Objects.BooleanObject
		  ' File.exists? as BooleanObject.
		  
		  if self.file <> Nil and self.file.Exists then
		    return new BooleanObject(True)
		  else
		    return new BooleanObject(False)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFile() As Roo.Objects.BooleanObject
		  ' File.file? as BooleanObject
		  
		  if self.file = Nil or not self.file.Exists then return new BooleanObject(False)
		  
		  return new BooleanObject(not self.file.Directory)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFlush() As Variant
		  ' File.flush
		  ' Immediately sends the contents of internal write buffers to disk.
		  
		  If Bin <> Nil Then Bin.Flush
		  
		  Return New NothingObject
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoName() As Variant
		  ' File.name as TextObject or Nothing.
		  
		  if self.file = Nil then
		    return new NothingObject
		  else
		    return new TextObject(self.file.Name)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoPath() As Variant
		  ' File.path as TextObject or Nothing.
		  
		  if self.file = Nil then
		    return new NothingObject
		  else
		    return new TextObject(self.file.NativePath)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReadable() As Roo.Objects.BooleanObject
		  ' File.readable? as BooleanObject.
		  
		  if self.file = Nil then
		    return new BooleanObject(False)
		  else
		    return new BooleanObject(self.file.IsReadable)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReadAll(where As Roo.Token) As Variant
		  ' File.read_all
		  ' Returns the content of this file as Text and then closes the file.
		  ' Returns Nothing if the File object's file is invalid.
		  
		  If Not ValidFile(False) Then Return New NothingObject
		  
		  ' Close any open streams.
		  If Bin <> Nil Then Bin.Close
		  If Tin <> Nil Then Tin.Close
		  
		  ' Open the file.
		  Dim result As String
		  Try
		    Tin = TextInputStream.Open(File)
		    Closed = False
		    result = Tin.ReadAll
		    Tin.Close
		    Closed = True
		  Catch err As IOException
		    Raise New RuntimeError(where, "Unable to open the File object's TextInputStream.")
		  End Try
		  
		  Return New TextObject(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReadInt(intSize As Integer, signed As Boolean, where As Roo.Token) As Variant
		  ' Convenience method for the following File methods:
		  ' File.read_int8, File,read_int16, File.read_int32, File.read_int64
		  ' File.read_uint8, File.read_uint16, File.read_uint32, File.read_uint64
		  
		  ' Make sure this file is valid.
		  If Not ValidFile(False) Then Return New NothingObject
		  
		  ' If this file has not been opened, open a new BinaryStream.
		  If Closed Then
		    Try
		      Bin = BinaryStream.Open(File, True)
		      Closed = False
		    Catch err As IOException
		      Raise New RuntimeError(where, "Unable to open File object in binary mode: " + err.Message)
		    End Try
		  End If
		  
		  ' We have successfully opened the file. Read the requested number of bytes as an integer.
		  Dim result As NumberObject
		  Select Case intSize
		  Case 8
		    result =  New NumberObject(If(signed, Bin.ReadInt8, Bin.ReadUInt8))
		  Case 16
		    result = New NumberObject(If(signed, Bin.ReadInt16, Bin.ReadUInt16))
		  Case 32
		    result = New NumberObject(If(signed, Bin.ReadInt32, Bin.ReadUInt32))
		  Case 64
		    result = New NumberObject(If(signed, Bin.ReadInt64, Bin.ReadUInt64))
		  End Select
		  
		  Pos = Bin.Position
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReadLines(where As Roo.Token) As Roo.Objects.ArrayObject
		  ' File.read_lines as Array
		  ' Returns a new array where each element is a line from this file. Closes the file when done.
		  ' If there is an error with the file then it returns an empty array.
		  
		  Dim lines() As Variant
		  
		  If Not ValidFile(False) Then Return New ArrayObject(lines)
		  
		  ' Close any open streams.
		  If Bin <> Nil Then Bin.Close
		  If Tin <> Nil Then Tin.Close
		  Closed = True
		  
		  ' Open the file.
		  Try
		    Tin = TextInputStream.Open(File)
		    Closed = False
		    Do
		      lines.Append(New TextObject(Tin.ReadLine))
		    Loop Until Tin.EOF
		    Tin.Close
		    Closed = True
		  Catch err As IOException
		    Raise New RuntimeError(where, "Unable to open the File object's TextInputStream.")
		  End Try
		  
		  Return New ArrayObject(lines)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoSetPath(value as Variant, where as Roo.Token)
		  ' Set the path of this file to the passed value.
		  
		  if value = Nil or not value isA Roo.Objects.TextObject then
		    raise new Roo.RuntimeError(where, "The file.path property should be a text object.")
		  end if
		  
		  try
		    self.file = new FolderItem(Roo.Objects.TextObject(value).value, FolderItem.PathTypeNative)
		  catch
		    self.file = Nil
		  end try
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoWriteable() As Roo.Objects.BooleanObject
		  ' File.writeable? as BooleanObject.
		  
		  if self.file = Nil then
		    return new BooleanObject(False)
		  else
		    return new BooleanObject(self.file.IsWriteable)
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name as Token) As Variant
		  ' Override RooInstance.Get().
		  
		  if Lookup.FileMethod(name.lexeme) then return new FileObjectMethod(self, name.lexeme)
		  
		  if Lookup.FileGetter(name.lexeme) then
		    select case name.lexeme
		    Case "close"
		      Return DoClose
		    Case "closed?"
		      Return New BooleanObject(closed)
		    case "count"
		      return DoCount
		    Case "delete!"
		      Return DoDelete
		    case "directory?"
		      return DoDirectory
		    case "exists?"
		      return DoExists
		    case "file?"
		      return DoFile
		    Case "flush"
		      Return DoFlush
		    case "name"
		      return DoName
		    case "nothing?"
		      return new BooleanObject(False)
		    case "number?"
		      return new BooleanObject(False)
		    case "path"
		      return DoPath
		    Case "pos"
		      Return New NumberObject(Pos)
		    Case "read_all"
		      Return DoReadAll(name)
		    Case "read_int8"
		      Return DoReadInt(8, True, name)
		    Case "read_int16"
		      Return DoReadInt(16, True, name)
		    Case "read_int32"
		      Return DoReadInt(32, True, name)
		    Case "read_int64"
		      Return DoReadInt(64, True, name)
		    Case "read_lines"
		      Return DoReadLines(name)
		    case "readable?"
		      return DoReadable
		    case "to_text"
		      if self.file = Nil then
		        return new TextObject("Nothing")
		      else
		        return new TextObject(self.file.NativePath)
		      end if
		    case "type"
		      return new TextObject("File")
		    Case "read_uint8"
		      Return DoReadInt(8, False, name)
		    Case "read_uint16"
		      Return DoReadInt(16, False, name)
		    Case "read_uint32"
		      Return DoReadInt(32, False, name)
		    Case "read_uint64"
		      Return DoReadInt(64, False, name)
		    case "writeable?"
		      return DoWriteable
		    end select
		  end if
		  
		  raise new RuntimeError(name, "File objects have no method named `" + name.lexeme + "`.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name As Roo.Token, value As Variant)
		  #Pragma Unused name
		  #Pragma Unused value
		  
		  ' Override RooInstance.Set
		  ' We want to prevent both the creating of new fields on File objects and setting their values
		  ' EXCEPT for a few specific permitted values.
		  
		  Select Case name.Lexeme
		  Case "path"
		    DoSetPath(value, name)
		    Return
		  Case "pos"
		    If Not CheckInteger(value, True) Then
		      Raise New RuntimeError(name, "File.pos must be an integer >= 0. Instead got `" + _
		      Textable(value).ToText(Nil) + "`")
		    Else
		      Pos = NumberObject(value).value
		    End If
		  Else
		    Raise New RuntimeError(name, "Cannot create or set fields on File objects " + _
		    "(File." + name.Lexeme + ").")
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter) As String
		  ' Part of the Textable interface.
		  
		  #Pragma Unused interpreter
		  
		  If Self.file = Nil Then
		    Return "Nothing"
		  Else
		    Return Self.file.NativePath
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ValidFile(checkWriteable As Boolean) As Boolean
		  ' This method makes sure that this File object has a valid file on disk.
		  ' Returns True if it is or False if not.
		  
		  If File = Nil Then Return False
		  If Not File.Exists Then Return False
		  If Not File.IsReadable Then Return False
		  If checkWriteable And Not File.IsWriteable Then Return False
		  
		  Return True
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Bin As BinaryStream
	#tag EndProperty

	#tag Property, Flags = &h0
		Closed As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		File As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		Pos As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		Tin As TextInputStream
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
		#tag ViewProperty
			Name="Pos"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Closed"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
