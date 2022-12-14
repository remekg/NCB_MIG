-- wypełnienie listy kodow pocztowych
-- czas ładowania 15:13 12.08.22

drop table if exists ncb_mig.ref.lista_pna;

SELECT * 
into ncb_mig.ref.lista_pna
FROM (
									select pna, WOJEWÓDZTWO, POWIAT, GMINA, MIEJSCOWOŚĆ from Stage.dbo.PNA1_MiejscowosciIUlice
									union
									select pna, WOJEWÓDZTWO, POWIAT, GMINA, MIEJSCOWOŚĆ from Stage.dbo.PNA2_PodmiotyZOdrebymPNA
									union
									select pna, WOJEWÓDZTWO, POWIAT, GMINA, MIEJSCOWOŚĆ from Stage.dbo.PNA3_PlacowkiPocztowe
									union
									select pna, WOJEWÓDZTWO, POWIAT, GMINA, MIEJSCOWOŚĆ from Stage.dbo.PNA4_JednostkiOrganizacyjnePoczty
										) pna;

create clustered index ix_pna on NCB_MIG.ref.lista_pna (pna);

truncate table dbo.TERYT_PNA
SET IDENTITY_INSERT dbo.TERYT_PNA ON
;
WITH A AS (
SELECT *
		,TRIM(j.value) AS WYNIK
		,CASE WHEN CHARINDEX('-',TRIM(j.value))>0 THEN
			LEFT(REPLACE(REPLACE(REPLACE(TRIM(j.value),'(p)',''),'(n)',''),'DK','100000')
				,CHARINDEX('-',TRIM(j.value))-1) 
		ELSE REPLACE(REPLACE(REPLACE(TRIM(j.value),'(p)',''),'(n)',''),'DK','100000')
		END AS PODZIELONE_OD
		,CASE WHEN CHARINDEX('-',TRIM(j.value))>0 THEN
			SUBSTRING(REPLACE(REPLACE(REPLACE(TRIM(j.value),'(p)',''),'(n)',''),'DK','100000')
				,CHARINDEX('-',TRIM(j.value))+1,10) 
		ELSE REPLACE(REPLACE(REPLACE(TRIM(j.value),'(p)',''),'(n)',''),'DK','100000')
		END AS PODZIELONE_DO
		,CASE WHEN RIGHT(TRIM(j.value),3)='(p)' 
			THEN 'P'
			WHEN RIGHT(TRIM(j.value),3)='(n)'
			THEN 'N'
		END AS PARZYSTOSC
FROM CRS.dbo.PowiazanieTERYTzPNA pna
CROSS APPLY STRING_SPLIT(pna.[PNA_NUMERY],',') j
WHERE ZrodloDanychPNA=1
AND CzyUsuniety=0
)



INSERT INTO dbo.TERYT_PNA ([ADRES_MIS_KEY], [TERYT_KOD_TERC], [TERYT_WOJ_NAZWA], [TERYT_WOJ_TERC], [TERYT_POW_NAZWA], [TERYT_POW_TERC], [TERYT_GM_NAZWA], [TERYT_GM_TERC], [TERYT_GM_TYP], [TERYT_GM_TYP_NAZWA], [TERYT_MIEJ_NAZWA], [TERYT_MIEJ_SIMC], [TERYT_MIEJ_SIMC_POD], [TERYT_MIEJ_RODZ_SIMC], [TERYT_MIEJ_RODZ], [TERYT_ULICA_NAZWA_1], [TERYT_ULICA_NAZWA_2], [TERYT_ULICA_CECHA], [TERYT_ULICA], [TERYT_ULICA_SKLEJONA_1], [TERYT_ULICA_SKLEJONA_Z_CECHA_1], [TERYT_MIEJSCOWOSC], [PNA], [PNA_MIEJSCOWOSC], [PNA_ULICA], [DataOstatniejAktualizacjiTERYT], [DataOstatniejAktualizacjiPNA], [DataOstatniejAktualizacji], [PNA_NUMERY], [WYNIK], [OD], [DO], [PARZYSTOSC])
	SELECT 
		[ADRES_MIS_KEY]
		,[TERYT_KOD_TERC]
		,[TERYT_WOJ_NAZWA]
		,[TERYT_WOJ_TERC]
		,[TERYT_POW_NAZWA]
		,[TERYT_POW_TERC]
		,[TERYT_GM_NAZWA]
		,[TERYT_GM_TERC]
		,[TERYT_GM_TYP]
		,[TERYT_NAZWA_DOD_GMINY] AS [TERYT_GM_TYP_NAZWA]
		,[TERYT_MIEJ_NAZWA]
		,[TERYT_MIEJ_SIMC]
		,[TERYT_MIEJ_SIMC_POD]
		,[TERYT_MIEJ_RODZ_SIMC]
		,[TERYT_MIEJ_RODZ]
		,[TERYT_ULICA_NAZWA_1]
		,[TERYT_ULICA_NAZWA_2]
		,[TERYT_ULICA_CECHA]
		,[TERYT_ULICA_SYMBOL] AS  TERYT_ULICA
		,[TERYT_ULICA_SKLEJONA_1]
		,[TERYT_ULICA_SKLEJONA_Z_CECHA_1]
		,[TERYT_MIEJSCOWOSC]
		,[PNA]
		,[PNA_MIEJSCOWOSC]
		,[PNA_ULICA]
		,[DataOstatniejAktualizacjiTERYT]
		,[DataOstatniejAktualizacjiPNA]
		,[DataOstatniejAktualizacji]
		,[PNA_NUMERY]
		,WYNIK
		,LEFT(PODZIELONE_OD, IIF(patindex('%[a-z]%', PODZIELONE_OD)>0, patindex('%[a-z]%', PODZIELONE_OD)-1,1000)) AS OD
		,LEFT(PODZIELONE_DO, IIF(patindex('%[a-z]%', PODZIELONE_DO)>0, patindex('%[a-z]%', PODZIELONE_DO)-1,1000)) AS DO
		,PARZYSTOSC
