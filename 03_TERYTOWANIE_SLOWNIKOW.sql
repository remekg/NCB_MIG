/* **********************************************
Data : 21.07.2022
Obiekt biznesowy : Partner Handlowy
Opis : Tworzenie i wype³nianie kolumn teryt

**************************************************
*/ 
--ALTER TABLE NCB_MIG.dbo.Adresy_ALL
--ADD Miasto_Teryt nvarchar(255),
--	KOR_Miasto_Teryt nvarchar(255),
--	Miasto_Teryt_POD nvarchar(255),
--	KOR_Miasto_Teryt_POD nvarchar(255),
--	KRAJ nvarchar(2),
--	KOR_KRAJ nvarchar(2),
--	TERYT_ULICY nvarchar(255),
--	KOR_TERYT_ULICY nvarchar(255),
--  KOD_POCZTOWY_POP nvarchar(6)

--Krok 1 wyszukanie pojedynczych kombinacji teryt i nazwa miejscowoœci
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
			ELSE TERYT_MIEJ_NAZWA
		END AS TERYT_MIEJ_NAZWA,
		TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
		WHERE LEN(TERYT_MIEJ_NAZWA) > 0	
		AND LEN(TERYT_MIEJ_SIMC) > 0
  ), 
  
  b as(
  select pna, 
		TERYT_MIEJ_NAZWA,
		--TERYT_MIEJ_SIMC,
		--COUNT(*) over (partition by pna,TERYT_MIEJ_NAZWA) as ile 
		STRING_AGG(TERYT_MIEJ_SIMC, '; ') AS TERYT_MIEJ_SIMC
  from a
  GROUP BY pna, 
		TERYT_MIEJ_NAZWA
  )
  select pna, 
		TERYT_MIEJ_NAZWA,
		TERYT_MIEJ_SIMC
  INTO ##tmp
  from b 
  --where ile =1 

  
  CREATE NONCLUSTERED INDEX IX_TMP ON ##tmp (PNA, TERYT_MIEJ_NAZWA, TERYT_MIEJ_SIMC)

  --wype³nianie kolumny teryt Miasto_Nazwai etap 1 (po kodzie pocztowym i nazwie)

UPDATE NCB_MIG.dbo.Adresy_ALL
	SET Miasto_Teryt =
		 TERYT_MIEJ_SIMC FROM ##tmp
		WHERE TERYT_MIEJ_NAZWA = Miasto_Nazwa
			AND PNA = Kod_Pocztowy
			

--wype³nianie kolumny teryt Miasto_Nazwai etap 2 (po kodzie pocztowym i nazwie z usuniêciem znaków)

UPDATE NCB_MIG.dbo.Adresy_ALL
	SET Miasto_Teryt =
		 TERYT_MIEJ_SIMC FROM ##tmp
		WHERE dbo.UsuwanieNieliter(TERYT_MIEJ_NAZWA) = dbo.UsuwanieNieliter(Miasto_Nazwa)
			AND PNA = Kod_Pocztowy
			AND (Miasto_Teryt IS NULL OR LEN(Miasto_Teryt) > LEN(TERYT_MIEJ_SIMC))
			

 --Krok 2 Wyszukiwanie unikalnych miejscowoœci z tylko jednym terytem w bazie PNA

   with a as (
SELECT	distinct 
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
			ELSE TERYT_MIEJ_NAZWA
		END AS TERYT_MIEJ_NAZWA,
		TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
	WHERE LEN(TERYT_MIEJ_NAZWA) > 0	
		AND LEN(TERYT_MIEJ_SIMC) > 0
  ), 
  
  b as(
  select  
		TERYT_MIEJ_NAZWA,
		TERYT_MIEJ_SIMC,
		COUNT(*) over (partition by TERYT_MIEJ_NAZWA) as ile 
  from a 
  )
  select 
		TERYT_MIEJ_NAZWA,
		TERYT_MIEJ_SIMC
  INTO ##tmp2
  from b 
  where ile =1 

    CREATE NONCLUSTERED INDEX IX_TMP ON ##tmp2 (TERYT_MIEJ_NAZWA, TERYT_MIEJ_SIMC)

--wype³nianie kolumny teryt Miasto_Nazwai etap 3 (po unikalnej nazwie)

UPDATE NCB_MIG.dbo.Adresy_ALL
	SET Miasto_Teryt =
		 TERYT_MIEJ_SIMC FROM ##tmp2
		WHERE TERYT_MIEJ_NAZWA = Miasto_Nazwa
			AND (Miasto_Teryt IS NULL OR LEN(Miasto_Teryt) > LEN(TERYT_MIEJ_SIMC))
			

--wype³nianie kolumny teryt Miasto_Nazwai etap 4 (po unikalnej nazwie z usuniêciem znaków)

UPDATE NCB_MIG.dbo.Adresy_ALL
	SET Miasto_Teryt =
		 TERYT_MIEJ_SIMC FROM ##tmp2
		WHERE dbo.UsuwanieNieliter(TERYT_MIEJ_NAZWA) = dbo.UsuwanieNieliter(Miasto_Nazwa)
			AND (Miasto_Teryt IS NULL OR LEN(Miasto_Teryt) > LEN(TERYT_MIEJ_SIMC))
			


