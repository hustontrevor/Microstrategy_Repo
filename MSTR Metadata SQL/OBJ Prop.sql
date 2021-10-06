DECLARE @Project as nvarchar(250);
DECLARE @ProjectID as nvarchar(250);
DECLARE @Table as nvarchar(250);
SET @Project = 'MyProj';
SET @Table = 'Person_Address_Dim';
SET @ProjectID = (Select p.object_id From DSSMDOBJINFO p Where p.OBJECT_NAME = @Project AND p.OBJECT_TYPE = 32);

SELECT *
FROM dbo.DSSMDOBJINFO o
LEFT JOIN dbo.DSSMDOBJPROP p ON p.OBJECT_ID = o.OBJECT_ID AND p.PROJECT_ID = o.PROJECT_ID
WHERE o.OBJECT_NAME = 'Street_Address_1'

--cast(o.OBJECT_ID as varchar(250)) = --'50C7D0D3-11D3-7CF9-C000-2DB9EA33224F' 		dbo.fn_CharToUniqueidentifier('07D43CA64D6DFF6F9639F2A9A41679BC')
AND o.PROJECT_ID = @ProjectID