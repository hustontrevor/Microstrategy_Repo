/*
**  TH 2017-Jan
**  Query MSTR Metadata to collect full list of Reports and Documents
**  @Project parameter is needed to filter the results. 
*/

DECLARE @Project as nvarchar(250);
SET @Project = 'MyProj';

WITH DIR AS (
	SELECT o.PROJECT_ID, o.OBJECT_ID, o.PARENT_ID, o.OBJECT_NAME Name, CAST('\' AS nvarchar(max)) Folder
	FROM DSSMDOBJINFO o
	WHERE o.PARENT_ID = '00000000-0000-0000-0000-000000000000'
	AND o.OBJECT_NAME <> 'Managed Objects'

	UNION ALL

	SELECT o.PROJECT_ID, o.OBJECT_ID, o.PARENT_ID, o.OBJECT_NAME Name, o2.Folder + o2.Name + '\' Folder
	FROM DSSMDOBJINFO o
	JOIN DIR o2 ON o.PARENT_ID = o2.OBJECT_ID AND o.PROJECT_ID = o2.PROJECT_ID
)

SELECT 
dbo.fn_UniqueidentifierToCharMSTR(o.OBJECT_ID) GUID
,o.OBJECT_NAME
,d.Folder
,o.CREATE_TIME
,o.MOD_TIME

, CASE O.OBJECT_TYPE		
	WHEN 1 THEN 'Filter'	WHEN 2 THEN 'Template' 	WHEN 3 THEN 'Report'	WHEN 4 THEN 'Metric'	
	WHEN 6 THEN 'Autostyle'	WHEN 8 THEN 'Folder'	WHEN 10 THEN 'Prompt'	WHEN 11 THEN 'Function'	
	WHEN 12 THEN 'Attribute'	WHEN 13 THEN 'Fact'	WHEN 14 THEN 'Hierarchy'	WHEN 15 THEN 'Table'	
	WHEN 18 THEN 'Shortcut'		WHEN 21 THEN 'Attribute ID'	WHEN 22 THEN 'Schema'	WHEN 23 THEN 'Cell Format'	
	WHEN 24 THEN 'Warehouse Catalog'	WHEN 25 THEN 'Warehouse Catalog Definition'	WHEN 26 THEN 'Table Column'	
	WHEN 28 THEN 'Property Sets'		WHEN 34 THEN 'Users/Groups'		WHEN 39 THEN 'Search'	
	WHEN 42 THEN 'Package'		WHEN 43 THEN 'Transformation'	WHEN 47 THEN 'Consoloidations'	
	WHEN 52 THEN 'Link'		WHEN 53 THEN 'Warehouse Table'		WHEN 55 THEN 'Document'	
	WHEN 56 THEN 'Drill Map'	WHEN 58 THEN 'Security Filter'	WHEN 60 THEN 'Answer'	
	WHEN 61 THEN 'Graph Style'	WHEN 71 THEN 'Palette'		ELSE 'OTHERS'	
END AS OBJECT_TYPE	


FROM DSSMDOBJINFO o
join DIR d ON d.OBJECT_ID = o.OBJECT_ID AND d.PROJECT_ID = o.PROJECT_ID

WHERE 
o.PROJECT_ID IN (Select p.object_id From DSSMDOBJINFO p Where p.OBJECT_NAME LIKE '%' + @Project + '%' AND p.OBJECT_TYPE = 32)

--AND o.OBJECT_TYPE IN (3, 55) -- Reports and Documents
AND o.OBJECT_TYPE <> 8  -- Ignore Folders

AND ( d.Folder LIKE '%Delete%' OR o.OBJECT_NAME LIKE '%Delete%' )
AND d.Folder NOT LIKE '%\Profiles%'

order by d.Folder, o.OBJECT_NAME



