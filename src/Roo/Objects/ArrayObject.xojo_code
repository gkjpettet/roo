#tag Class
Protected Class ArrayObject
Inherits RooInstance
	#tag Method, Flags = &h0
		Sub Constructor()
		  Constructor(0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(size as Integer)
		  ' Calling the overridden superclass constructor.
		  super.Constructor(Nil)
		  
		  if size >= 0 then redim elements(size-1)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(elements() as Variant)
		  ' Calling the overridden superclass constructor.
		  super.Constructor(Nil)
		  
		  self.elements = elements
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReverse() As ArrayObject
		  ' Array.reverse! as Array
		  ' Reverse the order of this array's elements and return this array.
		  
		  dim i, limit as Integer
		  dim tmp() as Variant
		  
		  limit = elements.Ubound
		  for i = limit downTo 0
		    tmp.Append(elements(i))
		  next i
		  
		  elements = tmp
		  
		  return self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoUnique(destructive as Boolean) As ArrayObject
		  ' Array.unique  |  Array.unique!
		  ' Returns an array constructed by removing duplicate values in this array. Can be destructive (!).
		  
		  const ROO_NOTHING = "*_*_ROONOTHING_*_*"
		  
		  dim encounted as new VariantToVariantHashMapMBS(True)
		  dim i, elementUbound as Integer
		  dim result() as Variant
		  
		  ' Loop through each element. Every time we encounter an element we haven't seen before we add it
		  ' to the encounted hash map. The key of the hash map is the object itself, EXCEPT for Text
		  ' objects (where we use the text value), Numbers (we use the numeric value), Boolean objects 
		  ' (we use the Boolean value) and Nothing objects (where we use an arbitrary text constant). Why
		  ' do we use the value of some objects and not others? Well, obviously two Numbers with the 
		  ' value "2.0" should be treated as the same for the purposes of this function but in reality 
		  ' are actually two different objects.
		  elementUbound = elements.Ubound
		  for i = 0 to elementUbound
		    if elements(i) isA TextObject then
		      if not encounted.HasKey(TextObject(elements(i)).value) then
		        result.Append(elements(i))
		        encounted.Value(TextObject(elements(i)).value) = True
		      end if
		    elseif elements(i) isA NumberObject then
		      if not encounted.HasKey(NumberObject(elements(i)).value) then
		        result.Append(elements(i))
		        encounted.Value(NumberObject(elements(i)).value) = True
		      end if
		    elseif elements(i) isA BooleanObject then
		      if not encounted.HasKey(BooleanObject(elements(i)).value) then
		        result.Append(elements(i))
		        encounted.Value(BooleanObject(elements(i)).value) = True
		      end if
		    elseif elements(i) isA NothingObject then
		      if not encounted.HasKey(ROO_NOTHING) then
		        result.Append(elements(i))
		        encounted.Value(ROO_NOTHING) = True
		      end if
		    else
		      if encounted.HasKey(elements(i)) = False then
		        result.Append(elements(i))
		        encounted.Value(elements(i)) = True
		      end if
		    end if
		  next i
		  
		  ' Destructive operation?
		  if destructive then elements = result
		  
		  return new ArrayObject(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name as Token) As Variant
		  ' Override RooInstance.Get().
		  
		  if Lookup.ArrayMethod(name.lexeme) then return new ArrayObjectMethod(self, name.lexeme)
		  
		  if Lookup.ArrayGetter(name.lexeme) then
		    select case name.lexeme
		    case "empty?"
		      ' Array.empty? as Integer
		      return new BooleanObject(if(elements.Ubound < 0, True, False))
		    case "length"
		      ' Array.length as Integer
		      return new NumberObject(elements.Ubound + 1)
		    case "nothing?"
		      return new BooleanObject(False)
		    case "number?"
		      return new BooleanObject(False)
		    case "pop"
		      ' Array.pop as Object or Nothing
		      if elements.Ubound < 0 then
		        return new NothingObject
		      else
		        return elements.Pop()
		      end if
		    case "reverse!"
		      return DoReverse()
		    case "shuffle!"
		      elements.Shuffle()
		      return self
		    case "to_text"
		      return new TextObject(self.ToText)
		    case "type"
		      return new TextObject("Array")
		    case "unique"
		      return DoUnique(False)
		    case "unique!"
		      return DoUnique(True)
		    end select
		  end if
		  
		  raise new RuntimeError(name, "Array objects have no method named `" + name.lexeme + "`.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(separator as String) As TextObject
		  ' Internal helper method.
		  ' Returns this array as a text object by joining it's elements together with `separator`.
		  ' Recurses through subarrays.
		  
		  dim i, limit as Integer
		  dim result as String
		  
		  if elements.Ubound < 0 then return new TextObject("")
		  
		  limit = elements.Ubound
		  for i = 0 to limit
		    if elements(i) isA ArrayObject then ' Recurse.
		      result = result + ArrayObject(elements(i)).Join(separator).value + if(i = limit, "", separator)
		    else
		      result = result + Textable(elements(i)).ToText() + if(i = limit, "", separator)
		    end if
		  next i
		  
		  return new TextObject(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name as Token, value as Variant)
		  #pragma Unused name
		  #pragma Unused value
		  
		  ' Override RooInstance.Set
		  ' We want to prevent both the creating of new fields on ArrayObjects and setting their values.
		  raise new RuntimeError(name, "Cannot create or set fields on intrinsic data types " +_ 
		  "(Array." + name.lexeme + ").")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Part of the Textable interface.
		  
		  dim s, value as String
		  dim a, i, max as Integer
		  dim d as Double
		  
		  s = "["
		  
		  if elements.Ubound >= 0 then
		    max = elements.Ubound
		    for a = 0 to max
		      if a <> 0 then s = s + ", "
		      if elements(a) isA NumberObject then
		        d = NumberObject(elements(a)).value
		        if Round(d) = d then ' Integer.
		          i = d
		          value = Str(i)
		        else ' Double.
		          value = Str(d)
		        end if
		      elseif elements(a) isA Textable then
		        value = """" + Textable(elements(a)).ToText + """"
		      else
		        value = "<No text representation>"
		      end if
		      s = s + value
		    next a
		  end if
		  
		  return s + "]"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		elements() As Variant
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
	#tag EndViewBehavior
End Class
#tag EndClass