FROM A;

--Uzupełnić teryt podstawowy miast  dzielnicami
UPDATE ref.lista_pna
SET Gmina = 
	SUBSTRING(MIEJSCOWOŚĆ, CHARINDEX('(', MIEJSCOWOŚĆ) + 1, 
	CHARINDEX(')', MIEJSCOWOŚĆ) - CHARINDEX('(', MIEJSCOWOŚĆ) - 1)	
WHERE POWIAT IN ('Kraków', 'Poznań', 'Łódź', 'Wrocław', 'Warszawa')
AND Miejscowość LIKE N'%(%)%'

UPDATE ref.lista_pna
SET MIEJSCOWOŚĆ = SUBSTRING(MIEJSCOWOŚĆ, CHARINDEX('(', MIEJSCOWOŚĆ) + 1, 
	CHARINDEX(')', MIEJSCOWOŚĆ) - CHARINDEX('(', MIEJSCOWOŚĆ) - 1)
WHERE Miejscowość LIKE N'%(%)%'
--uzupełnianie tabeli distonct kod pocztowy miejscowość
DROP TABLE IF EXISTS ref.dist_lista_pna

SELECT	distinct PNA,
		CASE WHEN POWIAT = N'Warszawa'
			THEN N'Warszawa'
			WHEN POWIAT = N'Poznań'
			THEN N'Poznań'
			WHEN POWIAT = N'Kraków'
			THEN N'Kraków'
			WHEN POWIAT = N'Łódź'
			THEN N'Łódź'
			WHEN POWIAT = N'Wrocław'
			THEN N'Wrocław'
			ELSE MIEJSCOWOŚĆ
		END AS MIEJSCOWOŚĆ
INTO ref.dist_lista_pna
FROM ref.lista_pna

DROP TABLE IF EXISTS ref.lista_pna_teryt

SELECT DISTINCT   k.*, 
TW.WOJ,  TP.POW, TG.GMI,TS.SYM, TS.RM, TS.SYMPOD
INTO ref.lista_pna_teryt
FROM ref.lista_pna AS K
JOIN stage.dbo.TERYT_TERC AS TW
ON K.WOJEWÓDZTWO = TW.NAZWA
AND TW.NAZWA_DOD = 'województwo'

JOIN stage.dbo.TERYT_TERC AS TP
ON K.Powiat = TP.NAZWA
--LEFT(K.POWIAT,4) = LEFT(TP.NAZWA, 4)
AND TP.POW IS NOT NULL
AND TP.GMI IS NULL
AND TW.WOJ = TP.WOJ
JOIN stage.dbo.TERYT_TERC AS TG
ON K.gmina = TG.NAZWA
AND TG.GMI IS NOT NULL
AND TW.WOJ = TG.WOJ 
AND TP.POW = TG.POW
LEFT JOIN Stage.dbo.TERYT_SIMC AS TS
ON CONCAT(TW.WOJ, TP.POW, TG.GMI) = CONCAT(TS.WOJ, TS.POW, TS.GMI)
AND K.MIEJSCOWOŚĆ = TS.Nazwa
AND TS.SYM IS NOT NULL

UPDATE dbo.TERYT_PNA
	SET PARZYSTOSC = 'NP'
	WHERE PARZYSTOSC IS NULL

UPDATE dbo.TERYT_PNA
	SET OD = '1',
		DO = '100000'
	WHERE LEN(OD) = 0

UPDATE NCB_MIG.dbo.TERYT_PNA
	SET	MIEJSCOWOSC_CLR = dbo.UsuwanieNieliter(REPLACE(REPLACE(TERYT_MIEJ_NAZWA, N' KOL.',N' KOLONIA'), N' MŁP', N' MAŁOPOLSKI'))
UPDATE NCB_MIG.dbo.TERYT_PNA
	SET ULICE_CLR = TRIM(REPLACE([dbo].[UsuwanieNieliter](REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TERYT_ULICA_SKLEJONA_1, N'ALEJA', 'AL '), N'ALEJE' , N'AL '), 'PLAC', 'PL '), '-GO ',' '),' GO ',' '), N'ŚWIĘTEGO', N'ŚW '), N'ŚWIĘTEJ', N'ŚW '), N'KSIĘDZA', N'KS '), N'BOHATERÓW', N'BOH '), N'GENERAŁA', N'GEN '), N'PUŁKOWNIKA', N'PŁK '),N'OSIEDLE', N'OS ')),'UL ', ''))
