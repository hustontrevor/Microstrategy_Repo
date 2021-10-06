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
		
SELECT 		
--o.oSOURCE,

CASE WHEN sd.FOLDER LIKE '%Supporting Items%'		
THEN SUBSTRING(sd.FOLDER		
	,CHARINDEX('Supporting Items',sd.FOLDER)+17	
	,LEN(sd.FOLDER)-(CHARINDEX('Supporting Items',sd.FOLDER)+17)-(LEN(RIGHT(sd.FOLDER,LEN(sd.FOLDER)-(CHARINDEX('Supporting Items',sd.FOLDER)+17)))-CHARINDEX('\',RIGHT(sd.FOLDER,LEN(sd.FOLDER)-(CHARINDEX('Supporting Items',sd.FOLDER)+17)))))	
ELSE ' '		
END [MODULE]
		
,CASE O.OBJECT_TYPE		
	WHEN 1 THEN 'Filter'		WHEN 2 THEN 'Template' 		WHEN 3 THEN 'Report'		WHEN 4 THEN 'Metric'	
	WHEN 6 THEN 'Autostyle'		WHEN 8 THEN 'Folder'		WHEN 10 THEN 'Prompt'		WHEN 11 THEN 'Function'	
	WHEN 12 THEN 'Attribute'		WHEN 13 THEN 'Fact'		WHEN 14 THEN 'Hierarchy'		WHEN 15 THEN 'Table'	
	WHEN 18 THEN 'Shortcut'		WHEN 21 THEN 'Attribute ID'		WHEN 22 THEN 'Schema'		WHEN 23 THEN 'Cell Format'	
	WHEN 24 THEN 'Warehouse Catalog'		WHEN 25 THEN 'Warehouse Catalog Definition'	
	WHEN 26 THEN 'Table Column'		WHEN 28 THEN 'Property Sets'		WHEN 34 THEN 'Users/Groups'		WHEN 39 THEN 'Search'	
	WHEN 42 THEN 'Package'		WHEN 43 THEN 'Transformation'		WHEN 47 THEN 'Consoloidations'		WHEN 52 THEN 'Link'	
	WHEN 53 THEN 'Warehouse Table'		WHEN 55 THEN 'Document'		WHEN 56 THEN 'Drill Map'		WHEN 58 THEN 'Security Filter'	
	WHEN 60 THEN 'Answer'		WHEN 61 THEN 'Graph Style'		WHEN 71 THEN 'Palette'		ELSE 'OTHERS'	
END AS [Object Type]		

,CASE WHEN sd.Folder LIKE '%\Metrics\' THEN 'N/A'
 ELSE
 REVERSE(SUBSTRING(REVERSE(LEFT(sd.FOLDER,LEN(sd.FOLDER)-1)),0,CHARINDEX('\',REVERSE(LEFT(sd.FOLDER,LEN(sd.FOLDER)-1))))) 
 END [Folder]

,CASE WHEN o.SS_OBJECT_NAME <> '' THEN o.SS_OBJECT_NAME ELSE o.OBJECT_NAME END [Object Name]
	
,o.DESCRIPTION [Description]
		
,CASE WHEN d.FOLDER LIKE '%Custom%'		
THEN SUBSTRING(d.FOLDER		
	,CHARINDEX('Custom',d.FOLDER)+7	
	,LEN(d.FOLDER)-(CHARINDEX('Custom',d.FOLDER)+7)-(LEN(RIGHT(d.FOLDER,LEN(d.FOLDER)-(CHARINDEX('Custom',d.FOLDER)+7)))-CHARINDEX('\',RIGHT(d.FOLDER,LEN(d.FOLDER)-(CHARINDEX('Custom',d.FOLDER)+7)))))	
ELSE ' '		
END [Custom Object]

--,o.CREATE_TIME	
,o.SS_CREATE_TIME [Date Added]
--,o.MOD_TIME		
--,o.SS_MOD_TIME	

/*		
,ISNULL(STUFF((SELECT '; ' + CAST(t.OBJECT_NAME AS nVARCHAR(MAX))		
     FROM DSSMDOBJSECU s  		
		JOIN DSSMDOBJINFO t ON s.TRUST_ID = t.OBJECT_ID
     WHERE s.OBJECT_ID = o.OBJECT_ID AND s.PROJECT_ID = o.PROJECT_ID 		
		AND s.rights IN (128,268435583,   268435711,805306623) -- see OBJ Security.sql for list of values
     GROUP BY t.OBJECT_NAME	
     ORDER BY t.OBJECT_NAME	
     FOR XML PATH('')),1,1,''),' ') [CLIENTS DENIED ACCESS]		
		
--,dbo.fn_UniqueidentifierToCharMSTR(o.OBJECT_ID) GUID		
,o.OBJECT_NAME [OBJECT NAME]	
,REPLACE(d.FOLDER,'\' + @Project,'') [OBJECT FOLDER]
	*/	
--,dbo.fn_UniqueidentifierToCharMSTR(o.SS_OBJECT_ID) SS_GUID		

-- Just the last folder

 --,sd.FOLDER

--,o.SS_DESCRIPTION	
		
--,o.OBJECT_TYPE		
--,o.SUBTYPE		
		
--,O_OWNER.OBJECT_NAME OOWNER		
--,O_OWNER.ABBREVIATION OOWNER_LOGIN		
		
		
FROM 		
(SELECT 'Base Objects' oSOURCE		
	,o.OBJECT_NAME ,o.OBJECT_ID ,o.PROJECT_ID ,o.OWNER_ID 	
	,o.DESCRIPTION ,o.OBJECT_TYPE ,o.SUBTYPE ,o.CREATE_TIME ,o.MOD_TIME	
	,o.OBJECT_NAME SS_OBJECT_NAME ,o.OBJECT_ID SS_OBJECT_ID ,o.PROJECT_ID SS_PROJECT_ID ,o.OWNER_ID SS_OWNER_ID 	
	,o.DESCRIPTION SS_DESCRIPTION,o.OBJECT_TYPE SS_OBJECT_TYPE ,o.SUBTYPE SS_SUBTYPE ,o.CREATE_TIME SS_CREATE_TIME ,o.MOD_TIME SS_MOD_TIME	
	FROM DSSMDOBJINFO o	
	WHERE o.OBJECT_TYPE <> 18 -- skip Shortcuts	
UNION ALL 		
	SELECT 'Report Components' oSOURCE	
	,co.OBJECT_NAME ,co.OBJECT_ID ,co.PROJECT_ID ,co.OWNER_ID 	
	,co.DESCRIPTION ,co.OBJECT_TYPE ,co.SUBTYPE ,co.CREATE_TIME ,co.MOD_TIME	
	,o.OBJECT_NAME + ' - ' + co.OBJECT_NAME SS_OBJECT_NAME ,o.OBJECT_ID SS_OBJECT_ID ,o.PROJECT_ID SS_PROJECT_ID ,o.OWNER_ID SS_OWNER_ID 	
	,o.DESCRIPTION SS_DESCRIPTION ,o.OBJECT_TYPE SS_OBJECT_TYPE ,o.SUBTYPE SS_SUBTYPE ,o.CREATE_TIME SS_CREATE_TIME ,o.MOD_TIME SS_MOD_TIME
	FROM DSSMDOBJINFO o	
	 JOIN DSSMDOBJDEPN c ON o.OBJECT_TYPE = 3 AND o.OBJECT_ID = c.OBJECT_ID AND o.PROJECT_ID = c.PROJECT_ID	
	 JOIN DSSMDOBJINFO co ON co.OBJECT_ID = c.DEPN_OBJID AND co.PROJECT_ID = c.PROJECT_ID	
UNION ALL 		
	SELECT 'Shortcuts' oSOURCE	
	,do.OBJECT_NAME ,do.OBJECT_ID ,do.PROJECT_ID ,do.OWNER_ID 	
	,do.DESCRIPTION ,do.OBJECT_TYPE ,do.SUBTYPE ,do.CREATE_TIME ,do.MOD_TIME	
	,o.OBJECT_NAME SS_OBJECT_NAME ,o.OBJECT_ID SS_OBJECT_ID ,o.PROJECT_ID SS_PROJECT_ID ,o.OWNER_ID SS_OWNER_ID 	
	,o.DESCRIPTION SS_DESCRIPTION ,o.OBJECT_TYPE SS_OBJECT_TYPE ,o.SUBTYPE SS_SUBTYPE ,o.CREATE_TIME SS_CREATE_TIME ,o.MOD_TIME SS_MOD_TIME
	FROM DSSMDOBJINFO o	
	 JOIN DSSMDOBJDEPN dp ON o.OBJECT_TYPE = 18 AND o.OBJECT_ID = dp.OBJECT_ID AND o.PROJECT_ID = dp.PROJECT_ID	
	 JOIN DSSMDOBJINFO do ON do.OBJECT_ID = dp.DEPN_OBJID AND do.PROJECT_ID = dp.PROJECT_ID 	
) o		
		
LEFT JOIN DIR d ON d.OBJECT_ID = o.OBJECT_ID AND d.PROJECT_ID = o.PROJECT_ID		
JOIN DIR sd ON sd.OBJECT_ID = o.SS_OBJECT_ID AND sd.PROJECT_ID = o.SS_PROJECT_ID		
		
LEFT JOIN DSSMDOBJINFO o_owner on o.OWNER_ID = o_owner.OBJECT_ID 		
		
		
WHERE 		
o.PROJECT_ID = (Select p.object_id From DSSMDOBJINFO p Where p.OBJECT_NAME = @Project AND p.OBJECT_TYPE = 32)		
		
AND sd.Folder LIKE '%Self Service\Supporting Items%'		
AND o.OBJECT_TYPE <> 8  -- Ignore Folders		
AND o.OBJECT_TYPE IN (4,12)  -- Atributes and Metrics
		
-- Filters for Confluence [List of Available Objects]
AND sd.Folder NOT LIKE '%Falcon Testing%'
AND sd.Folder NOT LIKE '%\Objects\%'
AND sd.Folder NOT LIKE '%\To Be Deleted\%'
--AND o.oSOURCE <> 'Base Objects'
		
order by sd.Folder ,2 ,3 ,o.OBJECT_NAME		

