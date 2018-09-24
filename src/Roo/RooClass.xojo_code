#tag Class
Protected Class RooClass
Inherits RooInstance
Implements Textable,Invokable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' If there's an initializer, that method’s arity determines how many arguments must be passed when the
		  ' user invokes the class itself. Roo doesn’t require a class to define an initializer however.
		  
		  dim initialiser as RooFunction = methods.Lookup("init", Nil)
		  if initialiser = Nil then
		    return 0
		  else
		    return initialiser.Arity()
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(metaclass as RooClass, superclass as RooClass, name as String, methods as StringToVariantHashMapMBS, isNative as Boolean = False)
		  super.Constructor(metaclass)
		  
		  self.superclass = superclass
		  self.name = name
		  self.methods = methods
		  self.isNative = isNative
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindMethod(instance as RooInstance, name as String) As RooFunction
		  ' Is this an instance method?
		  if methods.HasKey(name) then return RooFunction(methods.Value(name)).Bind(instance)
		  
		  ' Is it a method inherited from the superclass?
		  if superclass <> Nil then return superclass.FindMethod(instance, name)
		  
		  return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindNativeMethod(name as String) As Invokable
		  ' Does this class have the requested method?
		  if methods.HasKey(name) and methods.Value(name) isA Invokable then return methods.Value(name)
		  
		  ' If not, does it's superclass?
		  if superclass <> Nil then return superclass.FindNativeMethod(name)
		  
		  ' Can't find this method.
		  return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Token) As Variant
		  dim instance as new RooInstance(self)
		  
		  ' When a class is called, after the RooInstance is created, we look for an "init" method. 
		  ' If we find one, we immediately bind and invoke it just like a normal method call. 
		  ' The argument list is forwarded along.
		  dim initialiser as RooFunction = self.methods.Lookup("init", Nil)
		  if initialiser <> Nil then call initialiser.Bind(instance).Invoke(interpreter, arguments, where)
		  
		  return instance
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  return "<" + name + " class>"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private methods As StringToVariantHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h0
		name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		superclass As RooClass
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="name"
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
