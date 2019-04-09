#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  // Setup the app.
		  Initialise
		  
		  // Parse any command line arguments.
		  ParseOptions(args)
		  
		  // Does the user want to display help?
		  If Options.HelpRequested Then
		    Usage
		    Return 0
		  End If
		  
		  // Does the user want the version number?
		  If Options.BooleanValue("version") Then
		    PrintVersion
		    Return 0
		  End If
		  
		  // Should we allow network access?
		  DisableNetworking = Options.BooleanValue("network", False)
		  
		  // REPL or script execution?
		  If Options.Extra.Ubound < 0 Then
		    // REPL
		    Welcome
		    Prompt
		  ElseIf Options.Extra.Ubound = 0 Then
		    // Script execution.
		    ExecuteFile(Options.Extra(0))
		  Else
		    Usage
		  End If
		End Function
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function AllowNetworkAccessDelegate(sender As RooInterpreter, url As String) As Boolean
		  #Pragma Unused sender
		  #Pragma Unused url
		  
		  // The `n` and `network` command line flags determine if script networking 
		  // should be enabled or not.
		  // Return True to permit the interpreter to access the network, False to 
		  // deny it.
		  Return Not DisableNetworking
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DeletionPrevented(sender As RooInterpreter, f As FolderItem, where As RooToken)
		  // The interpreter has prevented the deletion of a file or folder.
		  
		  Using Rainbow
		  
		  #Pragma Unused sender
		  
		  Const QUOTE = """"
		  
		  Dim scriptName As String = If(where.File = Nil, "", where.File.NativePath)
		  Dim itemName As String = If(f = Nil, "", f.NativePath)
		  
		  Dim message As String = "An attempt to delete the FolderItem " + _
		  QUOTE + itemName + QUOTE + _
		  " from the script " + QUOTE + scriptName + QUOTE + _
		  " was prevented by the interpreter." + EndOfLine
		  
		  Print Colourise(message, Colour.Red)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ErrorOccurred(sender As RooInterpreter, type As RooInterpreter.ErrorType, where As RooToken, message As String)
		  #Pragma Unused sender
		  
		  Using Rainbow
		  
		  // What kind of error occurred?
		  Select Case type
		  Case RooInterpreter.ErrorType.Analyser
		    Print Colourise("Static analysis error (line " + Str(where.Line) + ", pos " + _
		    Str(where.Start) + ").", Colour.Red)
		    Print "Token: " + where.Lexeme
		    
		  Case RooInterpreter.ErrorType.Parser
		    Print Colourise("Parser error (line " + Str(where.Line) + ", pos " + Str(where.Start) + ").", Colour.Red)
		    Print "Token: " + where.Lexeme
		    
		  Case RooInterpreter.ErrorType.Runtime
		    Print Colourise("Runtime error (line " + Str(where.Line) + ", pos " + _
		    Str(where.Start) + ").", Colour.Red)
		    Print "Token: " + where.Lexeme
		    
		  Case RooInterpreter.ErrorType.Scanner
		    Print Colourise("Scanner error.", Colour.Red)
		    If where.File <> Nil Then Print("File: " + where.File.NativePath)
		    Print("Location: line " + Str(where.Line) + ", position " + Str(where.Start))
		    
		  End Select
		  
		  // Print the actual error message.
		  Print(message)
		  
		  Quit(0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ExecuteFile(filePath As String)
		  // Execute the contents of the passed file.
		  
		  Using Rainbow
		  
		  Dim sourcefile As FolderItem
		  
		  Try
		    sourceFile = New FolderItem(filePath, FolderItem.PathTypeNative)
		    If sourcefile = Nil Or Not sourcefile.Exists Then
		      Print Colourise("File does not exist: '" + filePath + "'.", Colour.Red)
		      Quit(-1)
		    End if
		  Catch
		    Print Colourise("File does not exist: '" + filePath + "'.", Colour.Red)
		    Quit(-1)
		  End Try
		  
		  // Is the file readable?
		  If Not sourcefile.IsReadable Then
		    Print Colourise("Unable to open file `" + sourcefile.NativePath + "` for reading.", Colour.Red)
		    Quit(-1)
		  End If
		  
		  // Run the file.
		  Interpreter.Interpret(sourceFile)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Initialise()
		  // Create and configure an interpreter.
		  Interpreter = New RooInterpreter
		  AddHandler Interpreter.ErrorOccurred, AddressOf Self.ErrorOccurred
		  AddHandler Interpreter.Print, AddressOf Self.PrintDelegate
		  AddHandler Interpreter.Input, AddressOf Self.InputDelegate
		  AddHandler Interpreter.AllowNetworkAccess, AddressOf AllowNetworkAccessDelegate
		  AddHandler Interpreter.DeletionPrevented, AddressOf Self.DeletionPrevented
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function InputDelegate(sender As RooInterpreter, prompt As String) As String
		  // The interpreter's native input() function has been called.
		  
		  #Pragma Unused sender
		  
		  // Display a prompt if needed.
		  If prompt <> "" Then Print(prompt)
		  
		  // Prompt the user for some input.
		  Dim userInput As String = DefineEncoding(REALbasic.Input, Encodings.UTF8)
		  
		  // Return the entered input to the sender.
		  Return userInput
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ParseOptions(args() As String)
		  Options = New OptionParser(kAppName, kAppDescription)
		  
		  Options.AddOption New Option("v", "version", "Get the version number of the Roo interpreter", Option.OptionType.Boolean)
		  Options.AddOption New Option("n", "network", "Disable network access", Option.OptionType.Boolean)
		  
		  Try
		    Options.Parse(args)
		  Catch OptionMissingKeyException
		    Print "Invalid usage"
		    Print ""
		    
		    Options.ShowHelp
		    
		    Quit 1
		  End Try
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PrintDelegate(sender As RooInterpreter, what As String)
		  // The interpreter's native print() function has been called.
		  
		  #Pragma Unused sender
		  
		  REALbasic.Print(what)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PrintVersion()
		  Print RooVersion + " (" + App.BuildDate.AbbreviatedDate + _
		  ", revision " + Str(App.kRunCount) + ")"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Prompt()
		  // Interactive (REPL) mode.
		  
		  Interpreter.Reset
		  Interpreter.REPL = True
		  
		  Do
		    Stdout.Write(">>> ")
		    REPLInput = Input.DefineEncoding(Encodings.UTF8).Trim
		    Interpreter.Interpret(REPLInput, True) // Tell the interpreter to preserve state.
		  Loop
		  
		  Exception err As RooQuit
		    // The user wants to quit the REPL mode.
		    Quit(0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RooVersion() As String
		  // Returns the current version of the Roo interpreter as a String.
		  
		  Return Str(Roo.kVersionMajor) + "." + Str(Roo.kVersionMinor) + "." + Str(Roo.kVersionBug)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Usage()
		  // Prints the usage of the interpreter to the terminal.
		  
		  Using Rainbow
		  
		  Dim TAB As String = Chr(9)
		  
		  Welcome
		  
		  Print Colourise("Usage: roo [option]", Colour.Yellow)
		  Print "roo <file>" + TAB + ": Run a script"
		  Print "roo -h" + TAB + TAB + ": Display help"
		  Print "roo -v" + TAB + TAB + ": Display the interpreter's version number"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Welcome()
		  // Prints the interpreter's welcome message.
		  
		  Print("Roo interpreter (v" + RooVersion + ")")
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private DisableNetworking As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Interpreter As RooInterpreter
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Options As OptionParser
	#tag EndProperty

	#tag Property, Flags = &h21
		Private REPLInput As String
	#tag EndProperty


	#tag Constant, Name = kAppDescription, Type = String, Dynamic = False, Default = \"The Roo programming language", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kAppName, Type = String, Dynamic = False, Default = \"Roo", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kRunCount, Type = String, Dynamic = False, Default = \"74", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
