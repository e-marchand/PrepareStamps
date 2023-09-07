# Prepare Stamps

... for tracking data changes

## trackin data changes?

By adding a `__GlobalStamp` field to a table, when a record is created or updated, it's `__GlobalStamp` field value will be set to the value of an auto incremental stamp global to the database.

```
example:
you create a Company C record: global stamp 1
you create an Employe A record: global stamp 2
you change Employe A name: global stamp 3 (no more 2 for the record)
you change a Company C record bale: global stamp 4
you create an Employe B record: global stamp 5
-> you have Company C with __GlobalStamps=4, Employe A with __GlobalStamp=3, Employe B with __GlobalStamp=5
```

So you could using ORDA query or REST ($filter) on each tables to get the data changes since a previous value of this global stamp.
For instance the filter used to request the data could be `__GlobalStamp > 42`

To track deleted records, records that could no more view in tables, we need a cemetery that contains all table id/names and primary key values of deleted records.
We create a table named `__DeletedRecords` , that could be consulted like any other tables, here using `__Stamp` if we want to see new deleted records since a previous value of global stamp.

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
