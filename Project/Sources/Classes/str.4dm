
// === === === === === === === === === === === === === === === === === === === === === === === === === ===
Class constructor($content)
	
	Super:C1705()
	
	This:C1470.value:=""
	
	If (Count parameters:C259>=1)
		
		This:C1470.setText($content)
		
	Else 
		
		This:C1470.length:=0
		This:C1470.styled:=False:C215
		
	End if 
	
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === ===
	// Defines the contents of the string & returns the updated object string
Function setText($content) : cs:C1710.str
	
	Case of 
			
			//______________________________________________________
		: (Value type:C1509($content)=Is text:K8:3)
			
			This:C1470.value:=$content
			
			//______________________________________________________
		: (Value type:C1509($content)=Is object:K8:27)\
			 | (Value type:C1509($content)=Is collection:K8:32)
			
			This:C1470.value:=JSON Stringify:C1217($content)
			
			//______________________________________________________
		: (Value type:C1509($content)=Is time:K8:8)
			
			This:C1470.value:=Time string:C180($content)
			
			//______________________________________________________
		Else 
			
			This:C1470.value:=String:C10($content)
			
			//______________________________________________________
	End case 
	
	This:C1470.success:=True:C214
	This:C1470.length:=Length:C16(This:C1470.value)
	
	return This:C1470
	
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === ===
	// Returns value as lower camelcase
Function lowerCamelCase($target : Text) : Text
	
	var $t : Text
	var $i : Integer
	var $c : Collection
	
	$target:=Count parameters:C259=0 ? This:C1470.value : $target
	
	If (Length:C16($target)>0)
		
		If (Length:C16($target)>=2)
			
			$t:=This:C1470.spaceSeparated($target)
			
			// Remove spaces
			$c:=Split string:C1554($t; " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
			
			// Capitalization of the first letter of words from the 2nd
			If ($c.length>1)
				
				$c[0]:=Lowercase:C14($c[0])
				
				For ($i; 1; $c.length-1; 1)
					
					$t:=Lowercase:C14($c[$i])
					$t[[1]]:=Uppercase:C13($t[[1]])
					$c[$i]:=$t
					
				End for 
				
				return $c.join()
				
			Else 
				
				return Lowercase:C14($t)
				
			End if 
			
		Else 
			
			return $target
			
		End if 
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === ===
	// Returns underscored value & camelcase (lower or upper) value as space separated
Function spaceSeparated($target : Text) : Text
	
	var $char : Text
	var $uppercase : Boolean
	var $i; $l : Integer
	var $c : Collection
	
	$target:=Count parameters:C259=0 ? This:C1470.value : $target
	$target:=Replace string:C233($target; "_"; " ")
	
	$c:=New collection:C1472
	
	If (Position:C15(" "; $target)>0)
		
		$c:=Split string:C1554($target; " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
		
	Else 
		
		For each ($char; Split string:C1554($target; ""))
			
			$i+=1
			
			If ($i=1)
				
				$uppercase:=Character code:C91(Uppercase:C13($char))=Character code:C91($target[[$i]])
				
			Else 
				
				If (Character code:C91(Lowercase:C14($char))#Character code:C91($target[[$i]])) & Not:C34($uppercase)  // Cesure
					
					$c.push(Substring:C12($target; $l; $i-$l-1))
					$l:=$i
					$uppercase:=False:C215
					
				Else 
					
					$uppercase:=Character code:C91(Uppercase:C13($char))=Character code:C91($target[[$i]])
					
				End if 
			End if 
		End for each 
		
		$c.push(Substring:C12($target; $l))
		
	End if 
	
	return $c.join(" ")
	