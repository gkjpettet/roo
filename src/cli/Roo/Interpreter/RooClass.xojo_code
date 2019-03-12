#tag Class
Protected Class RooClass
Inherits RooInstance
Implements Invokable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // If there's an initializer, that method’s arity determines how many arguments must be passed 
		  // when the user invokes the class itself. 
		  // Note that Roo doesn’t force a class to define an initializer.
		  
		  Dim initialiser As RooFunction = Methods.Lookup("init", Nil)
		  If initialiser = Nil Then
		    Return 0
		  Else
		    Return initialiser.Arity
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(metaclass As RooClass, superclass As RooClass, name As String, methods As Xojo.Core.Dictionary, interpreter As RooInterpreter)
		  Super.Constructor(metaclass)
		  
		  Self.Superclass = superclass
		  Self.Name = name
		  Self.Methods = If(methods <> Nil, methods, Roo.CaseSensitiveDictionary)
		  
		  Self.Interpreter = interpreter
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindMethod(instance As RooInstance, name As String) As RooFunction
		  // Is this an instance method?
		  If methods.HasKey(name) Then Return RooFunction(methods.Value(name)).Bind(instance)
		  
		  // Is it a method inherited from the superclass?
		  If superclass <> Nil Then Return superclass.FindMethod(instance, name)
		  
		  // This class does not have a method with this name.
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Create a new instance of this class.
		  
		  Dim instance As New RooInstance(Self)
		  
		  // When a class is called, after the RooInstance is created, we look for an "init" method. 
		  // If we find one, we immediately bind and invoke it just like a normal method call. 
		  // The argument list is forwarded along.
		  Dim initialiser As RooFunction = Methods.Lookup("init", Nil)
		  If initialiser <> Nil Then Call initialiser.Bind(instance).Invoke(interpreter, arguments, where)
		  
		  // Return this newly initialised class.
		  Return instance
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  Return "<" + Name + " class>"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Interpreter As RooInterpreter
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Methods As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Superclass As RooClass
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
			Name="name"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