UPDATE NCB_MIG.dbo.TERYT_PNA
	SET ULICA_KROTKA_CLR = TRIM(REPLACE([dbo].[UsuwanieNieliter](REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TERYT_ULICA_NAZWA_1, N'ALEJA', 'AL '), N'ALEJE' , N'AL '), 'PLAC', 'PL '), '-GO ',' '),' GO ',' '), N'ŚWIĘTEGO', N'ŚW '), N'ŚWIĘTEJ', N'ŚW '), N'KSIĘDZA', N'KS '), N'BOHATERÓW', N'BOH '), N'GENERAŁA', N'GEN '), N'PUŁKOWNIKA', N'PŁK '),N'OSIEDLE', N'OS ')),'UL ', ''))

/**Uzpełnianie tabel na potrzeby terytowania miejscowości**/

--PNA, nazwa miejscowości teryt miejscowości

DROP TABLE IF EXISTS ref.PNA_NazwaM_TerytM;

with a as (
SELECT	distinct PNA,
		CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
			THEN N'Warszawa'
			WHEN TERYT_POW_NAZWA = N'Poznań'
			THEN N'Poznań'
			WHEN TERYT_POW_NAZWA = N'Kraków'
			THEN N'Kraków'
			WHEN TERYT_POW_NAZWA = N'Łódź'
			THEN N'Łódź'
			WHEN TERYT_POW_NAZWA = N'Wrocław'
			THEN N'Wrocław'
			ELSE TERYT_MIEJ_NAZWA
		END AS TERYT_MIEJ_NAZWA,   --po miejscowość_nazwa
		TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
		WHERE LEN(TERYT_MIEJ_NAZWA) > 0	
		AND LEN(TERYT_MIEJ_SIMC) > 0
  ), 
  
  b as(
  select pna, 
		TERYT_MIEJ_NAZWA,
		STRING_AGG(TERYT_MIEJ_SIMC, '; ') AS TERYT_MIEJ_SIMC
  from a
  GROUP BY pna, 
		TERYT_MIEJ_NAZWA
  )
  select pna, 
		TERYT_MIEJ_NAZWA,
		TERYT_MIEJ_SIMC
  INTO ref.PNA_NazwaM_TerytM
  from b  
  ;
  CREATE NONCLUSTERED INDEX IX_TMP ON ref.PNA_NazwaM_TerytM (PNA, TERYT_MIEJ_NAZWA, TERYT_MIEJ_SIMC);

  --PNA, nazwa miejscowości CLR teryt miejscowości
DROP TABLE IF EXISTS ref.PNA_NazwaMCLR_TerytM;

  with a as (
SELECT	distinct PNA,
		CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
			THEN N'Warszawa'
			WHEN TERYT_POW_NAZWA = N'Poznań'
			THEN N'Poznań'
			WHEN TERYT_POW_NAZWA = N'Kraków'
			THEN N'Kraków'
			WHEN TERYT_POW_NAZWA = N'Łódź'
			THEN N'Łódź'
			WHEN TERYT_POW_NAZWA = N'Wrocław'
			THEN N'Wrocław'
			ELSE MIEJSCOWOSC_CLR  
		END AS MIEJSCOWOSC_CLR, --po miejscowość_CLR
		TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
		WHERE LEN(TERYT_MIEJ_NAZWA) > 0	
		AND LEN(TERYT_MIEJ_SIMC) > 0
  ), 
 c as(
  select pna, 
		MIEJSCOWOSC_CLR AS MIEJSCOWOSC_TMP_CLR,
		STRING_AGG(TERYT_MIEJ_SIMC, '; ') AS TERYT_MIEJ_SIMC
  from a
  GROUP BY pna, 
		MIEJSCOWOSC_CLR
  )
  select pna, 
		MIEJSCOWOSC_TMP_CLR,
		TERYT_MIEJ_SIMC
  INTO ref.PNA_NazwaMCLR_TerytM
  from c

  CREATE NONCLUSTERED INDEX IX_TMP ON ref.PNA_NazwaMCLR_TerytM (PNA, MIEJSCOWOSC_TMP_CLR, TERYT_MIEJ_SIMC);

  --Nazwa miejscowości CLR nazwa ulicy CLR teryt miejscowości
  DROP TABLE IF EXISTS ref.NazwaMCLR_NazwaUCLR_TerytM;

     with a as (
SELECT	distinct 
		CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
			THEN N'Warszawa'
			WHEN TERYT_POW_NAZWA = N'Poznań'
			THEN N'Poznań'
			WHEN TERYT_POW_NAZWA = N'Kraków'
			THEN N'Kraków'
			WHEN TERYT_POW_NAZWA = N'Łódź'
			THEN N'Łódź'
			WHEN TERYT_POW_NAZWA = N'Wrocław'
			THEN N'Wrocław'
			ELSE MIEJSCOWOSC_CLR
		END AS MIEJSCOWOSC_CLR,
		TERYT_MIEJ_SIMC,
		ULICE_CLR
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
	WHERE LEN(TERYT_MIEJ_NAZWA) > 0	
		AND LEN(TERYT_MIEJ_SIMC) > 0
  ), 
  
  b as(
  select  
		MIEJSCOWOSC_CLR,
		ULICE_CLR,
		STRING_AGG(TERYT_MIEJ_SIMC, '; ') AS TERYT_MIEJ_SIMC
  from a
  GROUP BY MIEJSCOWOSC_CLR,
		ULICE_CLR
  )
  select 
		MIEJSCOWOSC_CLR AS MIEJSCOWOSC_TMP_CLR,
		ULICE_CLR AS ULICE_TMP_CLR,
		TERYT_MIEJ_SIMC
  INTO ref.NazwaMCLR_NazwaUCLR_TerytM
  from b;

