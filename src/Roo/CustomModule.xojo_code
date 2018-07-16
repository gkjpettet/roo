#tag Class
Protected Class CustomModule
Inherits RooModule
	#tag Method, Flags = &h0
		Sub Constructor(name as String, methods as StringToVariantHashMapMBS)
		  ' Pass empty arrays for modules and classes since Roo currently doesn't support 
		  ' submodules and classes within native modules.
		  dim modules() as Roo.RooModule
		  dim classes() as Roo.RooClass
		  
		  ' Create a metaclass for this module to enable the use of these methods (which are essentially static).
		  dim metaclass as new RooClass(Nil, Nil, name + " metaclass", methods) 
		  
		  ' Call the overridden superclass constructor.
		  super.Constructor(metaclass, name, modules, classes, methods, True)
		  
		End Sub
	#tag EndMethod


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
	#tag EndViewBehavior
End Class
#tag EndClass
