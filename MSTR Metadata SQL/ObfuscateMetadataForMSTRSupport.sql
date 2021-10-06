!! ONLY RUN ON BACKUPS (comment out this line) !! 

UPDATE DSSMDOBJINFO 
SET OBJECT_NAME = ''  -- name used for search
, ABBREVIATION = ''  -- login id
, DESCRIPTION = ''   -- optional, security manager usually writes in group membership notes here
WHERE OBJECT_TYPE = 34 
AND SUBTYPE = 8704  -- 8704 = users, 8705 = user groups 

UPDATE DSSCSADDRESS
SET DISP_NAME = ''
, [ADDRESS] = ''

UPDATE dbo.DSSCSMSGINFO
SET OBJECT_OWNER_NAME = ''
,MESSAGE_OWNER_NAME = ''

UPDATE dbo.IS_INBOX_ACT_STATS
SET USERNAME = ''
,OWNERNAME = ''

UPDATE dbo.IS_MESSAGE_STATS
SET RECIPIENTCONTACTNAME = ''

UPDATE dbo.IS_SESSION_STATS
SET CLIENTMACHINE = ''