--  CREATE NONCLUSTERED INDEX IX_TMP ON ref.NazwaMCLR_NazwaUCLR_TerytM (ULICE_TMP_CLR, MIEJSCOWOSC_TMP_CLR, TERYT_MIEJ_SIMC);

--Nazwa miejscowości CLR nazwa ulicy krótkiej CLR teryt miejscowosci
  DROP TABLE IF EXISTS ref.NazwaMCLR_NazwaUKrotkiejCLR_TerytM;

   with a as (
SELECT	distinct 
		CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
			THEN N'Warszawa'
			WHEN TERYT_POW_NAZWA = N'Poznań'
			THEN N'Poznań'
			WHEN TERYT_POW_NAZWA = N'Kraków'
			THEN N'Kraków'
			WHEN TERYT_POW_NAZWA = N'Łódź'
			THEN N'Łódź'
			WHEN TERYT_POW_NAZWA = N'Wrocław'
			THEN N'Wrocław'
			ELSE MIEJSCOWOSC_CLR
		END AS MIEJSCOWOSC_CLR,
		TERYT_MIEJ_SIMC,
		[ULICA_KROTKA_CLR]
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
	WHERE LEN(TERYT_MIEJ_NAZWA) > 0	
		AND LEN(TERYT_MIEJ_SIMC) > 0
  ), 
  
  b as(
  select  
		MIEJSCOWOSC_CLR,
		[ULICA_KROTKA_CLR],
		STRING_AGG(TERYT_MIEJ_SIMC, '; ') AS TERYT_MIEJ_SIMC
  from a
  GROUP BY MIEJSCOWOSC_CLR,
		[ULICA_KROTKA_CLR]
  )
  select 
		MIEJSCOWOSC_CLR AS MIEJSCOWOSC_TMP_CLR,
		[ULICA_KROTKA_CLR] AS ULICE_TMP_CLR,
		TERYT_MIEJ_SIMC
  INTO ref.NazwaMCLR_NazwaUKrotkiejCLR_TerytM
  from b;

 --CREATE NONCLUSTERED INDEX IX_TMP ON ref.NazwaMCLR_NazwaUKrotkiejCLR_TerytM (ULICE_TMP_CLR, MIEJSCOWOSC_TMP_CLR, TERYT_MIEJ_SIMC);

 --PNA nazwa miejscowości nazwa ulicy sklejonej teryt miejscowosci
   DROP TABLE IF EXISTS ref.PNA_NazwaM_NazwaU_TerytM;

   with a as (
SELECT	distinct PNA,
		CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
			THEN N'Warszawa'
			WHEN TERYT_POW_NAZWA = N'Poznań'
			THEN N'Poznań'
			WHEN TERYT_POW_NAZWA = N'Kraków'
			THEN N'Kraków'
			WHEN TERYT_POW_NAZWA = N'Łódź'
			THEN N'Łódź'
			WHEN TERYT_POW_NAZWA = N'Wrocław'
			THEN N'Wrocław'
			ELSE TERYT_MIEJ_NAZWA
		END AS TERYT_MIEJ_NAZWA,
		TERYT_ULICA_SKLEJONA_1,
		TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
		WHERE LEN(TERYT_MIEJ_NAZWA) > 0	
			AND LEN(TERYT_KOD_TERC) > 0
			AND LEN(TERYT_MIEJ_SIMC) > 0
			AND LEN(TERYT_ULICA_SKLEJONA_1) > 0
  ),	
  
  b as(
  select PNA,  
		TERYT_MIEJ_NAZWA,
		TERYT_ULICA_SKLEJONA_1,
		STRING_AGG(TERYT_MIEJ_SIMC, '; ') AS TERYT_MIEJ_SIMC
  from a 
  GROUP BY PNA,  
		TERYT_MIEJ_NAZWA,
		TERYT_ULICA_SKLEJONA_1
  )
  select PNA, 
		TERYT_MIEJ_NAZWA,
		TERYT_ULICA_SKLEJONA_1,
		TERYT_MIEJ_SIMC
  INTO ref.PNA_NazwaM_NazwaU_TerytM
  from b;
  
  CREATE NONCLUSTERED INDEX IX_TMP ON ref.PNA_NazwaM_NazwaU_TerytM (PNA, TERYT_MIEJ_NAZWA, TERYT_MIEJ_SIMC, TERYT_ULICA_SKLEJONA_1)

  --PNA, Nazwa miejscowości CLR nazwa ulicy CLR teryt miejscowosci
    DROP TABLE IF EXISTS ref.PNA_NazwaMCLR_NazwaUCLR_TerytM;
  
  with a as (
SELECT	distinct PNA,
		CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
			THEN N'Warszawa'
			WHEN TERYT_POW_NAZWA = N'Poznań'
			THEN N'Poznań'
			WHEN TERYT_POW_NAZWA = N'Kraków'
			THEN N'Kraków'
			WHEN TERYT_POW_NAZWA = N'Łódź'
			THEN N'Łódź'
			WHEN TERYT_POW_NAZWA = N'Wrocław'
			THEN N'Wrocław'
			ELSE MIEJSCOWOSC_CLR
		END AS MIEJSCOWOSC_CLR,
		ULICE_CLR,
		TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
		WHERE LEN(MIEJSCOWOSC_CLR) > 0	
			AND LEN(TERYT_MIEJ_SIMC) > 0
			AND LEN(ULICE_CLR) > 0
  ),	
  
  c as(
  select PNA,  
		MIEJSCOWOSC_CLR,
		ULICE_CLR,
		STRING_AGG(TERYT_MIEJ_SIMC, '; ') AS TERYT_MIEJ_SIMC
  from a 
  GROUP BY PNA,  
		MIEJSCOWOSC_CLR,
		ULICE_CLR
  )
  select PNA, 
		MIEJSCOWOSC_CLR AS MIEJSCOWOSC_TMP_CLR,
		ULICE_CLR AS ULICE_TMP_CLR,
		TERYT_MIEJ_SIMC
  INTO ref.PNA_NazwaMCLR_NazwaUCLR_TerytM
  from c;

  CREATE NONCLUSTERED INDEX IX_TMP ON ref.PNA_NazwaMCLR_NazwaUCLR_TerytM (PNA, MIEJSCOWOSC_TMP_CLR, ULICE_TMP_CLR, TERYT_MIEJ_SIMC);

  --PNA nazwa miejscowości CLR nazwa ulicy krótkiej CLR teryt miejscowości
    DROP TABLE IF EXISTS ref.PNA_NazwaMCLR_NazwaUKrotkaCLR_TerytM;

    with a as (
SELECT	distinct PNA,
		CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
			THEN N'Warszawa'
			WHEN TERYT_POW_NAZWA = N'Poznań'
			THEN N'Poznań'
			WHEN TERYT_POW_NAZWA = N'Kraków'
			THEN N'Kraków'
			WHEN TERYT_POW_NAZWA = N'Łódź'
			THEN N'Łódź'
			WHEN TERYT_POW_NAZWA = N'Wrocław'
			THEN N'Wrocław'
			ELSE MIEJSCOWOSC_CLR
		END AS MIEJSCOWOSC_CLR,
		[ULICA_KROTKA_CLR],
		TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
		WHERE LEN(MIEJSCOWOSC_CLR) > 0	
			AND LEN(TERYT_MIEJ_SIMC) > 0
			AND LEN([ULICA_KROTKA_CLR]) > 0
  ),	
  
  b as(
  select PNA,  
		MIEJSCOWOSC_CLR,
		[ULICA_KROTKA_CLR],
		STRING_AGG(TERYT_MIEJ_SIMC, '; ') AS TERYT_MIEJ_SIMC
  from a
  GROUP BY PNA,  
		MIEJSCOWOSC_CLR,
		[ULICA_KROTKA_CLR]
  )
  select PNA, 
		MIEJSCOWOSC_CLR AS MIEJSCOWOSC_TMP_CLR,
		[ULICA_KROTKA_CLR] AS ULICA_KROTKA_TMP_CLR,
		TERYT_MIEJ_SIMC
  INTO ref.PNA_NazwaMCLR_NazwaUKrotkaCLR_TerytM
  from b;
  
  CREATE NONCLUSTERED INDEX IX_TMP ON ref.PNA_NazwaMCLR_NazwaUKrotkaCLR_TerytM (PNA, MIEJSCOWOSC_TMP_CLR, TERYT_MIEJ_SIMC, ULICA_KROTKA_TMP_CLR);

  --PNA nazwa miejscowosci teryt miejscowości dla pełnej listy PNA

    DROP TABLE IF EXISTS ref.Lista_PNA_NazwaM_TerytM;

  with a as (
SELECT	distinct PNA,
		CASE WHEN POWIAT = N'Warszawa'
			THEN N'Warszawa'
			WHEN POWIAT = N'Poznań'
			THEN N'Poznań'
			WHEN POWIAT = N'Kraków'
			THEN N'Kraków'
			WHEN POWIAT = N'Łódź'
			THEN N'Łódź'
			WHEN POWIAT = N'Wrocław'
			THEN N'Wrocław'
			ELSE MIEJSCOWOŚĆ
		END AS TERYT_MIEJ_NAZWA,
		SYM AS TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[ref].[lista_pna_teryt]
		WHERE LEN(MIEJSCOWOŚĆ) > 0	
			AND LEN(SYM) > 0
  ),	
  
  c as(
  select PNA,  
		TERYT_MIEJ_NAZWA,
		STRING_AGG(TERYT_MIEJ_SIMC, '; ') AS TERYT_MIEJ_SIMC
  from a
  GROUP BY PNA, 
		TERYT_MIEJ_NAZWA

  )
  select PNA, 
		TERYT_MIEJ_NAZWA,
		TERYT_MIEJ_SIMC
  INTO ref.Lista_PNA_NazwaM_TerytM
  from c;

    CREATE NONCLUSTERED INDEX IX_TMP ON ref.Lista_PNA_NazwaM_TerytM (PNA,TERYT_MIEJ_NAZWA , TERYT_MIEJ_SIMC);
