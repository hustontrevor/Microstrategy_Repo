DECLARE @Project as nvarchar(250);
DECLARE @ProjectID as nvarchar(250);

SET @Project = 'MyProj Falcon';
SET @ProjectID = (Select p.object_id From DSSMDOBJINFO p Where p.OBJECT_NAME = @Project AND p.OBJECT_TYPE = 32);

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
--CASE WHEN o.OBJECT_NAME = @Table THEN 'Component' ELSE 'Dependent' END Relation,
o.OBJECT_ID
, o.OBJECT_NAME
, case o.object_type
	when 1 then 'filter (1)' when 2 then 'template (2)' when 3 then 'report (3)' when 4 then 'metric (4)' when 6 then 'autostyle (6)'
	when 8 then 'folder (8)' when 10 then 'prompt (10)' when 11 then 'function (11)' when 12 then 'attribute (12)' when 13 then 'fact (13)'
	when 14 then 'hierarchy (14)' when 15 then 'table (15)' when 18 then 'shortcut (18)' when 21 then 'attribute id (21)' when 22 then 'schema (22)'
	when 23 then 'cell format (23)' when 24 then 'warehouse catalog (24)' when 25 then 'warehouse catalog definition (25)' when 26 then 'table column (26)'
	when 28 then 'property sets (28)' when 34 then 'users/groups (34)' when 39 then 'search (39)' when 42 then 'package (42)' when 43 then 'transformation (43)'
	when 47 then 'consolidations (47)' when 52 then 'link (52)' when 53 then 'warehouse table (53)' when 55 then 'document (55)' when 56 then 'drill map (56)'
	when 58 then 'security filter (58)' when 60 then 'answer (60)' when 61 then 'graph style (61)' when 71 then 'palette (71)' else 'OTHERS'
end AS oType

,f.Folder OBJECT_PATH

FROM DSSMDOBJINFO o

JOIN DIR f ON f.OBJECT_ID = o.OBJECT_ID AND o.PROJECT_ID = f.PROJECT_ID

WHERE 
o.PROJECT_ID = @ProjectID


AND o.OBJECT_TYPE = 15

AND o.OBJECT_ID NOT IN 
	(SELECT d.OBJECT_ID 
		FROM DSSMDOBJDEPN D 
		JOIN DSSMDOBJINFO od ON od.OBJECT_ID = d.DEPN_OBJID AND od.PROJECT_ID = d.DEPN_PRJID
		WHERE o.PROJECT_ID = d.PROJECT_ID  
			AND od.OBJECT_TYPE IN (12,13) )


ORDER BY f.Folder, o.OBJECT_NAME