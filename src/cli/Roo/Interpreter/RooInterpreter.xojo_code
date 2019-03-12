#tag Class
Protected Class RooInterpreter
Implements RooExprVisitor, RooStmtVisitor
	#tag Method, Flags = &h21
		Private Sub AnalyserErrorDelegate(sender As RooAnalyser, token As RooToken, message As String)
		  #Pragma Unused sender
		  
		  // An error occurred during the analysis of the parse tree.
		  AnalyserError(token, message)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BothNumbers(obj1 As Variant, obj2 As Variant) As Boolean
		  // Returns True if both objects are RooNumbers, False otherwise.
		  If obj1 IsA RooNumber And obj2 IsA RooNumber Then
		    Return True
		  Else
		    Return False
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BothStringable(obj1 As Variant, obj2 As Variant) As Boolean
		  // Returns True if both objects implement the Stringable interface, False otherwise.
		  If obj1 IsA Stringable And obj2 IsA Stringable Then
		    Return True
		  Else
		    Return False
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(absoluteRoot As FolderItem = Nil)
		  // Create a root environment that will hold native modules. This will enclose the 
		  // Globals environment. Creating the Natives environment in the constructor allows us to 
		  // reset the interpreter and not incur the overhead of redefining native modules and 
		  // functions again.
		  
		  // Determine the root of the volume that the interpreter is running on and 
		  // use this as the root for absolute paths when the interpreter is accessing 
		  // the file system.
		  If absoluteRoot = Nil Or absoluteRoot.Exists = False Then
		    Dim f As FolderItem = App.ExecutableFile.Parent
		    Do
		      If f.Parent = Nil Or Not f.Parent.Exists Then Exit
		      f = f.Parent
		    Loop
		    Self.AbsoluteRoot = f
		  Else
		    Self.AbsoluteRoot = absoluteRoot
		  End If
		  
		  // Setup a new parser.
		  Parser = New RooParser
		  AddHandler Parser.ScanningError, AddressOf ScannerErrorDelegate
		  AddHandler Parser.ParsingError, AddressOf ParserErrorDelegate
		  
		  // Setup a new analyser.
		  Analyser = New RooAnalyser(Self)
		  AddHandler Analyser.Error, AddressOf AnalyserErrorDelegate
		  
		  // Make sure that the Roo module has been initialised.
		  Roo.Initialise
		  
		  // Create a new enclosing environment to hold our native classes, functions and modules.
		  Natives = New RooEnvironment
		  
		  // Default to file system safe mode.
		  mFileSystemSafeMode = True
		  
		  // Add the standard library functions and modules to the runtime.
		  InitialiseStandardLibrary
		  
		  // Reset the interpreter.
		  Reset
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function CorrectArity(invokee As Invokable, argCount As Integer) As Boolean
		  // Checks that the the correct number of arguments for the specified invokable object have been passed
		  // (i.e `argCount` matches the invokable's "arity").
		  // An invokable object's Arity() function returns a Variant which is either an integer or an array 
		  // of integers.
		  // If an integer is returned it means that this invokable object has only one method signature.
		  // If an array of integers is returned then there are multiple signatures which take
		  // differing numbers of arguments.
		  // E.g: The `Text.slice()` method can take one or two arguments. In that case, Arity() will 
		  // return an integer array in the form: arity(0) = 1, arity(1) = 2.
		  
		  Dim arities() As Integer
		  Dim arity As Variant = invokee.Arity
		  
		  If arity.IsArray Then // This invokable object has more than one method signature.
		    arities = arity
		    If arities.IndexOf(argCount) <> -1 Then Return True
		  Else // This invokable object has only one method signature.
		    If argCount = arity.IntegerValue Then Return True
		  End If
		  
		  // Wrong arity.
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DefineNativeFunction(name As String, func As Variant)
		  Natives.Define(name, func)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DefineNativeModule(name as String, m as RooNativeModule)
		  Natives.Define(name, m)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeletionPreventedDelegate(f As FolderItem, where As RooToken)
		  // Provides a hook to fire this interpreter's DeletionPrevented event.
		  DeletionPrevented(f, where)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DidAccessNetwork(url As String, status As Integer)
		  // Called internally when a network access was made and was either successful or 
		  // timed out.
		  // We use this method as a proxy to fire the interpreter's NetworkAccessed event.
		  
		  NetworkAccessed(url, status)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Evaluate(expr As RooExpr) As Variant
		  If expr <> Nil Then
		    Return expr.Accept(Self)
		  Else
		    Return Nil
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Execute(statement As RooStmt)
		  // This method is analogous to Evaluate (which takes an expression).
		  
		  Call statement.Accept(Self)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ExecuteBlock(statements() As RooStmt, env As RooEnvironment)
		  // Execute a block of statements within the passed environment.
		  
		  Dim limit As Integer = statements.Ubound
		  Dim i As Integer
		  
		  // Keep a reference to the current interpreter's environment.
		  Dim previous As RooEnvironment = Environment
		  
		  Try
		    
		    // Switch to the block's environment.
		    Environment = env
		    
		    // Execute the statements in the block.
		    For i = 0 To limit
		      Execute(statements(i))
		    Next i
		    
		  Finally
		    
		    // Always restore the interpreter's environment back to what it was.
		    Environment = previous
		    
		  End Try
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseStandardLibrary()
		  DefineNativeFunction("assert", New RooSLAssert)
		  DefineNativeFunction("DateTime", New RooSLDateTime)
		  DefineNativeFunction("input", New RooSLInput)
		  DefineNativeFunction("input_value", New RooSLInputValue)
		  DefineNativeFunction("print", New RooSLPrint)
		  DefineNativeFunction("Regex", New RooSLRegex)
		  
		  DefineNativeModule("FileSystem", New RooSLFileSystem(Self))
		  DefineNativeModule("HTTP", New RooSLHTTP(Self))
		  DefineNativeModule("JSON", New RooSLJSON)
		  DefineNativeModule("Maths", New RooSLMaths)
		  DefineNativeModule("Roo", New RooSLRoo)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function InputHook(prompt As String) As String
		  // This method exists to provide an accessible hook to the interpreter's Input event.
		  
		  Return Input(prompt)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Interpret(f As FolderItem, preserveState As Boolean = False)
		  // Reset the interpreter if required.
		  If Not preserveState Then Reset
		  
		  // flag that we've started.
		  mIsRunning = True
		  
		  // Parse the source file into an abstract syntax tree.
		  Dim ast() As RooStmt = Parser.Parse(f)
		  If Parser.HasError Then
		    mIsRunning = False
		    Return
		  End If
		  
		  // Analyse the tree.
		  Analyser.Analyse(ast)
		  If Analyser.HasError Then
		    mIsRunning = False
		    Return
		  End If
		  
		  // Interpret the AST.
		  Interpret(ast)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Interpret(statements() As RooStmt)
		  // Flag that we've started.
		  mIsRunning = True
		  
		  // Execute each of the passed statements in order.
		  Dim i, limit As Integer
		  limit = statements.Ubound
		  For i = 0 To limit
		    
		    Execute(statements(i))
		    
		    If ForceKill Then
		      mIsRunning = False
		      Return
		    End If
		    
		  Next i
		  
		  // We've finished execution.
		  mIsRunning = False
		  
		  // Catch any runtime errors and fire our custom event.
		  Exception err As RooRuntimeError
		    mIsRunning = False
		    RuntimeError(err.Token, err.Message)
		    Return
		    
		    // Exit gracefully if the `quit` statement is encountered in non-REPL
		    // mode or raise the quit exception further if REPL mode.
		  Exception err As RooQuit
		    mIsRunning = False
		    If REPL Then
		      #Pragma BreakOnExceptions False
		      Raise err
		    Else
		      Return
		    End If
		    
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Interpret(source As String, preserveState As Boolean = False)
		  // Reset the interpreter if required.
		  If Not preserveState Then Reset
		  
		  // Flag that we've started.
		  mIsRunning = True
		  
		  // Parse the source code into an abstract syntax tree.
		  Dim ast() As RooStmt = Parser.Parse(source)
		  If Parser.HasError Then
		    mIsRunning = False
		    Return
		  End If
		  
		  // Analyse the tree.
		  Analyser.Analyse(ast)
		  If Analyser.HasError Then
		    mIsRunning = False
		    Return
		  End If
		  
		  // Interpret the AST.
		  Interpret(ast)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsEqual(a As Variant, b As Variant) As Boolean
		  // Returns True if objects `a` and `b` are considered by Roo to be equal. False if not.
		  // Built in data types (text, booleans, numbers and dates) are always compared by value.
		  // Instances are always compared by reference.
		  
		  // Are they the same object in memory?
		  If a = b Then Return True
		  
		  // Objects compared by value.
		  // Text objects. We do a CASE-SENSITIVE comparison.
		  If a IsA RooText And b IsA RooText then
		    Return If(StrComp(RooText(a).Value, RooText(b).Value, 0) = 0, True, False)
		  End If
		  
		  // Boolean objects.
		  If a IsA RooBoolean And b IsA RooBoolean Then
		    Return RooBoolean(a).Value = RooBoolean(b).Value
		  End If
		  
		  // Number objects.
		  If BothNumbers(a, b) Then Return RooNumber(a).Value = RooNumber(b).Value
		  
		  If a IsA RooDateTime And b IsA RooDateTime Then
		    Return RooDateTime(a).Value.SecondsFrom1970 = RooDateTime(b).Value.SecondsFrom1970
		  End If
		  
		  // Nothing always equals nothing.
		  If a IsA RooNothing And b IsA RooNothing Then Return True
		  
		  // Not equal.
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsTruthy(what As Variant) As Boolean
		  // In Roo, Nothing and False are False, everything else is True.
		  
		  If what = Nil Or what IsA RooNothing Then Return False
		  If what IsA RooBoolean Then Return RooBoolean(what).Value
		  
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LookupVariable(name As RooToken, expr As RooExpr) As Variant
		  // Returns the requested variable by finding it in the correct scope.
		  
		  // Look up the resolved distance (calculated by the Analyser).
		  Dim distance As Integer = Locals.Lookup(expr, -1)
		  
		  If distance = -1 Then
		    // Global variable.
		    Return Globals.Get(name)
		  Else
		    // Locally scoped variable.
		    Return Environment.GetAt(distance, name.Lexeme)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ParserErrorDelegate(sender As RooParser, where As RooToken, message As String)
		  #Pragma Unused sender
		  
		  // An error occurred whilst parsing the source code.
		  ParserError(where, message)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PrintHook(s As String)
		  // This method exists to provide an accessible hook to the interpreter's Print event.
		  
		  Print(s)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Reset()
		  // Reset the interpreter.
		  // Do not flush out the Natives environment. There's no need as they are read-only and we don't
		  // want to have to re-add the entire standard library every time we reset the interpreter.
		  
		  ForceKill = False
		  mIsRunning = False
		  Globals = New RooEnvironment(Natives) // Note that global classes, functions, etc will shadow Natives.
		  Environment = globals
		  Locals = New Dictionary // Stores resolution information from the Analyser.
		  Nothing = New RooNothing // The global Nothing object.
		  Custom = New Dictionary
		  REPL = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Resolve(expr As RooExpr, depth As Integer)
		  Locals.Value(expr) = depth
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RooPathToFolderItem(path As String, baseFile As FolderItem) As FolderItem
		  // Takes a Roo file path and returns it as a FolderItem or Nil if it's not possible 
		  // to derive one.
		  // File paths in Roo are separated by forward slashes.
		  // `../` moves up the hierarchy to the parent.
		  // If a path starts with a `/` it is absolute, otherwise it is taken to be 
		  // relative to `baseFile`.
		  
		  // An empty path refers to the base file.
		  If path = "" Then Return baseFile
		  
		  // Is this an absolute path? If so it will begin with `/`.
		  Dim absolute As Boolean = False
		  If path.Left(1) = "/" Then
		    absolute = True
		    path = path.Right(path.Len - 1)
		  End If
		  
		  // Split the path into it's constituent parts.
		  Dim chars() As String = path.Split("")
		  Dim char, part, parts() As String
		  For Each char In chars
		    If char = "/" Then
		      parts.Append(part)
		      part = ""
		    Else
		      part = part + char
		    End if
		  Next char
		  If char <> "/" Then parts.Append(part)
		  
		  Dim result As FolderItem
		  
		  // Handle absolute paths.
		  If absolute Then
		    result = New FolderItem(AbsoluteRoot.NativePath, FolderItem.PathTypeNative)
		    For Each part In parts
		      If part = ".." Then
		        result = result.Parent
		      Else
		        result = result.Child(part)
		      End If
		    Next part
		    Return result
		  End If
		  
		  // Handle relative paths.
		  If baseFile = Nil Then
		    result = AbsoluteRoot
		  ElseIf Not baseFile.Directory Then // Use this file's parent folder as our starting point.
		    result = New FolderItem(baseFile.Parent.NativePath, FolderItem.PathTypeNative)
		  Else
		    result = New FolderItem(baseFile.NativePath, FolderItem.PathTypeNative)
		  End If
		  For Each part In parts
		    If part = ".." Then
		      result = result.Parent
		    Else
		      result = result.Child(part)
		    End If
		  Next part
		  
		  Return result
		  
		  Exception err
		    Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ScannerErrorDelegate(sender As RooParser, file As FolderItem, message As String, line As Integer, position As Integer)
		  #Pragma Unused sender
		  
		  // An error occurred during source code scanning.
		  ScannerError(file, message, line, position)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ShouldAllowNetworkAccess(url As String) As Boolean
		  // Internal method. 
		  // Called by the HTTP module to determine whether or not to allow access to the 
		  // network using the specified URL.
		  // It fires the interpreter's AllowNetworkAccess() event. If this event returns 
		  // False then we need to prevent the interpreter from accessing the network by 
		  // returning False from this method. If it returns True then we return True 
		  // from this method.
		  // We do it this way so that if the AllowNetworkAccess() event is not handled by a 
		  // Xojo developer, the interpreter will default to disallowing network access.
		  
		  Return AllowNetworkAccess(url)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function VariantAsString(v As Variant) As String
		  // A more robust and Roo-friendly implementation of Variant.StringValue().
		  
		  If v = Nil Then Return "Nil"
		  If v IsA RooBoolean Then Return "Boolean object"
		  If v IsA RooNumber Then Return "Number object"
		  If v IsA RooText Then Return "Text object"
		  If v IsA RooNothing Then Return "Nothing"
		  If v IsA RooClass Then Return RooClass(v).Name + " class"
		  If v IsA RooFunction Or v IsA RooInstance Then Return Stringable(v).StringValue
		  
		  Dim info As Xojo.Introspection.TypeInfo = Xojo.Introspection.GetType(v)
		  Return info.Name
		  
		  Exception err
		    Return "Cannot determine type."
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitArrayAssignExpr(expr As RooArrayAssignExpr) As Variant
		  // The user wants to assign a value to an element in an array.
		  // The array's identifer is expr.Name
		  // The index of the element to assign to is the expr.Index expression (to be evaluated).
		  // The value to assign to the specified element is expr.Value
		  // compound assignment is permitted (+=, -=, /=, *=, %=) as well as simple assignment (=).
		  
		  Dim current, newValue, assigneeVariant As Variant
		  Dim index As Integer
		  Dim assignee As RooArray
		  
		  // Get the array we are assigning to.
		  Dim distance As Integer = Locals.Lookup(expr, -1)
		  If distance = -1 Then // Global variable.
		    assigneeVariant = Globals.Get(expr.Name)
		  Else // Locally scoped variable.
		    assigneeVariant = environment.GetAt(distance, expr.Name.Lexeme)
		  End If
		  If assigneeVariant = Nil Then
		    Raise New RooRuntimeError(expr.Name, "Error retrieving variable `" + expr.Name.Lexeme + "`.")
		  ElseIf assigneeVariant IsA RooNothing Then
		    // Non-initialised variable. Initialise it as an empty array object.
		    assigneeVariant = New RooArray
		  End If
		  
		  // Evaluate the right hand side of the assignment.
		  newValue = Evaluate(expr.Value)
		  
		  // Help the Xojo compiler by telling it that we're working with a RooArray, not a Variant.
		  assignee = RooArray(assigneeVariant)
		  
		  Try
		    index = RooNumber(Evaluate(expr.Index)).Value
		  Catch err
		    Raise New RooRuntimeError(expr.Name, _
		    "Expected an integer index value for the element to assign to.")
		  End Try
		  
		  // Is there an element at this index?
		  If index < 0 Then
		    Raise New RooRuntimeError(expr.Name, "Expected an integer index >= 0.")
		  ElseIf index <= assignee.Elements.Ubound Then
		    current = assignee.Elements(index)
		  Else
		    current = Nil
		  End If
		  
		  // Prohibit the compound assignment operators with non-existent elements.
		  If (current = Nil Or current IsA RooNothing) And expr.Operator.Type <> Roo.TokenType.EQUAL Then
		    Raise New RooRuntimeError(expr.Name, "Cannot use a compound assigment operator on Nothing.")
		  End If
		  
		  // What type of assignment is this?
		  Select Case expr.Operator.Type
		  Case Roo.TokenType.PLUS_EQUAL
		    If BothNumbers(current, newValue) Then
		      // Arithmetic addition.
		      newValue = New RooNumber(RooNumber(current).Value + RooNumber(newValue).Value)
		    Else // Text concatenation.
		      newValue = New RooText(Stringable(current).StringValue + Stringable(newValue).StringValue)
		    End If
		    
		  Case Roo.TokenType.MINUS_EQUAL // Compound subtraction (-=).
		    Roo.AssertAreNumbers(expr.Operator, current, newValue)
		    newValue = New RooNumber(RooNumber(current).Value - RooNumber(newValue).Value)
		    
		  Case Roo.TokenType.SLASH_EQUAL // Compound division (/=).
		    Roo.AssertAreNumbers(expr.Operator, current, newValue)
		    If RooNumber(newValue).Value = 0 Then Raise New RooRuntimeError(expr.Operator, "Division by zero")
		    newValue = New RooNumber(RooNumber(current).Value / RooNumber(newValue).Value)
		    
		  Case Roo.TokenType.STAR_EQUAL // Compound multiplication (*=).
		    Roo.AssertAreNumbers(expr.Operator, current, newValue)
		    newValue = New RooNumber(RooNumber(current).Value * RooNumber(newValue).Value)
		    
		  Case Roo.TokenType.PERCENT_EQUAL // Compound modulo (%=).
		    Roo.AssertAreNumbers(expr.Operator, current, newValue)
		    If RooNumber(newValue).Value = 0 Then Raise New RooRuntimeError(expr.Operator, "Modulo with zero")
		    newValue = New RooNumber(RooNumber(current).Value Mod RooNumber(newValue).Value)
		  End Select
		  
		  // Assign the new value to the correct element.
		  If index > assignee.Elements.Ubound Then
		    // Increase the size of this array to accomodate this new element, filling the 
		    // preceding elements with Nothing.
		    Dim numNothings As Integer = index - assignee.Elements.Ubound
		    For i As Integer = 1 To numNothings
		      assignee.Elements.Append(Nothing)
		    Next i
		  End If
		  assignee.Elements(index) = newValue
		  
		  // Assign the newly updated array to the correct environment.
		  If distance = -1 Then // Global variable.
		    Globals.Assign(expr.Name, assignee)
		  Else // Locally scoped variable.
		    Environment.AssignAt(distance, expr.Name, assignee)
		  End If
		  
		  // Return the value we assigned to the element to allow nesting (e.g: `print(a[2] = "hi")`)
		  Return newValue
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitArrayExpr(expr As RooArrayExpr) As Variant
		  // Return the requested element from this array.
		  // The identifier of the array is expr.Name
		  // The index of the element to return is the result of evaluating expr.Index
		  
		  #Pragma BreakOnExceptions False
		  
		  Dim index As RooNumber
		  Dim a As RooArray
		  
		  // Get the requested array.
		  Try
		    a = LookupVariable(expr.Name, expr)
		  Catch
		    Raise New RooRuntimeError(expr.Name, "You are treating `" + expr.Name.Lexeme + _
		    "` like an array but it isn't one.")
		  End Try
		  
		  // Evaluate the index.
		  Try
		    index = Evaluate(expr.Index)
		  Catch err As IllegalCastException
		    Raise New RooRuntimeError(expr.Name, "Integer array index expected")
		  End Try
		  
		  // Ensure that an integer index has been passed.
		  If Not Roo.IsInteger(index.Value) Then
		    Raise New RooRuntimeError(expr.Name, "Array indices must be integers, not fractional numbers.")
		  End If
		  
		  // Return the correct element or Nothing if out of bounds.
		  Try
		    Return a.Elements(index.Value)
		  Catch OutOfBoundsException
		    Return Nothing
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitArrayLiteralExpr(expr As RooArrayLiteralExpr) As Variant
		  // The interpreter is visiting an array literal node. E.g:
		  // [1, 2, "hello"]
		  // a = ["a", True]
		  
		  // Create a new runtime representation for the array.
		  Dim a As New RooArray
		  
		  // Evaluate each of the elements in the array literal.
		  For Each element As RooExpr In expr.Elements
		    a.Elements.Append(Evaluate(element))
		  Next element
		  
		  Return a
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitAssignExpr(expr As RooAssignExpr) As Variant
		  // Examples:
		  // a = 10;
		  // b += "world!"
		  
		  // Retrieve the current value of the variable.
		  Dim current As Variant
		  // How many hops from the current environment is the variable?
		  Dim distance As Integer = Locals.Lookup(expr, -1)
		  If distance = -1 Then
		    // The variable should be in the global scope.
		    current = Globals.Get(expr.Name)
		  Else
		    // It's a local variable.
		    current = Environment.GetAt(distance, expr.Name.Lexeme)
		  end if
		  
		  // Disallow compound assignment operations on array objects (since no index has been provided).
		  // This catches edge cases like:
		  // var a = [2,3]
		  // a += 10
		  If current IsA RooArray And expr.Operator.Type <> Roo.TokenType.EQUAL Then
		    Raise New RooRuntimeError(expr.Name, _
		    "Cannot use a compound assignment operator on an array without providing an index.")
		  End If
		  
		  // Evaluate the new value.
		  Dim newValue As Variant = Evaluate(expr.Value)
		  
		  // Determine the type of assignment.
		  Select Case expr.Operator.Type
		  Case Roo.TokenType.PLUS_EQUAL
		    If BothNumbers(current, newValue) Then
		      // Arithmetic addition.
		      newValue = New RooNumber(RooNumber(current).Value + RooNumber(newValue).Value)
		    ElseIf BothStringable(current, newValue) Then
		      // Text concatenation.
		      newValue = New RooText(Stringable(current).StringValue + Stringable(newValue).StringValue)
		    End If
		  Case Roo.TokenType.MINUS_EQUAL
		    // Compound subtraction (-=).
		    Roo.AssertAreNumbers(expr.Operator, current, newValue)
		    newValue = New RooNumber(RooNumber(current).Value - RooNumber(newValue).Value)
		  Case Roo.TokenType.PERCENT_EQUAL
		    // Compound modulo (%=).
		    Roo.AssertAreNumbers(expr.Operator, current, newValue)
		    If RooNumber(newValue).Value = 0 Then Raise New RooRuntimeError(expr.Operator, "Modulo with zero")
		    newValue = New RooNumber(RooNumber(current).Value Mod RooNumber(newValue).Value)
		  Case Roo.TokenType.SLASH_EQUAL
		    // Compound division (/=).
		    Roo.AssertAreNumbers(expr.Operator, current, newValue)
		    newValue = New RooNumber(RooNumber(current).Value / RooNumber(newValue).Value)
		  Case Roo.TokenType.STAR_EQUAL
		    // Compound multiplication (*=).
		    Roo.AssertAreNumbers(expr.Operator, current, newValue)
		    newValue = New RooNumber(RooNumber(current).Value * RooNumber(newValue).Value)
		  End Select
		  
		  // Assign the new value to the variable.
		  If distance = -1 Then
		    Globals.Assign(expr.Name, newValue)
		  Else
		    Environment.AssignAt(distance, expr.Name, newValue)
		  End If
		  
		  // Return the new value to allow nesting (e.g: `print(a = 2)`)
		  Return newValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBinaryExpr(expr As RooBinaryExpr) As Variant
		  // Evaluate the left and right operands.
		  Dim left As Variant = Evaluate(expr.Left)
		  Dim right As Variant = Evaluate(expr.Right)
		  
		  Select Case expr.Operator.Type
		  Case Roo.TokenType.PLUS
		    If BothNumbers(left, right) Then
		      // Arithmetic addition.
		      Return New RooNumber(RooNumber(left).Value + RooNumber(right).Value)
		    Else
		      // Text concatenation.
		      Return New RooText(Stringable(left).StringValue + Stringable(right).StringValue)
		    End If
		    
		  Case Roo.TokenType.MINUS // Subtraction.
		    Roo.AssertAreNumbers(expr.Operator, left, right)
		    Return New RooNumber(RooNumber(left).Value - RooNumber(right).Value)
		    
		  Case Roo.TokenType.SLASH // Division.
		    Roo.AssertAreNumbers(expr.Operator, left, right)
		    If RooNumber(right).Value = 0 Then Raise New RooRuntimeError(expr.Operator, "Division by zero")
		    Return New RooNumber(RooNumber(left).Value / RooNumber(right).Value)
		    
		  Case Roo.TokenType.STAR // Multiplication.
		    Roo.AssertAreNumbers(expr.Operator, left, right)
		    Return New RooNumber(RooNumber(left).Value * RooNumber(right).Value)
		    
		  Case Roo.TokenType.EQUAL_EQUAL // left == right
		    Return New RooBoolean(IsEqual(left, right))
		    
		  Case Roo.TokenType.NOT_EQUAL // left <> right
		    Return New RooBoolean(Not IsEqual(left, right))
		    
		  Case Roo.TokenType.GREATER // Greater than (left > right).
		    If BothNumbers(left, right) Then
		      Return New RooBoolean(RooNumber(left).Value > RooNumber(right).Value)
		    ElseIf left IsA RooDateTime And right IsA RooDateTime Then
		      Return New RooBoolean(RooDateTime(left).Value.SecondsFrom1970 > _
		      RooDateTime(right).Value.SecondsFrom1970)
		    Else
		      Raise New RooRuntimeError(expr.Operator, _
		      "The `>` operator requires either two numbers or two DateTime objects")
		    End If
		    
		  Case Roo.TokenType.GREATER_EQUAL // Greater than or equal to (left >= right).
		    If BothNumbers(left, right) Then
		      Return New RooBoolean(RooNumber(left).Value >= RooNumber(right).Value)
		    ElseIf left IsA RooDateTime And right IsA RooDateTime Then
		      Return New RooBoolean(RooDateTime(left).Value.SecondsFrom1970 >= _
		      RooDateTime(right).Value.SecondsFrom1970)
		    Else
		      Raise New RooRuntimeError(expr.Operator, _
		      "The `>=` operator requires either two numbers or two DateTime objects")
		    End If
		    
		  Case Roo.TokenType.LESS // Less than (left < right).
		    If BothNumbers(left, right) Then
		      Return New RooBoolean(RooNumber(left).Value < RooNumber(right).Value)
		    ElseIf left IsA RooDateTime And right IsA RooDateTime Then
		      Return New RooBoolean(RooDateTime(left).Value.SecondsFrom1970 < _
		      RooDateTime(right).Value.SecondsFrom1970)
		      Raise New RooRuntimeError(expr.Operator, _
		      "The `<` operator requires either two numbers or two DateTime objects")
		    End If
		    
		  Case Roo.TokenType.LESS_EQUAL // Less than or equal to (left <= right).
		    If BothNumbers(left, right) Then
		      Return New RooBoolean(RooNumber(left).Value <= RooNumber(right).Value)
		    ElseIf left IsA RooDateTime And right IsA RooDateTime Then
		      Return New RooBoolean(RooDateTime(left).Value.SecondsFrom1970 <= _
		      RooDateTime(right).Value.SecondsFrom1970)
		      Raise New RooRuntimeError(expr.Operator, _
		      "The `<=` operator requires either two numbers or two DateTime objects")
		    End If
		    
		  Case Roo.TokenType.CARET // Exponent (left ^ right)
		    Roo.AssertAreNumbers(expr.Operator, left, right)
		    Return New RooNumber(RooNumber(left).Value ^ RooNumber(right).Value)
		    
		  Case Roo.TokenType.PERCENT // Modulo (left % right).
		    Roo.AssertAreNumbers(expr.Operator, left, right)
		    If RooNumber(right).Value = 0 Then Raise New RooRuntimeError(expr.Operator, "Modulo with zero")
		    Return New RooNumber(RooNumber(left).Value Mod RooNumber(right).Value)
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBitwiseExpr(expr As RooBitwiseExpr) As Variant
		  // Evaluate the left and right operands.
		  Dim left As Variant = Evaluate(expr.Left)
		  Dim right As Variant = Evaluate(expr.Right)
		  
		  // The bitwise operations all require positive integer operands.
		  Roo.AssertArePositiveIntegers(expr.Operator, left, right)
		  
		  // Cast the operands to 64-bit integers.
		  Dim intLeft, intRight As UInt64
		  intLeft = RooNumber(left).Value
		  intRight = RooNumber(right).Value
		  
		  Select Case expr.Operator.Type
		  Case Roo.TokenType.AMPERSAND
		    // Bitwise AND operation.
		    Return New RooNumber(intLeft And intRight)
		  Case Roo.TokenType.PIPE
		    // Bitwise OR operation.
		    Return New RooNumber(intLeft Or intRight)
		  Case Roo.TokenType.LESS_LESS
		    // Bit shift left.
		    Return New RooNumber(Bitwise.ShiftLeft(intLeft, intRight))
		  Case Roo.TokenType.GREATER_GREATER
		    // Bit shift right.
		    Return New RooNumber(Bitwise.ShiftRight(intLeft, intRight))
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBlockStmt(stmt As RooBlockStmt) As Variant
		  // Execute this block, passing to it a new environment enclosed by the current environment.
		  
		  ExecuteBlock(stmt.Statements, New RooEnvironment(Environment))
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBooleanLiteralExpr(expr As RooBooleanLiteralExpr) As Variant
		  Return New RooBoolean(expr.Value)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBreakStmt(stmt As RooBreakStmt) As Variant
		  // The interpreter has encountered a break statement.
		  
		  #Pragma Unused stmt
		  
		  If stmt.Condition <> Nil Then
		    // Evaluate the break condition.
		    If IsTruthy(Evaluate(stmt.Condition)) Then
		      #Pragma BreakOnExceptions False // Xojo bug. Compiler ignores if at top of the method.
		      Raise New RooBreak
		    End If
		  Else // Unconditional break.
		    #Pragma BreakOnExceptions False // Xojo bug. Compiler ignores if at top of the method.
		    Raise New RooBreak
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitClassStmt(stmt As RooClassStmt) As Variant
		  // The intepreter is visiting a class definition.
		  
		  Dim staticMethods, methods As Xojo.Core.Dictionary
		  Dim func As RooFunction
		  Dim superclass As RooClass = Nil
		  
		  Environment.Define(stmt.Name.Lexeme, Nothing)
		  
		  // Evaluate this class definition's (optional) superclass and make sure that, 
		  // if defined, it is actually a class.
		  Dim superclassVariant As Variant = Nil
		  If stmt.Superclass <> Nil Then
		    superclassVariant = Evaluate(stmt.Superclass)
		    If Not superclassVariant IsA RooClass Then
		      Raise New RooRuntimeError(stmt.Superclass.Name, "Classes must inherit from another class (" + _
		      stmt.Superclass.Name.Lexeme + " is a " + Roo.VariantTypeAsString(superclassVariant) + ").")
		    End If
		    superclass = superclassVariant
		    // Create a new environment to store a reference to the superclass.
		    Environment = New RooEnvironment(Environment)
		    Environment.Define("super", superclass)
		  End If
		  
		  // Convert the static methods into their runtime representation as RooFunctions.
		  staticMethods = New Xojo.Core.Dictionary
		  For Each sm As RooFunctionStmt In stmt.StaticMethods
		    func = New RooFunction(sm, Environment, False)
		    staticMethods.Value(sm.Name.Lexeme) = func
		  Next sm
		  
		  // Create this class definition's metaclass (to permit static methods).
		  Dim metaclass As New RooClass(Nil, superclass, stmt.Name.Lexeme + " metaclass", staticMethods, Self)
		  
		  // Convert the instance methods into their runtime representation as RooFunctions.
		  methods = New Xojo.Core.Dictionary
		  For each m As RooFunctionStmt In stmt.Methods
		    func = New RooFunction(m, Environment, If(m.Name.Lexeme = "init", True, False))
		    methods.Value(m.Name.Lexeme) = func
		  Next m
		  
		  // Convert the class syntax node into its runtime representation.
		  Dim klass As New RooClass(metaclass, superclass, stmt.Name.Lexeme, methods, Self)
		  
		  // If a superclass was defined, pop the previously created environment off.
		  if superclass <> Nil Then Environment = Environment.Enclosing
		  
		  // Store the class object in the variable we previously declared.
		  Environment.Assign(stmt.Name, klass)
		  
		  Return klass
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitExitStmt(stmt As RooExitStmt) As Variant
		  // The interpreter is visiting an `exit` statement.
		  
		  #Pragma Unused stmt
		  #Pragma BreakOnExceptions False
		  
		  Raise New RooExit
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitExpressionStmt(stmt As RooStmt) As Variant
		  #If Self.kDebugMode
		    // Print out the result of expression statements in debugging mode.
		    Dim result As Variant = Evaluate(stmt.Expression)
		    If result IsA Stringable Then Print("=> " + Stringable(result).StringValue)
		  #Else
		    Call Evaluate(stmt.Expression)
		  #Endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitFunctionStmt(stmt As RooFunctionStmt) As Variant
		  // The interpreter is visiting a function declaration.
		  
		  // Create a runtime representation for this function.
		  Dim func As New RooFunction(stmt, Environment, False)
		  
		  // Define the function in the current environment.
		  Environment.Define(stmt.Name.Lexeme, func)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitGetExpr(expr As RooGetExpr) As Variant
		  // The interpreter is trying to retrieve a property or method on an instance.
		  
		  // First evaluate the expression whose property is being accessed.
		  Dim obj As Variant = Evaluate(expr.Obj)
		  
		  If obj IsA RooInstance Then
		    RooInstance(obj).IndexOrKey = Evaluate(expr.IndexOrKey)
		    Dim result As Variant = RooInstance(obj).Get(expr.Name)
		    
		    // If the field we are accessing is a getter then invoke it right now and return the
		    // result of that. Otherwise just return the method without invoking it.
		    If result IsA RooFunction And RooFunction(result).Declaration.Parameters = Nil Then
		      // This is a getter method.
		      result = RooFunction(result).Invoke(Self, Nil, expr.Name)
		    End If
		    
		    Return result
		  End If
		  
		  Raise New RooRuntimeError(expr.Name, "Only instances have fields.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitGroupingExpr(expr As RooGroupingExpr) As Variant
		  Return Evaluate(expr.Expression)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitHashAssignExpr(expr As RooHashAssignExpr) As Variant
		  // The user wants to assign a value to a Hash.
		  // The Hash's identifer is expr.Name
		  // The key to assign to is expr.Key (to be evaluated).
		  // The value to assign to the specified key is expr.Value
		  // Shorthand assignment is permitted (+=, -=, /=, *=, %=) as well as simple assignment (=).
		  
		  Dim current, value, key, variable As Variant
		  Dim distance As Integer
		  Dim h As RooHash
		  
		  // Evaluate the right hand side of the assignment.
		  value = Evaluate(expr.Value)
		  
		  // Get this hash variable.
		  distance = Locals.Lookup(expr, -1)
		  If distance = -1 Then
		    // Global variable.
		    variable = Globals.Get(expr.Name)
		  Else
		    // Locally scoped variable.
		    variable = Environment.GetAt(distance, expr.Name.Lexeme)
		  End If
		  
		  If variable = Nil Then
		    Raise New RooRuntimeError(expr.Name, "Error retrieving hash variable `" + expr.Name.Lexeme + "`.")
		  ElseIf variable IsA RooNothing Then
		    // Non-initialised variable. Initialise it as a empty hash object.
		    variable = New RooHash
		  End If
		  
		  // Cast to a RooHash to help the Xojo IDE with autocompletion, etc.
		  h = RooHash(variable)
		  
		  // Get the key to assign to.
		  // Remember, we use the raw value of RooText, RooNumber and RooBoolean objects as 
		  // the key. For other types, we use the actual object.
		  key = Evaluate(expr.Key)
		  If key IsA RooText Then
		    key = RooText(key).Value.ToText // Use Text not String.
		  ElseIf key IsA RooNumber Then
		    key = RooNumber(key).Value
		  ElseIf key IsA RooBoolean Then
		    key = RooBoolean(key).Value
		  End If
		  
		  // Does this key exist? If so, get the current value of it.
		  If h.HasKey(key) Then
		    current = h.GetValue(key)
		  Else
		    current = Nil
		  End If
		  
		  // Prevent the use of the compound assignment operators (+', -=, /=, *=) on non-existent keys.
		  If (current = Nil Or current IsA RooNothing) And expr.Operator.type <> Roo.TokenType.EQUAL Then
		    Raise New RooRuntimeError(expr.name, "Cannot use a compound assigment operator on Nothing.")
		  end if
		  
		  // What type of assignment is this?
		  Select Case expr.Operator.Type
		  Case Roo.TokenType.PLUS_EQUAL // Compound addition (+=).
		    If BothNumbers(current, value) Then
		      // Arithmetic addition.
		      value = New RooNumber(RooNumber(current).Value + RooNumber(value).Value)
		    Else
		      // Text concatenation.
		      value = New RooText(Stringable(current).StringValue + Stringable(value).StringValue)
		    End If
		    
		  Case Roo.TokenType.MINUS_EQUAL // Compound subtraction (-=).
		    Roo.AssertAreNumbers(expr.Operator, current, value)
		    value = New RooNumber(RooNumber(current).Value - RooNumber(value).Value)
		    
		  Case Roo.TokenType.SLASH_EQUAL // Compound division (/=).
		    Roo.AssertAreNumbers(expr.Operator, current, value)
		    If RooNumber(value).Value = 0 Then Raise New RooRuntimeError(expr.Operator, "Division by zero")
		    value = New RooNumber(RooNumber(current).Value / RooNumber(value).Value)
		    
		  Case Roo.TokenType.STAR_EQUAL // Compound multiplication (*=).
		    Roo.AssertAreNumbers(expr.Operator, current, value)
		    value = New RooNumber(RooNumber(current).Value * RooNumber(value).Value)
		    
		  Case Roo.TokenType.PERCENT_EQUAL // Compound modulo (%=).
		    Roo.AssertAreNumbers(expr.Operator, current, value)
		    If RooNumber(value).Value = 0 Then Raise New RooRuntimeError(expr.Operator, "Modulo with zero")
		    value = New RooNumber(RooNumber(current).Value Mod RooNumber(value).Value)
		  End Select
		  
		  // Assign the new value to this key.
		  h.Dict.Value(key) = value
		  
		  // Assign the newly updated hash to the correct environment.
		  If distance = -1 Then
		    Globals.Assign(expr.Name, h)
		  Else
		    Environment.AssignAt(distance, expr.Name, h)
		  End If
		  
		  // Return the value we assigned to the key to allow nesting (e.g: `print(h{"name"} = "Garry")`)
		  Return value
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitHashExpr(expr As RooHashExpr) As Variant
		  // Return the value associated with the specified key for this Hash.
		  // The identifier of the Hash is expr.Name
		  // The key is the result of evaluating expr.Key
		  
		  Dim keyValue As Variant
		  Dim hash As RooHash
		  
		  // Get this Hash
		  Try
		    hash = LookupVariable(expr.Name, expr)
		  Catch
		    Raise New RooRuntimeError(expr.Name, "You are treating `" + expr.Name.Lexeme + _
		    "` like a Hash but it isn't one.")
		  End Try
		  
		  // Evaluate the key.
		  keyValue = Evaluate(expr.Key)
		  
		  If keyValue IsA RooNothing Then 
		    Raise New RooRuntimeError(expr.Name, "Nothing is not a valid Hash key.")
		  End If
		  
		  // Return the requested value or Nothing if it doesn't exist.
		  // Try a speedy object lookup first.
		  If hash.Dict.HasKey(keyValue) Then Return hash.Dict.Value(keyValue)
		  
		  // Remember that we don't store RooText, RooNumber and RooBoolean objects directly as keys. 
		  // Instead we store them as their text, double or boolean value.
		  If keyValue IsA RooText then
		    Dim t as Text = RooText(keyValue).Value.ToText // Use Text not String.
		    If hash.Dict.HasKey(t) Then
		      Return hash.Dict.Value(t)
		    Else
		      Return Nothing
		    End If
		  ElseIf keyValue IsA RooNumber Then
		    Dim d as Double = RooNumber(keyValue).Value
		    Return hash.Dict.Lookup(d, Nothing)
		  ElseIf keyValue IsA RooBoolean Then
		    Return hash.Dict.Lookup(RooBoolean(keyValue).Value, Nothing)
		  Else
		    Return Nothing
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitHashLiteralExpr(expr As RooHashLiteralExpr) As Variant
		  // The interpreter has encountered a hash literal (e.g: {"name" => "value"}).
		  
		  // Create a new runtime representation for the hash.
		  Dim h As New RooHash
		  Dim key, value As Variant
		  
		  For Each entry As Xojo.Core.DictionaryEntry In expr.Dict
		    
		    key = Evaluate(entry.Key)
		    value = Evaluate(expr.Dict.Value(entry.Key))
		    
		    // For text, numerical and boolean objects, we use their raw values as the keys.
		    If key IsA RooText Then
		      key = RooText(key).Value.ToText // Use Text not String.
		    ElseIf key IsA RooNumber Then
		      key = RooNumber(key).Value
		    ElseIf key IsA RooBoolean Then
		      key = RooBoolean(key).Value
		    End If
		    
		    h.Dict.Value(key) = value
		    
		  Next entry
		  
		  Return h
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitIfStmt(stmt As RooIfStmt) As Variant
		  // The interpreter is visiting an if statement.
		  
		  // Try the primary condition.
		  If IsTruthy(Evaluate(stmt.Condition)) Then
		    Execute(stmt.ThenBranch)
		    Return Nothing
		  End If
		  
		  // Try the `or` clauses in order.
		  If stmt.OrStatements.Ubound >= 0 Then
		    For i As Integer = 0 To stmt.OrStatements.Ubound
		      If IsTruthy(Evaluate(stmt.OrStatements(i).Condition)) Then
		        Execute(stmt.OrStatements(i).ThenBranch)
		        Return Nothing
		      End If
		    Next i
		  End If
		  
		  // Try the else clause, if present.
		  If stmt.ElseBranch <> Nil Then
		    Execute(stmt.ElseBranch)
		    Return Nothing
		  End If
		  
		  Exception err As RooExit
		    // Encountered an `exit` statement. Simply exit the `if` construct.
		    Return Nothing
		    
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitInvokeExpr(expr As RooInvokeExpr) As Variant
		  // Evaluate the expression for the invokee. Usually this will be an identifier that looks up 
		  // the function by its name but it could be anything. 
		  Dim invokeeVariant As Variant = Evaluate(expr.Invokee)
		  
		  // Evaluate any arguments.
		  Dim arguments() As Variant
		  If expr.Arguments <> Nil Then // Remember that getters will have a Nil arguments array.
		    For i As Integer = 0 To expr.Arguments.Ubound
		      arguments.Append(Evaluate(expr.Arguments(i)))
		    Next i
		  End If
		  
		  // Make sure that we have an invokable invokee.
		  If Not invokeeVariant IsA Invokable Then
		    Raise New RooRuntimeError(expr.Paren, "Only functions, " + _
		    "methods and class initialisers can be invoked.")
		  End If
		  Dim invokee As Invokable = invokeeVariant
		  
		  // Check that the number of arguments passed to this invokable object is correct.
		  If Not CorrectArity(invokee, arguments.Ubound + 1) Then
		    Raise New RooRuntimeError(expr.Paren, "Incorrect number of arguments passed to " + _
		    Stringable(invokee).StringValue + ".")
		  End If
		  
		  // Return the result of the invokcation.
		  Return invokee.Invoke(Self, arguments, expr.Paren)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitLogicalExpr(expr As RooLogicalExpr) As Variant
		  // The interpreter has encountered either a logical `and` or a logical `or` expression.
		  
		  Dim left As Variant = Evaluate(expr.Left)
		  
		  If expr.Operator.Type = Roo.TokenType.OR_KEYWORD Then
		    If IsTruthy(left) Then Return left
		  Else
		    If Not IsTruthy(left) Then Return left
		  End If
		  
		  Return Evaluate(expr.Right)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitModuleStmt(stmt As RooModuleStmt) As Variant
		  Dim func As RooFunction
		  
		  // Define the module's name in the current environment.
		  Environment.Define(stmt.Name.Lexeme, Nothing)
		  
		  // Store the current environment and then immediately create a new one that 
		  // will act as the module's namespace.
		  Dim oldEnv As RooEnvironment = Environment
		  Environment = New RooEnvironment(oldEnv)
		  
		  // Convert any methods in the module to RooFunctions.
		  Dim methods As Xojo.Core.Dictionary = Roo.CaseSensitiveDictionary
		  For Each f As RooFunctionStmt In stmt.Methods
		    func = New RooFunction(f, Environment, False)
		    methods.Value(f.Name.Lexeme) = func
		  Next f
		  
		  // Create a metaclass for this module to enable the use of the above 
		  // methods (which are essentially static).
		  Dim metaclass As New RooClass(Nil, Nil, stmt.Name.Lexeme + " metaclass", methods, Self)
		  
		  // Convert any sub-module declarations to RooModules within this module's namespace.
		  Dim modules() As RooModule
		  For Each m As RooModuleStmt In stmt.Modules
		    modules.Append(VisitModuleStmt(m))
		  Next m
		  
		  // Convert any class declarations to RooClasses within this module's namespace.
		  Dim classes() As RooClass
		  For Each c As RooClassStmt In stmt.Classes
		    classes.Append(VisitClassStmt(c))
		  Next c
		  
		  // Convert the passed module statement node into its runtime representation.
		  Dim m As New RooModule(metaclass, stmt.Name.Lexeme, modules, classes, methods)
		  
		  // Store the module object in the variable we previously declared.
		  Environment.Assign(stmt.Name, m)
		  
		  // Done defining the module. Restore the environment.
		  Environment = oldEnv
		  
		  return m
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitNothingExpr(expr As RooNothingExpr) As Variant
		  #Pragma Unused expr
		  
		  // We only need one Nothing representation in the runtime...
		  Return Nothing
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitNumberLiteralExpr(expr As RooNumberLiteralExpr) As Variant
		  // Return a runtime representation of this number literal.
		  
		  Return New RooNumber(expr.Value)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitOrStmt(stmt As RooOrStmt) As Variant
		  // The interpreter will never visit one of these nodes. They are only visited by the Analyser.
		  #Pragma Unused stmt
		  
		  Return Nothing
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitPassStmt(stmt As RooPassStmt) As Variant
		  // The `pass` statement does nothing.
		  #Pragma Unused stmt
		  
		  Return Nothing
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitQuitStmt(stmt As RooQuitStmt) As Variant
		  // The interpreter has encountered the quit keyword.
		  
		  #Pragma Unused stmt
		  #Pragma BreakOnExceptions False
		  
		  Raise New RooQuit
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitReturnStmt(stmt As RooReturnStmt) As Variant
		  // The interpreter has encountered the `return` keyword.
		  
		  Dim value As Variant
		  
		  // If there is an (optional) return value, evaluate it.
		  If stmt.Value <> Nil Then value = Evaluate(stmt.Value)
		  
		  #Pragma BreakOnExceptions False
		  Raise New RooReturn(value)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitSelfExpr(expr As RooSelfExpr) As Variant
		  Return LookupVariable(expr.Keyword, expr)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitSetExpr(expr As RooSetExpr) As Variant
		  // The interpreter is trying to set the value of a field on an instance.
		  
		  // Evaluate the object we're trying to set the field on.
		  Dim obj As Variant = Evaluate(expr.Obj)
		  
		  // Bail if the object is not an instance.
		  If Not obj IsA RooInstance Then
		    #Pragma BreakOnExceptions False
		    Raise New RooRuntimeError(expr.Name, "Can only set fields on instances.")
		  End If
		  
		  // Disallow the alteration of fields on native modules and classes.
		  If obj IsA RooNativeClass Then
		    // We give a specisal dispensation to RooNativeSettable objects. These are 
		    // native classes that handle their own property setting. 
		    If obj IsA RooNativeSettable = False Then
		      #Pragma BreakOnExceptions False
		      Raise New RooRuntimeError(expr.Operator, "Cannot set fields on native classes or types.")
		    End If
		  ElseIf obj IsA RooNativeModule Then
		    #Pragma BreakOnExceptions False
		    Raise New RooRuntimeError(expr.Operator, "Cannot set fields on native modules.")
		  End If
		  
		  // Evaluate the value that we will assign and set the field.
		  Dim value As Variant = Evaluate(expr.Value)
		  
		  // Since simple assignment with `=` is the most common type of set operation, handle it first
		  // before the select case statement below for a slight performance increase.
		  If expr.Operator.Type = Roo.TokenType.EQUAL Then
		    RooInstance(obj).Set(expr.Name, value)
		    Return value
		  End If
		  
		  // Get the current value of the requested field as we need to manipulate it.
		  Dim current As Variant = RooInstance(obj).fields.Lookup(expr.name.lexeme, Nil)
		  If current = Nil Then
		    // Prevent the use of compound assignment operators (+=, -=, %=, /=, *=) when 
		    // the property doesn't exist.
		    #Pragma BreakOnExceptions False
		    Raise New RooRuntimeError(expr.Operator, "Cannot use the " + _
		    RooToken.TypeToString(expr.Operator.type) + _
		    " operator on an undefined instance field (" + RooInstance(obj).StringValue + "." + _
		    expr.Name.Lexeme + ").")
		  End If
		  
		  // Handle the compound operators.
		  Select Case expr.Operator.Type
		  Case Roo.TokenType.PLUS_EQUAL // Compound addition (current += value).
		    If BothNumbers(current, value) Then
		      // Arithmetic addition.
		      value = New RooNumber(RooNumber(current).Value + RooNumber(value).Value)
		    Else
		      // Text concatenation.
		      value = New RooText(Stringable(current).StringValue + Stringable(value).StringValue)
		    End If
		    
		  Case Roo.TokenType.MINUS_EQUAL // Compound subtraction (current -= value).
		    Roo.AssertAreNumbers(expr.Operator, current, value)
		    value = New RooNumber(RooNumber(current).Value - RooNumber(value).Value)
		    
		  Case Roo.TokenType.SLASH_EQUAL // Compound division (current /= value).
		    Roo.AssertAreNumbers(expr.Operator, current, value)
		    If RooNumber(value).Value = 0 Then Raise New RooRuntimeError(expr.Operator, "Division with zero")
		    value = New RooNumber(RooNumber(current).Value / RooNumber(value).Value)
		    
		  Case Roo.TokenType.STAR_EQUAL // Compound multiplication (current *= value).
		    Roo.AssertAreNumbers(expr.Operator, current, value)
		    value = New RooNumber(RooNumber(current).Value * RooNumber(value).Value)
		    
		  Case Roo.TokenType.PERCENT_EQUAL // Compound modulo (current %= value).
		    Roo.AssertAreNumbers(expr.Operator, current, value)
		    If RooNumber(value).Value = 0 Then Raise New RooRuntimeError(expr.Operator, "Modulo with zero")
		    value = New RooNumber(RooNumber(current).Value Mod RooNumber(value).Value)
		  End Select
		  
		  // Actually do the assignment for the operators other than EQUAL (which has already returned).
		  RooInstance(obj).Set(expr.Name, value)
		  
		  Return value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitSuperExpr(expr As RooSuperExpr) As Variant
		  // The interpreter has encountered the `super` keyword.
		  
		  Dim distance As Integer = Locals.Lookup(expr, -1)
		  If distance = -1 Then
		    // Not supposed to happen...
		    Raise New RooRuntimeError(expr.Keyword, "An error occurred in the Interpreter.VisitSuperExpr method.")
		  End If
		  
		  Dim superclass As RooClass = Environment.GetAt(distance, "super")
		  
		  // "self" is always one level nearer than "super"'s environment.
		  Dim obj As RooInstance = Environment.GetAt(distance - 1, "self")
		  
		  Dim method As RooFunction = superclass.FindMethod(obj, expr.Method.Lexeme)
		  If method = Nil Then
		    Raise New RooRuntimeError(expr.Method, "Undefined field `" + expr.Method.Lexeme + "`.")
		  Else
		    Return method
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitTernaryExpr(expr As RooTernaryExpr) As Variant
		  // The interpreter has encountered a ternary operation.
		  // E.g: `var a = b > c ? True : False`
		  
		  Dim condition As Variant = Evaluate(expr.Expression)
		  
		  If IsTruthy(condition) Then
		    Return Evaluate(expr.ThenBranch)
		  Else
		    Return Evaluate(expr.ElseBranch)
		  End If
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitTextLiteralExpr(expr As RooTextLiteralExpr) As Variant
		  // Return the runtime representation of this text literal.
		  
		  Return New RooText(expr.Value)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitUnaryExpr(expr As RooUnaryExpr) As Variant
		  // Since Roo's scanner is unable to identify negative numbers, we need to 
		  // handle number literals following the MINUS token as a special case. 
		  If expr.Operator.Type = Roo.TokenType.MINUS Then
		    If expr.Right IsA RooGetExpr Then
		      If RooGetExpr(expr.Right).Obj IsA RooNumberLiteralExpr Then
		        // Negate the literal value.
		        RooNumberLiteralExpr(RooGetExpr(expr.Right).Obj).Value = _
		        -RooNumberLiteralExpr(RooGetExpr(expr.Right).Obj).Value
		        // Evaluate the right hand expression.]
		        Return Evaluate(expr.Right)
		      End If
		    End If
		  End If
		  
		  // The right hand expression is NOT a number literal. Proceed.
		  // Evaluate the expression.
		  Dim right As Variant = Evaluate(expr.Right)
		  
		  Select Case expr.Operator.Type
		  Case Roo.TokenType.BANG, Roo.TokenType.NOT_KEYWORD // Boolean negation.
		    Return New RooBoolean(Not IsTruthy(right))
		    
		  Case Roo.TokenType.MINUS // Arithmetic negation.
		    Roo.AssertAreNumbers(expr.Operator, right)
		    Return New RooNumber(-RooNumber(right).Value)
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitVariableExpr(expr As RooVariableExpr) As Variant
		  // Return the requested variable.
		  Return LookupVariable(expr.Name, expr)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitVarStmt(varStatement As RooVarStmt) As Variant
		  // Examples:
		  //   var a;
		  //   var a = 10;
		  
		  Dim value As Variant
		  
		  If varStatement.Initialiser = Nil Then
		    // No initialiser, e.g. var a;
		    value = Self.Nothing
		  Else
		    // There is an initialiser, e.g. var a = 10;
		    value = Evaluate(varStatement.Initialiser)
		  End If
		  
		  // Define this newly created variable in the current scope.
		  Self.Environment.Define(varStatement.Name.Lexeme, value)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitWhileStmt(stmt As RooWhileStmt) As Variant
		  Try
		    
		    While IsTruthy(Evaluate(stmt.Condition)) And Not ForceKill
		      Execute(stmt.Body)
		    Wend
		    
		  Catch b As RooBreak
		    
		    // `break` statement encountered - exit the while loop.
		    Return Nothing
		    
		  End Try
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event AllowNetworkAccess(url As String) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event AnalyserError(token As RooToken, message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event DeletionPrevented(f As FolderItem, where As RooToken)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Input(prompt As String) As String
	#tag EndHook

	#tag Hook, Flags = &h0
		Event NetworkAccessed(url As String, status As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ParserError(where As RooToken, message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Print(s As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event RuntimeError(where As RooToken, message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ScannerError(file As FolderItem, message As String, line As Integer, position As Integer)
	#tag EndHook


	#tag Property, Flags = &h0
		#tag Note
			This references the location on disk that the interpreter will consider the root 
			when resolving absolute paths during file system access.
			
		#tag EndNote
		AbsoluteRoot As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Analyser As RooAnalyser
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			Used to store arbitrary data for the interpreter.
			Only of use to Xojo developers.
		#tag EndNote
		Custom As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Tracks the current environment. Changes as the interpreter enters and exits local scopes.
		#tag EndNote
		Private Environment As RooEnvironment
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mFileSystemSafeMode
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // Get a reference to the FileSystem module in this interpreter's Natives Environment.
			  Dim fs As RooSLFileSystem = Natives.Values.Value("FileSystem")
			  
			  // Set the safe mode appropriately.
			  fs.SafeMode = value
			  
			  Exception err
			    Raise New RooRuntimeError(New RooToken(Roo.TokenType.ERROR), "Unable to get reference to the FileSystem module")
			End Set
		#tag EndSetter
		FileSystemSafeMode As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		ForceKill As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			Holds a fixed reference to the outermost global environment.
		#tag EndNote
		Globals As RooEnvironment
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mIsRunning
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // Read only.
			  
			End Set
		#tag EndSetter
		IsRunning As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		#tag Note
			This Dictionary stores resolution information passed to the Interpreter from the Analyser during
			static analysis.
			Key = RooExpr
			Value = Integer (depth)
		#tag EndNote
		Private Locals As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFileSystemSafeMode As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIsRunning As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			Holds a reference the environment which contains modules, classes, functions and variables that are 
			part of the standard library or are created by Xojo developers.
		#tag EndNote
		Natives As RooEnvironment
	#tag EndProperty

	#tag Property, Flags = &h0
		Nothing As RooNothing
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Parser As RooParser
	#tag EndProperty

	#tag Property, Flags = &h0
		REPL As Boolean = False
	#tag EndProperty


	#tag Constant, Name = kDebugMode, Type = Boolean, Dynamic = False, Default = \"False", Scope = Public
	#tag EndConstant


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
			Name="ForceKill"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsRunning"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FileSystemSafeMode"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="REPL"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