--PNA 4 znaki nazwa miejscowości CLR teryt miejscowości

    DROP TABLE IF EXISTS ref.PNA4Znaki_NazwaMCLR_TerytM;

  with a as (
SELECT	distinct LEFT(PNA,4) AS PNA,
		CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
			THEN N'Warszawa'
			WHEN TERYT_POW_NAZWA = N'Poznań'
			THEN N'Poznań'
			WHEN TERYT_POW_NAZWA = N'Kraków'
			THEN N'Kraków'
			WHEN TERYT_POW_NAZWA = N'Łódź'
			THEN N'Łódź'
			WHEN TERYT_POW_NAZWA = N'Wrocław'
			THEN N'Wrocław'
			ELSE MIEJSCOWOSC_CLR  
		END AS MIEJSCOWOSC_CLR, --po miejscowość_CLR
		TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
		WHERE LEN(TERYT_MIEJ_NAZWA) > 0	
		AND LEN(TERYT_MIEJ_SIMC) > 0
  ), 
 c as(
  select pna, 
		MIEJSCOWOSC_CLR AS MIEJSCOWOSC_TMP_CLR,
		STRING_AGG(TERYT_MIEJ_SIMC, ';') AS TERYT_MIEJ_SIMC
  from a
  GROUP BY pna, 
		MIEJSCOWOSC_CLR
  )
  select pna, 
		MIEJSCOWOSC_TMP_CLR,
		TERYT_MIEJ_SIMC
  INTO ref.PNA4Znaki_NazwaMCLR_TerytM
  from c

      CREATE NONCLUSTERED INDEX IX_TMP ON ref.PNA4Znaki_NazwaMCLR_TerytM (PNA,MIEJSCOWOSC_TMP_CLR , TERYT_MIEJ_SIMC);
