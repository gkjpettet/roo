#tag Class
Protected Class RooSLFileSystemItemMethod
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // Return the arity of this method. This is stored in the cached 
		  // FileSystemItemMethods dictionary.
		  
		  Return RooSLCache.FileSystemItemMethods.Value(Name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(owner As RooSLFileSystemItem, name As String)
		  Self.Owner = owner
		  Self.Name = name
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Copy(args() As Variant, where As RooToken, interpreter As RooInterpreter) As RooBoolean
		  // FileSystem.Item.copy_to(destination, overwrite) as Boolean
		  // Copies this file/folder to the specified destination.
		  // `destination` may be either a relative/absolute text path or a 
		  // FileSystem.Item object.
		  // If `overwrite` is True then we will permit the overwriting of files/folder.
		  // Returns a Boolean object - True if successful, False if not.
		  // Essentially an alias to FileSystem.copy
		  
		  // Inject this File object as the first argument.
		  args.Insert(0, Owner)
		  
		  // Get a reference to the FileSystem.copy method for this interpreter.
		  Dim name As New RooToken
		  name.Lexeme = "copy"
		  Dim copyMethod As Invokable = Owner.Owner.MethodWithName(name)
		  
		  // Invoke the FileSystem.copy method with the altered arguments.
		  Return copyMethod.Invoke(interpreter, args, where)
		  
		  Exception err
		    Raise New RooRuntimeError(where, "Internal error occurred in RooSLFileSystemItemMethod.Copy")
		    
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EachChar(args() As Variant, where As RooToken, interpreter As RooInterpreter) As RooNumber
		  // FileSystem.Item.each_char(func as Invokable, optional arguments as Array) as Number
		  // Invokes the passed function for each character within this file, passing to the function the 
		  // character as the first argument.
		  // The file must be encoded as UTF-8 or else bad things will probably happen.
		  // Optionally the method can take a second argument in the form of an Array. The elements of this
		  // Array will be passed to the function as additional arguments.
		  // Returns the number of characters invoked.
		  
		  // E.g: 
		  
		  ' def listChar(char):
		  '   print(char)
		  
		  ' def prefixChar(char, what):
		  '   print(what + char)
		  
		  ' Assume test.txt file contents is:
		  ' Iron Man
		  ' Hulk
		  ' Thor
		  
		  ' var f = FileSystem.Item("/Users/garry/Desktop/test.txt")
		  ' f.each_char(listChar)
		  ' # Prints:
		  ' I
		  ' r
		  ' o   etc
		  
		  ' f.each_char(prefixChar, ["Char: "])
		  ' # Prints:
		  ' Char: I
		  ' Char: r
		  ' Char: o   etc
		  
		  Dim funcArgs() As Variant
		  Dim func As Invokable
		  
		  // Check that `func` is invokable.
		  Roo.AssertIsInvokable(where, args(0))
		  func = args(0)
		  
		  // If a second argument has been passed, check that it's an Array object.
		  If args.Ubound = 1 Then
		    Roo.AssertIsArray(where, args(1))
		    // Get an array of the additional arguments to pass to the function that we will invoke.
		    Dim limit As Integer = RooArray(args(1)).Elements.Ubound
		    For i As Integer = 0 To limit
		      funcArgs.Append(RooArray(args(1)).Elements(i))
		    Next i
		  End If
		  
		  // Check that we have the correct number of arguments for `func`.
		  // NB: +2 as we will pass in each character as the first argument.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) Then
		    Raise New RooRuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Stringable(func).StringValue + " function.")
		  End If
		  
		  // Is the file valid?
		  If Not Owner.ValidFile(False) Then
		    Raise New RooRuntimeError(where, "The FileSystem.Item object's file is not valid.")
		  ElseIf Owner.File.Directory Then
		    Raise New RooRuntimeError(where, "The FileSystem.Item object is a folder, not a file.")
		  End If
		  
		  // Open the file.
		  Dim char As RooText
		  Dim tin As TextInputStream
		  Dim charCount As Integer = 0
		  
		  tin = TextInputStream.Open(Owner.File)
		  Do
		    char = New RooText(tin.Read(1, Encodings.UTF8))
		    charCount = charCount + 1
		    // Inject the character as the first argument to `func`.
		    funcArgs.Insert(0, char)
		    // Call the function for this character.
		    Call func.Invoke(interpreter, funcArgs, where)
		    // Remove the character from the argument list prior to the next iteration.
		    funcArgs.Remove(0)
		  Loop Until tin.EOF
		  tin.Close
		  
		  // Return the number of characters.
		  Return New RooNumber(charCount)
		  
		  Exception err As IOException
		    Raise New RooRuntimeError(where, "Unable to open or read the FileSystem.Item object's TextInputStream.")
		    
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EachLine(args() As Variant, where As RooToken, interpreter As RooInterpreter) As RooNumber
		  // FileSystem.Item.each_line(func as Invokable, optional arguments as Array) as Number
		  // Invokes the passed function for each line within this file, passing to the function the 
		  // line as the first argument and the line number (zero-based) as the second argument.
		  // Optionally the method can take a second argument in the form of an Array. The elements of this
		  // Array will be passed to the function as additional arguments.
		  // Returns the number of lines invoked.
		  
		  // E.g: 
		  
		  ' def itemise(line, number):
		  '   print(number + ". " + line)
		  
		  ' def suffix(line, number, what):
		  '   print(line + what)
		  
		  ' Assume test.txt file contents are:
		  ' Iron Man
		  ' Hulk
		  ' Thor
		  
		  ' var f = FileSystem.Item("/Users/garry/Desktop/test.txt")
		  ' f.each_line(itemise)
		  ' # Prints:
		  ' # 0. Iron Man
		  ' # 2. Hulk
		  ' # 3. Thor
		  
		  ' f.each_line(suffix, ["!"])
		  ' # Prints:
		  ' # Iron Man!
		  ' # Hulk!
		  ' # Thor!
		  
		  Dim funcArgs() As Variant
		  Dim func As Invokable
		  
		  // Check that `func` is invokable.
		  Roo.AssertIsInvokable(where, args(0))
		  func = args(0)
		  
		  
		  // If a second argument has been passed, check that it's an Array object.
		  If args.Ubound = 1 Then
		    Roo.AssertIsArray(where, args(1))
		    // Get an array of the additional arguments to pass to the function we will invoke.
		    Dim limit As Integer = RooArray(args(1)).Elements.Ubound
		    For i As Integer = 0 To limit
		      funcArgs.Append(RooArray(args(1)).Elements(i))
		    Next i
		  End If
		  
		  // Check that we have the correct number of arguments for `func`.
		  // NB: +3 as we will pass in each line and line number as the first two arguments.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 3) Then
		    Raise New RooRuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Stringable(func).StringValue + " function.")
		  End If
		  
		  // Is the file valid?
		  If Not Owner.ValidFile(False) Then
		    Raise New RooRuntimeError(where, "The FileSystem.Item object's file is not valid.")
		  ElseIf Owner.File.Directory Then
		    Raise New RooRuntimeError(where, "The FileSystem.Item object is a folder, not a file.")
		  End If
		  
		  // Open the file.
		  Dim tin As TextInputStream
		  Dim lineNumber As Integer = -1
		  Dim line As RooText
		  
		  tin = TextInputStream.Open(Owner.File)
		  Do
		    lineNumber = lineNumber + 1
		    line = New RooText(tin.ReadLine(Encodings.UTF8))
		    // Inject the line number as the second argument to `func`.
		    funcArgs.Insert(0, New RooNumber(lineNumber))
		    // Inject the line contents as the first argument to `func`.
		    funcArgs.Insert(0, line)
		    // Call the function for this line.
		    Call func.Invoke(interpreter, funcArgs, where)
		    // Remove the line from the argument list prior to the next iteration.
		    funcArgs.Remove(0)
		    // Remove the line number from the argument list prior to the next iteration.
		    funcArgs.Remove(0)
		  Loop Until tin.EOF
		  tin.Close
		  
		  // Return the number of lines invoked.
		  Return New RooNumber(lineNumber + 1)
		  
		  Exception err
		    Raise New RooRuntimeError(where, "Unable to open the FileSystem.Item object's TextInputStream.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  Select Case Name
		  Case "append"
		    Return Write(arguments, where, False, True)
		  Case "append_line"
		    Return Write(arguments, where, True, True)
		  Case "copy_to"
		    Return Copy(arguments, where, interpreter)
		  Case "each_char"
		    Return EachChar(arguments, where, interpreter)
		  Case "each_line"
		    Return EachLine(arguments, where, interpreter)
		  Case "move_to"
		    Return Move(arguments, where, interpreter)
		  Case "write"
		    Return Write(arguments, where, False, False)
		  Case "write_line"
		    Return Write(arguments, where, True, False)
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Move(args() As Variant, where As RooToken, interpreter As RooInterpreter) As RooBoolean
		  // FileSystem.Item.move_to(destination, overwrite) as Boolean
		  // Moves this file/folder to the specified destination.
		  // `destination` may be either a relative/absolute text path or a 
		  // FileSystem.Item object.
		  // If `overwrite` is True then we will permit the overwriting of files/folder.
		  // Returns a Boolean object - True if successful, False if not.
		  // Essentially an alias to FileSystem.move
		  
		  // Inject this File object as the first argument.
		  args.Insert(0, Owner)
		  
		  // Get a reference to the FileSystem.move method for this interpreter.
		  Dim name As New RooToken
		  name.Lexeme = "move"
		  Dim moveMethod As Invokable = Owner.Owner.MethodWithName(name)
		  
		  // Invoke the FileSystem.move method with the altered arguments.
		  Return moveMethod.Invoke(interpreter, args, where)
		  
		  Exception err
		    Raise New RooRuntimeError(where, "Internal error occurred in RooSLFileSystemItemMethod.Move")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<function " + Name + ">"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Write(args() As Variant, where As RooToken, addEOL As Boolean, append As Boolean) As Variant
		  // FileSystem.Item.write(data as Text) as Integer
		  // or:
		  // FileSystem.Item.append(data as Text) as Integer
		  // Writes (or appends) the passed text to this FileSystem.Item object's file.
		  // If a Text argument is not passed then Roo will convert the passed argument to its text representation.
		  // Returns the number of bytes written to disk.
		  ' If `addEOL` is True then we will add the end of line delimiter to the data to write.
		  // If the method fails for any reason then 0 is returned.
		  
		  // Check the file is valid.
		  If Not Owner.ValidFile(True) Then Return New RooNumber(0)
		  If Owner.File.Directory Then Return New RooNumber(0)
		  
		  // Get the data to write.
		  Roo.AssertIsStringable(where, args(0))
		  Dim data As String = Stringable(args(0)).StringValue
		  
		  // Add an EOL to the end of the data?
		  data = If(addEOL, data + EndOfLine, data)
		  
		  // Create a TextOutputStream.
		  Dim tout As TextOutputStream
		  
		  // Set the TextOutputStream to either append or create as needed.
		  If append Then
		    tout = TextOutputStream.Append(Owner.File)
		  Else
		    tout = TextOutputStream.Create(Owner.File)
		  End If
		  
		  // Write the data.
		  tout.Write(data)
		  tout.Close
		  
		  // Return the number of bytes written.
		  Return New RooNumber(data.LenB)
		  
		  // Any error is handled by returning zero bytes written.
		  Exception err
		    Return New RooNumber(0)
		    
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		#tag Note
			The name of this Text object method.
		#tag EndNote
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The RooSLFileSystemItem object that owns this method.
		#tag EndNote
		Owner As RooSLFileSystemItem
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