--Krok 3 wyszukanie pojedynczych kombinacji teryt gm. i nazwa miejscowoœci

  with a as (
SELECT	distinct TERYT_KOD_TERC,
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
			ELSE TERYT_MIEJ_NAZWA
		END AS TERYT_MIEJ_NAZWA,
		TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
		WHERE LEN(TERYT_MIEJ_NAZWA) > 0	
			AND LEN(TERYT_KOD_TERC) > 0
			AND LEN(TERYT_MIEJ_SIMC) > 0
  ),	
  
  b as(
  select TERYT_KOD_TERC, 
		TERYT_MIEJ_NAZWA,
		--TERYT_MIEJ_SIMC,
		--COUNT(*) over (partition by TERYT_KOD_TERC,TERYT_MIEJ_NAZWA) as ile 
		STRING_AGG(TERYT_MIEJ_SIMC, '; ') AS TERYT_MIEJ_SIMC
  from a
  GROUP BY TERYT_KOD_TERC, 
		TERYT_MIEJ_NAZWA
  )
  select TERYT_KOD_TERC, 
		TERYT_MIEJ_NAZWA,
		TERYT_MIEJ_SIMC
  INTO ##tmp3
  from b 
  --where ile =1 

  
  CREATE NONCLUSTERED INDEX IX_TMP ON ##tmp3 (TERYT_KOD_TERC, TERYT_MIEJ_NAZWA, TERYT_MIEJ_SIMC)

  
--wype³nianie kolumny teryt Miasto_Nazwai etap 5 (po nazwie i gminie)

UPDATE NCB_MIG.dbo.Adresy_ALL
	SET Miasto_Teryt =
		 TERYT_MIEJ_SIMC FROM ##tmp3
		WHERE TERYT_MIEJ_NAZWA = Miasto_Nazwa
			AND (Miasto_Teryt IS NULL OR LEN(Miasto_Teryt) > LEN(TERYT_MIEJ_SIMC))
			AND LEFT(Gmina_7,7) = TERYT_KOD_TERC
			


--wype³nianie kolumny teryt Miasto_Nazwai etap 6 (po kodzie pocztowym i nazwie z usuniêciem znaków z usuniêciem znaków)

UPDATE NCB_MIG.dbo.Adresy_ALL
	SET Miasto_Teryt =
		 TERYT_MIEJ_SIMC FROM ##tmp3
		WHERE dbo.UsuwanieNieliter(TERYT_MIEJ_NAZWA) = dbo.UsuwanieNieliter(Miasto_Nazwa)
			AND (Miasto_Teryt IS NULL OR LEN(Miasto_Teryt) > LEN(TERYT_MIEJ_SIMC))
			AND LEFT(Gmina_7,7) = TERYT_KOD_TERC
			

--Krok 4 wyszukanie pojedynczych kombinacji teryt i PNA

  with a as (
SELECT	distinct TERYT_KOD_TERC,
		PNA,
		TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
		WHERE LEN(PNA) > 0	
			AND LEN(TERYT_KOD_TERC) > 0
			AND LEN(TERYT_MIEJ_SIMC) > 0
  ),	
  
  b as(
  select TERYT_KOD_TERC, 
		PNA,
		TERYT_MIEJ_SIMC,
		COUNT(*) over (partition by TERYT_KOD_TERC, PNA) as ile 
  from a 
  )
  select TERYT_KOD_TERC, 
		PNA,
		TERYT_MIEJ_SIMC
  INTO ##tmp4
  from b 
  where ile =1 

  
  CREATE NONCLUSTERED INDEX IX_TMP ON ##tmp4 (TERYT_KOD_TERC, PNA, TERYT_MIEJ_SIMC)

  --wype³nianie kolumny teryt Miasto_Nazwai etap 7 (po gminie i PNA)

UPDATE NCB_MIG.dbo.Adresy_ALL
	SET Miasto_Teryt =
		 TERYT_MIEJ_SIMC FROM ##tmp4
		WHERE PNA = Kod_Pocztowy
			AND (Miasto_Teryt IS NULL OR LEN(Miasto_Teryt) > LEN(TERYT_MIEJ_SIMC))
			AND LEFT(Gmina_7,7) = TERYT_KOD_TERC
			

--Krok 5 wyszukanie pojedynczych kombinacji PNA, Miasto, Ulica

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
		--TERYT_MIEJ_SIMC,
		--COUNT(*) over (partition by PNA,TERYT_MIEJ_NAZWA, TERYT_ULICA_SKLEJONA_1) as ile 
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
  INTO ##tmp5
  from b 
  --where ile =1 

  
  CREATE NONCLUSTERED INDEX IX_TMP ON ##tmp5 (PNA, TERYT_MIEJ_NAZWA, TERYT_MIEJ_SIMC, TERYT_ULICA_SKLEJONA_1)

  
--wype³nianie kolumny teryt Miasto_Nazwai etap 8 (po PNA, ulicy i miasto)