--PNA 4 znaki nazwa miejscowości CLR teryt miejscowości

    DROP TABLE IF EXISTS ref.PNA4Znaki_NazwaMCLR_GUS6_TerytM;

  with a as (
SELECT	distinct LEFT(PNA,4) AS PNA,
		CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
			THEN N'Warszawa'
			WHEN TERYT_POW_NAZWA = N'Poznań'
			THEN N'Poznań'
			WHEN TERYT_POW_NAZWA = N'Kraków'
			THEN N'Kraków'
			WHEN TERYT_POW_NAZWA = N'Łódź'
			THEN N'Łódź'
			WHEN TERYT_POW_NAZWA = N'Wrocław'
			THEN N'Wrocław'
			ELSE MIEJSCOWOSC_CLR  
		END AS MIEJSCOWOSC_CLR, --po miejscowość_CLR
		LEFT(TERYT_KOD_TERC,6) AS GUS_TMP,
		TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
		WHERE LEN(TERYT_MIEJ_NAZWA) > 0	
		AND LEN(TERYT_MIEJ_SIMC) > 0
  ), 
 c as(
  select pna, 
		MIEJSCOWOSC_CLR AS MIEJSCOWOSC_TMP_CLR,
		GUS_TMP,
		STRING_AGG(TERYT_MIEJ_SIMC, ';') AS TERYT_MIEJ_SIMC
  from a
  GROUP BY pna, 
		MIEJSCOWOSC_CLR,
		GUS_TMP
  )
  select pna, 
		MIEJSCOWOSC_TMP_CLR,
		GUS_TMP,
		TERYT_MIEJ_SIMC
  INTO ref.PNA4Znaki_NazwaMCLR_GUS6_TerytM
  from c

      CREATE NONCLUSTERED INDEX IX_TMP ON ref.PNA4Znaki_NazwaMCLR_GUS6_TerytM (PNA,MIEJSCOWOSC_TMP_CLR ,GUS_TMP, TERYT_MIEJ_SIMC);

/**Uzpełnianie tabel na potrzeby terytowania ulic**/ 
--teryt miejscowości nazwa ulicy, teryt ulicy
    DROP TABLE IF EXISTS ref.TerytM_NazwaU_TerytU;

with a as 
(
	SELECT	distinct SYM AS TERYT_MIEJ_SIMC,
					TRIM(CONCAT(NAZWA_2,' ' ,NAZWA_1)) AS TERYT_ULICA_SKLEJONA_1,
					SYM_UL TERYT_ULICA
	FROM CRS.[zrodlo].[TERYT_ULIC]
	WHERE  LEN(SYM_UL) = 5
			AND [CzyUsuniety]=0
  ),	

  b as(
  select 
		TERYT_MIEJ_SIMC, 
		TERYT_ULICA_SKLEJONA_1, 
		STRING_AGG(TERYT_ULICA, '; ') AS TERYT_ULICA
  from a
  GROUP BY  TERYT_MIEJ_SIMC, 
		TERYT_ULICA_SKLEJONA_1
  )
  select TERYT_MIEJ_SIMC, TERYT_ULICA_SKLEJONA_1, TERYT_ULICA
  INTO ref.TerytM_NazwaU_TerytU
  from b 

;
CREATE INDEX ix_ulice ON ref.TerytM_NazwaU_TerytU (TERYT_MIEJ_SIMC, TERYT_ULICA_SKLEJONA_1)
INCLUDE (TERYT_ULICA);

--teryt miejscowości, nazwa ulicyCLR teryt ulicy
    DROP TABLE IF EXISTS ref.TerytM_NazwaUCLR_TerytU;

