#tag Class
Protected Class Interpreter
Implements ExprVisitor,StmtVisitor
	#tag Method, Flags = &h21
		Private Sub CheckNumberOperands(operator as Token, ParamArray operands as Variant)
		  ' Check that the passed operands are NumberObjects. If any aren't, raise an error.
		  
		  for each operand as Variant in operands
		    if operand isA NumberObject = False then
		      raise new RuntimeError(operator, "Expected a number operand.")
		    end if
		  next operand
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  Roo.FileSystem.Initialise
		  
		  Reset()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function CorrectArity(func as Invokable, argCount as Integer) As Boolean
		  ' Checks that the the correct number of arguments for the specified invokable object have been passed
		  ' (i.e `argCount` matches the invokable's "arity").
		  ' A invokable object's Arity() function returns a Variant which is either an integer or an array of integers.
		  ' If an integer is returned it means that this invokable object has only one method signature.
		  ' If an array of integers is returned then there are multiple functions with this name which take
		  ' differing numbers of arguments (i.e: have different method signatures). 
		  ' For example, the `Text.slice()` method can take one or two arguments. In that case, Arity() will 
		  ' return an integer array in the form: arity(0) = 1, arity(1) = 2.
		  
		  dim arities() as Integer
		  dim arity as Variant = func.Arity()
		  
		  if arity.IsArray then ' This function has more than one method signature.
		    arities = arity
		    if arities.IndexOf(argCount) <> -1 then return True
		  else ' This function has only one method signature.
		    if argCount = arity.IntegerValue then return True
		  end if
		  
		  return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DefineGlobalFunction(name as String, func as Variant)
		  self.globals.Define(name, func)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DefineNativeModule(m as Roo.CustomModule)
		  ' Define this module's name in the current environment.
		  self.environment.Define(m.name, self.nothing)
		  
		  ' Store the current environment and then immediately create a new one that will act as 
		  ' the module's namespace.
		  dim oldEnv as Environment = self.environment
		  self.environment = new Environment(oldEnv)
		  
		  ' Store the module object in the variable we previously declared.
		  dim modName as new Roo.Token
		  modName.type = TokenType.IDENTIFIER
		  modName.lexeme = m.name
		  self.environment.Assign(modName, m)
		  
		  ' Done defining the module. Restore the environment.
		  self.environment = oldEnv
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Evaluate(expr as Expr) As Variant
		  If expr <> Nil Then
		    Return expr.Accept(self)
		  Else
		    Return Nil
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Execute(stmt as Stmt)
		  ' This method is analogous to Evaluate() for expressions.
		  
		  call stmt.Accept(self)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ExecuteBlock(statements() as Stmt, environment as Environment)
		  dim limit as integer = statements.Ubound
		  dim i as Integer
		  
		  dim previous as Environment = self.environment
		  
		  try
		    
		    self.environment = environment
		    
		    for i = 0 to limit
		      Execute(statements(i))
		    next i
		    
		  finally
		    
		    self.environment = previous
		    
		  end try
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HookInput(prompt as String) As String
		  ' This method exists to provide an accessible hook to the interpreter's Input event.
		  
		  return Input(prompt)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HookPrint(what as String)
		  ' This method exists to provide an accessible hook to the interpreter's Print event.
		  
		  Print(what)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Interpret(statements() as Stmt)
		  dim i, limit as Integer
		  
		  limit = statements.Ubound
		  for i = 0 to limit
		    Execute(statements(i))
		    if forceKill then return
		  next i
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsEqual(a as Variant, b as Variant) As Boolean
		  ' Returns True if objects `a` and `b` are considered to be equal. False if not.
		  ' Built in data types (text, booleans, numbers and dates) are always compared by value.
		  ' Instances are always compared by reference.
		  
		  ' Same object in memory?
		  if a = b then return True
		  
		  ' Handle text, numbers, booleans and dates.
		  if a isA TextObject and b isA TextObject then
		    return if(StrComp(TextObject(a).value, TextObject(b).value, 0) = 0, True, False)
		  end if
		  
		  if a isA BooleanObject and b isA BooleanObject then
		    return BooleanObject(a).value = BooleanObject(b).value
		  end if
		  
		  if a isA NumberObject and b isA NumberObject then
		    return NumberObject(a).value = NumberObject(b).value
		  end if
		  
		  If a IsA DateTimeObject And b IsA DateTimeObject Then
		    Return DateTimeObject(a).Value.SecondsFrom1970 = DateTimeObject(b).Value.SecondsFrom1970
		  End If
		  
		  if a isA NothingObject and b isA NothingObject then return True
		  
		  return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsTruthy(what as Variant) As Boolean
		  ' In Roo, Nothing and False are False, everything else is True.
		  
		  if what = Nil then return False
		  if what isA NothingObject then return False
		  if what isA BooleanObject then return BooleanObject(what).value
		  return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LookupVariable(name as Token, expr as Expr) As Variant
		  ' Look up the resolved distance in our hash map.
		  dim distance as Integer = locals.Lookup(expr, -1) ' <-- note the default value of -1
		  
		  if distance = -1 then
		    ' Our resolver only resolved local variables so a distance of -1 means this must be a global variable.
		    return globals.Get(name)
		  else
		    ' Found a local variable.
		    return environment.GetAt(distance, name.lexeme)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Reset()
		  ' Reset the interpreter.
		  
		  Self.ForceKill = False
		  
		  Self.Custom = New Xojo.Core.Dictionary
		  
		  Self.Globals = New Environment
		  Self.Environment = globals
		  
		  Self.Locals = New VariantToVariantHashMapMBS ' Stores resolution information from the Resolver
		  Self.Nothing = New NothingObject ' The global Nothing object
		  
		  SetupNativeFunctions()
		  SetupNativeModules()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Resolve(expr as Expr, depth as Integer)
		  locals.Value(expr) = depth
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetupNativeFunctions()
		  DefineGlobalFunction("DateTime", New Roo.Native.Functions.DateTime)
		  DefineGlobalFunction("File", New Roo.Native.Functions.File)
		  DefineGlobalFunction("input",New Roo.Native.Functions.Input)
		  DefineGlobalFunction("print", New Roo.Native.Functions.Print)
		  DefineGlobalFunction("Request", New Roo.Native.Functions.Request)
		  DefineGlobalFunction("Response", New Roo.Native.Functions.Response)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetupNativeModules()
		  dim methods as StringToVariantHashMapMBS
		  
		  ' ##########################################################################
		  ' FileUtils module
		  ' ##########################################################################
		  methods = New StringToVariantHashMapMBS
		  methods.Value("copy") = New Roo.Native.Modules.FileUtilsCopy
		  methods.Value("delete") = New Roo.Native.Modules.FileUtilsDelete
		  methods.Value("mkdir") = New Roo.Native.Modules.FileUtilsMkDir
		  methods.Value("move") = New Roo.Native.Modules.FileUtilsMove
		  DefineNativeModule(New Roo.Native.Modules.FileUtils("FileUtils", methods))
		  
		  ' ##########################################################################
		  ' HTTP module
		  ' ##########################################################################
		  methods = new StringToVariantHashMapMBS
		  methods.Value("delete") = new Roo.Native.Modules.HTTPDelete
		  methods.Value("get") = new Roo.Native.Modules.HTTPGet
		  methods.Value("post") = new Roo.Native.Modules.HTTPPost
		  methods.Value("put") = new Roo.Native.Modules.HTTPPut
		  DefineNativeModule(new Roo.Native.Modules.HTTP("HTTP", methods))
		  
		  ' ##########################################################################
		  ' JSON module
		  ' ##########################################################################
		  methods = new StringToVariantHashMapMBS
		  methods.Value("generate") = new Roo.Native.Modules.JSONGenerate
		  methods.Value("parse") = new Roo.Native.Modules.JSONParse
		  DefineNativeModule(new Roo.Native.Modules.NativeJSONModule("JSON", methods))
		  
		  ' ##########################################################################
		  ' Maths module
		  ' ##########################################################################
		  methods = new StringToVariantHashMapMBS
		  methods.Value("random_int") = new Roo.Native.Modules.MathsRandomInt
		  DefineNativeModule(new Roo.Native.Modules.Maths("Maths", methods))
		  
		  ' ##########################################################################
		  ' Roo module
		  ' ##########################################################################
		  methods = new StringToVariantHashMapMBS
		  DefineNativeModule(new Roo.Native.Modules.NativeRooModule("Roo", methods))
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Stringify(obj as Variant) As String
		  ' Temporary method for printing out the result of interpretation.
		  
		  if obj = Nil then return "Nil"
		  
		  if obj isA NothingObject then return "Nothing"
		  
		  if obj isA NumberObject then
		    dim d as Double = NumberObject(obj).value
		    if Round(d) = d then
		      dim i as Integer = d
		      return Str(i)
		    end if
		    return Str(d)
		  end if
		  
		  if obj isA TextObject then return TextObject(obj).value
		  
		  if obj isA BooleanObject then return BooleanObject(obj).value.ToString
		  
		  return obj.StringValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitArrayAssignExpr(expr as ArrayAssignExpr) As Variant
		  ' The user wants to assign a value to an array.
		  ' The array's identifer is expr.name
		  ' The index of the element to assign to is the expr.index expression (to be evaluated).
		  ' The value to assign to the specified element is expr.value
		  ' Shorthand assignment is permitted (+=, -=, /=, *=, %=) and well as simple assignment (=).
		  
		  dim currentValue, value, indexValue, variable as Variant
		  dim distance, index as Integer
		  dim a as ArrayObject
		  
		  ' Evaluate the right hand side of the assignment.
		  value = Evaluate(expr.value)
		  
		  ' Get this variable.
		  distance = locals.Lookup(expr, -1)
		  if distance = -1 then
		    ' Can't find this variable in our resolved local variables so assume it's global.
		    variable = globals.Get(expr.name)
		  else
		    ' It's a local variable.
		    variable = environment.GetAt(distance, expr.name.lexeme)
		  end if
		  
		  if variable = Nil then
		    raise new RuntimeError(expr.name, "Error retrieving variable `" + expr.name.lexeme + "`.")
		  elseif variable isA NothingObject then
		    ' Non-initialised variable. Initialise it as an empty array object.
		    variable = new ArrayObject
		  end if
		  
		  a = ArrayObject(variable)
		  
		  ' Get the index of the element to assign to.
		  indexValue = Evaluate(expr.index)
		  if not indexValue isA NumberObject and not NumberObject(indexValue).IsInteger then
		    raise new RuntimeError(expr.name, "Expected an integer index value for the element to assign to.")
		  end if
		  
		  index = NumberObject(indexValue).value
		  
		  ' Is there an element at this index?
		  if index < 0 then
		    raise new RuntimeError(expr.name, "Expected an integer index >= 0.")
		  elseif index <= a.elements.Ubound then
		    currentValue = a.elements(index)
		  else
		    currentValue = Nil
		  end if
		  
		  ' Prohibit the compound assignment operators (+', -=, /=, *=) on non-existent elements.
		  if currentValue = Nil and expr.operator.type <> TokenType.EQUAL then
		    raise new RuntimeError(expr.name, "Cannot use a compound assigment operator on Nothing.")
		  end if
		  
		  ' What type of assignment is this?
		  select case expr.operator.type
		  case TokenType.PLUS_EQUAL ' +=
		    if currentValue isA NumberObject and value isA NumberObject then ' Arithmetic addition.
		      value = new NumberObject(NumberObject(currentValue).value + NumberObject(value).value)
		    elseif currentValue isA Textable and value isA Textable then ' Text concatenation.
		      value = new TextObject(Textable(currentValue).ToText + Textable(value).ToText)
		    else
		      raise new RuntimeError(expr.operator, "Either both operands must be numbers or viable text " + _
		      "concatenation must be possible.")
		    end if
		    
		  case TokenType.MINUS_EQUAL ' -=
		    CheckNumberOperands(expr.operator, currentValue, value)
		    value = new NumberObject(NumberObject(currentValue).value - NumberObject(value).value)
		    
		  case TokenType.SLASH_EQUAL ' /=
		    CheckNumberOperands(expr.operator, currentValue, value)
		    value = new NumberObject(NumberObject(currentValue).value / NumberObject(value).value)
		    
		  case TokenType.STAR_EQUAL ' *=
		    CheckNumberOperands(expr.operator, currentValue, value)
		    value = new NumberObject(NumberObject(currentValue).value * NumberObject(value).value)
		    
		  case TokenType.PERCENT_EQUAL ' %=
		    CheckNumberOperands(expr.operator, currentValue, value)
		    if NumberObject(value).value = 0 then raise new RuntimeError(expr.operator, "Modulo with zero")
		    value = new NumberObject(NumberObject(currentValue).value Mod NumberObject(value).value)
		  end select
		  
		  ' Assign the new value to the correct element.
		  if index > a.elements.Ubound then
		    ' Increase the size of this array to accomodate this new element, filling the preceding elements 
		    ' with Nothing.
		    dim numNothings as Integer = index - a.elements.Ubound
		    for i as Integer = 1 to numNothings
		      a.elements.Append(self.nothing)
		    next i
		  end if
		  a.elements(index) = value
		  
		  ' Assign the newly updated array to the correct environment.
		  if distance = -1 then
		    globals.Assign(expr.name, a)
		  else
		    environment.AssignAt(distance, expr.name, a)
		  end if
		  
		  ' Return the value we assigned to the element value to allow nesting (e.g: `print(a[2] = "hi")`)
		  return value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitArrayExpr(expr as ArrayExpr) As Variant
		  ' Return the requested element from this array.
		  ' The identifier of the array is expr.name
		  ' The index of the element to return is the result of evaluating expr.index
		  
		  dim index as Variant
		  dim a as ArrayObject
		  
		  ' Get this array
		  try
		    a = LookupVariable(expr.name, expr)
		  catch
		    raise new RuntimeError(expr.name, "You are treating `" + expr.name.lexeme + _
		    "` like an array but it isn't one.")
		  end try
		  
		  ' Evaluate the index.
		  index = Evaluate(expr.index)
		  
		  ' Make sure an integer index has been passed.
		  if not index isA NumberObject then
		    raise new RuntimeError(expr.name, "Expected an integer array index but got " + VariantType(index))
		  elseif not NumberObject(index).IsInteger then
		    raise new RuntimeError(expr.name, "Array indices must be integers, not fractional numbers.")
		  end if
		  
		  ' Return the correct element or Nothing if out of bounds.
		  try
		    return a.elements(NumberObject(index).value)
		  catch OutOfBoundsException
		    return self.nothing
		  end try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitArrayLiteralExpr(expr as ArrayLiteralExpr) As Variant
		  ' The interpreter is visiting an array literal node (e.g: [1, 2, "hello"]).
		  
		  ' Create a new runtime representation for the array.
		  dim a as new ArrayObject
		  
		  ' Evaluate each of the elements in the array literal.
		  dim i, limit as Integer
		  limit = expr.elements.Ubound
		  for i = 0 to limit
		    a.elements.Append(Evaluate(expr.elements(i)))
		  next i
		  
		  ' Return the array object.
		  return a
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitAssignExpr(expr as AssignExpr) As Variant
		  ' Get the current value of the variable.
		  dim currentValue as Variant
		  dim distance as Integer = locals.Lookup(expr, -1)
		  if distance = -1 then
		    ' Can't find this variable in our resolved local variables so assume it's global.
		    currentValue = globals.Get(expr.name)
		  else
		    ' It's a local variable.
		    currentValue = environment.GetAt(distance, expr.name.lexeme)
		  end if
		  
		  ' Disallow compound assignment operators on array objects (since no index has been provided).
		  ' This catches weird edge cases like:
		  ' var a = [2,3]
		  ' a += 10
		  if currentValue isA ArrayObject and expr.operator.type <> TokenType.EQUAL then
		    raise new RuntimeError(expr.name, "Cannot use a compound assignment operator on an array without an index.")
		  end if
		  
		  ' Evaluate the new value.
		  dim value as Variant = Evaluate(expr.value)
		  
		  ' Determine the type of assignment this is.
		  select case expr.operator.type
		  case TokenType.PLUS_EQUAL
		    ' Arithmetic addition?
		    if currentValue isA NumberObject and value isA NumberObject then
		      value = new NumberObject(NumberObject(currentValue).value + NumberObject(value).value)
		    elseif currentValue isA Textable and value isA Textable then ' Text concatenation?
		      value = new TextObject(Textable(currentValue).ToText + Textable(value).ToText)
		    else
		      raise new RuntimeError(expr.operator, "Unable to convert operands to a text representation")
		    end if
		    
		  case TokenType.MINUS_EQUAL ' -=
		    CheckNumberOperands(expr.operator, currentValue, value)
		    value = new NumberObject(NumberObject(currentValue).value - NumberObject(value).value)
		    
		  case TokenType.PERCENT_EQUAL ' %=
		    CheckNumberOperands(expr.operator, currentValue, value)
		    if NumberObject(value).value = 0 then raise new RuntimeError(expr.operator, "Modulo with zero")
		    value = new NumberObject(NumberObject(currentValue).value Mod NumberObject(value).value)
		    
		  case TokenType.SLASH_EQUAL ' /=
		    CheckNumberOperands(expr.operator, currentValue, value)
		    value = new NumberObject(NumberObject(currentValue).value / NumberObject(value).value)
		    
		  case TokenType.STAR_EQUAL ' *=
		    CheckNumberOperands(expr.operator, currentValue, value)
		    value = new NumberObject(NumberObject(currentValue).value * NumberObject(value).value)
		  end select
		  
		  ' Assign the new value to the variable.
		  if distance = -1 then
		    self.globals.Assign(expr.name, value)
		  else
		    self.environment.AssignAt(distance, expr.name, value)
		  end if
		  
		  ' Return the new value to allow nesting (e.g: `print(a = 2)`)
		  return value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBinaryExpr(expr as BinaryExpr) As Variant
		  dim left as Variant = Evaluate(expr.left)
		  dim right as Variant = Evaluate(expr.right)
		  
		  select case expr.operator.type
		  case TokenType.CARET ' left ^ right (exponent)
		    CheckNumberOperands(expr.operator, left, right)
		    return new NumberObject(NumberObject(left).value ^ NumberObject(right).value)
		    
		  case TokenType.COMMA
		    return right
		    
		  case TokenType.GREATER ' left > right
		    ' DateTime?
		    If left IsA DateTimeObject And right IsA DateTimeObject Then
		      Return New BooleanObject(DateTimeObject(left).value.SecondsFrom1970 > DateTimeObject(right).value.SecondsFrom1970)
		    End If
		    ' Number?
		    CheckNumberOperands(expr.operator, left, right)
		    return new BooleanObject(NumberObject(left).value > NumberObject(right).value)
		    
		  case TokenType.GREATER_EQUAL ' left >= right
		    ' DateTime?
		    If left IsA DateTimeObject And right IsA DateTimeObject Then
		      Return New BooleanObject(DateTimeObject(left).value.SecondsFrom1970 >= DateTimeObject(right).value.SecondsFrom1970)
		    End If
		    ' Number?
		    CheckNumberOperands(expr.operator, left, right)
		    return new BooleanObject(NumberObject(left).value >= NumberObject(right).value)
		    
		  case TokenType.LESS ' left < right
		    ' DateTime?
		    If left IsA DateTimeObject And right IsA DateTimeObject Then
		      Return New BooleanObject(DateTimeObject(left).value.SecondsFrom1970 < DateTimeObject(right).value.SecondsFrom1970)
		    End If
		    ' Number?
		    CheckNumberOperands(expr.operator, left, right)
		    return new BooleanObject(NumberObject(left).value < NumberObject(right).value)
		    
		  case TokenType.LESS_EQUAL ' left <= right
		    ' DateTime?
		    If left IsA DateTimeObject And right IsA DateTimeObject Then
		      Return New BooleanObject(DateTimeObject(left).value.SecondsFrom1970 <= DateTimeObject(right).value.SecondsFrom1970)
		    End If
		    ' Number?
		    CheckNumberOperands(expr.operator, left, right)
		    return new BooleanObject(NumberObject(left).value <= NumberObject(right).value)
		    
		  case TokenType.MINUS ' left - right
		    CheckNumberOperands(expr.operator, left, right)
		    return new NumberObject(NumberObject(left).value - NumberObject(right).value)
		    
		  case TokenType.PERCENT ' left % right
		    CheckNumberOperands(expr.operator, left, right)
		    if NumberObject(right).value = 0 then raise new RuntimeError(expr.operator, "Modulo with zero")
		    return new NumberObject(NumberObject(left).value Mod NumberObject(right).value)
		    
		  case TokenType.PLUS
		    ' Arithmetic addition?
		    if left isA NumberObject and right isA NumberObject then
		      return new NumberObject(NumberObject(left).value + NumberObject(right).value)
		    end if
		    ' Text concatenation?
		    if left isA Textable and right isA Textable then
		      return new TextObject(Textable(left).ToText + Textable(right).ToText)
		    end if
		    raise new RuntimeError(expr.operator, "Unable to convert operands to a text representation")
		    
		  case TokenType.SLASH ' left / right
		    CheckNumberOperands(expr.operator, left, right)
		    if NumberObject(right).value = 0 then raise new RuntimeError(expr.operator, "Division by zero")
		    return new NumberObject(NumberObject(left).value / NumberObject(right).value)
		    
		  case TokenType.STAR ' left * right
		    CheckNumberOperands(expr.operator, left, right)
		    return new NumberObject(NumberObject(left).value * NumberObject(right).value)
		    
		  case TokenType.NOT_EQUAL ' left <> right
		    return new BooleanObject(not IsEqual(left, right))
		    
		  case TokenType.EQUAL_EQUAL ' left == right
		    return new BooleanObject(IsEqual(left, right))
		    
		  end select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBlockStmt(stmt as BlockStmt) As Variant
		  ' Execute this block, passing to it a new environment enclosed by the current environment for its scope.
		  
		  ExecuteBlock(stmt.statements, new Environment(self.environment))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBooleanLiteralExpr(expr as BooleanLiteralExpr) As Variant
		  return new BooleanObject(expr.value)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBreakStmt(stmt as Roo.Statements.BreakStmt) As Variant
		  ' The interpreter is visiting a break statement.
		  
		  #pragma Unused stmt
		  #pragma BreakOnExceptions False
		  
		  if stmt.condition <> Nil then
		    if IsTruthy(Evaluate(stmt.condition)) then raise new BreakReturn
		  else
		    ' Unconditional break.
		    raise new BreakReturn
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitClassStmt(stmt as ClassStmt) As Variant
		  dim staticMethods, methods as StringToVariantHashMapMBS
		  dim i, limit as Integer
		  dim func as RooFunction
		  
		  self.environment.Define(stmt.name.lexeme, self.nothing)
		  
		  ' Evaluate this classes' (optional) superclass and make sure that, if defined, it is actually a class.
		  dim superclass as Variant = Nil
		  if stmt.superclass <> Nil then
		    superclass = Evaluate(stmt.superclass)
		    if not superclass isA RooClass then
		      raise new RuntimeError(stmt.superclass.name, "Classes must inherit from another class (" + _
		      stmt.superclass.name.lexeme + " is a " + VariantType(superclass) + ").")
		    end if
		    
		    ' Create a new environment to store a reference to the superclass - the actual RooClass object 
		    ' for the superclass which we have now that we are in the runtime.
		    self.environment = new Environment(self.environment)
		    self.environment.Define("super", superclass)
		  end if
		  
		  ' Convert the static methods into their runtime representation as RooFunctions.
		  staticMethods = new StringToVariantHashMapMBS(True)
		  limit = stmt.staticMethods.Ubound
		  for i = 0 to limit
		    func = new RooFunction(stmt.staticMethods(i), environment, False)
		    staticMethods.Value(stmt.staticMethods(i).name.lexeme) = func
		  next i
		  
		  ' Create this class's metaclass (to permit static methods).
		  dim metaclass as new RooClass(Nil, superclass, stmt.name.lexeme + " metaclass", staticMethods)
		  
		  ' Convert each instance method into its runtime representation as a RooFunction.
		  methods = new StringToVariantHashMapMBS(True)
		  limit = stmt.methods.Ubound
		  for i = 0 to limit
		    func = new RooFunction(stmt.methods(i), environment, _
		    if(StrComp(stmt.methods(i).name.lexeme, "init", 0) = 0, True, False))
		    methods.Value(stmt.methods(i).name.lexeme) = func
		  next i
		  
		  ' Convert the class syntax node into its runtime representation.
		  dim klass as _ 
		  new RooClass(metaclass, if(superclass = Nil, Nil, RooClass(superclass)), stmt.name.lexeme, methods)
		  
		  ' If a superclass was defined, pop the previously created environment off.
		  if superclass <> Nil then self.environment = environment.enclosing
		  
		  ' Store the class object in the variable we previously declared.
		  self.environment.Assign(stmt.name, klass)
		  
		  return klass
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitExpressionStmt(stmt as Stmt) As Variant
		  call Evaluate(stmt.expression)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitFunctionStmt(stmt as FunctionStmt) As Variant
		  dim func as new RooFunction(stmt, self.environment, False)
		  
		  self.environment.Define(stmt.name.lexeme, func)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitGetExpr(expr as Roo.Expressions.GetExpr) As Variant
		  ' First evaluate the expression whose property is being accessed.
		  dim obj as Variant = Evaluate(expr.obj)
		  
		  If obj IsA RooInstance Then
		    RooInstance(obj).IndexOrKey = Evaluate(expr.IndexOrKey)
		    Dim result As Variant = RooInstance(obj).Get(expr.Name)
		    
		    ' If the field we are accessing is a getter then invoke it right now and return the
		    ' result of that get. Otherwise just return the method without invoking it.
		    If result IsA RooFunction And RooFunction(result).Declaration.Parameters = Nil Then
		      ' This is a getter method.
		      result = RooFunction(result).Invoke(Self, Nil, expr.name)
		    End If
		    
		    Return result
		  End If
		  
		  Raise New RuntimeError(expr.Name, "Only instances have properties.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitGroupingExpr(expr as GroupingExpr) As Variant
		  return Evaluate(expr.expression)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitHashAssignExpr(expr as HashAssignExpr) As Variant
		  ' The user wants to assign a value to a Hash.
		  ' The Hash's identifer is expr.name
		  ' The key to assign to is the expr.key expression (to be evaluated).
		  ' The value to assign to the specified key is expr.value
		  ' Shorthand assignment is permitted (+=, -=, /=, *=, %=) as well as simple assignment (=).
		  
		  dim currentValue, value, key, variable as Variant
		  dim distance as Integer
		  dim h as HashObject
		  
		  ' Evaluate the right hand side of the assignment.
		  value = Evaluate(expr.value)
		  
		  ' Get this variable.
		  distance = locals.Lookup(expr, -1)
		  if distance = -1 then
		    ' Can't find this variable in our resolved local variables so assume it's global.
		    variable = globals.Get(expr.name)
		  else
		    ' It's a local variable.
		    variable = environment.GetAt(distance, expr.name.lexeme)
		  end if
		  
		  if variable = Nil then
		    raise new RuntimeError(expr.name, "Error retrieving variable `" + expr.name.lexeme + "`.")
		  elseif variable isA NothingObject then
		    ' Non-initialised variable. Initialise it as a empty hash object.
		    variable = new HashObject
		  end if
		  
		  h = HashObject(variable)
		  
		  ' Get the key to assign to.
		  key = Evaluate(expr.key)
		  if key isA TextObject then
		    key = TextObject(key).value
		  elseif key isA NumberObject then
		    key = NumberObject(key).value
		  elseif key isA BooleanObject then
		    key = BooleanObject(key).value
		  end if
		  
		  ' Does this key exist? If so, get the current value of it.
		  if h.HasKey(key) then
		    currentValue = h.GetValue(key)
		  else
		    currentValue = Nil
		  end if
		  
		  ' Prohibit the compound assignment operators (+', -=, /=, *=) on non-existent keys.
		  if currentValue = Nil and expr.operator.type <> TokenType.EQUAL then
		    raise new RuntimeError(expr.name, "Cannot use a compound assigment operator on Nothing.")
		  end if
		  
		  ' What type of assignment is this?
		  select case expr.operator.type
		  case TokenType.PLUS_EQUAL ' +=
		    if currentValue isA NumberObject and value isA NumberObject then ' Arithmetic addition.
		      value = new NumberObject(NumberObject(currentValue).value + NumberObject(value).value)
		    elseif currentValue isA Textable and value isA Textable then ' Text concatenation.
		      value = new TextObject(Textable(currentValue).ToText + Textable(value).ToText)
		    else
		      raise new RuntimeError(expr.operator, "Either both operands must be numbers or viable text " + _
		      "concatenation must be possible.")
		    end if
		    
		  case TokenType.MINUS_EQUAL ' -=
		    CheckNumberOperands(expr.operator, currentValue, value)
		    value = new NumberObject(NumberObject(currentValue).value - NumberObject(value).value)
		    
		  case TokenType.SLASH_EQUAL ' /=
		    CheckNumberOperands(expr.operator, currentValue, value)
		    value = new NumberObject(NumberObject(currentValue).value / NumberObject(value).value)
		    
		  case TokenType.STAR_EQUAL ' *=
		    CheckNumberOperands(expr.operator, currentValue, value)
		    value = new NumberObject(NumberObject(currentValue).value * NumberObject(value).value)
		    
		  case TokenType.PERCENT_EQUAL ' %=
		    CheckNumberOperands(expr.operator, currentValue, value)
		    if NumberObject(value).value = 0 then raise new RuntimeError(expr.operator, "Modulo with zero")
		    value = new NumberObject(NumberObject(currentValue).value Mod NumberObject(value).value)
		  end select
		  
		  ' Assign the new value to this key.
		  h.map.Value(key) = value
		  
		  ' Assign the newly updated Hash to the correct environment.
		  if distance = -1 then
		    globals.Assign(expr.name, h)
		  else
		    environment.AssignAt(distance, expr.name, h)
		  end if
		  
		  ' Return the value we assigned to the key to allow nesting (e.g: `print(h|"name"| = "Garry")`)
		  return value
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitHashExpr(expr as HashExpr) As Variant
		  ' Return the value associated with the specified key for this Hash.
		  ' The identifier of the Hash is expr.name
		  ' The key is the result of evaluating expr.key
		  
		  dim keyValue as Variant
		  dim hash as HashObject
		  
		  ' Get this Hash
		  try
		    hash = LookupVariable(expr.name, expr)
		  catch
		    raise new RuntimeError(expr.name, "You are treating `" + expr.name.lexeme + _
		    "` like a Hash but it isn't one.")
		  end try
		  
		  ' Evaluate the key.
		  keyValue = Evaluate(expr.key)
		  
		  if keyValue isA NothingObject then 
		    raise new RuntimeError(expr.name, "Cannot assign Nothing to a Hash key.")
		  end if
		  
		  ' Return the correct required value or Nothing if it doesn't exist.
		  if hash.map.HasKey(keyValue) then
		    return hash.map.Value(keyValue)
		  elseif keyValue isA TextObject then
		    dim keyAsString as String = TextObject(keyValue).value
		    if hash.map.HasKey(keyAsString) then
		      return hash.map.Value(keyAsString)
		    else
		      return self.nothing
		    end if
		  elseif keyValue isA NumberObject then
		    dim keyAsNumber as Double = NumberObject(keyValue).value
		    return hash.map.Lookup(keyAsNumber, self.nothing)
		  elseif keyValue isA BooleanObject then
		    return hash.map.Lookup(BooleanObject(keyValue).value, self.nothing)
		  else
		    return self.nothing
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitHashLiteralExpr(expr as HashLiteralExpr) As Variant
		  ' The interpreter is visiting a hash literal (e.g: {"name" => "value"}).
		  
		  ' Create a new runtime representation for the hash.
		  dim h as new HashObject
		  dim key as Variant
		  
		  ' Evaluate each of the keys and values in the backing hash map.
		  dim i as VariantToVariantHashMapIteratorMBS = expr.map.first
		  dim e as VariantToVariantHashMapIteratorMBS = expr.map.last
		  
		  while i.isNotEqual(e)
		    key = Evaluate(i.Key)
		    if key isA TextObject then
		      key = TextObject(key).value
		    elseif key isA NumberObject then
		      key = NumberObject(key).value
		    elseif key isA BooleanObject then
		      key = BooleanObject(key).value
		    end if
		    
		    h.map.Value(key) = Evaluate(i.Value)
		    
		    i.MoveNext()
		  wend
		  
		  ' Done.
		  return h
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitIfStmt(stmt as IfStmt) As Variant
		  ' The interpreter is visiting an if statement.
		  
		  if IsTruthy(Evaluate(stmt.condition)) then
		    
		    Execute(stmt.thenBranch)
		    
		  elseif stmt.elseBranch <> Nil then
		    
		    Execute(stmt.elseBranch)
		    
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitInvokeExpr(expr as InvokeExpr) As Variant
		  ' Evaluate the expression for the invokee. Usually this be an identifier that looks up the function by its name
		  ' but it could be anything. 
		  dim invokee as Variant = Evaluate(expr.invokee)
		  
		  ' Evaluate the arguments (if any).
		  dim arguments() as Variant
		  dim i, limit as Integer
		  if expr.arguments <> Nil then ' Remember that getters will have a Nil arguments array.
		    limit = expr.arguments.Ubound
		    for i = 0 to limit
		      arguments.Append(Evaluate(expr.arguments(i)))
		    next i
		  end if
		  
		  if not invokee isA Invokable then
		    #pragma BreakOnExceptions False
		    raise new RuntimeError(expr.paren, "Only functions and classes can be invoked.")
		  end if
		  
		  ' Any object that can be called like a function will implement the Invokable interface...
		  dim func as Invokable = Invokable(invokee)
		  
		  ' Check that the number of arguments passed to this invokable object is correct.
		  if not CorrectArity(func, arguments.Ubound + 1) then
		    raise new RuntimeError(expr.paren, "Incorrect number of arguments passed.")
		  end if
		  
		  return func.Invoke(self, arguments, expr.paren)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitLogicalExpr(expr as LogicalExpr) As Variant
		  dim left as Variant = Evaluate(expr.left)
		  
		  if expr.operator.type = TokenType.OR_KEYWORD then
		    
		    if IsTruthy(left) then return left
		    
		  else
		    if not IsTruthy(left) then return left
		    
		  end if
		  
		  return Evaluate(expr.right)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitModuleStmt(stmt as ModuleStmt) As Variant
		  dim i, limit as Integer
		  dim func as RooFunction
		  
		  ' Define the module's name in the current environment.
		  self.environment.Define(stmt.name.lexeme, self.nothing)
		  
		  ' Store the current environment and then immediately create a new one that will act as the module's namespace.
		  dim oldEnv as Environment = self.environment
		  self.environment = new Environment(oldEnv)
		  
		  ' Convert any methods in the module to RooFunctions.
		  dim methods as new StringToVariantHashMapMBS(True)
		  limit = stmt.methods.Ubound
		  for i = 0 to limit
		    func = new RooFunction(stmt.methods(i), self.environment, False)
		    methods.Value(stmt.methods(i).name.lexeme) = func
		  next i
		  
		  ' Create a metaclass for this module to enable the use of these methods (which are essentially static).
		  dim metaclass as new RooClass(Nil, Nil, stmt.name.lexeme + " metaclass", methods)
		  
		  ' Convert any sub-module declarations to RooModules within this module's namespace.
		  dim modules() as RooModule
		  limit = stmt.modules.Ubound
		  for i = 0 to limit
		    modules.Append(VisitModuleStmt(stmt.modules(i)))
		  next i
		  
		  ' Convert any class declarations to RooClasses within this module's namespace.
		  dim classes() as RooClass
		  limit = stmt.classes.Ubound
		  for i = 0 to limit
		    classes.Append(VisitClassStmt(stmt.classes(i)))
		  next i
		  
		  ' Convert the passed module statement AST node into its runtime representation (a RooModule).
		  dim m as new RooModule(metaclass, stmt.name.lexeme, modules, classes, methods)
		  
		  ' Store the module object in the variable we previously declared.
		  self.environment.Assign(stmt.name, m)
		  
		  ' Done defining the module. Restore the environment.
		  self.environment = oldEnv
		  
		  return m
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitNothingExpr(expr as NothingExpr) As Variant
		  #pragma Unused expr
		  
		  ' We only need one Nothing object in the runtime.
		  return self.nothing
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitNumberLiteralExpr(expr as NumberLiteralExpr) As Variant
		  return new NumberObject(expr.value)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitQuitStmt(stmt as QuitStmt) As Variant
		  ' The interpreter is visiting a quit statement.
		  
		  #pragma Unused stmt
		  #pragma BreakOnExceptions False
		  
		  raise new QuitReturn
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitRegexLiteralExpr(expr as RegexLiteralExpr) As Variant
		  return new RegexObject(expr)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitReturnStmt(stmt as ReturnStmt) As Variant
		  dim value as Variant
		  
		  if stmt.value <> Nil then value = Evaluate(stmt.value)
		  
		  #pragma BreakOnExceptions Off
		  raise new ReturnException(value)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitSelfExpr(expr as SelfExpr) As Variant
		  return LookupVariable(expr.keyword, expr)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitSetExpr(expr as SetExpr) As Variant
		  ' Evaluate the object we're trying to set the field on.
		  dim obj as Variant = Evaluate(expr.obj)
		  
		  ' Bail if the object is NOT an instance.
		  if not obj isA RooInstance then
		    #pragma BreakOnExceptions False
		    raise new RuntimeError(expr.name, "Only instances have fields.")
		  end if
		  
		  ' Disallow the alteration of fields on native modules and classes.
		  if obj isA RooModule and RooModule(obj).isNative then
		    raise new RuntimeError(expr.operator, "Cannot set values on built-in modules.")
		  elseif obj isA RooClass and RooClass(obj).isNative then
		    raise new RuntimeError(expr.operator, "Cannot set values on built-in classes.")
		  end if
		  
		  ' Evaluate the value that we will assign and set the field.
		  dim value as Variant = Evaluate(expr.value)
		  
		  ' Since simple assignment with `=` is the most common type of set operation, handle it first
		  ' before the select case statement below for a slight performance increase.
		  if expr.operator.type = TokenType.EQUAL then
		    RooInstance(obj).Set(expr.name, value)
		    return value
		  end if
		  
		  ' Get the current value of the requested field as we need to manipulate it.
		  dim currentValue as Variant = RooInstance(obj).fields.Lookup(expr.name.lexeme, Nil)
		  if currentValue = Nil then
		    ' Prohibit compound assignment operators (+=, -=, %=, /=, *=) when the property doesn't exist.
		    #pragma BreakOnExceptions False
		    raise new RuntimeError(expr.operator, "Cannot use the " + Token.TypeToString(expr.operator.type) + _
		    " operator on an undefined class field (" + RooInstance(obj).ToText + "." + expr.name.lexeme + ").")
		  end if
		  
		  select case expr.operator.type
		  case TokenType.PLUS_EQUAL ' currentValue += value
		    ' Arithmetic addition?
		    if currentValue isA NumberObject and value isA NumberObject then
		      value = new NumberObject(NumberObject(currentValue).value + NumberObject(value).value)
		    elseif currentValue isA Textable and value isA Textable then ' Text concatenation?
		      value = new TextObject(Textable(currentValue).ToText + Textable(value).ToText)
		    else
		      raise new RuntimeError(expr.operator, "Unable to convert operands to a text representation.")
		    end if
		    
		  case TokenType.MINUS_EQUAL
		    CheckNumberOperands(expr.operator, currentValue, value)
		    value = new NumberObject(NumberObject(currentValue).value - NumberObject(value).value)
		    
		  case TokenType.PERCENT_EQUAL ' currentValue %= value
		    CheckNumberOperands(expr.operator, currentValue, value)
		    if NumberObject(value).value = 0 then raise new RuntimeError(expr.operator, "Modulo with zero")
		    value = new NumberObject(NumberObject(currentValue).value Mod NumberObject(value).value)
		    
		  case TokenType.SLASH_EQUAL ' currentValue /= value
		    CheckNumberOperands(expr.operator, currentValue, value)
		    value = new NumberObject(NumberObject(currentValue).value / NumberObject(value).value)
		    
		  case TokenType.STAR_EQUAL ' currentValue *= value
		    CheckNumberOperands(expr.operator, currentValue, value)
		    value = new NumberObject(NumberObject(currentValue).value * NumberObject(value).value)
		    
		  end select
		  
		  ' Actually do the assignment for the operators other than EQUAL (which has already returned).
		  RooInstance(obj).Set(expr.name, value)
		  
		  return value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitSuperExpr(expr as SuperExpr) As Variant
		  dim distance as Integer = locals.Lookup(expr, -1)
		  if distance = -1 then
		    raise new RuntimeError(expr.keyword, "An error occurred in the Interpreter.VisitSuperExpr method.")
		  end if
		  
		  dim superclass as RooClass = environment.GetAt(distance, "super")
		  
		  ' "self" is always one level nearer than "super"'s environment.
		  dim obj as RooInstance = environment.GetAt(distance - 1, "self")
		  
		  dim method as RooFunction = superclass.FindMethod(obj, expr.method.lexeme)
		  if method = Nil then
		    raise new RuntimeError(expr.method, "Undefined property `" + expr.method.lexeme + "`.")
		  else
		    return method
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitTernaryExpr(expr as TernaryExpr) As Variant
		  ' The interpreter is visiting a ternary operation node.
		  ' E.g: `var a = b > c ? True : False`
		  
		  dim condition as Variant = Evaluate(expr.expression)
		  
		  if IsTruthy(condition) then
		    return Evaluate(expr.thenBranch)
		  else
		    return Evaluate(expr.elseBranch)
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitTextLiteralExpr(expr as TextLiteralExpr) As Variant
		  return new TextObject(expr.value)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitUnaryExpr(expr as UnaryExpr) As Variant
		  ' Evaulate the expression.
		  dim right as Variant = Evaluate(expr.right)
		  
		  select case expr.operator.type
		  case TokenType.BANG, TokenType.NOT_KEYWORD ' Boolean negation.
		    return new BooleanObject(not IsTruthy(right))
		    
		  case TokenType.MINUS ' Arithmetic negation.
		    CheckNumberOperands(expr.operator, right)
		    return new NumberObject(-NumberObject(right).value)
		  end select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitVariableExpr(expr as VariableExpr) As Variant
		  return LookupVariable(expr.name, expr)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitVarStmt(stmt as VarStmt) As Variant
		  ' If not initialised, new variables are set to Nothing by default.
		  dim value as Variant = self.nothing
		  
		  if stmt.initialiser <> Nil then value = Evaluate(stmt.initialiser)
		  
		  self.environment.Define(stmt.name.lexeme, value)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitWhileStmt(stmt as WhileStmt) As Variant
		  try
		    
		    while IsTruthy(Evaluate(stmt.condition)) and not forceKill
		      Execute(stmt.body)
		    wend
		    
		  catch b as BreakReturn
		    
		    ' Break statement. Simply exit the while loop.
		    return self.nothing
		    
		  end try
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Input(prompt as String) As String
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Print(what as String)
	#tag EndHook


	#tag Note, Name = Native Functions
		Native functions are functions that are built into the Roo programming language.
		To create a new native function, create a new class that implements the following interfaces:
		- Invokable
		- Textable
		You should then add it to the interpreter within the Interpreter.SetupNativeFunctions() method.
		
	#tag EndNote


	#tag Property, Flags = &h0
		#tag Note
			Used to store arbitrary data for the interpreter.
			Only of use to Xojo developers.
		#tag EndNote
		Custom As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Tracks the current environment. Changes as the interpreter enters and exits local scopes.
		#tag EndNote
		Private Environment As Environment
	#tag EndProperty

	#tag Property, Flags = &h0
		ForceKill As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			Holds a fixed reference to the outermost global environment.
		#tag EndNote
		Globals As Environment
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			This hash map stores resolution information passed to the Interpreter from the Resolver during
			static analysis.
			Key = Expr
			Value = Integer (depth)
		#tag EndNote
		Private Locals As VariantToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h0
		Nothing As Variant
	#tag EndProperty


	#tag Constant, Name = PI, Type = Double, Dynamic = False, Default = \"3.141593", Scope = Public
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
	#tag EndViewBehavior
End Class
#tag EndClass
