#tag Class
Protected Class Parser
	#tag Method, Flags = &h21
		Private Function ActuallyParse() As Stmt()
		  ' This method actually does the parsing. It is called from one of the two Parse() methods after 
		  ' those methods have correctly setup the scanner.
		  
		  Redim tokens(-1)
		  current = 0
		  hasError = False
		  Dim statements() As Stmt
		  
		  ' Tokenise the source code.
		  Try
		    tokens = scanner.Scan()
		  Catch e As ScannerError
		    ScanningError(e)
		    hasError = True
		    Return statements
		  End Try
		  
		  ' Bail early if there is only an EOF token.
		  If tokens.Ubound = 0 Then Return statements
		  
		  ' Parse the tokens.
		  Dim s As Stmt
		  While tokens(current).type <> TokenType.EOF
		    s = Declaration
		    If s <> Nil Then statements.Append(s)
		  Wend
		  
		  ' Return the AST.
		  Return statements
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Addition() As Expr
		  ' Addition → Multiplication ( ( MINUS | PLUS ) Multiplication )*
		  
		  dim operator as Token
		  dim right as Expr
		  
		  dim expr as Expr = Multiplication()
		  
		  while Match(TokenType.MINUS, TokenType.PLUS)
		    operator = tokens(current - 1)
		    right = Multiplication()
		    expr = new BinaryExpr(expr, operator, right)
		  wend
		  
		  return expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Advance()
		  ' Consumes the current token WITHOUT returning it.
		  
		  if tokens(current).type <> TokenType.EOF then current = current + 1
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Advance() As Token
		  ' Consumes the current token and returns it.
		  
		  if tokens(current).type <> TokenType.EOF then current = current + 1
		  
		  return tokens(current - 1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Assignment() As Expr
		  ' Assignment → ( CALL DOT )? IDENTIFIER 
		  '                   (EQUAL | PLUS_EQUAL | MINUS_EQUAL | STAR_EQUAL | SLASH_EQUAL | PERCENT_EQUAL) Assignment
		  '            | Ternary
		  
		  dim expr as Expr = Ternary()
		  
		  if Match(TokenType.EQUAL, TokenType.PLUS_EQUAL, TokenType.MINUS_EQUAL, _
		    TokenType.STAR_EQUAL, TokenType.SLASH_EQUAL, TokenType.PERCENT_EQUAL) then
		    
		    dim operator as Token = tokens(current - 1)
		    dim value as Expr = Assignment()
		    
		    if expr isA VariableExpr then
		      dim name as Token = VariableExpr(expr).name
		      return new AssignExpr(name, value, operator)
		      
		    elseif expr isA GetExpr then
		      dim get as GetExpr = GetExpr(expr)
		      return new SetExpr(get.obj, get.name, value, operator)
		      
		    elseif expr isA ArrayExpr then
		      dim name as Token = ArrayExpr(expr).name
		      dim index as Expr = ArrayExpr(expr).index
		      return new ArrayAssignExpr(name, index, value, operator)
		      
		    elseif expr isA HashExpr then
		      dim name as Token = HashExpr(expr).name
		      dim key as Expr = HashExpr(expr).key
		      return new HashAssignExpr(name, key, value, operator)
		      
		    end if
		    
		    raise new ParserError(operator, "Invalid assignment target.")
		    
		  end if
		  
		  return expr
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function AtEnd() As Boolean
		  ' Checks to see if we've run out of tokens to parse.
		  
		  return Peek().type = TokenType.EOF
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Block() As Stmt()
		  ' Block → LCURLY Declaration* RCURLY
		  
		  dim statements() as Stmt
		  
		  while not Check(TokenType.RCURLY) and tokens(current).type <> TokenType.EOF
		    statements.Append(Declaration())
		  wend
		  
		  call Consume(TokenType.RCURLY, "Expected `}` after block.")
		  
		  return statements
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BreakStatement() As Stmt
		  ' BreakStmt → BREAK SEMICOLON
		  ' BreakStmt → BREAK (IF Expression)? SEMICOLON
		  
		  dim condition as Roo.Expr
		  
		  ' Get a reference to the triggering `break` token in case we encounter an error and need
		  ' to inform the user of it's position in the source code.
		  dim keyword as Token = tokens(current - 1)
		  
		  ' Is there a break condition?
		  if Match(TokenType.IF_KEYWORD) then condition = Expression()
		  
		  call Consume(TokenType.SEMICOLON, "Expected a `;` after the break keyword.")
		  
		  return new BreakStmt(keyword, condition)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Check(type as TokenType) As Boolean
		  ' Returns True if the current token type matches `type`, otherwise we return False. 
		  ' Unlike Match(), it doesn't consume the token.
		  
		  return if(tokens(current).type = type, True, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ClassDeclaration() As ClassStmt
		  ' ClassDeclaration → CLASS IDENTIFIER ( LESS IDENTIFIER )? LCURLY FunctionDeclaration* RCURLY
		  
		  dim name as Token = Consume(TokenType.IDENTIFIER, "Expected a class name.")
		  
		  ' Has a superclass been defined?
		  dim superclass as VariableExpr = Nil
		  if Match(TokenType.LESS) then
		    call Consume(TokenType.IDENTIFIER, "Expected a superclass name.")
		    superclass = new VariableExpr(tokens(current - 1))
		  end if
		  
		  call Consume(TokenType.LCURLY, "Expected a `{` before class body.")
		  
		  ' Get any static and instance methods.
		  dim staticMethods(), methods() as FunctionStmt
		  while not Check(TokenType.RCURLY) and tokens(current).type <> TokenType.EOF()
		    if tokens(current).type = TokenType.STATIC_KEYWORD then
		      current = current + 1
		      staticMethods.Append(FunctionDeclaration("method"))
		    else
		      methods.Append(FunctionDeclaration("method"))
		    end if
		  wend
		  
		  call Consume(TokenType.RCURLY, "Expected a '}' after class body.")
		  
		  return new ClassStmt(name, superclass, staticMethods, methods)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Comparison() As Expr
		  ' Comparison → Addition ( ( GREATER | GREATER_EQUAL | LESS | LESS_EQUAL ) Addition )*
		  
		  dim operator as Token
		  dim right as Expr
		  
		  dim expr as Expr = Addition()
		  
		  while Match(TokenType.GREATER, TokenType.GREATER_EQUAL, TokenType.LESS, TokenType.LESS_EQUAL)
		    operator = tokens(current - 1)
		    right = Addition()
		    expr = new BinaryExpr(expr, operator, right)
		  wend
		  
		  return expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  scanner = new Scanner("")
		  hasError = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Consume(type as TokenType, message as String) As Token
		  ' Checks to see if the current token's type is `type`. If so we return the current token.
		  
		  #pragma BreakOnExceptions False
		  
		  if Check(type) then return Advance()
		  
		  ' Houston, we have a problem.
		  hasError = True
		  raise new ParserError(tokens(current), message)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Declaration() As Stmt
		  ' Declaration → VarDeclaration | FunctionDeclaration | ClassDeclaration | ModuleDeclaration | Statement
		  
		  try
		    
		    if Match(TokenType.VAR) then return VarDeclaration()
		    if Match(TokenType.FUNCTION_KEYWORD) then return FunctionDeclaration("function")
		    if Match(TokenType.CLASS_KEYWORD) then return ClassDeclaration()
		    if Match(TokenType.MODULE_KEYWORD) then return ModuleDeclaration()
		    
		    return Statement()
		    
		  catch err as ParserError
		    
		    ParsingError(err.token, err.message)
		    Synchronise()
		    return Nil
		    
		  end try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Equality() As Expr
		  ' Equality → Comparison ( ( NOT_EQUAL | EQUAL_EQUAL ) Comparison )*
		  
		  dim operator as Token
		  dim right as Expr
		  
		  dim expr as Expr = Comparison()
		  
		  while Match(TokenType.NOT_EQUAL, TokenType.EQUAL_EQUAL)
		    
		    operator = Previous()
		    right = Comparison()
		    expr = new BinaryExpr(expr, operator, right)
		    
		  wend
		  
		  return expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Expression() As Expr
		  ' Expression → Assignment
		  
		  return Assignment()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ExpressionStatement() As Stmt
		  Dim expr As Expr = Expression()
		  
		  Try
		    Call Consume(TokenType.SEMICOLON, "Expected `;` after expression.")
		  Catch
		    ' Semicolons are expected after expression statements.
		    ' There is an edge case where an expression statement may end with a hash literal.
		    ' In this case, the scanner will not have automatically inserted a semicolon if one was 
		    ' omitted by the user. Handle that here.
		    Self.hasError = False
		  End Try
		  
		  If expr <> Nil Then
		    Return New ExpressionStmt(expr)
		  Else
		    Return Nil
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FinishInvoke(invokee as Expr) As Expr
		  ' Used in conjunction with Invoke() to parse the (optional) arguments list.
		  
		  dim arguments() as Expr
		  
		  if not Check(tokenType.RPAREN) then
		    
		    do
		      if arguments.Ubound = 7 then
		        ' Limit the number of arguments to 8 (simplifies things in our future VM implementation).
		        hasError = True
		        raise new ParserError(tokens(current), "Cannot have more than 8 arguments.")
		      end if
		      
		      arguments.Append(Expression())
		      
		    loop until not Match(TokenType.COMMA)
		  end if
		  
		  dim paren as Token = Consume(TokenType.RPAREN, "Expected `)` after arguments.")
		  
		  return new InvokeExpr(invokee, paren, arguments)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ForStatement() As Stmt
		  ' ForStmt → FOR LPAREN (VarDeclaration | ExpressionStmt | SEMICOLON ) 
		  '           Expression? SEMICOLON Expression? RPAREN Statement
		  
		  ' E.g: for (var i = 0; i < 10; i = i + 1) print(i);
		  
		  Call Consume(TokenType.LPAREN, "Expected `(` after for keyword.")
		  
		  ' Get the initialiser (if defined).
		  Dim initialiser As Stmt
		  If Match(TokenType.SEMICOLON) Then
		    initialiser = Nil ' The initialiser has been omitted.
		  ElseIf Match(TokenType.VAR) Then
		    initialiser = VarDeclaration()
		  Else
		    initialiser = ExpressionStatement()
		  End If
		  
		  ' Get the loop condition (if defined).
		  Dim condition As Expr = Nil
		  If Not Check(TokenType.SEMICOLON) Then condition = Expression()
		  Call Consume(TokenType.SEMICOLON, "Expected `;` after for loop condition.")
		  
		  ' Get the increment (if defined).
		  Dim increment As Expr = Nil
		  If Not Check(TokenType.RPAREN) Then increment = Expression()
		  Call Consume(TokenType.RPAREN, "Expected `)` after for loop clauses.")
		  
		  ' Get the loop body.
		  Dim body As Stmt = Statement()
		  
		  ' Desugar to a while loop.
		  ' The increment, if there is one, executes after the body in each iteration of the loop.
		  ' We do that by replacing the body with a little block that contains the original body
		  ' followed by an expression statement that evaluates the increment.
		  If increment <> Nil Then
		    Dim blockStatements() As Stmt ' HACK: Xojo can't create an array of subclasses using the `Array` keyword.
		    blockStatements.Append(body)
		    blockStatements.Append(New ExpressionStmt(increment))
		    body = New BlockStmt(blockStatements)
		  End If
		  
		  ' Next, we take the condition and the body and build the loop using a primitive while loop.
		  ' If the condition is omitted, we jam in True to make an infinite loop.
		  If condition = Nil Then condition = New BooleanLiteralExpr(True)
		  body = New WhileStmt(condition, body)
		  
		  ' Finally, if there is an initializer, it runs once before the entire loop. We do that by,
		  ' again, replacing the whole statement with a block that runs the initializer and then executes the loop.
		  If initialiser <> Nil Then body = New BlockStmt(Array(initialiser, body))
		  
		  Return body
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FunctionDeclaration(kind as String) As FunctionStmt
		  ' FunctionStmt → IDENTIFIER (LPAREN parameters? RPAREN)? Block
		  
		  ' A method (NOT a function) can be declared without parentheses to signify that it is a getter method.
		  ' Getter declarations are represented in the FunctionStmt by setting the `parameters` array to Nil. 
		  ' Methods that take no parameters will set `parameters` to an empty array. This is a very important
		  ' distinction and we must be careful to check for Nil when utilising the `parameters` property in the 
		  ' Resolver and the Interpeter. 
		  
		  dim name as Token = Consume(TokenType.IDENTIFIER, "Expected a " + kind + " name. ")
		  
		  dim parameters() as Token
		  if kind <> "method" or Check(TokenType.LPAREN) then
		    call Consume(TokenType.LPAREN, "Expected `(` after " + kind + " name.")
		    if not Check(TokenType.RPAREN) then
		      do
		        if parameters.Ubound = 7 then
		          ' Limit the number of parameters to 8 (simplifies things in our future VM implementation).
		          hasError = True
		          raise new ParserError(tokens(current), "Cannot have more than 8 parameters.")
		        end if
		        parameters.Append(Consume(TokenType.IDENTIFIER, "Expected parameter name."))
		      loop until not Match(TokenType.COMMA)
		    end if
		    call Consume(TokenType.RPAREN, "Expected a `)` after parameters.")
		  else
		    parameters = Nil
		  end if
		  
		  call Consume(TokenType.LCURLY, "Expected  a `{` before " + kind + " body.")
		  
		  dim body() as Stmt = Block()
		  
		  return new FunctionStmt(name, parameters, body)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IfStatement() As Stmt
		  ' IfStmt → IF Expression Statement ( ELSE Statement )?
		  
		  Dim condition As Expr = Expression()
		  Dim thenBranch As Stmt = Statement()
		  Dim elseBranch As Stmt = Nil
		  If Match(TokenType.ELSE_KEYWORD) Then elseBranch = Statement()
		  
		  Return New IfStmt(condition, thenBranch, elseBranch)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InsertSemicolon(line As Integer)
		  Dim semicolon As New Roo.Token
		  semicolon.line = line
		  semicolon.type = TokenType.SEMICOLON
		  
		  Self.Tokens.Insert(current, semicolon)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Invoke() As Expr
		  ' Invoke → Primary ( LPAREN arguments? RPAREN | DOT IDENTIFIER )*
		  
		  Dim expr As Expr = Primary()
		  
		  While True
		    
		    If Match(TokenType.LPAREN) Then
		      ' Each time we find a `(`, use FinishInvoke() to parse the Invoke expression using the 
		      ' previously parsed expression as the invokee. The returned expression becomes the new 
		      ' expr and then loop to see if the result is itself called.
		      expr = FinishInvoke(expr)
		    ElseIf Match(TokenType.DOT) Then
		      Dim name As Token = Consume(TokenType.IDENTIFIER, "Expected a property name after `.`.")
		      
		      ' Is the identifier an array or hash?
		      If Match(TokenType.LSQUARE) Then ' Array.
		        Dim index As Expr = Expression
		        Call Consume(TokenType.RSQUARE, "Expected a `]` after an array index.")
		        expr = New GetExpr(expr, name, index)
		      ElseIf Match(TokenType.LCURLY) Then ' Hash.
		        Dim key As Expr = Expression
		        Call Consume(TokenType.RCURLY, "Expected a `}` after a hash key.")
		        expr = New GetExpr(expr, name, key)
		      Else
		        expr = New GetExpr(expr, name)
		      End If
		    Else
		      Exit
		    End If
		    
		  Wend
		  
		  Return expr
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function KeyValue() As Roo.KeyValuePair
		  ' Return the next key-value pair.
		  ' Valid format is:
		  ' KEY => VALUE
		  ' Where KEY and VALUE are both valid expressions.
		  ' Returns a Roo.KeyValuePair object.
		  
		  dim key as Expr = Expression()
		  
		  call Consume(TokenType.ARROW, "Expected `=>` operator after hash key.")
		  
		  dim value as Expr = Expression()
		  
		  return new Roo.KeyValuePair(key, value)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LogicAnd() As Expr
		  ' LogicAnd → Equality ( AND Equality )*
		  
		  dim operator as Token
		  dim right as Expr
		  
		  dim expr as Expr = Equality()
		  
		  while Match(TokenType.AND_KEYWORD)
		    
		    operator = tokens(current - 1)
		    right = Equality()
		    expr = new LogicalExpr(expr, operator, right)
		    
		  wend
		  
		  return expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LogicOr() As Expr
		  ' LogicOr → LogicAnd ( OR LogicAnd )*
		  
		  dim operator as Token
		  dim right as Expr
		  
		  dim expr as Expr = LogicAnd()
		  
		  while Match(TokenType.OR_KEYWORD)
		    
		    operator = tokens(current - 1)
		    right = LogicAnd()
		    expr = new LogicalExpr(expr, operator, right)
		    
		  wend
		  
		  return expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Match(ParamArray types as TokenType) As Boolean
		  ' Checks to see if the current token is any of the passed types. If it is then, the token is 
		  ' consumed and we return True. Otherwise we leave the token where it is and return False.
		  
		  dim limit as Integer = types.Ubound
		  dim i as Integer
		  
		  for i = 0 to limit
		    if Check(types(i)) then
		      if tokens(current).type <> TokenType.EOF then current = current + 1
		      return True
		    end if
		  next i
		  
		  return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ModuleDeclaration() As ModuleStmt
		  ' ModuleDeclaration → MODULE IDENTIFIER LCURLY (ModuleDeclaration | ClassDeclaration | FunctionDeclaration)* RCURLY
		  
		  dim name as Token = Consume(TokenType.IDENTIFIER, "Expected a module name.")
		  
		  call Consume(TokenType.LCURLY, "Expected a `{` before module body.")
		  
		  ' Get any modules, classes and methods defined within the module.
		  dim modules() as ModuleStmt
		  dim classes() as ClassStmt
		  dim methods() as FunctionStmt
		  while not Check(TokenType.RCURLY) and tokens(current).type <> TokenType.EOF
		    if Check(TokenType.CLASS_KEYWORD) then
		      call Consume(TokenType.CLASS_KEYWORD, "")
		      classes.Append(ClassDeclaration())
		    elseif Check(TokenType.MODULE_KEYWORD) then
		      call Consume(TokenType.MODULE_KEYWORD, "")
		      modules.Append(ModuleDeclaration())
		    else
		      methods.Append(FunctionDeclaration("method"))
		    end if
		  wend
		  
		  call Consume(TokenType.RCURLY, "Expected a '}' after module body.")
		  
		  return new ModuleStmt(name, modules, classes, methods)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Multiplication() As Expr
		  ' Multiplication → Unary ((SLASH|STAR|PERCENT|CARET) Unary)*
		  
		  dim operator as Token
		  dim right as Expr
		  
		  dim expr as Expr = Unary()
		  
		  while Match(TokenType.SLASH, TokenType.STAR, TokenType.PERCENT, TokenType.CARET)
		    
		    operator = tokens(current - 1)
		    right = Unary()
		    expr = new BinaryExpr(expr, operator, right)
		    
		  wend
		  
		  return expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Parse(sourceFile as FolderItem) As Stmt()
		  ' Builds the AST and returns it as an array of Stmts.
		  ' If a scanning error occurs we fire the ScannerError event and return an empty array.
		  
		  ' Initialise our scanner with this source file.
		  scanner = new Scanner(sourceFile)
		  
		  ' Now parse.
		  Return ActuallyParse
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Parse(source as String) As Stmt()
		  ' Builds the AST and returns it as an array of Stmts.
		  ' If a scanning error occurs we fire the ScannerError event and return an empty array.
		  
		  ' Initialise our scanner with this source text.
		  scanner = new Scanner(source)
		  
		  ' Now parse.
		  Return ActuallyParse
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Peek() As Token
		  ' Returns the current token we have yet to consume.
		  
		  return tokens(current)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Previous() As Token
		  ' Returns the most recently consumed token.
		  
		  return tokens(current - 1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Primary() As Expr
		  ' Primary → BOOLEAN | NOTHING | SELF | NUMBER | TEXT
		  '         | LPAREN Expression RPAREN 
		  '         | IDENTIFIER
		  '         | SUPER DOT IDENTIFIER 
		  '         | LSQUARE arguments? RSQUARE
		  
		  ' Simple literals (booleans, numbers, nothing, text and regex).
		  if Match(TokenType.BOOLEAN) then return new BooleanLiteralExpr(tokens(current - 1).lexeme.ToBoolean)
		  if Match(TokenType.NUMBER) then return new NumberLiteralExpr(tokens(current - 1).lexeme.Val)
		  if Match(TokenType.NOTHING) then return new NothingExpr
		  if Match(TokenType.TEXT) then return new TextLiteralExpr(tokens(current - 1).lexeme)
		  if Match(TokenType.REGEX) then return new RegexLiteralExpr(tokens(current - 1).lexeme, tokens(current - 1))
		  
		  ' Array literal? (E.g: [1, 3, "a"]
		  if Match(TokenType.LSQUARE) then
		    dim elements() as Expr
		    if tokens(current).type = TokenType.RSQUARE then ' Empty array []
		      current = current + 1 ' Consume the `]`
		      return new ArrayLiteralExpr(elements)
		    end if
		    do
		      elements.Append(Expression())
		    loop until not Match(TokenType.COMMA)
		    if not Match(TokenType.RSQUARE) then
		      raise new ParserError(tokens(current - 1), _
		      "Expected a closing square bracket after an array literal list.")
		    end if
		    return new ArrayLiteralExpr(elements)
		  end if
		  
		  ' Hash literal? (E.g: {"a" => 1, "b" => 2})
		  if Match(TokenType.LCURLY) then
		    dim keyValues() as Roo.KeyValuePair
		    if tokens(current).type = TokenType.RCURLY then ' Empty hash {}
		      current = current + 1 ' Consume the `}`
		      return new HashLiteralExpr(keyValues)
		    end if
		    do
		      keyValues.Append(KeyValue())
		    loop until not Match(TokenType.COMMA)
		    if not Match(TokenType.RCURLY) then
		      raise new ParserError(tokens(current - 1), _
		      "Expected a closing `}` after a hash literal list.")
		    end if
		    return new HashLiteralExpr(keyValues)
		  end if
		  
		  ' Self.
		  if Match(TokenType.SELF_KEYWORD) then return new SelfExpr(tokens(current - 1))
		  
		  ' Super.
		  if Match(TokenType.SUPER_KEYWORD) then
		    dim keyword as Token = tokens(current - 1)
		    call Consume(TokenType.DOT, "Expected superclass method name after `super.`.")
		    dim method as Token = Consume(TokenType.IDENTIFIER, "Expected superclass method name.")
		    return new SuperExpr(keyword, method)
		  end if
		  
		  ' Grouping expression.
		  if Match(TokenType.LPAREN) then
		    dim expr as Expr = Expression()
		    call Consume(TokenType.RPAREN, "Expected ')' after expression.")
		    return new GroupingExpr(expr)
		  end if
		  
		  ' Variable, array and hash access.
		  if Match(TokenType.IDENTIFIER) then
		    dim identifier as Token = tokens(current - 1)
		    if Match(TokenType.LSQUARE) then ' Array? (a[3])
		      dim index as Expr = Expression()
		      call Consume(TokenType.RSQUARE, "Expected a closing `]` after an array index.")
		      return new ArrayExpr(identifier, index)
		    elseif Match(TokenType.LCURLY) then ' Hash? (a{"name"})
		      dim key as Expr = Expression()
		      call Consume(TokenType.RCURLY, "Expected a closing `}` after a hash key.")
		      return new HashExpr(identifier, key)
		    else
		      return new VariableExpr(tokens(current - 1))
		    end if
		  end if
		  
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function QuitStatement() As Stmt
		  ' QuitStmt → QUIT SEMICOLON
		  
		  ' Get a reference to the triggering `quit` token in case we encounter an error and need
		  ' to inform the user of it's position in the source code.
		  dim keyword as Token = tokens(current - 1)
		  
		  call Consume(TokenType.SEMICOLON, "Expected a `;` after the quit keyword.")
		  
		  return new QuitStmt(keyword)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ReturnStatement() As Stmt
		  ' Get a reference to the `return` keyword for prettier error reporting later (if one occurs).
		  dim keyword as Token = tokens(current - 1)
		  
		  ' Is there a return value? We default to Nothing if there isn't.
		  dim value as Expr = new NothingExpr
		  if not Check(TokenType.SEMICOLON) then value = Expression()
		  
		  call Consume(TokenType.SEMICOLON, "Expected a `;` after return value.")
		  
		  return new ReturnStmt(keyword, value)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Statement() As Stmt
		  ' Statement → ExpressionStatement 
		  '           | Block
		  '           | BreakStmt
		  '           | ForStmt
		  '           | IfStmt
		  '           | QuitStmt
		  '           | ReturnStmt
		  '           | WhileStmt
		  
		  if Match(TokenType.LCURLY) then return new BlockStmt(Block())
		  if Match(TokenType.BREAK_KEYWORD) then return BreakStatement()
		  if Match(TokenType.IF_KEYWORD) then return IfStatement()
		  if Match(TokenType.QUIT_KEYWORD) then return QuitStatement()
		  if Match(TokenType.FOR_KEYWORD) then return ForStatement()
		  if Match(TokenType.RETURN_KEYWORD) then return ReturnStatement()
		  if Match(TokenType.WHILE_KEYWORD) then return WhileStatement()
		  
		  return ExpressionStatement()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Synchronise()
		  ' The parser is panicking. To get back on track search for a statement boundary.
		  
		  Advance()
		  
		  while tokens(current).type <> TokenType.EOF
		    
		    if tokens(current - 1).type = TokenType.SEMICOLON then return
		    
		    select case tokens(current).type
		    case TokenType.ELSE_KEYWORD, TokenType.FUNCTION_KEYWORD, _
		      TokenType.IF_KEYWORD, TokenType.VAR, TokenType.WHILE_KEYWORD
		      return
		    end select
		    
		    Advance()
		    
		  wend
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Ternary() As Expr
		  ' Ternary → LogicOr (QUERY Expression COLON Ternary)?
		  
		  dim expr as Expr = LogicOr()
		  
		  if Match(TokenType.QUERY) then
		    dim thenBranch as Expr = Expression()
		    call Consume(TokenType.COLON, "Expected a `:` after `then` condition in ternary operator.")
		    dim elseBranch as Expr = Ternary()
		    expr = new TernaryExpr(expr, thenBranch, elseBranch)
		  end if
		  
		  return expr
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Unary() As Expr
		  ' Unary → (BANG|NOT|MINUS) Unary
		  '       | Invoke
		  
		  if Match(TokenType.BANG, TokenType.NOT_KEYWORD, TokenType.MINUS) then
		    
		    dim operator as Token = tokens(current - 1)
		    dim right as Expr = Unary()
		    
		    return new UnaryExpr(operator, right)
		    
		  end if
		  
		  return Invoke()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function VarDeclaration() As Stmt
		  ' VarDeclaration → VAR IDENTIFIER ( EQUAL Expression )? SEMICOLON
		  
		  Dim name As Roo.Token = Consume(TokenType.IDENTIFIER, "Expected a variable name.")
		  
		  ' Is there an initialiser for this variable (i.e: a = 10)?
		  Dim initialiser As Expr = Nil
		  If Match(TokenType.EQUAL) Then initialiser = Expression()
		  
		  Try
		    Call Consume(TokenType.SEMICOLON, "Expected `;` after variable declaration.")
		  Catch
		    ' Semicolons are expected after a variable declaration.
		    ' There is an edge case where a declaration initialiser may end with a hash literal.
		    ' In this case, the scanner will not have automatically inserted a semicolon if one was 
		    ' omitted by the user. Handle that here.
		    Self.hasError = False
		  End Try
		  
		  Return New VarStmt(name, initialiser)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function WhileStatement() As Stmt
		  ' WhileStmt → WHILE Expression Statement
		  
		  Dim condition As Expr = Expression()
		  
		  Dim body As Stmt = Statement()
		  
		  Return New WhileStmt(condition, body)
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event ParsingError(where as Token, message as String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ScanningError(e as Roo.ScannerError)
	#tag EndHook


	#tag Property, Flags = &h21
		#tag Note
			A pointer to the next token to parse.
		#tag EndNote
		Private current As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		hasError As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		Private scanner As Scanner
	#tag EndProperty

	#tag Property, Flags = &h21
		Private tokens() As Token
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
			Name="hasError"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
