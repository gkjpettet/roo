#tag Class
Protected Class FileObjectMethod
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  Select Case Self.name
		  Case "append"
		    Return 1
		  Case "append_line"
		    Return 1
		  Case "copy_to"
		    Return 2
		  Case "each_byte"
		    Return Array(1, 2)
		  Case "each_char"
		    Return Array(1, 2)
		  Case "each_line"
		    Return Array(1, 2)
		  Case "move_to"
		    Return 2
		  Case "read"
		    Return 1
		  Case "responds_to?"
		    Return 1
		  Case "write"
		    Return 1
		  Case "write_line"
		    Return 1
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(parent as FileObject, name as String)
		  self.parent = parent
		  self.name = name
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoCopy(arguments() As Variant, where As Roo.Token, interpreter As Roo.Interpreter) As Variant
		  ' File.copy_to(destination, overwrite) as Boolean
		  ' Copies this file/folder to the specified destination.
		  ' `destination` may be either a relative/absolute text path or a File object.
		  ' If `overwrite` is True then we will permit the overwriting of files/folder.
		  ' Returns a Boolean object - True if successful, False if not.
		  ' Essentially an alias to FileUtils.copy(Self, destination)
		  
		  ' Check the first argument is either Text or a File object.
		  If Not arguments(0) IsA TextObject And Not arguments(0) IsA FileObject Then
		    Raise New RuntimeError(where, "The File.copy_to(destination, overwrite) method expects a " + _
		    "Text or File object parameter for `destination`. Instead got " + VariantType(arguments(0)) + ".")
		  End If
		  
		  ' Inject this File object as the first argument.
		  arguments.Insert(0, Self.Parent)
		  
		  ' Create a new instance of the FileUtils.copy method and use that to handle the copy.
		  Dim copyMethod As New Roo.Native.Modules.FileUtilsCopy
		  Return copyMethod.Invoke(interpreter, arguments, where)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEachByte(args() As Variant, where As Roo.Token, interpreter As Interpreter) As Roo.Objects.NumberObject
		  ' File.each_byte(func as Invokable, optional arguments as Array) as Array
		  ' Invokes the passed function for each byte within this file, passing to the function the 
		  ' byte as an integer as the first argument.
		  ' Optionally the method can take a second argument in the form of an Array. The elements of this
		  ' Array will be passed to the function as additional arguments.
		  ' Returns the current position in the stream.
		  ' E.g: 
		  
		  ' function list(byte) {
		  '   print(byte);
		  ' }
		  
		  ' function prefix(byte, what) {
		  '   print(what + byte);
		  ' }
		  
		  ' Assume file contents are:
		  ' Iron Man
		  ' Hulk
		  ' Thor
		  
		  ' var f = File("Users/garry/Desktop/test.txt");
		  ' f.each_line(list)
		  ' # Prints:
		  
		  
		  ' f.each_line(prefix, ["Byte Value: "]
		  ' # Prints:
		  
		  
		  Dim funcArgs() As Variant
		  Dim func As Invokable
		  
		  ' Check that `func` is invokable.
		  If Not args(0) IsA Invokable Then
		    Raise New RuntimeError(where, "The " + Self.Name + "(func, args?) method expects a function as the " +_
		    "first parameter. Instead got " + VariantType(args(0)) + ".")
		  Else
		    func = args(0)
		  End If
		  
		  ' If a second argument has been passed, check that it's an ArrayObject.
		  If args.Ubound = 1 then
		    If Not args(1) IsA ArrayObject Then
		      Raise New RuntimeError(where, "The " + Self.name + "(func, args?) method expects the optional " +_
		      "second parameter to be an array. Instead got " + VariantType(args(1)) + ".")
		    Else
		      ' Get an array of the additional arguments to pass to the function we will invoke.
		      For Each v As Variant In ArrayObject(args(1)).Elements
		        funcArgs.Append(v)
		      Next v
		    End If
		  End If
		  
		  ' Check that we have the correct number of arguments for `func`.
		  ' +2 as we will pass in each byte as the first argument.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) Then
		    Raise New RuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Textable(func).ToText + " function.")
		  End If
		  
		  ' Is the file valid?
		  If Not Parent.ValidFile(False) Then
		    Raise New RuntimeError(where, "The File object's file is not valid.")
		  End If
		  
		  ' Close any open streams.
		  If Parent.Bin <> Nil Then Parent.Bin.Close
		  If Parent.Tin <> Nil Then Parent.Tin.Close
		  Parent.Closed = True
		  
		  ' Open the file.
		  Dim theByte As Roo.Objects.NumberObject
		  Try
		    Parent.Bin = BinaryStream.Open(Parent.File)
		    Parent.Closed = False
		    Do
		      theByte = New NumberObject(Parent.Bin.ReadInt8)
		      ' Inject the byte as the first argument to `func`.
		      funcArgs.Insert(0, theByte)
		      ' Call the function for this byte.
		      call func.Invoke(interpreter, funcArgs, where)
		      ' Remove the byte from the argument list prior to the next iteration.
		      funcArgs.Remove(0)
		    Loop Until Parent.Bin.EOF
		    Parent.Bin.Close
		    Parent.Closed = True
		  Catch err As IOException
		    Raise New RuntimeError(where, "Unable to open the File object's BinaryStream.")
		  End Try
		  
		  ' Return the current position in the stream.
		  Return New NumberObject(Parent.Bin.Position)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEachChar(args() As Variant, where As Roo.Token, interpreter As Interpreter) As Roo.Objects.NumberObject
		  ' File.each_char(func as Invokable, optional arguments as Array) as Array
		  ' Invokes the passed function for each character within this file, passing to the function the 
		  ' character as an integer as the first argument.
		  ' The file must be encoded as UTF-8 or else bad things will happen!
		  ' Optionally the method can take a second argument in the form of an Array. The elements of this
		  ' Array will be passed to the function as additional arguments.
		  ' Returns the current position in the stream.
		  ' E.g: 
		  
		  ' function listChar(char) {
		  '   print(char);
		  ' }
		  
		  ' function prefixChar(char, what) {
		  '   print(what + char);
		  ' }
		  
		  ' Assume file contents are:
		  ' Iron Man
		  ' Hulk
		  ' Thor
		  
		  ' var f = File("Users/garry/Desktop/test.txt");
		  ' f.each_line(listChar)
		  ' # Prints:
		  ' I
		  ' r
		  ' o   etc
		  
		  ' f.each_line(prefixChar, ["Char: "]
		  ' # Prints:
		  ' Char: I
		  ' Char: r
		  ' Char: o   etc
		  
		  Dim funcArgs() As Variant
		  Dim func As Invokable
		  
		  ' Check that `func` is invokable.
		  If Not args(0) IsA Invokable Then
		    Raise New RuntimeError(where, "The " + Self.Name + "(func, args?) method expects a function as the " +_
		    "first parameter. Instead got " + VariantType(args(0)) + ".")
		  Else
		    func = args(0)
		  End If
		  
		  ' If a second argument has been passed, check that it's an ArrayObject.
		  If args.Ubound = 1 then
		    If Not args(1) IsA ArrayObject Then
		      Raise New RuntimeError(where, "The " + Self.name + "(func, args?) method expects the optional " +_
		      "second parameter to be an array. Instead got " + VariantType(args(1)) + ".")
		    Else
		      ' Get an array of the additional arguments to pass to the function we will invoke.
		      For Each v As Variant In ArrayObject(args(1)).Elements
		        funcArgs.Append(v)
		      Next v
		    End If
		  End If
		  
		  ' Check that we have the correct number of arguments for `func`.
		  ' +2 as we will pass in each character as the first argument.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) Then
		    Raise New RuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Textable(func).ToText + " function.")
		  End If
		  
		  ' Is the file valid?
		  If Not Parent.ValidFile(False) Then
		    Raise New RuntimeError(where, "The File object's file is not valid.")
		  End If
		  
		  ' Close any open streams.
		  If Parent.Bin <> Nil Then Parent.Bin.Close
		  If Parent.Tin <> Nil Then Parent.Tin.Close
		  Parent.Closed = True
		  
		  ' Open the file.
		  Dim char As Roo.Objects.TextObject
		  Try
		    Parent.Tin = TextInputStream.Open(Parent.File)
		    Parent.Closed = False
		    Do
		      char = New TextObject(Parent.Tin.Read(1, Encodings.UTF8))
		      ' Inject the character as the first argument to `func`.
		      funcArgs.Insert(0, char)
		      ' Call the function for this character.
		      call func.Invoke(interpreter, funcArgs, where)
		      ' Remove the character from the argument list prior to the next iteration.
		      funcArgs.Remove(0)
		    Loop Until Parent.Tin.EOF
		    Parent.Tin.Close
		    Parent.Closed = True
		  Catch err As IOException
		    Raise New RuntimeError(where, "Unable to open the File object's TextInputStream.")
		  End Try
		  
		  ' Return the current position in the stream.
		  Return New NumberObject(Parent.Tin.PositionB)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEachLine(args() As Variant, where As Roo.Token, interpreter As Interpreter) As Roo.Objects.NumberObject
		  ' File.each_line(func as Invokable, optional arguments as Array) as Array
		  ' Invokes the passed function for each line within this file, passing to the function the 
		  ' line as the first argument and the line number (1-based) as the second argument.
		  ' Optionally the method can take a second argument in the form of an Array. The elements of this
		  ' Array will be passed to the function as additional arguments.
		  ' Returns the current position in the stream.
		  ' E.g: 
		  
		  ' function itemise(line, number) {
		  '   print(number + ". " + line);
		  ' }
		  ' 
		  ' function suffix(line, number, what) {
		  '   print(line + what);
		  ' }
		  
		  ' Assume file contents are:
		  ' Iron Man
		  ' Hulk
		  ' Thor
		  
		  ' var f = File("Users/garry/Desktop/test.txt");
		  ' f.each_line(itemise)
		  ' # Prints:
		  ' # 1. Iron Man
		  ' # 2. Hulk
		  ' # 3. Thor
		  
		  ' f.each_line(suffix, ["!"])
		  ' # Prints:
		  ' # Iron Man!
		  ' # Hulk!
		  ' # Thor!
		  
		  Dim funcArgs() As Variant
		  Dim func As Invokable
		  
		  ' Check that `func` is invokable.
		  If Not args(0) IsA Invokable Then
		    Raise New RuntimeError(where, "The " + Self.Name + "(func, args?) method expects a function as the " +_
		    "first parameter. Instead got " + VariantType(args(0)) + ".")
		  Else
		    func = args(0)
		  End If
		  
		  ' If a second argument has been passed, check that it's an ArrayObject.
		  If args.Ubound = 1 then
		    If Not args(1) IsA ArrayObject Then
		      Raise New RuntimeError(where, "The " + Self.name + "(func, args?) method expects the optional " +_
		      "second parameter to be an array. Instead got " + VariantType(args(1)) + ".")
		    Else
		      ' Get an array of the additional arguments to pass to the function we will invoke.
		      For Each v As Variant In ArrayObject(args(1)).Elements
		        funcArgs.Append(v)
		      Next v
		    End If
		  End If
		  
		  ' Check that we have the correct number of arguments for `func`.
		  ' +3 as we will pass in each line and line number as the first two arguments.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 3) Then
		    Raise New RuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Textable(func).ToText + " function.")
		  End If
		  
		  ' Is the file valid?
		  If Not Parent.ValidFile(False) Then
		    Raise New RuntimeError(where, "The File object's file is not valid.")
		  End If
		  
		  ' Close any open streams.
		  If Parent.Bin <> Nil Then Parent.Bin.Close
		  If Parent.Tin <> Nil Then Parent.Tin.Close
		  Parent.Closed = True
		  
		  ' Open the file.
		  Dim lineNumber As Integer = 1
		  Dim line As Roo.Objects.TextObject
		  Try
		    Parent.Tin = TextInputStream.Open(Parent.File)
		    Parent.Closed = False
		    Do
		      line = New TextObject(Parent.Tin.ReadLine)
		      ' Inject the line number as the second argument to `func`.
		      funcArgs.Insert(0, New NumberObject(lineNumber))
		      ' Inject the line contents as the first argument to `func`.
		      funcArgs.Insert(0, line)
		      ' Call the function for this line.
		      call func.Invoke(interpreter, funcArgs, where)
		      ' Remove the line from the argument list prior to the next iteration.
		      funcArgs.Remove(0)
		      ' Remove the line number from the argument list prior to the next iteration.
		      funcArgs.Remove(0)
		      lineNumber = lineNumber + 1
		    Loop Until Parent.Tin.EOF
		    Parent.Tin.Close
		    Parent.Closed = True
		  Catch err As IOException
		    Raise New RuntimeError(where, "Unable to open the File object's TextInputStream.")
		  End Try
		  
		  ' Return the current position in the stream.
		  Return New NumberObject(Parent.Tin.PositionB)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMove(arguments() As Variant, where As Roo.Token, interpreter As Roo.Interpreter) As Variant
		  ' File.move_to(destination, overwrite) as Boolean
		  ' Moves this file/folder to the specified destination.
		  ' `destination` may be either a relative/absolute text path or a File object.
		  ' If `overwrite` is True then we will permit the overwriting of files/folder.
		  ' Returns a Boolean object - True if successful, False if not.
		  ' Essentially an alias to FileUtils.move(Self, destination)
		  
		  ' Check the first argument is either Text or a File object.
		  If Not arguments(0) IsA TextObject And Not arguments(0) IsA FileObject Then
		    Raise New RuntimeError(where, "The File.move_to(destination, overwrite) method expects a " + _
		    "Text or File object parameter for `destination`. Instead got " + VariantType(arguments(0)) + ".")
		  End If
		  
		  ' Inject this File object as the first argument.
		  arguments.Insert(0, Self.Parent)
		  
		  ' Create a new instance of the FileUtils.move method and use that to handle the copy.
		  Dim moveMethod As New Roo.Native.Modules.FileUtilsMove
		  Return moveMethod.Invoke(interpreter, arguments, where)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoRead(arguments() As Variant, where As Roo.Token) As Variant
		  ' File.read(count as Integer) as Text
		  ' Reads the specified number of bytes from the file as Text.
		  ' If `count` is higher than the amount of bytes currently available in the stream then all 
		  ' available bytes will be returned.
		  ' Returns Nothing if the File object's file is invalid.
		  
		  If Not Parent.ValidFile(False) Then Return New NothingObject
		  
		  ' Check that a positive integer argument has been passed.
		  If Not Parent.CheckInteger(arguments(0), True) Then
		    Raise New RuntimeError(where, "The File.read(count) method expects a positive integer for the " + _
		    "`count` parameter. Instead got `" + Textable(arguments(0)).ToText + "`.")
		  End If
		  Dim count As Integer = NumberObject(arguments(0)).value
		  
		  If Parent.Closed Then
		    Try
		      Parent.Bin = BinaryStream.Open(Parent.File)
		      Parent.Closed = False
		    Catch err As IOException
		      Raise New RuntimeError(where, "Unable to open File object BinaryStream.")
		    End Try
		  End If
		  
		  Dim result As String
		  If Parent.Bin = Nil Then
		    Raise New RuntimeError(where, "Internal consistency problem. The File object's BinaryStream is Nil.")
		  End If
		  Try
		    result = Parent.Bin.Read(count)
		    Parent.Pos = Parent.Bin.Position
		  Catch err As IOException
		    Raise New RuntimeError(where, "Unable to read the File object's BinaryStream.")
		  End Try
		  
		  Return New TextObject(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoRespondsTo(arguments() as Variant, where as Token) As BooleanObject
		  ' File.responds_to?(what as Text) as Boolean.
		  
		  ' Make sure a Text argument is passed to the method.
		  if not arguments(0) isA TextObject then
		    raise new RuntimeError(where, "The " + self.name + "(what) method expects an integer parameter. " + _
		    "Instead got " + VariantType(arguments(0)) + ".")
		  end if
		  
		  dim what as String = TextObject(arguments(0)).value
		  
		  if Lookup.FileGetter(what) then
		    return new BooleanObject(True)
		  elseif Lookup.FileMethod(what) then
		    return new BooleanObject(True)
		  else
		    return new BooleanObject(False)
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoWrite(arguments() As Variant, where As Roo.Token, addEOL As Boolean, append As Boolean) As Roo.Objects.NumberObject
		  ' File.write(data as Text) as Integer.
		  ' Writes the passed text data to this File object's file.
		  ' If a Text argument is not passed then Roo will convert the passed argument to its text representation.
		  ' Returns the number of bytes written to disk.
		  ' If `addEOL` is True then we will add the end of line delimiter to the data to write.
		  
		  ' Check the file is valid.
		  If Parent.File = Nil Or Not Parent.File.IsWriteable Then Return New NumberObject(0)
		  
		  ' Get the data to write.
		  Dim data As String
		  If arguments(0) IsA TextObject Then
		    data = TextObject(arguments(0)).value
		  ElseIf arguments(0) IsA Textable Then
		    data = Textable(arguments(0)).ToText
		  Else
		    Raise New RuntimeError(where, "Unable to write the data to disk as it has no text representation.")
		  End If
		  
		  ' Add EOL?
		  data = IF(addEOL, data + EndOfLine, data)
		  
		  ' Do we need to create a new BinaryStream? Yes if the file needs creating or we are NOT appending.
		  If Not Parent.File.Exists Or Not (append And Parent.Closed)Then
		    ' Create a new BinaryStream.
		    Try
		      Parent.Bin = BinaryStream.Create(Parent.File, True) ' True = overwrite.
		      Parent.Closed = False
		    Catch err As IOException
		      Raise New RuntimeError(where, "Unable to create a new BinaryStream.")
		    End Try
		  ElseIf append Then
		    ' Open a BinaryStream for this existing file.
		    Try
		      Parent.Bin = BinaryStream.Open(Parent.File, True) ' True = overwrite.
		      Parent.Closed = False
		    Catch err As IOException
		      Raise New RuntimeError(where, "Unable to create a new BinaryStream.")
		    End Try
		  End If
		  
		  Dim startPos, bytesWritten As Integer
		  If Parent.Bin = Nil Then
		    Raise New RuntimeError(where, "Internal consistency error. The File object's BinaryStream is Nil.")
		  End If
		  If append Then Parent.Bin.Position = Parent.Bin.Length
		  startPos = Parent.Bin.Position
		  Try
		    Parent.Bin.Write(data)
		    bytesWritten = Parent.Bin.Position - startPos
		  Catch err As IOException
		    Raise New RuntimeError(where, "Unable to write data to the File object's BinaryStream.")
		  End Try
		  
		  ' Return the number of bytes written.
		  Return New NumberObject(bytesWritten)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As Interpreter, arguments() As Variant, where As Roo.Token) As Variant
		  #Pragma Unused interpreter
		  
		  Select Case Self.Name
		  Case "append"
		    Return DoWrite(arguments, where, False, True)
		  Case "append_line"
		    Return DoWrite(arguments, where, True, True)
		  Case "copy_to"
		    Return DoCopy(arguments, where, interpreter)
		  Case "each_byte"
		    Return DoEachByte(arguments, where, interpreter)
		  Case "each_char"
		    Return DoEachChar(arguments, where, interpreter)
		  Case "each_line"
		    Return DoEachLine(arguments, where, interpreter)
		  Case "move_to"
		    Return DoMove(arguments, where, interpreter)
		  Case "read"
		    Return DoRead(arguments, where)
		  Case "responds_to?"
		    Return DoRespondsTo(arguments, where)
		  Case "write"
		    Return DoWrite(arguments, where, False, False)
		  Case "write_line"
		    Return DoWrite(arguments, where, True, False)
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Part of the Textable interface.
		  
		  return "<function " + self.name + ">"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Parent As Roo.Objects.FileObject
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
