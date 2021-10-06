DECLARE @Project as nvarchar(250);
DECLARE @ProjectID as nvarchar(250);
SET @Project = 'MyProj Falcon RFQA';
SET @ProjectID = (Select p.object_id From DSSMDOBJINFO p Where p.OBJECT_NAME = @Project AND p.OBJECT_TYPE = 32);

DECLARE @Table as nvarchar(250);
SET @Table = 'Budget_Person_Fact';

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

,DEPN AS (		
	SELECT 1 lvl, d.*, cast(cast(o.OBJECT_TYPE as varchar(5)) + ' ' + o.OBJECT_NAME + '/' as varchar(max)) HPath
	FROM dbo.DSSMDOBJDEPN d
		JOIN DSSMDOBJINFO o ON o.OBJECT_ID = d.DEPN_OBJID AND o.PROJECT_ID = d.PROJECT_ID
	WHERE --d.PROJECT_ID = @ProjectID	
		--AND o.OBJECT_NAME = @Table
		( o.OBJECT_NAME LIKE '%XXXXX%' OR o.OBJECT_NAME LIKE '%XXXXX%' OR o.OBJECT_NAME LIKE '%XXXXX%' OR o.OBJECT_NAME LIKE '%CustomerKC%' )
		AND o.OBJECT_TYPE = 15		
		
	UNION ALL	
		
	SELECT d0.lvl + 1 lvl, d.*, d0.HPath + cast(cast(o.OBJECT_TYPE as varchar(5)) +' ' +  o.OBJECT_NAME + '/' as varchar(max)) HPath
	FROM DEPN d0
		JOIN dbo.DSSMDOBJDEPN d ON d0.OBJECT_ID = d.DEPN_OBJID AND d0.DEPN_PRJID = d.PROJECT_ID
		JOIN DSSMDOBJINFO o ON o.OBJECT_ID = d.DEPN_OBJID AND o.PROJECT_ID = d.PROJECT_ID
	WHERE d.DEPNOBJ_TYPE NOT IN (15, 11, 22) -- no tables (infinite recursion), functions, schema, schema hierarchy
		AND lvl < 90
)

SELECT 
d.lvl
,(Select p.object_name From DSSMDOBJINFO p Where p.object_id = o.project_id ) PROJECT
, o.OBJECT_ID
, f.Folder
, o.OBJECT_NAME
, case o.object_type
	when 1 then 'filter' when 2 then 'template' when 3 then 'report' when 4 then 'metric' when 6 then 'autostyle'
	when 8 then 'folder' when 10 then 'prompt' when 11 then 'function' when 12 then 'attribute' when 13 then 'fact'
	when 14 then 'hierarchy' when 15 then 'table' when 18 then 'shortcut' when 21 then 'attribute id' when 22 then 'schema'
	when 23 then 'cell format' when 24 then 'warehouse catalog' when 25 then 'warehouse catalog definition' when 26 then 'table column'
	when 28 then 'property sets' when 34 then 'users/groups' when 39 then 'search' when 42 then 'package' when 43 then 'transformation'
	when 47 then 'consolidations' when 52 then 'link' when 53 then 'warehouse table' when 55 then 'document' when 56 then 'drill map'
	when 58 then 'security filter' when 60 then 'answer' when 61 then 'graph style' when 71 then 'palette' else 'OTHERS'
end AS OBJ_TYPE
, od.OBJECT_ID DEPN_ID
, od.OBJECT_NAME DEPN_NM
, case od.object_type
	when 1 then 'filter' when 2 then 'template' when 3 then 'report' when 4 then 'metric' when 6 then 'autostyle'
	when 8 then 'folder' when 10 then 'prompt' when 11 then 'function' when 12 then 'attribute' when 13 then 'fact'
	when 14 then 'hierarchy' when 15 then 'table' when 18 then 'shortcut' when 21 then 'attribute id' when 22 then 'schema'
	when 23 then 'cell format' when 24 then 'warehouse catalog' when 25 then 'warehouse catalog definition' when 26 then 'table column'
	when 28 then 'property sets' when 34 then 'users/groups' when 39 then 'search' when 42 then 'package' when 43 then 'transformation'
	when 47 then 'consolidations' when 52 then 'link' when 53 then 'warehouse table' when 55 then 'document' when 56 then 'drill map'
	when 58 then 'security filter' when 60 then 'answer' when 61 then 'graph style' when 71 then 'palette' else 'OTHERS'
end AS DEPN_TYPE
,HPath

,(SELECT COUNT(*) FROM DSSMDOBJDEPN dp WHERE dp.PROJECT_ID = o.PROJECT_ID AND dp.depn_objID = o.OBJECT_ID ) DependentCount

FROM DEPN d
JOIN DSSMDOBJINFO o ON o.OBJECT_ID = d.OBJECT_ID AND o.PROJECT_ID = d.PROJECT_ID
JOIN DSSMDOBJINFO od ON od.OBJECT_ID = d.DEPN_OBJID AND od.PROJECT_ID = d.DEPN_PRJID

LEFT JOIN DIR f ON f.OBJECT_ID = o.OBJECT_ID AND f.PROJECT_ID = o.PROJECT_ID

WHERE 
o.PROJECT_ID in (Select p.object_id From DSSMDOBJINFO p Where p.OBJECT_NAME NOT LIKE ('%old') AND p.OBJECT_TYPE = 32)


ORDER BY o.PROJECT_ID, d.lvl, od.OBJECT_NAME, o.OBJECT_NAME