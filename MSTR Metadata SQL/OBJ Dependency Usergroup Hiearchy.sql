WITH GROUPS AS (
	SELECT o.PROJECT_ID, o.OBJECT_ID, CAST( NULL AS uniqueidentifier) DEPN_OBJID, o.OBJECT_NAME NAME, CAST('\' AS nvarchar(max)) HIERARCHY
	FROM DSSMDOBJINFO o
	WHERE 
	o.PARENT_ID = '73F74825-596C-11D3-8F1B-006008960167'   -- children of [User Groups]
	AND NOT EXISTS (SELECT 1 FROM DSSMDOBJDEPN d WHERE d.OBJECT_ID = o.OBJECT_ID) -- userGroups with no parents
	AND o.OBJECT_NAME NOT IN ('MicroStrategy Groups - DO NOT USE', 'Everyone')  -- ignore Everyone group

	UNION ALL

	SELECT o.PROJECT_ID, o.OBJECT_ID, d.DEPN_OBJID, o.OBJECT_NAME NAME, o2.HIERARCHY + o2.Name + '\' HIERARCHY
	FROM DSSMDOBJINFO o
	JOIN DSSMDOBJDEPN d ON o.OBJECT_ID = d.OBJECT_ID AND o.PROJECT_ID = d.PROJECT_ID
	JOIN GROUPS o2 ON d.DEPN_OBJID = o2.OBJECT_ID AND o.PROJECT_ID = o2.PROJECT_ID	
	WHERE o.SUBTYPE = 8705  -- Just groups
)

SELECT 
h.*
,(SELECT COUNT(*) FROM GROUPS g WHERE g.OBJECT_ID = h.OBJECT_ID) ParentCount
,(SELECT COUNT(*) FROM GROUPS g WHERE g.DEPN_OBJID = h.OBJECT_ID) ChildCount
FROM GROUPS h 
JOIN DSSMDOBJINFO o ON o.OBJECT_ID = h.OBJECT_ID 

order BY h.HIERARCHY, h.NAME
