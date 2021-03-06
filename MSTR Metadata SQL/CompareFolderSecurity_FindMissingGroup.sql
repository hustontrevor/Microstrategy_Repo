/*
	Takes MSTR @Project and queries metadata for all objects that have @MainGroup
	Then only returns objects where @CompareGroup is missing from the ACL list
	
	TAH		20200513		Created
*/

DECLARE @Project as nvarchar(250);			
SET @Project = 'MyProj';			
			
DECLARE @MainGroup as nvarchar(250);			
DECLARE @CompareGroup as nvarchar(250);			
SET @MainGroup = 'Customer';			
SET @CompareGroup = 'Customer Previous Year';			
			
			
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
			
, SECULIST AS (			
	SELECT o.PROJECT_ID		
		,o.OBJECT_ID	
		,g.OBJECT_ID GROUP_ID	
		,ISNULL(STUFF((SELECT '; ' + CAST(t1.OBJECT_NAME AS nVARCHAR(MAX))	
		 FROM DSSMDOBJSECU s1  	
			JOIN DSSMDOBJINFO t1 ON s1.TRUST_ID = t1.OBJECT_ID
		 WHERE s1.OBJECT_ID = o.OBJECT_ID AND s1.PROJECT_ID = o.PROJECT_ID 	
			AND t1.OBJECT_NAME NOT IN ('Administrator','Administrators','Local','Everyone')
			AND t1.OBJECT_ID <> g.OBJECT_ID
		 GROUP BY t1.OBJECT_NAME	
		 ORDER BY t1.OBJECT_NAME	
		 FOR XML PATH('')),1,1,''),' ') [OTHERACCESS]	
	FROM DSSMDOBJINFO o		
	JOIN DSSMDOBJSECU s ON s.OBJECT_ID = o.OBJECT_ID AND s.PROJECT_ID = o.PROJECT_ID		
	JOIN DSSMDOBJINFO g ON s.TRUST_ID = g.OBJECT_ID		
	GROUP BY o.PROJECT_ID, o.OBJECT_ID ,g.OBJECT_ID		
)			
			
, UGROUPSHIERARCHY AS (			
	SELECT g.OBJECT_NAME, g.OBJECT_ID, g.OBJECT_NAME TOPPARENTCLIENT, g.OBJECT_ID TOPPARENTGUID		
     FROM DSSMDOBJDEPN d 			
		join DSSMDOBJINFO g on d.OBJECT_ID = g.OBJECT_ID 	
		join DSSMDOBJINFO p on d.DEPN_OBJID = p.OBJECT_ID 	
      WHERE p.OBJECT_TYPE = 34 and p.SUBTYPE <> 8704			
	  AND p.OBJECT_NAME = 'CLIENTS'		
			
	UNION ALL 		
			
	SELECT g.OBJECT_NAME, g.OBJECT_ID, u.TOPPARENTCLIENT, u.TOPPARENTGUID		
     FROM DSSMDOBJDEPN d 			
		join UGROUPSHIERARCHY u on d.DEPN_OBJID = u.OBJECT_ID 	
		join DSSMDOBJINFO g on d.OBJECT_ID = g.OBJECT_ID 	
	 WHERE g.OBJECT_TYPE = 34 and g.SUBTYPE <> 8704		
)			
			
SELECT 			
(Select p.object_name From DSSMDOBJINFO p Where p.object_id = o.project_id ) PROJECT			
,s.RIGHTS 			
			
,dbo.fn_UniqueidentifierToCharMSTR(o.OBJECT_ID) GUID			
,o.OBJECT_NAME			
,d.folder			
			
,g.OBJECT_NAME GROUP_NAME			
			
,secl.OTHERACCESS			
			
FROM DSSMDOBJINFO o			
JOIN DSSMDOBJSECU s ON s.OBJECT_ID = o.OBJECT_ID AND s.PROJECT_ID = o.PROJECT_ID			
JOIN DSSMDOBJINFO g ON s.TRUST_ID = g.OBJECT_ID --AND g.PROJECT_ID = o.PROJECT_ID --Users and groups dont use Project the same way			
			
JOIN DIR d ON o.OBJECT_ID = d.OBJECT_ID AND d.PROJECT_ID = o.PROJECT_ID			
			
JOIN SECULIST secl ON o.OBJECT_ID = secl.OBJECT_ID AND o.PROJECT_ID = secl.PROJECT_ID AND secl.GROUP_ID = g.OBJECT_ID			
			
			
WHERE 			
o.PROJECT_ID = (Select p.object_id From DSSMDOBJINFO p Where p.OBJECT_NAME = @Project AND p.OBJECT_TYPE = 32)			
			
AND o.OBJECT_TYPE = 8  -- Folders only			
AND d.Folder NOT LIKE '%\Profiles\%'			
AND d.Folder NOT LIKE '%\To be Deleted\%'			
			
AND g.OBJECT_NAME NOT IN ('Administrator','Administrators','Local','Everyone')			
			
AND g.OBJECT_ID IN ( SELECT u.OBJECT_ID FROM UGROUPSHIERARCHY u WHERE u.TOPPARENTCLIENT = @MainGroup )			
			
AND NOT EXISTS (			
	SELECT 1		
	FROM DSSMDOBJSECU s2 		
	JOIN DSSMDOBJINFO g2 ON s2.TRUST_ID = g2.OBJECT_ID		
	WHERE s2.OBJECT_ID = o.OBJECT_ID AND s2.PROJECT_ID = o.PROJECT_ID		
		--AND g2.OBJECT_ID IN ( SELECT u.OBJECT_ID FROM UGROUPSHIERARCHY u WHERE u.TOPPARENTCLIENT = @CompareGroup )	
		AND g2.OBJECT_NAME = REPLACE(g.OBJECT_NAME,@MainGroup,@CompareGroup)	
	)		
			
and s.RIGHTS <= 268435711  -- ignore Child rights			
			
order by d.Folder + o.OBJECT_NAME, g.OBJECT_NAME, s.rights 			
