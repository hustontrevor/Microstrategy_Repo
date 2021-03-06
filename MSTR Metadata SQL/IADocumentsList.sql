/*		
**  TH 2017-Feb		
**  Query MSTR Metadata to collect all objects used in 'Self Service'		
**  @Project parameter is needed to filter the results. 		
*/		
Use MSTR_Metadata;		
		
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
	WHERE o.OBJECT_NAME <> 'System Objects'	
)		
, UGROUPSHIERARCHY AS (			
	SELECT 1 lvl, g.OBJECT_NAME, g.OBJECT_ID, g.OBJECT_NAME TOPPARENTCLIENT, g.OBJECT_ID TOPPARENTGUID		
     FROM DSSMDOBJDEPN d 			
		join DSSMDOBJINFO g on d.OBJECT_ID = g.OBJECT_ID 	
		join DSSMDOBJINFO p on d.DEPN_OBJID = p.OBJECT_ID 	
      WHERE p.OBJECT_TYPE = 34 and p.SUBTYPE <> 8704			
	  AND p.OBJECT_NAME = 'CLIENTS'		
			
	UNION ALL 		
			
	SELECT u.lvl + 1, g.OBJECT_NAME, g.OBJECT_ID, u.TOPPARENTCLIENT, u.TOPPARENTGUID		
     FROM DSSMDOBJDEPN d 			
		join UGROUPSHIERARCHY u on d.DEPN_OBJID = u.OBJECT_ID 	
		join DSSMDOBJINFO g on d.OBJECT_ID = g.OBJECT_ID 	
	 WHERE g.OBJECT_TYPE = 34 and g.SUBTYPE <> 8704		
)
	
SELECT 		
--o.oSOURCE,		
CASE O.OBJECT_TYPE		
	WHEN 1 THEN 'Filter'		WHEN 2 THEN 'Template' 		WHEN 3 THEN 'Report'		WHEN 4 THEN 'Metric'	
	WHEN 6 THEN 'Autostyle'		WHEN 8 THEN 'Folder'		WHEN 10 THEN 'Prompt'		WHEN 11 THEN 'Function'	
	WHEN 12 THEN 'Attribute'		WHEN 13 THEN 'Fact'		WHEN 14 THEN 'Hierarchy'		WHEN 15 THEN 'Table'	
	WHEN 18 THEN 'Shortcut'		WHEN 21 THEN 'Attribute ID'		WHEN 22 THEN 'Schema'		WHEN 23 THEN 'Cell Format'	
	WHEN 24 THEN 'Warehouse Catalog'		WHEN 25 THEN 'Warehouse Catalog Definition'	
	WHEN 26 THEN 'Table Column'		WHEN 28 THEN 'Property Sets'		WHEN 34 THEN 'Users/Groups'		WHEN 39 THEN 'Search'	
	WHEN 42 THEN 'Package'		WHEN 43 THEN 'Transformation'		WHEN 47 THEN 'Consoloidations'		WHEN 52 THEN 'Link'	
	WHEN 53 THEN 'Warehouse Table'		WHEN 55 THEN 'Document'		WHEN 56 THEN 'Drill Map'		WHEN 58 THEN 'Security Filter'	
	WHEN 60 THEN 'Answer'		WHEN 61 THEN 'Graph Style'		WHEN 71 THEN 'Palette'		ELSE 'OTHERS'	
END AS [Object_Type]	
		
,u.OBJECT_NAME
		
,dbo.fn_UniqueidentifierToCharMSTR(o.OBJECT_ID) GUID		
,o.OBJECT_NAME [OBJECT NAME]	
,REPLACE(d.FOLDER,'\' + @Project,'') [OBJECT FOLDER]

,o.DESCRIPTION 
	
		
FROM DSSMDOBJINFO o				
JOIN DIR d ON d.OBJECT_ID = o.OBJECT_ID AND d.PROJECT_ID = o.PROJECT_ID		
LEFT JOIN UGROUPSHIERARCHY u 
	ON (o.OBJECT_NAME LIKE '%' + u.OBJECT_NAME + '%'
		AND u.lvl = 1)
		
		
WHERE 		
o.PROJECT_ID = (Select p.object_id From DSSMDOBJINFO p Where p.OBJECT_NAME = @Project AND p.OBJECT_TYPE = 32)		
		
AND d.Folder LIKE '%Applications%'		
AND d.Folder NOT LIKE '%To Be Deleted%'		

AND o.OBJECT_TYPE <> 8  -- Ignore Folders		
AND o.OBJECT_TYPE = 55  -- Documents
		
order by d.Folder ,o.OBJECT_NAME		
