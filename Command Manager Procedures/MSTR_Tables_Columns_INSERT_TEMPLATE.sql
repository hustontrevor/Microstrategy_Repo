TRUNCATE TABLE dbo.MSTR_Tables_Columns
GO

--This insert is created via a Command Manager script run through the Build Server
INSERT INTO dbo.MSTR_Tables_Columns 
( 
	RunDate 
	,Project 
	,iServer 
	,TableGUID 
	,TableName 
	,WarehouseTableName 
	,ColumnName 
	,DataType 
) 
SELECT getDate(),'MyProj Falcon Dev','vm-XXXXX','50E0FF264CAE3EC8E5B7968890F4CB58','Admit_Date_Day_Of_Month','Date_Day_Of_Month','Date_Day_Of_Month','Integer (4)'
UNION ALL SELECT getDate(),'MyProj Falcon Dev','vm-XXXXX','667A2F1348DE6611D5DF22AA962C8125','Admit_Date_Dim','Admit_Date_Dim','Date_Month','Unsigned (1)'