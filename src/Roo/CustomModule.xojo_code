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

	#tag Method, Flags = &h0
		Function HashOrValue(hash As Roo.Objects.HashObject, indexOrKey As Variant) As Variant
		  ' The script is trying to access a Hash property on this custom module. 
		  ' If indexOrKey is Nil then the script is requesting the Hash object itself.
		  ' If indexOrKey <> Nil then the script is trying to access a the value associated 
		  ' with a key.
		  
		  If indexOrKey <> Nil Then
		    ' Retrieve a value from the specified key of the passed Hash object.
		    Return hash.GetValue(indexOrKey)
		  Else
		    ' Just return the Hash object itself.
		    Return hash
		  End If
		End Function
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
