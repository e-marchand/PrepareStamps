# PrepareStamps

## Setup
 First create an instance 

```4d
var $prepare : cs.PrepareStamps
$prepare:=cs.PrepareStamps.new()
```

## Verify

To verify that all is ok

```4d
var $status : Boolean
$status:=$prepare.verify()
```

To verify for a selection of tables

```4d
var $status : Boolean
$status:=$prepare.verify(New collection("table1"; "table2"))
```

## Create/Modify

To create all missing fields and deleted record table

```4d
$status:=$prepare.run()
```

To create all missing fields of selected table and deleted record table

```4d
$status:=$prepare.run(New collection("table1"; "table2"))
```

## Errors

To have more information about last operation if return value is `False`

```4d
$col:=$prepare.errors
```
