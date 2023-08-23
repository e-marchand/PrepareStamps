Class constructor
	This:C1470._init()
	
Function _init()
	This:C1470.deletedRecordsTable:=New object:C1471(\
		"name"; "__DeletedRecords"; \
		"fields"; New collection:C1472)
	
	This:C1470.deletedRecordsTable.fields.push(New object:C1471(\
		"name"; "ID"; \
		"type"; "INT64"; \
		"indexed"; True:C214; \
		"primaryKey"; True:C214; \
		"autoincrement"; True:C214; \
		"_type"; "number"))
	
	This:C1470.deletedRecordsTable.fields.push(New object:C1471(\
		"name"; "__Stamp"; \
		"type"; "INT64"; \
		"indexed"; True:C214; \
		"_type"; "number"))
	
	This:C1470.deletedRecordsTable.fields.push(New object:C1471(\
		"name"; "__TableNumber"; \
		"type"; "INT32"; \
		"_type"; "number"))
	
	This:C1470.deletedRecordsTable.fields.push(New object:C1471(\
		"name"; "__TableName"; \
		"type"; "VARCHAR(255)"; \
		"_type"; "string"))
	
	This:C1470.deletedRecordsTable.fields.push(New object:C1471(\
		"name"; "__PrimaryKey"; \
		"type"; "VARCHAR(255)"; \
		"_type"; "string"))
	
	This:C1470.stampField:=New object:C1471(\
		"name"; "__GlobalStamp"; \
		"type"; "INT64"; \
		"indexed"; True:C214; \
		"_type"; "number")
	
