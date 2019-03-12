#tag Class
Protected Class RooAnalyser
Implements RooExprVisitor, RooStmtVisitor
	#tag Method, Flags = &h0
		Sub Analyse(expr As RooExpr)
		  // Analyse this expression.
		  Call expr.Accept(Self)
		  
		  Exception err As NilObjectException
		    HasError = True
		    Error(New RooToken(Roo.TokenType.ERROR), "NilObjectException in RooAnalyser.Analyse(expression)")
		  Exception err As RooAnalyserError
		    HasError = True
		    Error(err.Token, err.Message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Analyse(statements() As RooStmt)
		  // Analyse each statement individually.
		  
		  Dim i, limit As Integer
		  
		  limit = statements.Ubound
		  For i = 0 To limit
		    Analyse(statements(i))
		    If HasError Then Return
		  Next i
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Analyse(statement As RooStmt)
		  // Analyse this statement.
		  Call statement.Accept(Self)
		  
		  Exception err As NilObjectException
		    HasError = True
		    Error(New RooToken(Roo.TokenType.ERROR), "NilObjectException in RooAnalyser.Analyse(statement)")
		  Exception err As RooAnalyserError
		    HasError = True
		    Error(err.Token, err.Message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AnalyseFunction(func As RooFunctionStmt, type As RooAnalyser.FunctionType)
		  // Resolve a function's body.
		  // We do this separately from its definition since we also use it for resolving Roo methods in classes. 
		  // It creates a new scope for the body and then binds variables for each of the function’s parameters.
		  
		  Dim i, limit As Integer
		  
		  // We need to track if the current code is within a function or not.
		  Dim enclosingFunction As RooAnalyser.FunctionType = CurrentFunction
		  CurrentFunction = type
		  
		  BeginScope
		  
		  If func.Parameters <> Nil Then // Remember, getters will have a Nil parameter list.
		    limit = func.Parameters.Ubound
		    For i = 0 To limit
		      DeclareSymbol(func.Parameters(i))
		      DefineSymbol(func.Parameters(i))
		    Next i
		  End If
		  
		  Analyse(func.Body)
		  
		  EndScope
		  
		  // Restore the current function.
		  CurrentFunction = enclosingFunction
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AnalyseLocal(expr As RooExpr, name As RooToken)
		  // Start at the innermost scope and work outwards, looking in each scope for a matching name. 
		  // If we find the variable, we tell the interpreter that it's has been resolved, passing in 
		  // the number of scopes between the current innermost scope and the scope where the variable was found. 
		  // So, if the variable was found in the current scope, it passes 0 to the interpreter. 
		  // If it’s in the immediately enclosing scope it passes it 1, etc.
		  
		  Dim top As Integer = scopes.Ubound
		  Dim i As Integer
		  
		  For i = top DownTo 0
		    If Scopes(i).HasKey(name.Lexeme) Then
		      interpreter.Resolve(expr, top - i)
		      Return
		    End If
		  Next i
		  
		  // Not found. Assume the variable is global in scope.
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BeginScope()
		  // Create a new scope (represented by a Dictionary) by pushing it to our scope stack.
		  Scopes.Append(New Dictionary) // <Key: String, Value: Boolean>
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(interpreter As RooInterpreter)
		  Self.Interpreter = interpreter
		  Redim Self.Scopes(-1)
		  Self.CurrentFunction = FunctionType.None
		  Self.CurrentClass = ClassType.None
		  Self.LoopLevel = 0
		  Self.IfLevel = 0
		  Self.HasError = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DeclareSymbol(name As RooToken)
		  // Add this variable to the innermost scope so that it shadows any outer one and so that we know the 
		  // variable exists. We mark it as "not ready yet" by binding its name to False. Each value in the 
		  // Scope Dictionary translates to "is finished being initialized" (True/False).
		  
		  If Scopes.Ubound < 0 Then Return
		  
		  // Make sure the user doesn't try to re-declare a variable within the current scope.
		  If Scopes(Scopes.Ubound).HasKey(name.Lexeme) Then
		    HasError = True
		    Raise New RooAnalyserError(name, "A variable named `" + name.Lexeme + _
		    "` has already been declared in the current scope.")
		  End If
		  
		  Scopes(Scopes.Ubound).Value(name.Lexeme) = False
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DefineSymbol(name As RooToken)
		  // Done defining the symbol.
		  
		  If Scopes.Ubound < 0 Then Return
		  
		  Scopes(Scopes.Ubound).Value(name.Lexeme) = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EndScope()
		  // End this scope by removing it from our scope stack.
		  Call Scopes.Pop
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitArrayAssignExpr(expr As RooArrayAssignExpr) As Variant
		  // Analyse the expression for the assigned value in case it contains references to other variables.
		  Analyse(expr.Value)
		  
		  // Now resolve the variable that’s being assigned to.
		  AnalyseLocal(expr, expr.Name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitArrayExpr(expr As RooArrayExpr) As Variant
		  AnalyseLocal(expr, expr.Name)
		  Analyse(expr.Index)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitArrayLiteralExpr(expr As RooArrayLiteralExpr) As Variant
		  // Resolve each element of this array.
		  
		  Dim i, limit As Integer
		  limit = expr.Elements.Ubound
		  For i = 0 To limit
		    Analyse(expr.Elements(i))
		  Next i
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitAssignExpr(expr As RooAssignExpr) As Variant
		  // Analyse the expression for the assigned value in case it contains references to other variables.
		  // Then use AnalyseLocal() to analyse the variable that’s being assigned to.
		  
		  Analyse(expr.Value)
		  AnalyseLocal(expr, expr.Name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBinaryExpr(expr As RooBinaryExpr) As Variant
		  // Analyse both sides of the binary operation.
		  
		  Analyse(expr.Left)
		  Analyse(expr.Right)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBitwiseExpr(expr As RooBitwiseExpr) As Variant
		  // Analyse both sides of the bitwise operation.
		  
		  Analyse(expr.Left)
		  Analyse(expr.Right)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBlockStmt(statement As RooBlockStmt) As Variant
		  // Begins a new scope, traverses into the statements inside the block, and then discards the scope. 
		  
		  BeginScope
		  Analyse(statement.Statements)
		  EndScope
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBooleanLiteralExpr(expr As RooBooleanLiteralExpr) As Variant
		  // As literal expressions don't mention variables and don't contain any subexpressions 
		  // there's nothing to do.
		  #Pragma Unused expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitBreakStmt(statement As RooBreakStmt) As Variant
		  #Pragma BreakOnExceptions False
		  
		  // Make sure that the`break` keyword is only called from within a loop. It doesn't make sense otherwise.
		  If LoopLevel <= 0 Then
		    HasError = True
		    Raise New RooAnalyserError(statement.Keyword, "Cannot break when not in a loop.")
		  End If
		  
		  // Analyse the optional break condition.
		  If statement.Condition <> Nil Then Analyse(statement.Condition)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitClassStmt(classStmt As RooClassStmt) As Variant
		  Dim i, limit As Integer
		  
		  DeclareSymbol(classStmt.Name)
		  DefineSymbol(classStmt.Name)
		  
		  // We need to track if the current code is within a class or not. This will help us prevent 
		  // erroneous uses of the `self` keyword outside of a class.
		  Dim enclosingClass as ClassType = CurrentClass
		  CurrentClass = ClassType.Klass
		  
		  // Handle this class' (optional) superclass.
		  If classStmt.Superclass <> Nil Then
		    CurrentClass = ClassType.Subclass
		    Analyse(classStmt.Superclass)
		    // Create a new scope surrounding all of the superclass' methods. 
		    // In this scope, we define the name "super". 
		    BeginScope
		    Scopes(Scopes.Ubound).Value("super") = True
		  End If
		  
		  // Static methods.
		  limit = classStmt.StaticMethods.Ubound
		  For i = 0 To limit
		    BeginScope
		    Scopes(Scopes.UBound).Value("self") = True
		    AnalyseFunction(classStmt.staticMethods(i), FunctionType.Method)
		    EndScope
		  Next i
		  
		  // Before we start resolving the instance method bodies, we push a new scope and 
		  // define "self" in it as if it were a variable.
		  BeginScope
		  Scopes(Scopes.UBound).Value("self") = True
		  
		  // Instance methods.
		  limit = classStmt.Methods.Ubound
		  For i = 0 To limit
		    If classStmt.Methods(i).Name.Lexeme = "init" Then
		      AnalyseFunction(classStmt.Methods(i), FunctionType.Initialiser)
		    Else
		      AnalyseFunction(classStmt.Methods(i), FunctionType.Method)
		    End If
		  Next i
		  
		  EndScope
		  
		  // If a superclass was defined then we need to end the scope we created above that defined "super".
		  If classStmt.Superclass <> Nil Then EndScope
		  
		  CurrentClass = enclosingClass
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitExitStmt(statement As RooExitStmt) As Variant
		  #Pragma BreakOnExceptions False
		  
		  // Make sure that the `exit` keyword is only called from within an `if` construct. 
		  // It doesn't make sense otherwise.
		  If IfLevel <= 0 Then
		    HasError = True
		    Raise New RooAnalyserError(statement.Keyword, "Cannot break when not in an `if` construct.")
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitExpressionStmt(statement As RooStmt) As Variant
		  Analyse(statement.Expression)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitFunctionStmt(functionStatement As RooFunctionStmt) As Variant
		  // Like we do with variables, we declare and define the name of the function in the current scope. 
		  // Unlike variables, we define the name eagerly, before resolving the function’s body. 
		  // This lets a function recursively refer to itself inside its own body.
		  
		  DeclareSymbol(functionStatement.Name)
		  DefineSymbol(functionStatement.Name)
		  
		  AnalyseFunction(functionStatement, FunctionType.Func)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitGetExpr(expr As RooGetExpr) As Variant
		  // Since properties are looked up dynamically, they don’t get resolved. 
		  // Therefore we only recurse into the expression to the left of the dot. 
		  // The actual property access happens in the interpreter.
		  Analyse(expr.Obj)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitGroupingExpr(expr As RooGroupingExpr) As Variant
		  Analyse(expr.Expression)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitHashAssignExpr(expr As RooHashAssignExpr) As Variant
		  // Analyse the expression for the assigned value in case it also contains references to other variables.
		  Analyse(expr.Value)
		  
		  // Now analyse the variable that’s being assigned to.
		  AnalyseLocal(expr, expr.Name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitHashExpr(expr As RooHashExpr) As Variant
		  AnalyseLocal(expr, expr.Name)
		  Analyse(expr.Key)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitHashLiteralExpr(expr As RooHashLiteralExpr) As Variant
		  // Resolve each key and value in this hash's backing Dictionary.
		  
		  For Each entry As Xojo.Core.DictionaryEntry in expr.Dict
		    Analyse(RooExpr(entry.Key))
		    Analyse(RooExpr(expr.Dict.Value(entry.Key)))
		  Next entry
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitIfStmt(ifStatement As RooIfStmt) As Variant
		  IfLevel = IfLevel + 1
		  
		  Analyse(ifStatement.Condition)
		  Analyse(ifStatement.ThenBranch)
		  For Each orStatement As RooOrStmt In ifStatement.OrStatements
		    Analyse(orStatement)
		  Next orStatement
		  If ifStatement.ElseBranch <> Nil Then Analyse(ifStatement.ElseBranch)
		  
		  IfLevel = IfLevel - 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitInvokeExpr(expr As RooInvokeExpr) As Variant
		  Analyse(expr.Invokee)
		  
		  For Each argument As RooExpr In expr.Arguments
		    Analyse(argument)
		  Next argument
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitLogicalExpr(expr As RooLogicalExpr) As Variant
		  Analyse(expr.Left)
		  Analyse(expr.Right)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitModuleStmt(moduleStatement As RooModuleStmt) As Variant
		  Dim i, limit As Integer
		  
		  DeclareSymbol(moduleStatement.Name)
		  DefineSymbol(moduleStatement.Name)
		  
		  Dim enclosingClass As ClassType = CurrentClass
		  currentClass = ClassType.ModuleType
		  
		  // Analyse any classes in this module.
		  limit = moduleStatement.Classes.Ubound
		  For i = 0 To limit
		    Call VisitClassStmt(moduleStatement.Classes(i))
		  Next i
		  
		  // Before we start analysing the method bodies we start a new scope and define `self` as if it were 
		  // a new variable.
		  BeginScope
		  Scopes(Scopes.Ubound).Value("self") = True
		  
		  // Analyse methods.
		  limit = moduleStatement.Methods.Ubound
		  For i = 0 To limit
		    BeginScope
		    Scopes(Scopes.Ubound).Value("self") = True
		    AnalyseFunction(moduleStatement.Methods(i), FunctionType.METHOD) 
		    EndScope
		  Next i
		  
		  EndScope
		  
		  CurrentClass = enclosingClass
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitNothingExpr(expr As RooNothingExpr) As Variant
		  // As literal expressions don't mention variables and don't contain any subexpressions 
		  // there's nothing to do.
		  #Pragma Unused expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitNumberLiteralExpr(expr As RooNumberLiteralExpr) As Variant
		  // As literal expressions don't mention variables and don't contain any subexpressions 
		  // there's nothing to do.
		  #Pragma Unused expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitOrStmt(orStmt As RooOrStmt) As Variant
		  IfLevel = IfLevel + 1
		  
		  Analyse(orStmt.Condition)
		  Analyse(orStmt.ThenBranch)
		  
		  IfLevel = IfLevel - 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitPassStmt(stmt As RooPassStmt) As Variant
		  // Nothing to do. The `pass` statement is a no-op.
		  #Pragma Unused stmt
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitQuitStmt(stmt As RooQuitStmt) As Variant
		  // Nothing to do.
		  #Pragma Unused stmt
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitReturnStmt(returnStatement As RooReturnStmt) As Variant
		  // Check that this return statement is being called from within a function and not from top level code.
		  If CurrentFunction = FunctionType.None Then
		    HasError = True
		    Raise New RooAnalyserError(returnStatement.keyword, "Cannot return from top-level code.")
		  end if
		  
		  #Pragma BreakOnExceptions True
		  
		  // Analyse the return value (if any).
		  If returnStatement.Value <> Nil And Not returnStatement.Value IsA RooNothingExpr Then
		    If CurrentFunction = FunctionType.Initialiser Then
		      HasError = True
		      Raise New RooAnalyserError(returnStatement.Keyword, "Cannot return a value from an initialiser.")
		    End If
		    Analyse(returnStatement.Value)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitSelfExpr(selfExpression As RooSelfExpr) As Variant
		  If CurrentClass = ClassType.None Then
		    HasError = True
		    Raise New RooAnalyserError(selfExpression.Keyword, "Cannot use `self` outside of a class.")
		  End If
		  
		  AnalyseLocal(selfExpression, selfExpression.Keyword)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitSetExpr(expr As RooSetExpr) As Variant
		  // Recurse into the two subexpressions of this set expression (the object whose property is being set 
		  // and the value it’s being set to) and analyse them.
		  
		  Analyse(expr.Value)
		  Analyse(expr.Obj)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitSuperExpr(superExpression As RooSuperExpr) As Variant
		  // Catch cases when the user is trying to use `super` outside of a class or in a 
		  // class with no superclass.
		  If CurrentClass = ClassType.None Then
		    HasError = True
		    Raise New RooAnalyserError(superExpression.Keyword, "Cannot use `super` outside of a class. ")
		  ElseIf CurrentClass <> ClassType.Subclass Then
		    HasError = True
		    Raise New RooAnalyserError(superExpression.Keyword, "Cannot use `super` in a class with no superclass.")
		  End If
		  
		  // We analyse the `super` token exactly as if it were a variable. 
		  // We'll store the number of hops along the environment chain that the interpreter needs to traverse 
		  // to find the environment where the superclass is stored.
		  AnalyseLocal(superExpression, superExpression.Keyword)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitTernaryExpr(ternaryExpression As RooTernaryExpr) As Variant
		  Analyse(ternaryExpression.Expression)
		  Analyse(ternaryExpression.ElseBranch)
		  Analyse(ternaryExpression.ThenBranch)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitTextLiteralExpr(expr As RooTextLiteralExpr) As Variant
		  // As literal expressions don't mention variables and don't contain any subexpressions 
		  // there's nothing to do.
		  #Pragma Unused expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitUnaryExpr(unaryExpression As RooUnaryExpr) As Variant
		  Analyse(unaryExpression.Right)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitVariableExpr(expr As RooVariableExpr) As Variant
		  // Check to see if the variable is being accessed inside its own initializer. 
		  // This is where the values in the scope map come into play. If the variable exists in the 
		  // current scope but its value is False, that means we have declared it but not yet defined it. 
		  // We report that error.
		  
		  If Scopes.Ubound >= 0 And Scopes(Scopes.Ubound).HasKey(expr.Name.Lexeme) And _
		    Scopes(Scopes.Ubound).Value(expr.Name.Lexeme) = False Then
		    HasError = True
		    Raise New RooAnalyserError(expr.Name, "Cannot read a local variable in its own initialiser.")
		  End If
		  
		  // Now let's actually analyse the variable.
		  AnalyseLocal(expr, expr.Name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitVarStmt(stmt As RooVarStmt) As Variant
		  DeclareSymbol(stmt.Name)
		  
		  If Not stmt.Initialiser IsA RooNothingExpr And stmt.Initialiser <> Nil Then Analyse(stmt.Initialiser)
		  
		  DefineSymbol(stmt.Name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisitWhileStmt(stmt As RooWhileStmt) As Variant
		  // Enter the loop.
		  LoopLevel = LoopLevel + 1
		  
		  // Analyse any symbols within the while statement's condition and its body.
		  Analyse(stmt.Condition)
		  Analyse(stmt.Body)
		  
		  // Exit the loop.
		  LoopLevel = LoopLevel - 1
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Error(token As RooToken, message As String)
	#tag EndHook


	#tag Property, Flags = &h21
		Private CurrentClass As RooAnalyser.ClassType
	#tag EndProperty

	#tag Property, Flags = &h21
		Private CurrentFunction As RooAnalyser.FunctionType
	#tag EndProperty

	#tag Property, Flags = &h0
		HasError As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		IfLevel As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			A reference to the interpreter that this resolver works for.
		#tag EndNote
		Private Interpreter As RooInterpreter
	#tag EndProperty

	#tag Property, Flags = &h21
		Private LoopLevel As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Keeps track of the stack of scopes currently in scope.
			Each element in the stack is a Dictionary representing a single block scope.
			Key = variable name.
			Value = Boolean. True means the variable is finished being initialised.
		#tag EndNote
		Private Scopes() As Dictionary
	#tag EndProperty


	#tag Enum, Name = ClassType, Type = Integer, Flags = &h21
		None
		  Klass
		  ModuleType
		Subclass
	#tag EndEnum

	#tag Enum, Name = FunctionType, Flags = &h0
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
			Name="HasError"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IfLevel"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
