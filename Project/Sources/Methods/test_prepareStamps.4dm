//%attributes = {}

var $prepare : cs:C1710.PrepareStamps
$prepare:=cs:C1710.PrepareStamps.new()

var $status : Boolean
$status:=$prepare.verify()

If (Not:C34($status))
	If (Shift down:C543)
		ALERT:C41(JSON Stringify:C1217($prepare.errors; *))
	End if 
Else 
	// nothing to test, TODO: maybe remote deleted record table and some global stamps
	// so do it manually first
End if 

var $status : Boolean
$status:=$prepare.run()
ASSERT:C1129($status; JSON Stringify:C1217($prepare.errors; *))

$status:=$prepare.verify()

ASSERT:C1129($status; JSON Stringify:C1217($prepare.errors; *))