/*
**  TH 2017-Jan
**  Query MSTR Metadata to collect full list of Reports and Documents
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
)

SELECT 
o.OBJECT_NAME
,d.Folder
,o.CREATE_TIME
,o.MOD_TIME
,dbo.fn_UniqueidentifierToCharMSTR(o.OBJECT_ID) GUID

,o.OBJECT_TYPE
,o.SUBTYPE
, CASE o.object_type
	WHEN 1 THEN 'Filter (1)'	
	WHEN 2 THEN 'Template (2)' 	
	WHEN 3 THEN 'Report'	
	WHEN 4 THEN 'Metric'	
	WHEN 6 THEN 'Autostyle (6)'	
	WHEN 8 THEN 'Folder (8)'	
	WHEN 10 THEN 'Prompt (10)'	
	WHEN 11 THEN 'Function (11)'	
	WHEN 12 THEN 'Attribute'	
	WHEN 13 THEN 'Fact (13)'	
	WHEN 14 THEN 'Hierarchy (14)'	
	WHEN 15 THEN 'Table (15)'	
	WHEN 18 THEN 'Shortcut'	
	WHEN 21 THEN 'Attribute ID (21)'	
	WHEN 22 THEN 'Schema (22)'	
	WHEN 23 THEN 'Cell Format (23)'	
	WHEN 24 THEN 'Warehouse Catalog (24)'	
	WHEN 25 THEN 'Warehouse Catalog Definition (25)'	
	WHEN 26 THEN 'Table Column (26)'	
	WHEN 28 THEN 'Property Sets (28)'	
	WHEN 34 THEN 'Users/Groups (34)'	
	WHEN 39 THEN 'Search (39)'	
	WHEN 42 THEN 'Package (42)'	
	WHEN 43 THEN 'Transformation (43)'	
	WHEN 47 THEN 'Consoloidations (47)'	
	WHEN 52 THEN 'Link (52)'	
	WHEN 53 THEN 'Warehouse Table (53)'	
	WHEN 55 THEN 'Document'	
	WHEN 56 THEN 'Drill Map (56)'	
	WHEN 58 THEN 'Security Filter (58)'	
	WHEN 60 THEN 'Answer (60)'	
	WHEN 61 THEN 'Graph Style (61)'	
	WHEN 71 THEN 'Palette (71)'	
	ELSE 'OTHERS'
END AS oType

,o_owner.OBJECT_NAME oOwner
,o_owner.ABBREVIATION oOwner_Login
,o_Add.ADDRESS OwnerAddress

,STUFF((SELECT ';' + CAST(g.OBJECT_NAME AS nVARCHAR(MAX))
     FROM DSSMDOBJDEPN d 
		join DSSMDOBJINFO u on d.OBJECT_ID = u.OBJECT_ID 
		join DSSMDOBJINFO g on d.DEPN_OBJID = g.OBJECT_ID 
      WHERE u.OBJECT_TYPE = 34 and u.SUBTYPE = 8704 --subtype = users
        AND u.OBJECT_ID = o_owner.OBJECT_ID 
      ORDER BY g.OBJECT_NAME
     FOR XML PATH('')),1,1,'') OwnerGroups

FROM DSSMDOBJINFO o
join DIR d ON d.OBJECT_ID = o.OBJECT_ID AND d.PROJECT_ID = o.PROJECT_ID
left join DSSMDOBJINFO o_owner on o.OWNER_ID = o_owner.OBJECT_ID 
left join DSSCSADDRESS o_Add on o_Add.CONTACT_ID = dbo.fn_UniqueidentifierToCharMSTR(o_owner.OBJECT_ID) AND o_Add.DELIVERY_TYPE = 1

WHERE 
o.PROJECT_ID = (Select p.object_id From DSSMDOBJINFO p Where p.OBJECT_NAME = @Project AND p.OBJECT_TYPE = 32)

--AND o.OBJECT_TYPE IN (3, 55) -- Reports and Documents
AND o.OBJECT_TYPE <> 8  -- Ignore Folders

order by d.Folder, o.OBJECT_NAME



