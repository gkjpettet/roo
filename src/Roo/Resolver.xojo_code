#tag Class
Protected Class Resolver
Implements ExprVisitor,StmtVisitor
	#tag Method, Flags = &h21
		Private Sub BeginScope()
		  scopes.Append(new StringToVariantHashMapMBS(True)) ' <Key: String, Value: Boolean>
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(interpreter as Interpreter)
		  self.interpreter = interpreter
		  redim self.scopes(-1)
		  currentFunction = FunctionType.None
		  currentClass = ClassType.None
		  loopLevel = 0
		  hasError = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DeclareSymbol(name as Token)
		  ' Add this variable to the innermost scope so that it shadows any outer one and so that we know the 
		  ' variable exists. We mark it as “not ready yet” by binding its name to False. Each value in the 
		  ' StringToVariantHashMapMBS translates to “is finished being initialized” (True/False).
		  
		  if scopes.Ubound < 0 then return
		  
		  ' Make sure the user doesn't try to redeclare a variable within the current scope.
		  if scopes(scopes.Ubound).HasKey(name.lexeme) then
		    hasError = True
		    raise new ResolverError(name, "A variable named `" + name.lexeme + "` has already been declared in this scope.")
		  end if
		  
		  scopes(scopes.Ubound).Value(name.lexeme) = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineSymbol(name as Token)
		  ' Done defining the symbol.
		  
		  if scopes.Ubound < 0 then return
		  
		  scopes(scopes.Ubound).Value(name.lexeme) = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EndScope()
		  call scopes.Pop()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Resolve(expr as Expr)
		  call expr.Accept(self)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Resolve(statements() as Stmt)
		  ' Resolves each statement in the passed array of Stmts.
		  
		  dim i, limit as Integer
		  
		  limit = statements.Ubound
		  for i = 0 to limit
		    Resolve(statements(i))
		  next i
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Resolve(stmt as Stmt)
		  call stmt.Accept(self)
		  
		  exception err as NilObjectException
		    hasError = True
		    raise new ResolverError(new Token(TokenType.ERROR), "NilObjectException in Resolver.Resolve(stmt as Stmt).")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ResolveFunction(func as FunctionStmt, type as FunctionType)
		  ' Resolve a function's body.
		  ' We do this separately from its definition since we also use it for resolving Roo methods in classes. 
		  ' It creates a new scope for the body and then binds variables for each of the function’s parameters.
		  
		  dim i, limit as Integer
		  
		  ' We need to track if the current code is within a function or not.
		  dim enclosingFunction as FunctionType = currentFunction
		  currentFunction = type
		  
		  BeginScope()
		  
		  if func.parameters <> Nil then ' (Remember, getters will have a Nil parameter list).
		    limit = func.parameters.Ubound
		    for i = 0 to limit
		      DeclareSymbol(func.parameters(i))
		      DefineSymbol(func.parameters(i))
		    next i
		  end if
		  
		  Resolve(func.body)
		  
		  EndScope()
		  
		  ' Restore the current function.
		  currentFunction = enclosingFunction
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ResolveLocal(expr as Expr, name as Token)
		  ' Start at the innermost scope and work outwards, looking in each scope map for a matching name. 
		  ' If we find the variable, we tell the interpreter it has been resolved, passing in the number of
		  ' scopes between the current innermost scope and the scope where the variable was found. 
		  ' So, if the variable was found in the current scope, it passes in 0. If it’s in the immediately 
		  ' enclosing scope it passes in 1, etc
		  
		  dim top as Integer = scopes.Ubound
		  dim i as Integer
		  
		  for i = top downTo 0
		    if scopes(i).HasKey(name.lexeme) then
		      interpreter.Resolve(expr, top - i)
		      return
		    end if
		  next i
		  
		  ' Not found. Assume the variable is global in scope.
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitArrayAssignExpr(expr as ArrayAssignExpr) As Variant
		  ' Resolve the expression for the assigned value in case it also contains references to other variables.
		  Resolve(expr.value)
		  
		  ' Now resolve the variable that’s being assigned to.
		  ResolveLocal(expr, expr.name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitArrayExpr(expr as ArrayExpr) As Variant
		  ResolveLocal(expr, expr.name)
		  
		  Resolve(expr.index)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitArrayLiteralExpr(expr as ArrayLiteralExpr) As Variant
		  ' Resolve each element of this array.
		  
		  dim i, limit as Integer
		  limit = expr.elements.Ubound
		  for i = 0 to limit
		    Resolve(expr.elements(i))
		  next i
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitAssignExpr(expr as AssignExpr) As Variant
		  ' Resolve the expression for the assigned value in case it also contains references to other variables.
		  ' Then we use resolveLocal() to resolve the variable that’s being assigned to.
		  
		  Resolve(expr.value)
		  ResolveLocal(expr, expr.name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBinaryExpr(expr as BinaryExpr) As Variant
		  Resolve(expr.left)
		  Resolve(expr.right)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBlockStmt(stmt as BlockStmt) As Variant
		  ' Begins a new scope, traverses into the statements inside the block, and then discards the scope. 
		  
		  BeginScope()
		  Resolve(stmt.statements)
		  EndScope()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBooleanLiteralExpr(expr as BooleanLiteralExpr) As Variant
		  ' As literal expressions don't mention variables and don't contain any subexpressions there's nothing to do.
		  #pragma Unused expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBreakStmt(stmt as Roo.Statements.BreakStmt) As Variant
		  #pragma BreakOnExceptions False
		  
		  ' Make sure that `break` is only called from within a loop. Doesn't make sense otherwise.
		  if loopLevel <= 0 then
		    hasError = True
		    raise new ResolverError(stmt.keyword, "Cannot break when not in a loop.")
		  end if
		  
		  ' Resolve the optional break condition.
		  if stmt.condition <> Nil then Resolve(stmt.condition)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitClassStmt(stmt as ClassStmt) As Variant
		  dim i, limit as Integer
		  
		  DeclareSymbol(stmt.name)
		  DefineSymbol(stmt.name)
		  
		  ' We need to track if the current code is within a class or not. This will help us prevent 
		  ' erroneous uses of the "self" keyword outside of a class.
		  dim enclosingClass as ClassType = currentClass
		  currentClass = ClassType.Klass
		  
		  ' Handle this classes' (optional) superclass.
		  if stmt.superclass <> Nil then
		    currentClass = ClassType.Subclass
		    Resolve(stmt.superclass)
		    ' Create a new scope surrounding all of the superclass's methods. 
		    ' In this scope, we define the name “super”. 
		    BeginScope()
		    scopes(scopes.Ubound).Value("super") = True
		  end if
		  
		  ' Static methods.
		  limit = stmt.staticMethods.Ubound
		  for i = 0 to limit
		    BeginScope()
		    scopes(scopes.UBound).Value("self") = True
		    ResolveFunction(stmt.staticMethods(i), FunctionType.Method)
		    EndScope()
		  next i
		  
		  ' Before we start resolving the instance method bodies, we push a new scope and define "self" in it as if it 
		  ' were a variable.
		  BeginScope()
		  scopes(scopes.UBound).Value("self") = True
		  
		  ' Instance methods.
		  limit = stmt.methods.Ubound
		  for i = 0 to limit
		    if StrComp(stmt.methods(i).name.lexeme, "init", 0) = 0 then
		      ResolveFunction(stmt.methods(i), FunctionType.Initialiser)
		    else
		      ResolveFunction(stmt.methods(i), FunctionType.Method)
		    end if
		  next i
		  
		  EndScope()
		  
		  ' If a superclass was defined then we need to end the scope we created above that defined "super".
		  if stmt.superclass <> Nil then EndScope()
		  
		  currentClass = enclosingClass
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitExpressionStmt(stmt as Stmt) As Variant
		  Resolve(stmt.expression)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitFunctionStmt(stmt as FunctionStmt) As Variant
		  ' Like we do with variables, we declare and define the name of the function in the current scope. 
		  ' Unlike variables, we define the name eagerly, before resolving the function’s body. 
		  ' This lets a function recursively refer to itself inside its own body.
		  
		  DeclareSymbol(stmt.name)
		  DefineSymbol(stmt.name)
		  
		  ResolveFunction(stmt, FunctionType.Func)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitGetExpr(expr as GetExpr) As Variant
		  ' Since properties are looked up dynamically, they don’t get resolved. 
		  ' Therefore we only recurse into the expression to the left of the dot. 
		  ' The actual property access happens in the interpreter.
		  Resolve(expr.obj)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitGroupingExpr(expr as GroupingExpr) As Variant
		  Resolve(expr.expression)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function visitHashAssignExpr(expr as HashAssignExpr) As Variant
		  ' Resolve the expression for the assigned value in case it also contains references to other variables.
		  Resolve(expr.value)
		  
		  ' Now resolve the variable that’s being assigned to.
		  ResolveLocal(expr, expr.name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitHashExpr(expr as HashExpr) As Variant
		  ResolveLocal(expr, expr.name)
		  
		  Resolve(expr.key)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitHashLiteralExpr(expr as HashLiteralExpr) As Variant
		  ' Resolve each key and value in this hash's backing map.
		  
		  dim i as VariantToVariantHashMapIteratorMBS = expr.map.first
		  dim e as VariantToVariantHashMapIteratorMBS = expr.map.last
		  
		  while i.isNotEqual(e)
		    Resolve(Expr(i.Key))
		    Resolve(Expr(i.Value))
		    i.MoveNext()
		  wend
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitIfStmt(stmt as IfStmt) As Variant
		  Resolve(stmt.condition)
		  Resolve(stmt.thenBranch)
		  if stmt.elseBranch <> Nil then Resolve(stmt.elseBranch)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitInvokeExpr(expr as InvokeExpr) As Variant
		  Resolve(expr.invokee)
		  
		  for each argument as Expr in expr.arguments
		    Resolve(argument)
		  next argument
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitLogicalExpr(expr as LogicalExpr) As Variant
		  Resolve(expr.left)
		  Resolve(expr.right)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitModuleStmt(stmt as ModuleStmt) As Variant
		  dim i, limit as Integer
		  
		  DeclareSymbol(stmt.name)
		  DefineSymbol(stmt.name)
		  
		  dim enclosingClass as ClassType = currentClass
		  currentClass = ClassType.ModuleType
		  
		  ' Resolve classes
		  limit = stmt.classes.Ubound
		  for i = 0 to limit
		    call VisitClassStmt(stmt.classes(i))
		  next i
		  
		  ' Before we start resolving the method bodies we start a new scope and define `self` as if it were 
		  ' a new variable.
		  BeginScope()
		  scopes(scopes.Ubound).Value("self") = True
		  
		  ' Resolve methods.
		  limit = stmt.methods.Ubound
		  for i = 0 to limit
		    BeginScope()
		    scopes(scopes.Ubound).Value("self") = True
		    ResolveFunction(stmt.methods(i), FunctionType.METHOD) 
		    EndScope()
		  next i
		  
		  EndScope()
		  
		  currentClass = enclosingClass
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitNothingExpr(expr as NothingExpr) As Variant
		  ' As literal expressions don't mention variables and don't contain any subexpressions there's nothing to do.
		  #pragma Unused expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitNumberLiteralExpr(expr as NumberLiteralExpr) As Variant
		  ' As literal expressions don't mention variables and don't contain any subexpressions there's nothing to do.
		  #pragma Unused expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitQuitStmt(stmt as QuitStmt) As Variant
		  #pragma Unused stmt
		  
		  ' Nothing to resolve.
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitRegexLiteralExpr(expr as RegexLiteralExpr) As Variant
		  ' As literal expressions don't mention variables and don't contain any subexpressions there's nothing to do.
		  #pragma unused expr
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitReturnStmt(stmt as ReturnStmt) As Variant
		  ' Check that this return statement is being called from within a function and not from top level code.
		  if currentFunction = FunctionType.None then
		    hasError = True
		    raise new ResolverError(stmt.keyword, "Cannot return from top-level code.")
		  end if
		  
		  #pragma BreakOnExceptions True
		  
		  ' Resolve the return value (if any).
		  if stmt.value <> Nil and not stmt.value isA NothingExpr then
		    if currentFunction = FunctionType.Initialiser then
		      hasError = True
		      raise new ResolverError(stmt.keyword, "Cannot return a value from an initialiser.")
		    end if
		    Resolve(stmt.value)
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function visitSelfExpr(expr as SelfExpr) As Variant
		  if currentClass = ClassType.None then
		    hasError = True
		    raise new ResolverError(expr.keyword, "Cannot use `self` outside of a class.")
		  end if
		  
		  ResolveLocal(expr, expr.keyword)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitSetExpr(expr as SetExpr) As Variant
		  ' Recurse into the two subexpressions of this SetExpr, the object whose property is being set 
		  ' and the value it’s being set to and resolve them.
		  
		  Resolve(expr.value)
		  Resolve(expr.obj)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitSuperExpr(expr as SuperExpr) As Variant
		  ' Catch cases when the user is trying to use `super` outside of a class or in a class with no superclass.
		  if currentClass = ClassType.None then
		    hasError = True
		    raise new ResolverError(expr.keyword, "Cannot use `super` outside of a class. ")
		  elseif currentClass <> ClassType.Subclass then
		    hasError = True
		    raise new ResolverError(expr.keyword, "Cannot use `super` in a class with no superclass.")
		  end if
		  
		  ' We resolve the super token exactly as if it were a variable. 
		  ' We'll store the number of hops along the environment chain that the interpreter needs to walk 
		  ' to find the environment where the superclass is stored.
		  ResolveLocal(expr, expr.keyword)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitTernaryExpr(expr as TernaryExpr) As Variant
		  Resolve(expr.expression)
		  Resolve(expr.elseBranch)
		  Resolve(expr.thenBranch)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitTextLiteralExpr(expr as TextLiteralExpr) As Variant
		  ' As literal expressions don't mention variables and don't contain any subexpressions there's nothing to do.
		  #pragma Unused expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitUnaryExpr(expr as UnaryExpr) As Variant
		  Resolve(expr.right)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitVariableExpr(expr as VariableExpr) As Variant
		  ' Check to see if the variable is being accessed inside its own initializer. 
		  ' This is where the values in the scope map come into play. If the variable exists in the current scope 
		  ' but its value is False, that means we have declared it but not yet defined it. We report that error.
		  
		  if scopes.Ubound >= 0 and scopes(scopes.Ubound).HasKey(expr.name.lexeme) and _
		    scopes(scopes.Ubound).Value(expr.name.lexeme) = False then
		    hasError = True
		    raise new ResolverError(expr.name, "Cannot read local variable in its own initialiser.")
		  end if
		  
		  ' Let's actually resolve the variable.
		  ResolveLocal(expr, expr.name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitVarStmt(stmt as VarStmt) As Variant
		  DeclareSymbol(stmt.name)
		  
		  if not stmt.initialiser isA NothingExpr and stmt.initialiser <> Nil then Resolve(stmt.initialiser)
		  
		  DefineSymbol(stmt.name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitWhileStmt(stmt as WhileStmt) As Variant
		  loopLevel = loopLevel + 1
		  
		  ' Resolve any symbols within the while statement's condition and its body.
		  Resolve(stmt.condition)
		  Resolve(stmt.body)
		  
		  loopLevel = loopLevel - 1
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private currentClass As ClassType
	#tag EndProperty

	#tag Property, Flags = &h21
		Private currentFunction As FunctionType
	#tag EndProperty

	#tag Property, Flags = &h0
		hasError As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			A reference to the interpreter that this resolver works for.
		#tag EndNote
		Private interpreter As Interpreter
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			If the resolver is not currently within a loop then this is 0. For each loop that is entered we increment.
		#tag EndNote
		Private loopLevel As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Keeps track of the stack of scopes currently in scope.
			Each element in the stack is a StringToVariantHashMapMBS representing a single block scope.
			String key = variable name.
			Variant value = Boolean. True means the variable is finished being initialised.
		#tag EndNote
		Private scopes() As StringToVariantHashMapMBS
	#tag EndProperty


	#tag Enum, Name = ClassType, Type = Integer, Flags = &h0
		None
		  Klass
		  ModuleType
		Subclass
	#tag EndEnum

	#tag Enum, Name = FunctionType, Type = Integer, Flags = &h0
		None
		  Func
		  Initialiser
		Method
	#tag EndEnum


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
			Name="hasError"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
