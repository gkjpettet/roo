#tag Class
Protected Class RooModule
Inherits RooInstance
Implements Textable,Invokable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  return 0
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(metaclass as RooClass, name as String, modules() as RooModule, classes() as RooClass, methods as StringToVariantHashMapMBS, isNative as Boolean = False)
		  super.Constructor(metaclass)
		  
		  dim i, limit as Integer
		  
		  self.name = name
		  
		  ' Modules.
		  limit = modules.Ubound
		  for i = 0 to limit
		    self.fields.Value(modules(i).name) = modules(i)
		  next i
		  
		  ' Classes.
		  limit = classes.Ubound
		  for i = 0 to limit
		    self.fields.Value(classes(i).name) = classes(i)
		  next i
		  
		  ' Methods.
		  self.methods = methods
		  
		  self.isNative = isNative
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindMethod(instance as RooInstance, name as Text) As RooFunction
		  ' Does this module have the requested method?
		  if methods.HasKey(name) then return RooFunction(methods.Value(name)).Bind(instance)
		  
		  ' Can't find this method.
		  return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Token) As Variant
		  ' Part of the Invokable interface.
		  
		  #pragma Unused interpreter
		  #pragma Unused arguments
		  #pragma Unused where
		  
		  ' Disallow instantiation of a module.
		  raise new RuntimeError(where, "Cannot create an instance of a module.")
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  return name + " module"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		methods As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h0
		name As String
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
			Name="name"
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
