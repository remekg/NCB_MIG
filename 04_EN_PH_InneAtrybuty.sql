USE NCB_MIG;

UPDATE [en].[Stg_PH]
SET email_pop = [dbo].[email](mail)
WHERE 1=1
AND CzyMIG > 0
AND mail IS NOT NULL 
AND mail <> N''