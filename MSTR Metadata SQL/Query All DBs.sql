CREATE TABLE [dbo].[#THTMP] ( 
[DBNAME]     NVARCHAR(256)                        NULL
,[VSCHEMA]       varchar(200)                          NULL
,[VNAME]       varchar(200)                          NOT NULL
,[COLUMNNAME]       varchar(200)                          NOT NULL
--,[TYPE]       CHAR(1)                          NOT NULL
--,[TYPE_DESC]  NVARCHAR(120)                        NULL)
);


execute sp_msforeachdb 'IF ''?'' LIKE ''CCM_%_DW''
BEGIN INSERT INTO #THTMP
		SELECT ''?'' DB, ''xxx'' AS VSCHEMA, ''xxx'' AS VNAME, ''xxx'' AS [COLUMNNAME]
	UNION ALL 
		SELECT ''?'' DB, TABLE_SCHEMA [VSCHEMA], TABLE_NAME AS [VNAME], COLUMN_NAME AS [COLUMNNAME]
		FROM ?.information_schema.columns
		WHERE COLUMN_NAME = ''Cases''
END ';

SELECT * 
FROM #THTMP 
WHERE VName <> 'xxx'
ORDER BY 1;

SELECT DBNAME DB_MissingCol
FROM #THTMP 
GROUP BY DBNAME
HAVING COUNT(*) < 2
ORDER BY 1;

drop table #THTMP