Function _defaultTablesNames() : Collection
	return OB Keys:C1719(ds:C1482)\
		.filter(Formula:C1597(Position:C15("__"; $1.value)#1))\
		.filter(Formula:C1597(ds:C1482[$1.value].getInfo().exposed))
	
	
	// verify if all is ok
	// - if delete records tables exists and have correct fields
	// - if passed table names (or all exposed table if passing nothing) have globals stamps fields
	// Return True if ok, otherwise False and this object will contains a list of errors into "errors" fields (the first one)
Function verify($publishedTableNames : Collection) : Boolean
	
	var $t : Text
	var $field; $o; $pk : Object
	var $dataclass : 4D:C1709.DataClass
	
	// Mark:Verify __DeletedRecords dataclasses
	$dataclass:=ds:C1482[This:C1470.deletedRecordsTable.name]
	
	This:C1470.errors:=New collection:C1472
	
	If ($dataclass=Null:C1517)
		
		This:C1470.errors.push("The table \""+This:C1470.deletedRecordsTable.name+"\" doesn't exists")
		return False:C215
		
	End if 
	
	$o:=$dataclass.getInfo()
	
	$pk:=$dataclass[This:C1470.deletedRecordsTable.fields.query("primaryKey = true").pop().name]
	
	If (Not:C34(Bool:C1537($o.exposed)))\
		 || (String:C10($o.primaryKey)#$pk.name)\
		 || (Not:C34(Bool:C1537($pk.autoFilled)))\
		 || (Not:C34(Bool:C1537($pk.indexed)))
		
		Case of 
				
				//______________________________________________________
			: (Not:C34(Bool:C1537($o.exposed)))
				
				This:C1470.errors.push("The table \""+This:C1470.deletedRecordsTable.name+"\" is not exposed")
				
				//______________________________________________________
			: (String:C10($o.primaryKey)#$pk.name)
				
				This:C1470.errors.push("The primary key of the dataclass \""+This:C1470.deletedRecordsTable.name+"\" must be named \""+$pk.name+"\"")
				
				//______________________________________________________
		End case 
		
		return False:C215
		
	End if 
	
	For each ($o; This:C1470.deletedRecordsTable.fields)
		
		$field:=$dataclass[$o.name]
		
		If ($field=Null:C1517)\
			 || (Not:C34(Bool:C1537($field.exposed)))\
			 || ($field.type#$o._type)
			
			Case of 
					
					//______________________________________________________
				: (Not:C34(Bool:C1537($field.exposed)))
					
					This:C1470.errors.push("The attribute \""+$o.name+"\" of the dataclass \""+This:C1470.deletedRecordsTable.name+"\" must be exposed")
					
					//______________________________________________________
				: ($field.type#$o._type)
					
					This:C1470.errors.push("The type of the attribute \""+$o.name+"\" of the dataclass \""+This:C1470.deletedRecordsTable.name+"\" is not the expected one")
					
					//______________________________________________________
			End case 
			
			return False:C215
			
		End if 
	End for each 
	
	// Mark:Verify __GlobalStamp for published dataclasses
	
	If ($publishedTableNames=Null:C1517)  // means all exposed, not private ie. starting with __
		$publishedTableNames:=This:C1470._defaultTablesNames()
	End if 
	
	If ($publishedTableNames#Null:C1517)\
		 && ($publishedTableNames.length>0)
		
		For each ($t; $publishedTableNames)
			
			$dataclass:=ds:C1482[$t]
			
			If ($dataclass=Null:C1517)\
				 || ($dataclass[This:C1470.stampField.name]=Null:C1517)\
				 || ($dataclass[This:C1470.stampField.name].type#This:C1470.stampField._type)
				
				This:C1470.errors.push("The dataclass \""+$t+"\" has no global stamp yet")
				
				return False:C215
				
			End if 
		End for each 
	End if 
	
	return True:C214
	
	
/*
Returns True if everything is OK.
Returns False and an errors list if we can't solve the problem in current object.
*/
Function run($publishedTableNames : Collection) : Boolean
	
	var $t : Text
	var $o : Object
	var $error : cs:C1710.error
	
	This:C1470.errors:=New collection:C1472
	This:C1470.warnings:=New collection:C1472
	If ($publishedTableNames=Null:C1517)  // means all exposed, not private ie. starting with __
		$publishedTableNames:=This:C1470._defaultTablesNames()
	End if 
	
	$error:=cs:C1710.error.new()
	$error.capture()
	
	// MARK:Create __DeletedRecords dataclasses
	DOCUMENT:="CREATE TABLE IF NOT EXISTS "+String:C10(This:C1470.deletedRecordsTable.name)+" ("
	
	For each ($o; This:C1470.deletedRecordsTable.fields)
		
		DOCUMENT+=" "+String:C10($o.name)+" "+String:C10($o.type)+","
		
		If (Bool:C1537($o.primaryKey))
			
			DOCUMENT+=" PRIMARY KEY ("+String:C10($o.name)+"),"
			
		End if 
	End for each 
	
	// Delete the last ","
	DOCUMENT:=Delete string:C232(DOCUMENT; Length:C16(DOCUMENT); 1)
	
	DOCUMENT+=");"
	
	Begin SQL
		
		EXECUTE IMMEDIATE : DOCUMENT
		
	End SQL
	
	If ($error.noError())
		
		For each ($o; This:C1470.deletedRecordsTable.fields)
			
			If (Bool:C1537($o.autoincrement))
				
				DOCUMENT:="ALTER TABLE "+String:C10(This:C1470.deletedRecordsTable.name)+" MODIFY "+String:C10($o.name)+" ENABLE AUTO_INCREMENT;"
				
				Begin SQL
					
					EXECUTE IMMEDIATE : DOCUMENT
					
				End SQL
				
			End if 
			
			If ($error.withError())
				
				This:C1470.errors.push(JSON Stringify:C1217($error.errors())+" ("+DOCUMENT+")")
				$error.release()
				return False:C215
				
			End if 
		End for each 
	End if 
	
	// Create the indexes if any
	If ($error.noError())
		
		For each ($o; This:C1470.deletedRecordsTable.fields)
			
			If (Bool:C1537($o.indexed))
				
				DOCUMENT:="CREATE INDEX "+String:C10(This:C1470.deletedRecordsTable.name)+String:C10($o.name)+" ON "+String:C10(This:C1470.deletedRecordsTable.name)+" ("+String:C10($o.name)+");"
				
				Begin SQL
					
					EXECUTE IMMEDIATE : DOCUMENT
					
				End SQL
				
				If ($error.withError())
					
					If ($error.lastError().stack[0].code=1155)
						
						This:C1470.warnings.push("Index already exists for the attribute \""+$o.name+"\" of the table \""+This:C1470.deletedRecordsTable.name+"\"")
						$error.ignoreLastError()
						
					Else 
						
						This:C1470.errors.push(JSON Stringify:C1217($error.errors())+" ("+DOCUMENT+")")
						$error.release()
						return False:C215
						
					End if 
				End if 
			End if 
		End for each 
	End if 
	
	If ($error.noError())
		
		// Mark:Create __GlobalStamp for published dataclasses
		If ($publishedTableNames#Null:C1517)\
			 && ($publishedTableNames.length>0)
			
			var $str : cs:C1710.str
			$str:=cs:C1710.str.new()
			
			For each ($t; $publishedTableNames)
				
				DOCUMENT:="ALTER TABLE ["+$t+"] ADD TRAILING "+String:C10(This:C1470.stampField.name)+" "+String:C10(This:C1470.stampField.type)+";"
				
				Begin SQL
					
					EXECUTE IMMEDIATE : DOCUMENT
					
				End SQL
				
				If ($error.withError())
					
					If ($error.lastError().stack[0].code=1053)
						
						This:C1470.warnings.push("Attribute \""+This:C1470.stampField.name+"\" already exists for the dataclass \""+$t+"\"")
						$error.ignoreLastError()
						
					End if 
				End if 
				
				If ($error.noError())
					
					If (Bool:C1537(This:C1470.stampField.indexed))
						
						DOCUMENT:="CREATE INDEX "+String:C10(This:C1470.stampField.name)+"_"+$str.lowerCamelCase($t)+" ON ["+$t+"] ("+String:C10(This:C1470.stampField.name)+");"
						
						Begin SQL
							
							EXECUTE IMMEDIATE : DOCUMENT
							
						End SQL
						
						If ($error.withError())
							
							If ($error.lastError().stack[0].code=1155)
								
								// Index already exists
								This:C1470.warnings.push("Index of the attribute \""+This:C1470.stampField.name+"\\ of the dataclass \""+$t+"\" already exists")
								$error.ignoreLastError()
								
							Else 
								
								This:C1470.errors.push(JSON Stringify:C1217($error.errors())+" ("+DOCUMENT+")")
								$error.release()
								return False:C215
								
							End if 
						End if 
					End if 
				End if 
			End for each 
		End if 
	End if 
	
	$error.release()
	
	return True:C214
	