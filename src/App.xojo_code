#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  using Rainbow
		  
		  ' Register the MBS plugin.
		  if not RegisterPlugins.MBS() then
		    Print Colourise("Unable to register the MBS plugins.", Colour.Red)
		    return -1
		  end if
		  
		  Initialise()
		  
		  if args.Ubound > 1 then
		    
		    Usage()
		    return 0
		    
		  elseif args.Ubound = 1 then
		    
		    select case args(1)
		    case "-h"
		      Usage()
		      return 0
		    case "-v"
		      Print RooVersion()
		    else
		      ' Assume it's a script file to execute.
		      ExecuteFile(args(1))
		    end select
		    
		  else ' REPL.
		    
		    Welcome()
		    Prompt()
		    
		  end if
		End Function
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Execute(source as String)
		  ' Parse the source code.
		  dim ast() as Roo.Stmt = parser.Parse(source)
		  if self.parser.hasError then return ' No point continuing if we can't parse the script.
		  
		  ' Reset the interpreter (only if we're not in a REPL session).
		  if not repl then interpreter.Reset()
		  
		  ' Perform static analysis and symbol resolution on the AST.
		  resolver = new Roo.Resolver(interpreter)
		  resolver.Resolve(ast)
		  if resolver.hasError then return ' Don't run if the resolver failed.
		  
		  ' Run the code.
		  interpreter.Interpret(ast)
		  
		  ' Catch any errors. Remember that scanning and parsing errors will already call this window's
		  ' ScanningError() or ParsingError() methods if they occur.
		  exception err as Roo.ResolverError
		    ResolverError(err)
		  exception err as Roo.RuntimeError
		    RuntimeError(err)
		  exception err as Roo.QuitReturn
		    if repl then
		      raise err
		    else
		      return
		    end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ExecuteFile(filePath as String)
		  ' Execute the contents of the passed file.
		  
		  using Rainbow
		  
		  dim source as Text
		  dim tin as Xojo.IO.TextInputStream
		  dim sourcefile as Xojo.IO.FolderItem
		  
		  try
		    sourceFile = new Xojo.IO.FolderItem(filePath.ToText)
		  catch
		    Print Colourise("File does not exist: '" + filePath + "'.", Colour.Red)
		    return
		  end try
		  
		  ' Get the contents
		  tin = Xojo.IO.TextInputStream.Open(sourceFile, Xojo.Core.TextEncoding.UTF8)
		  source = tin.ReadAll()
		  tin.Close()
		  
		  ' Execute the source
		  Execute(source)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HandleInput(sender as Roo.Interpreter, prompt as String) As String
		  ' The interpreter's native input() function has been called.
		  
		  #pragma Unused sender
		  
		  ' Display a prompt if needed.
		  if prompt <> "" then Print(prompt)
		  
		  ' Prompt the user for some input.
		  dim userInput as String = DefineEncoding(REALbasic.Input(), Encodings.UTF8)
		  
		  ' Return the entered input to the sender.
		  return userInput
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HandlePrint(sender as Roo.Interpreter, what as String)
		  ' The interpreter's native print() function has been called.
		  
		  #pragma Unused sender
		  
		  REALbasic.Print(what)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Initialise()
		  ' Create a new parser.
		  self.parser = new Roo.Parser
		  
		  ' Tell the parser to call the app's ScanningError() method if a scanning error occurs.
		  AddHandler parser.ScanningError, AddressOf self.ScanningError
		  
		  ' Tell the parser to call the app's ParsingError() method if a parsing error occurs.
		  AddHandler parser.ParsingError, AddressOf self.ParsingError
		  
		  ' Create a new interpreter.
		  self.interpreter = new Roo.Interpreter
		  
		  ' Tell the interpreter to call the app's Print() or Input() methods whenever Roo's 
		  ' built-in print() or input() methods are called from a script.
		  AddHandler interpreter.Print, AddressOf self.HandlePrint
		  AddHandler interpreter.Input, AddressOf self.HandleInput
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ParsingError(sender as Roo.Parser, where as Roo.Token, message as String)
		  #pragma Unused sender
		  
		  ' An error has occurred during the parsing process.
		  
		  using Rainbow
		  
		  ' Report that a parsing error has occurred and its location.
		  Print Colourise("Parser error (line " + Str(where.line) + ", pos " + Str(where.start) + ").", Colour.Red)
		  Print "Token: " + where.lexeme
		  
		  ' Print the actual error message.
		  Print(message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Prompt()
		  ' Interactive mode.
		  
		  repl = True
		  self.interpreter.Reset()
		  
		  do
		    
		    Stdout.Write(">>> ")
		    promptInput = Input.DefineEncoding(Encodings.UTF8)
		    Execute(promptInput)
		    
		  loop
		  
		  exception err as Roo.QuitReturn
		    ' The user wants to quit the REPL mode.
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ResolverError(err as Roo.ResolverError)
		  ' An error has occurred during static analysis.
		  
		  using Rainbow
		  
		  ' Report that a resolver error has occurred and its location.
		  Print Colourise("Resolver error (line " + Str(err.token.line) + ", pos " + _
		  Str(err.token.start) + ").", Colour.Red)
		  Print "Token: " + err.token.lexeme
		  
		  ' Print the actual error message.
		  Print(err.message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RooVersion() As String
		  return Str(Roo.VERSION_MAJOR) + "." + Str(Roo.VERSION_MINOR) + "." + Str(Roo.VERSION_BUG)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RuntimeError(err as Roo.RuntimeError)
		  ' An error has occurred during interpretation.
		  
		  using Rainbow
		  
		  ' Report that a runtime error has occurred and its location.
		  Print Colourise("Runtime error (line " + Str(err.token.line) + ", pos " + _
		  Str(err.token.start) + ").", Colour.Red)
		  Print "Token: " + err.token.lexeme
		  
		  ' Print the actual error message.
		  Print(err.message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ScanningError(sender as Roo.Parser, message as String, line as Integer, position as Integer)
		  #pragma Unused sender
		  
		  ' An error has occurred during the scanning process.
		  
		  using Rainbow
		  
		  ' Report that a scanning error has occurred and its location.
		  Print Colourise("Scanner error (line " + Str(line) + ", pos " + Str(position) + ").", Colour.Red)
		  
		  ' Print the actual error message.
		  Print(message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Usage()
		  ' Prints the usage of the interpreter to the terminal.
		  
		  using Rainbow
		  
		  dim TAB as String = Chr(9)
		  
		  Welcome()
		  
		  Print Colourise("Usage: roo [option]", Colour.yellow)
		  Print "roo <file>" + TAB + TAB + ": Run a script"
		  Print "roo -h" + TAB + TAB + ": Display help"
		  Print "roo -v" + TAB + TAB + ": Display the interpreter's version number"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Welcome()
		  ' Prints the interpreter's welcome message.
		  
		  Print("Roo interpreter (v" + RooVersion + ")")
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		interpreter As Roo.Interpreter
	#tag EndProperty

	#tag Property, Flags = &h0
		parser As Roo.Parser
	#tag EndProperty

	#tag Property, Flags = &h0
		promptInput As String
	#tag EndProperty

	#tag Property, Flags = &h0
		repl As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		resolver As Roo.Resolver
	#tag EndProperty


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
