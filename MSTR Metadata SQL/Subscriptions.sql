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
	t.object_name ScheduleNm
	, REPLACE(t.OBJECT_NAME, 'Data Refresh -', '') ClientNm

	,sub.DISP_NAME SubNm	
	,o.OBJECT_NAME ReportNm	
	,REPLACE(d.Folder, '\CCM  Analytics RFQA', '') FolderPath
	
	--CREATE CACHEUPDATESUBSCRIPTION 'Potentially Preventable Admits (PPA) Module' SCHEDULE 'Data Refresh - HumanaFL' USER 'HumanaFL_QA' CONTENT 'Potentially Preventable Admits (PPA) Module' IN FOLDER '\Public Objects\Reports\Applications\PPE' IN PROJECT 'MyProj'  DELIVERYFORMAT HTML SENDNOTIFICATION
	,('CREATE CACHEUPDATESUBSCRIPTION ''' + sub.DISP_NAME + ''' SCHEDULE ''' + t.OBJECT_NAME 
		+ ''' USER ''' + REPLACE(t.OBJECT_NAME, 'Data Refresh -', '') + '_QA''  CONTENT  ''' + o.OBJECT_NAME
		+ ''' IN FOLDER ''' + REPLACE(d.Folder, '\CCM  Analytics RFQA', '') 
		+ ''' IN PROJECT ''MyProj''  DELIVERYFORMAT HTML SENDNOTIFICATION') CMScript

FROM 
dbo.DSSCSSUBINST sub 
JOIN dbo.DSSMDOBJINFO t ON dbo.fn_UniqueidentifierToCharMSTR(t.OBJECT_ID) = sub.TRIGGER_ID

JOIN dbo.DSSMDOBJINFO o ON dbo.fn_UniqueidentifierToCharMSTR(o.PROJECT_ID) = sub.PROJECT_ID 
	AND dbo.fn_UniqueidentifierToCharMSTR(o.OBJECT_ID) = sub.DATA_ID
	AND sub.RECIPIENT_ID <> '00000000000000000000000000000000'
LEFT JOIN DIR d ON d.OBJECT_ID = o.OBJECT_ID AND d.PROJECT_ID = o.PROJECT_ID	

WHERE 
o.PROJECT_ID = (Select p.object_id From DSSMDOBJINFO p Where p.OBJECT_NAME = @Project AND p.OBJECT_TYPE = 32)	

AND t.OBJECT_NAME LIKE '%Data Refresh -%'


ORDER BY 3, 1