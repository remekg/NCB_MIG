  with a as (
SELECT	distinct PNA,
		CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
			THEN N'Warszawa'
			WHEN TERYT_POW_NAZWA = N'Pozna�'
			THEN N'Pozna�'
			WHEN TERYT_POW_NAZWA = N'Krak�w'
			THEN N'Krak�w'
			WHEN TERYT_POW_NAZWA = N'��d�'
			THEN N'��d�'
			WHEN TERYT_POW_NAZWA = N'Wroc�aw'
			THEN N'Wroc�aw'
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