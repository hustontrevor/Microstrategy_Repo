with LIST2ROWS as (
select IS_REP_JOB_ID ,IS_SESSION_ID ,PR_ID ,DAY_ID ,HOUR_ID ,MINUTE_ID
	,CAST( LEFT(PR_ANSWERS, CHARINDEX(',',PR_ANSWERS+',')-1) as varchar(max)) RowData
    ,STUFF(PR_ANSWERS, 1, CHARINDEX(',',PR_ANSWERS+','), '') DelimData
from IS_PR_ANS_FACT	a10

union all
select IS_REP_JOB_ID ,IS_SESSION_ID ,PR_ID ,DAY_ID ,HOUR_ID ,MINUTE_ID
	,CAST(LEFT(DelimData, CHARINDEX(',',DelimData+',')-1) as varchar(max)) RowData
    ,STUFF(DelimData, 1, CHARINDEX(',',DelimData+','), '') DelimData
from LIST2ROWS
where DelimData <> ''
)

select
	a11.IS_SESSION_ID
	,a15.IS_PROJ_NAME  PROJ_NAME
	,a11.DAY_ID ,a11.MINUTE_ID TIME_ID 
	,a13.IS_REP_NAME  REP_NAME
	,a14.IS_PROMPT_NAME  PROMPT_NAME	
	,a11.RowData PROMPT_ANSWER
	--,a11.DelimData
from	LIST2ROWS	a11
	join	IS_REP_FACT	a12		on 	(a11.IS_REP_JOB_ID = a12.IS_REP_JOB_ID and a11.IS_SESSION_ID = a12.IS_SESSION_ID)
	join	IS_REP	a13			on 	(a12.IS_REP_ID = a13.IS_REP_ID)
	join	IS_PROMPT	a14		on 	(a11.PR_ID = a14.IS_PROMPT_ID)
	join	IS_PROJ	a15			on 	(a13.IS_PROJ_ID = a15.IS_PROJ_ID)
	
where 
	( a14.IS_PROMPT_NAME LIKE '%Object Prompt%' OR a14.IS_PROMPT_NAME LIKE '%Module Reporting Period%' )
	AND a15.IS_PROJ_NAME = 'MyProj'
	
ORDER BY a11.DAY_ID ,a11.MINUTE_ID ,a13.IS_REP_NAME ,a14.IS_PROMPT_NAME ,a11.RowData  
	
OPTION (maxrecursion 0)