with C as 
(
	SELECT	distinct SYM AS TERYT_MIEJ_SIMC, 
						TRIM(REPLACE([dbo].[UsuwanieNieliter](REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CONCAT(NAZWA_2,' ' ,NAZWA_1), N'ALEJA', 'AL '), N'ALEJE' , N'AL '), 'PLAC', 'PL '), '-GO ',' '),' GO ',' '), N'ŚWIĘTEGO', N'ŚW '), N'ŚWIĘTEJ', N'ŚW '), N'KSIĘDZA', N'KS '), N'BOHATERÓW', N'BOH '), N'GENERAŁA', N'GEN '), N'PUŁKOWNIKA', N'PŁK '),N'OSIEDLE', N'OS ')),'UL ', ''))
					AS ULICE_CLR, 
					SYM_UL AS TERYT_ULICA
	FROM CRS.zrodlo.TERYT_ULIC
	WHERE  LEN(SYM_UL) = 5
			AND [CzyUsuniety]=0
  ),	

  D as(
  select 
		TERYT_MIEJ_SIMC, 
		ULICE_CLR, 
		STRING_AGG(TERYT_ULICA, '; ') AS TERYT_ULICA
  from C
  GROUP BY  TERYT_MIEJ_SIMC, 
		ULICE_CLR
  )
  
  select TERYT_MIEJ_SIMC, ULICE_CLR AS ULICE_TMP_CLR, TERYT_ULICA
  INTO ref.TerytM_NazwaUCLR_TerytU
  from D;

CREATE INDEX ix_ulice ON ref.TerytM_NazwaUCLR_TerytU (TERYT_MIEJ_SIMC, ULICE_TMP_CLR)
INCLUDE (TERYT_ULICA);

--teryt miejscowości ulica krótka teryt ulicy
    DROP TABLE IF EXISTS ref.TerytM_NazwaUKrotka_TerytU;

with F as 
(
	SELECT	distinct SYM AS TERYT_MIEJ_SIMC,NAZWA_1 AS TERYT_ULICA_NAZWA_1,SYM_UL AS TERYT_ULICA
	FROM CRS.zrodlo.TERYT_ULIC
	WHERE  LEN(SYM_UL) = 5
			AND [CzyUsuniety]=0
  ),	
  
  G as(
  select 
		TERYT_MIEJ_SIMC, 
		TERYT_ULICA_NAZWA_1,  
		STRING_AGG(TERYT_ULICA, '; ') AS TERYT_ULICA
  from F
  GROUP BY TERYT_MIEJ_SIMC, 
		TERYT_ULICA_NAZWA_1
  )
  select TERYT_MIEJ_SIMC, TERYT_ULICA_NAZWA_1, TERYT_ULICA
  INTO ref.TerytM_NazwaUKrotka_TerytU
  from G

CREATE INDEX ix_ulice ON ref.TerytM_NazwaUKrotka_TerytU (TERYT_MIEJ_SIMC, TERYT_ULICA_NAZWA_1)
INCLUDE (TERYT_ULICA);

--Teryt miejscowości ulica krótka CLR teryt ulicy
    DROP TABLE IF EXISTS ref.TerytM_NazwaUKrotkaCLR_TerytU;

with I as 
(
	SELECT	distinct SYM AS TERYT_MIEJ_SIMC, 
						TRIM(REPLACE([dbo].[UsuwanieNieliter](REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(NAZWA_1, N'ALEJA', 'AL '), N'ALEJE' , N'AL '), 'PLAC', 'PL '), '-GO ',' '),' GO ',' '), N'ŚWIĘTEGO', N'ŚW '), N'ŚWIĘTEJ', N'ŚW '), N'KSIĘDZA', N'KS '), N'BOHATERÓW', N'BOH '), N'GENERAŁA', N'GEN '), N'PUŁKOWNIKA', N'PŁK '),N'OSIEDLE', N'OS ')),'UL ', ''))
					AS ULICA_KROTKA_CLR, 
					SYM_UL AS TERYT_ULICA
	FROM CRS.zrodlo.TERYT_ULIC
	WHERE  LEN(SYM_UL) = 5
			AND [CzyUsuniety]=0
  ),	
  
  J as(
  select 
		TERYT_MIEJ_SIMC, 
		ULICA_KROTKA_CLR,  
		STRING_AGG(TERYT_ULICA, '; ') AS TERYT_ULICA
  from I
  GROUP BY TERYT_MIEJ_SIMC, 
		ULICA_KROTKA_CLR
  )
  select TERYT_MIEJ_SIMC, ULICA_KROTKA_CLR, TERYT_ULICA
  INTO ref.TerytM_NazwaUKrotkaCLR_TerytU
  from J;

CREATE INDEX ix_ulice ON ref.TerytM_NazwaUKrotkaCLR_TerytU (TERYT_MIEJ_SIMC, ULICA_KROTKA_CLR)
INCLUDE (TERYT_ULICA);

--teryt miejscowości nazwa sklejona z cechą teryt ulicy
    DROP TABLE IF EXISTS ref.TerytM_NazwaUzCecha_TerytU;

