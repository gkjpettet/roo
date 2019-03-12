#tag Class
Protected Class RooModule
Inherits RooInstance
Implements Invokable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  Return 0
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(metaclass As RooClass, name As String, modules() As RooModule, classes() As RooClass, methods As Xojo.Core.Dictionary)
		  Super.Constructor(metaclass)
		  
		  Self.Name = name
		  
		  // Modules.
		  For Each m As RooModule In modules
		    Fields.Value(m.Name) = m
		  Next m
		  
		  // Classes.
		  For Each c As RooClass In classes
		    Fields.Value(c.Name) = c
		  Next c
		  
		  // Methods.
		  Self.Methods = methods
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindMethod(instance As RooInstance, name As String) As RooFunction
		  // Does this module have the requested method?
		  If Methods.HasKey(name) Then Return RooFunction(Methods.Value(name)).Bind(instance)
		  
		  // Can't find this method.
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  #Pragma Unused interpreter
		  #Pragma Unused arguments
		  #Pragma Unused where
		  
		  // Disallow instantiation of modules.
		  Raise New RooRuntimeError(where, "Cannot create an instance of a module.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  Return Name + " module"
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Methods As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="name"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
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
