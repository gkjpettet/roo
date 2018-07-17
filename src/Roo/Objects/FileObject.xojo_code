#tag Class
Protected Class FileObject
Inherits RooClass
	#tag Method, Flags = &h0
		Sub Constructor(file as FolderItem)
		  ' Calling the overridden superclass constructor.
		  super.Constructor(Nil)
		  
		  self.file = file
		End Sub
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
		    case "count"
		      return DoCount()
		    case "directory?"
		      return DoDirectory()
		    case "exists?"
		      return DoExists()
		    case "file?"
		      return DoFile()
		    case "name"
		      return DoName()
		    case "nothing?"
		      return new BooleanObject(False)
		    case "number?"
		      return new BooleanObject(False)
		    case "path"
		      return DoPath()
		    case "readable?"
		      return DoReadable()
		    case "to_text"
		      if self.file = Nil then
		        return new TextObject("Nothing")
		      else
		        return new TextObject(self.file.NativePath)
		      end if
		    case "type"
		      return new TextObject("File")
		    case "writeable?"
		      return DoWriteable()
		    end select
		  end if
		  
		  raise new RuntimeError(name, "File objects have no method named `" + name.lexeme + "`.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name as Roo.Token, value as Variant)
		  #pragma Unused name
		  #pragma Unused value
		  
		  ' Override RooInstance.Set
		  ' We want to prevent both the creating of new fields on File objects and setting their values 
		  ' EXCEPT for a few specific permitted values.
		  
		  select case name.lexeme
		  case "path"
		    DoSetPath(value, name)
		    return
		  else
		    raise new RuntimeError(name, "Cannot create or set fields on File objects " +_ 
		    "(File." + name.lexeme + ").")
		  end select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Part of the Textable interface.
		  
		  if self.file = Nil then
		    return "Nothing"
		  else
		    return self.file.NativePath
		  end if
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		file As FolderItem
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