with L as 
(
	SELECT	distinct SYM AS TERYT_MIEJ_SIMC, 
		TRIM(REPLACE([dbo].[UsuwanieNieliter](REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CONCAT(CECHA,' ',NAZWA_2,' ' ,NAZWA_1), N'ALEJA', 'AL '), N'ALEJE' , N'AL '), 'PLAC', 'PL '), '-GO ',' '),' GO ',' '), N'ŚWIĘTEGO', N'ŚW '), N'ŚWIĘTEJ', N'ŚW '), N'KSIĘDZA', N'KS '), N'BOHATERÓW', N'BOH '), N'GENERAŁA', N'GEN '), N'PUŁKOWNIKA', N'PŁK '),N'OSIEDLE', N'OS ')),'UL ', ''))
		as NAZWA, 
		SYM_UL AS TERYT_ULICA
	FROM CRS.zrodlo.TERYT_ULIC
	WHERE  LEN(SYM_UL) = 5
			AND [CzyUsuniety]=0
  ),	
  
  M as(
  select 
		TERYT_MIEJ_SIMC, 
		NAZWA, 
		STRING_AGG(TERYT_ULICA, '; ') AS TERYT_ULICA
  from L
  GROUP BY TERYT_MIEJ_SIMC, 
		NAZWA
  )
  select TERYT_MIEJ_SIMC, NAZWA, TERYT_ULICA
  INTO ref.TerytM_NazwaUzCecha_TerytU
  from M

CREATE INDEX ix_ulice ON ref.TerytM_NazwaUzCecha_TerytU (TERYT_MIEJ_SIMC, NAZWA)
INCLUDE (TERYT_ULICA);

--teryt miejscowości nazwa ulicy krótkiej z cechą teryt ulicy
    DROP TABLE IF EXISTS ref.TerytM_NazwaUKrotkazCecha_TerytU;

with O as 
(
	SELECT	distinct SYM AS  TERYT_MIEJ_SIMC,
		TRIM(REPLACE([dbo].[UsuwanieNieliter](REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(concat(CECHA,' ', NAZWA_1) , N'ALEJA', 'AL '), N'ALEJE' , N'AL '), 'PLAC', 'PL '), '-GO ',' '),' GO ',' '), N'ŚWIĘTEGO', N'ŚW '), N'ŚWIĘTEJ', N'ŚW '), N'KSIĘDZA', N'KS '), N'BOHATERÓW', N'BOH '), N'GENERAŁA', N'GEN '), N'PUŁKOWNIKA', N'PŁK '),N'OSIEDLE', N'OS ')),'UL ', ''))
		as NAZWA, 
		SYM_UL AS TERYT_ULICA
	FROM CRS.zrodlo.TERYT_ULIC
	WHERE  LEN(SYM_UL) = 5
  ),	
  
  P as(
  select 
		TERYT_MIEJ_SIMC, 
		NAZWA, 
		STRING_AGG(TERYT_ULICA, '; ') AS TERYT_ULICA
  from O 
  GROUP BY TERYT_MIEJ_SIMC, 
		NAZWA
  )
  select TERYT_MIEJ_SIMC, NAZWA, TERYT_ULICA
  INTO ref.TerytM_NazwaUKrotkazCecha_TerytU
  from P 
  ;

CREATE INDEX ix_ulice ON ref.TerytM_NazwaUKrotkazCecha_TerytU (TERYT_MIEJ_SIMC, NAZWA)
INCLUDE (TERYT_ULICA);

--teryt miejscowości nazwa ulicy CLR ,teryt ulicy, PNA
    DROP TABLE IF EXISTS ref.TerytM_PNA_NazwaUCLR_TerytU;

with R as 
(
	SELECT	distinct TERYT_MIEJ_SIMC,
			PNA,
			ULICE_CLR as NAZWA, 
			TERYT_ULICA
	FROM [NCB_MIG].[dbo].[TERYT_PNA]
	WHERE  LEN(TERYT_ULICA) = 5
  ),	
  
  S as(
  select 
		TERYT_MIEJ_SIMC,
		PNA,
		NAZWA, 
		STRING_AGG(TERYT_ULICA, '; ') AS TERYT_ULICA
  from R 
  GROUP BY TERYT_MIEJ_SIMC,
		PNA,
		NAZWA
  )
  select TERYT_MIEJ_SIMC, PNA, NAZWA, TERYT_ULICA
  INTO ref.TerytM_PNA_NazwaUCLR_TerytU
  from S 
  ;

CREATE INDEX ix_ulice ON ref.TerytM_PNA_NazwaUCLR_TerytU (TERYT_MIEJ_SIMC, PNA, NAZWA)
INCLUDE (TERYT_ULICA);

--teryt miejscowości nazwa ulicy krótkiej CLR ,teryt ulicy, PNA
    DROP TABLE IF EXISTS ref.TerytM_PNA_NazwaUKrotkaCLR_TerytU;

with T as 
(
	SELECT	distinct TERYT_MIEJ_SIMC,
			PNA,
			ULICA_KROTKA_CLR as NAZWA, 
			TERYT_ULICA
	FROM [NCB_MIG].[dbo].[TERYT_PNA]
	WHERE  LEN(TERYT_ULICA) = 5
  ),	
  
  U as(
  select 
		TERYT_MIEJ_SIMC,
		PNA,
		NAZWA, 
		STRING_AGG(TERYT_ULICA, '; ') AS TERYT_ULICA
  from T 
  GROUP BY TERYT_MIEJ_SIMC,
		PNA,
		NAZWA
  )
  select TERYT_MIEJ_SIMC, PNA, NAZWA, TERYT_ULICA
  INTO ref.TerytM_PNA_NazwaUKrotkaCLR_TerytU
  from U 
  ;

CREATE INDEX ix_ulice ON ref.TerytM_PNA_NazwaUKrotkaCLR_TerytU (TERYT_MIEJ_SIMC, PNA, NAZWA)
INCLUDE (TERYT_ULICA);
