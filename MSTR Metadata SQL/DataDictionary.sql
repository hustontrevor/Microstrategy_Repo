/*		
**  TH 2017-Jul		
**  Query MSTR Metadata to collect all objects for DataDictionary		
**  @Project parameter is needed to filter the results. 		
*/		
Use MSTR_Metadata;		
		
DECLARE @Project as nvarchar(250);		
SET @Project = 'MyProj Falcon Dev';		
		
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
dbo.fn_UniqueidentifierToCharMSTR(o.OBJECT_ID) OBJECT_GUID
,'MyProj' PROJECT
,o.OBJECT_NAME
,NULL NOTES
,o.DESCRIPTION
,'' SHORT_DESCRIPTION 
, case o.object_type
	when 1 then 'filter (1)' when 2 then 'template (2)' when 3 then 'report (3)' when 4 then 'metric (4)' when 6 then 'autostyle (6)'
	when 8 then 'folder (8)' when 10 then 'prompt (10)' when 11 then 'function (11)' when 12 then 'attribute (12)' when 13 then 'fact (13)'
	when 14 then 'hierarchy (14)' when 15 then 'table (15)' when 18 then 'shortcut (18)' when 21 then 'attribute id (21)' when 22 then 'schema (22)'
	when 23 then 'cell format (23)' when 24 then 'warehouse catalog (24)' when 25 then 'warehouse catalog definition (25)' when 26 then 'table column (26)'
	when 28 then 'property sets (28)' when 34 then 'users/groups (34)' when 39 then 'search (39)' when 42 then 'package (42)' when 43 then 'transformation (43)'
	when 47 then 'consolidations (47)' when 52 then 'link (52)' when 53 then 'warehouse table (53)' when 55 then 'document (55)' when 56 then 'drill map (56)'
	when 58 then 'security filter (58)' when 60 then 'answer (60)' when 61 then 'graph style (61)' when 71 then 'palette (71)' else 'OTHERS'
end AS oType		
	
,d.Folder FOLDER	

,'??' FINANCIAL
		
,CASE WHEN d.FOLDER LIKE '%Custom%'		
THEN SUBSTRING(d.FOLDER		
	,CHARINDEX('Custom',d.FOLDER)+7	
	,LEN(d.FOLDER)-(CHARINDEX('Custom',d.FOLDER)+7)-(LEN(RIGHT(d.FOLDER,LEN(d.FOLDER)-(CHARINDEX('Custom',d.FOLDER)+7)))-CHARINDEX('\',RIGHT(d.FOLDER,LEN(d.FOLDER)-(CHARINDEX('Custom',d.FOLDER)+7)))))	
ELSE 'Local Core'		
END CLIENT_NAME

,'??' SSMA_TIMESTAMP  

,CASE WHEN d.Folder LIKE '%DELETED%' THEN 'DELETED'
	WHEN o.HIDDEN = 1 THEN 'HIDDEN'
	ELSE '' END
  STATUS

,'??' VERSION 

/*		
,CASE WHEN sd.FOLDER LIKE '%Supporting Items%'		
THEN SUBSTRING(sd.FOLDER		
	,CHARINDEX('Supporting Items',sd.FOLDER)+17	
	,LEN(sd.FOLDER)-(CHARINDEX('Supporting Items',sd.FOLDER)+17)-(LEN(RIGHT(sd.FOLDER,LEN(sd.FOLDER)-(CHARINDEX('Supporting Items',sd.FOLDER)+17)))-CHARINDEX('\',RIGHT(sd.FOLDER,LEN(sd.FOLDER)-(CHARINDEX('Supporting Items',sd.FOLDER)+17)))))	
ELSE ' '		
END [MODULE]
*/
,'??' MODULE
,'??' SOURCE
,'??' DATA_TYPE  -- Command manager to check Forms

		
,ISNULL(STUFF((SELECT '; ' + CAST(t.OBJECT_NAME AS nVARCHAR(MAX))		
     FROM DSSMDOBJSECU s  		
		JOIN DSSMDOBJINFO t ON s.TRUST_ID = t.OBJECT_ID
     WHERE s.OBJECT_ID = o.OBJECT_ID AND s.PROJECT_ID = o.PROJECT_ID 		
		AND s.rights IN (128,268435583,   268435711,805306623) -- see OBJ Security.sql for list of values
     GROUP BY t.OBJECT_NAME	
     ORDER BY t.OBJECT_NAME	
     FOR XML PATH('')),1,1,''),' ') [CLIENTS DENIED ACCESS]		
		
		
FROM 		
DSSMDOBJINFO o	
		
LEFT JOIN DIR d ON d.OBJECT_ID = o.OBJECT_ID AND d.PROJECT_ID = o.PROJECT_ID		
		
		
WHERE 		
o.PROJECT_ID = (Select p.object_id From DSSMDOBJINFO p Where p.OBJECT_NAME = @Project AND p.OBJECT_TYPE = 32)		
		
--AND o.OBJECT_TYPE <> 8  -- Ignore Folders		
AND o.OBJECT_TYPE IN (4,12)  -- Atributes and Metrics


