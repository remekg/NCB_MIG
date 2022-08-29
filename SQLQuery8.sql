  with a as (
SELECT	distinct PNA,
		CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
			THEN N'Warszawa'
			WHEN TERYT_POW_NAZWA = N'Poznañ'
			THEN N'Poznañ'
			WHEN TERYT_POW_NAZWA = N'Kraków'
			THEN N'Kraków'
			WHEN TERYT_POW_NAZWA = N'£ódŸ'
			THEN N'£ódŸ'
			WHEN TERYT_POW_NAZWA = N'Wroc³aw'
			THEN N'Wroc³aw'
			ELSE TERYT_POW_NAZWA
		END 
		
		TERYT_MIEJ_NAZWA,
		TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
  ), 
  
  b as(
  select pna, 
		TERYT_MIEJ_NAZWA,
		TERYT_MIEJ_SIMC,
		COUNT(*) over (partition by pna,TERYT_MIEJ_NAZWA) as ile 
  from a 
  )
  select * from b where ile =1 AND LEN(TERYT_MIEJ_NAZWA)>0