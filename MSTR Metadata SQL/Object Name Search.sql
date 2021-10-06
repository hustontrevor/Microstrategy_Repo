Select 
(Select p.object_name From DSSMDOBJINFO p Where p.object_id = o.project_id ) PROJECT
, case o.object_type
	when 1 then 'filter' when 2 then 'template' when 3 then 'report' when 4 then 'metric' when 6 then 'autostyle'
	when 8 then 'folder' when 10 then 'prompt' when 11 then 'function' when 12 then 'attribute' when 13 then 'fact'
	when 14 then 'hierarchy' when 15 then 'table' when 18 then 'shortcut' when 21 then 'attribute id' when 22 then 'schema'
	when 23 then 'cell format' when 24 then 'warehouse catalog' when 25 then 'warehouse catalog definition' when 26 then 'table column'
	when 28 then 'property sets' when 34 then 'users/groups' when 39 then 'search' when 42 then 'package' when 43 then 'transformation'
	when 47 then 'consolidations' when 52 then 'link' when 53 then 'warehouse table' when 55 then 'document' when 56 then 'drill map'
	when 58 then 'security filter' when 60 then 'answer' when 61 then 'graph style' when 71 then 'palette' else 'OTHERS'
end AS OBJ_TYPE
,o.*

from dssmdobjinfo o 
where ( o.OBJECT_NAME LIKE '%XXXXX%' OR o.OBJECT_NAME LIKE '%XXXXX%' OR o.OBJECT_NAME LIKE '%AmerigroupTX%' OR o.OBJECT_NAME LIKE '%CustomerKC%' )
--and o.PROJECT_ID in (Select p.object_id From DSSMDOBJINFO p Where p.OBJECT_NAME NOT LIKE ('%old') AND p.OBJECT_TYPE = 32)

order by o.object_name