UPDATE NCB_MIG.dbo.Adresy_ALL
	SET Miasto_Teryt =
		 TERYT_MIEJ_SIMC FROM ##tmp5
		WHERE PNA = Kod_Pocztowy
			AND (Miasto_Teryt IS NULL OR LEN(Miasto_Teryt) > LEN(TERYT_MIEJ_SIMC))
			AND TERYT_ULICA_SKLEJONA_1 = Ulica_Nazwa_Pelna
			AND TERYT_MIEJ_NAZWA = Miasto_Nazwa
			

--wype³nianie kolumny teryt Miasto_Nazwai etap 9 (po PNA, ulicy i miasto z usuniêciem nieliter)

UPDATE NCB_MIG.dbo.Adresy_ALL
	SET Miasto_Teryt =
		 TERYT_MIEJ_SIMC FROM ##tmp5
		WHERE PNA = Kod_Pocztowy
			AND (Miasto_Teryt IS NULL OR LEN(Miasto_Teryt) > LEN(TERYT_MIEJ_SIMC))
			AND dbo.UsuwanieNieliter(TERYT_ULICA_SKLEJONA_1) = dbo.UsuwanieNieliter(Ulica_Nazwa_Pelna)
			AND dbo.UsuwanieNieliter(TERYT_MIEJ_NAZWA) = dbo.UsuwanieNieliter(Miasto_Nazwa)
			

  --Krok 6 wyszukanie pojedynczych kombinacji PNA, Miasto, Ulica krótka

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
			ELSE TERYT_MIEJ_NAZWA
		END AS TERYT_MIEJ_NAZWA,
		TERYT_ULICA_NAZWA_1,
		TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
		WHERE LEN(TERYT_MIEJ_NAZWA) > 0	
			AND LEN(TERYT_KOD_TERC) > 0
			AND LEN(TERYT_MIEJ_SIMC) > 0
			AND LEN(TERYT_ULICA_NAZWA_1) > 0
  ),	
  
  b as(
  select PNA,  
		TERYT_MIEJ_NAZWA,
		TERYT_ULICA_NAZWA_1,
		--TERYT_MIEJ_SIMC,
		--COUNT(*) over (partition by PNA,TERYT_MIEJ_NAZWA, TERYT_ULICA_NAZWA_1) as ile 
		STRING_AGG(TERYT_MIEJ_SIMC, '; ') AS TERYT_MIEJ_SIMC
  from a
  GROUP BY PNA,  
		TERYT_MIEJ_NAZWA,
		TERYT_ULICA_NAZWA_1
  )
  select PNA, 
		TERYT_MIEJ_NAZWA,
		TERYT_ULICA_NAZWA_1,
		TERYT_MIEJ_SIMC
  INTO ##tmp6
  from b 
  --where ile =1 

  
  CREATE NONCLUSTERED INDEX IX_TMP ON ##tmp6 (PNA, TERYT_MIEJ_NAZWA, TERYT_MIEJ_SIMC, TERYT_ULICA_NAZWA_1)
   
--CREATE NONCLUSTERED INDEX IX_1 ON NCB_MIG.dbo.Adresy_ALL (Kod_Pocztowy, Miasto_Nazwa)
--CREATE NONCLUSTERED INDEX IX_2 ON NCB_MIG.dbo.Adresy_ALL (kor_kod_poczt, kor_miejsc)


--wype³nianie kolumny teryt Miasto_Nazwai etap 10 (po PNA, ulicy krótkiej i miasto)

UPDATE NCB_MIG.dbo.Adresy_ALL
	SET Miasto_Teryt =
		 TERYT_MIEJ_SIMC FROM ##tmp6
		WHERE PNA = Kod_Pocztowy
			AND (Miasto_Teryt IS NULL OR LEN(Miasto_Teryt) > LEN(TERYT_MIEJ_SIMC))
			AND TERYT_ULICA_NAZWA_1 = Ulica_Nazwa_Pelna
			AND TERYT_MIEJ_NAZWA = Miasto_Nazwa
			

--wype³nianie kolumny teryt Miasto_Nazwai etap 11 (po PNA, ulicy krótkiej i miasto z usuniêciem nieliter)

UPDATE NCB_MIG.dbo.Adresy_ALL
	SET Miasto_Teryt =
		 TERYT_MIEJ_SIMC FROM ##tmp6
		WHERE PNA = Kod_Pocztowy
			AND (Miasto_Teryt IS NULL OR LEN(Miasto_Teryt) > LEN(TERYT_MIEJ_SIMC))
			AND dbo.UsuwanieNieliter(TERYT_ULICA_NAZWA_1) = dbo.UsuwanieNieliter(Ulica_Nazwa_Pelna)
			AND dbo.UsuwanieNieliter(TERYT_MIEJ_NAZWA) = dbo.UsuwanieNieliter(Miasto_Nazwa)
			

--DROP TABLE ##tmp
--DROP TABLE ##tmp2
--DROP TABLE ##tmp3
--DROP TABLE ##tmp4
--DROP TABLE ##tmp5