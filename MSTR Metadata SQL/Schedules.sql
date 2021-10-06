DECLARE @Project as nvarchar(250);		
SET @Project = 'MyProj Falcon RFQA';		

select 
 p.OBJECT_NAME Project
, u.OBJECT_NAME UserName
, t.OBJECT_NAME Schedule
, i.OBJECT_NAME INST
, case s.DELIVERY_TYPE when 1 then 'Email' when 128 then 'Mobile' when 16 then 'History' else 'Unknown' end as DeliveryType 
, s.DISP_NAME as Report 
, s.STATUS

,s.*

from DSSCSSUBINST s 
left join DSSMDOBJINFO u on s.OWNER_ID = dbo.fn_UniqueidentifierToCharMSTR( u.OBJECT_ID )
left join DSSMDOBJINFO t on s.TRIGGER_ID = dbo.fn_UniqueidentifierToCharMSTR( t.OBJECT_ID ) 
left join DSSMDOBJINFO p on s.PROJECT_ID = dbo.fn_UniqueidentifierToCharMSTR( p.OBJECT_ID ) 

left join DSSMDOBJINFO i on s.INST_ID = dbo.fn_UniqueidentifierToCharMSTR( i.OBJECT_ID ) 
--join DSSMDOBJINFO i on s.INST_ID = dbo.fn_UniqueidentifierToCharMSTR( i.OBJECT_ID ) 

WHERE 		
s.PROJECT_ID = (Select dbo.fn_UniqueidentifierToCharMSTR(p.object_id) From DSSMDOBJINFO p Where p.OBJECT_NAME = @Project AND p.OBJECT_TYPE = 32)