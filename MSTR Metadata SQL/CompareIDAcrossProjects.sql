/*		
**  TH 2017-Mar		
**  Query MSTR Metadata to collect all objects in %Custom% folders		
**  @Project parameter is needed to filter the results. 		
*/		
Use MSTR_Metadata;		
		
DECLARE @Project1 as nvarchar(250);		
SET @Project1 = 'MyProj Dev';		

DECLARE @Project2 as nvarchar(250);		
SET @Project2 = 'MyProj';		
		
WITH DIR AS (		
	SELECT o.PROJECT_ID, o.OBJECT_ID, o.PARENT_ID, o.OBJECT_NAME Name, CAST('/' AS nvarchar(max)) Folder	
	FROM DSSMDOBJINFO o	
	WHERE o.PARENT_ID = '00000000-0000-0000-0000-000000000000'	
	AND o.OBJECT_NAME <> 'Managed Objects'	
		
	UNION ALL	
		
	SELECT o.PROJECT_ID, o.OBJECT_ID, o.PARENT_ID, o.OBJECT_NAME Name, o2.Folder + o2.Name + '/' Folder	
	FROM DSSMDOBJINFO o	
	JOIN DIR o2 ON o.PARENT_ID = o2.OBJECT_ID AND o.PROJECT_ID = o2.PROJECT_ID	
	WHERE o.OBJECT_NAME <> 'System Objects'	
)		
		
SELECT 		
--o.oSOURCE		
CASE O.OBJECT_TYPE		
	WHEN 1 THEN 'Filter (1)'		WHEN 2 THEN 'Template (2)' 		WHEN 3 THEN 'Report'		WHEN 4 THEN 'Metric'		WHEN 6 THEN 'Autostyle (6)'		WHEN 8 THEN 'Folder (8)'	
	WHEN 10 THEN 'Prompt (10)'		WHEN 11 THEN 'Function (11)'		WHEN 12 THEN 'Attribute'		WHEN 13 THEN 'Fact'		WHEN 14 THEN 'Hierarchy (14)'		WHEN 15 THEN 'Table (15)'	
	WHEN 18 THEN 'Shortcut'		WHEN 21 THEN 'Attribute ID (21)'		WHEN 22 THEN 'Schema (22)'		WHEN 23 THEN 'Cell Format (23)'		WHEN 24 THEN 'Warehouse Catalog (24)'	
	WHEN 25 THEN 'Warehouse Catalog Definition (25)'		WHEN 26 THEN 'Table Column (26)'		WHEN 28 THEN 'Property Sets (28)'		WHEN 34 THEN 'Users/Groups (34)'	
	WHEN 39 THEN 'Search (39)'		WHEN 42 THEN 'Package (42)'		WHEN 43 THEN 'Transformation (43)'		WHEN 47 THEN 'Consoloidations (47)'		WHEN 52 THEN 'Link (52)'	
	WHEN 53 THEN 'Warehouse Table (53)'		WHEN 55 THEN 'Document'		WHEN 56 THEN 'Drill Map (56)'		WHEN 58 THEN 'Security Filter (58)'		WHEN 60 THEN 'Answer (60)'	
	WHEN 61 THEN 'Graph Style (61)'		WHEN 71 THEN 'Palette (71)'		ELSE 'OTHERS'	
END AS [OBJECT TYPE]		

	
,dbo.fn_UniqueidentifierToCharMSTR(o.OBJECT_ID) GUID	
,dbo.fn_UniqueidentifierToCharMSTR(c.OBJECT_ID) NewGUID	

,(Select p.object_name From DSSMDOBJINFO p Where p.OBJECT_id = c.PROJECT_ID AND p.OBJECT_TYPE = 32) NewProj

,o.OBJECT_NAME [OBJECT NAME]	
,d.FOLDER [OBJECT FOLDER]

,o.CREATE_TIME		
,o.MOD_TIME		
		

FROM 		
DSSMDOBJINFO o	
	
JOIN DSSMDOBJINFO c 
ON c.OBJECT_NAME = o.OBJECT_NAME 
	AND c.OBJECT_TYPE = o.OBJECT_TYPE
	AND c.PARENT_ID = o.PARENT_ID
	AND c.PROJECT_ID = (Select p.object_id From DSSMDOBJINFO p Where p.OBJECT_NAME = @Project2 AND p.OBJECT_TYPE = 32)
		
LEFT JOIN DIR d ON d.OBJECT_ID = o.OBJECT_ID AND d.PROJECT_ID = o.PROJECT_ID	
			
		
WHERE 		
o.PROJECT_ID = (Select p.object_id From DSSMDOBJINFO p Where p.OBJECT_NAME = @Project1 AND p.OBJECT_TYPE = 32)	

AND o.OBJECT_ID <> c.OBJECT_ID	

AND d.Folder NOT LIKE '%Profiles%'
AND d.Folder NOT LIKE '%/QA/%'
		
order by o.OBJECT_TYPE, o.OBJECT_NAME	
