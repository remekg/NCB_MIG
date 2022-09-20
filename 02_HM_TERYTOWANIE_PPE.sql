/* **********************************************
Data : 29.07.2022
Obiekt biznesowy : Punkt Poboru
Opis : Tworzenie i wype³nianie kolumn teryt

**************************************************
*/ 

--ALTER TABLE NCB_MIG.hm.Stg_PPE
--ADD 
--	TERYT_MIEJSCOWOSC nvarchar(255),
--	TERYT_MIEJSCOWOSC_POD nvarchar(255),
--	 MIEJSCOWOSC_CLR nvarchar(255),
--	ULICE_CLR nvarchar(255),
--  KOD_POCZTOWY_POP nvarchar(6)

--Krok 0 uzupe³nianie kolumn dodatkowych (ustalenia ze spotkañ, czyszczenie nazw)

UPDATE NCB_MIG.hm.Stg_PPE
	SET  MIEJSCOWOSC_CLR = dbo.UsuwanieNieliter(REPLACE(REPLACE(
		miejscowosc_ppe, N' KOL.',N' KOLONIA'), N' M£P', N' MA£OPOLSKI'))
UPDATE NCB_MIG.hm.Stg_PPE
	SET ULICE_CLR = TRIM(REPLACE([dbo].[UsuwanieNieliter](REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		ulica_ppe, N'ALEJA', 'AL '), N'ALEJE' , N'AL '), 'PLAC', 'PL '), '-GO ',' '),' GO ',' '), N'ŒWIÊTEGO', N'ŒW '), N'ŒWIÊTEJ', N'ŒW '), N'KSIÊDZA', N'KS '), N'BOHATERÓW', N'BOH '), N'GENERA£A', N'GEN '), N'PU£KOWNIKA', N'P£K '),N'OSIEDLE', N'OS ')),'UL ', ''))

;
--Krok 1 wyszukanie pojedynczych kombinacji PNA i nazwa miejscowoœci
  --wype³nianie kolumny teryt miejscowosci etap 1 (po kodzie pocztowym i nazwie)

UPDATE NCB_MIG.hm.Stg_PPE
	SET TERYT_MIEJSCOWOSC =
		 TERYT_MIEJ_SIMC FROM ref.PNA_NazwaM_TerytM
		WHERE TERYT_MIEJ_NAZWA = miejscowosc_ppe
			AND PNA = kod_pocztowy_ppe
			AND CzyMIG > 0;

-- Krok 2 wyszukanie pojedynczych kombinacji PNA i nazwa miejscowoœci_CLR

--wype³nianie kolumny teryt miejscowosci etap 2 (po kodzie pocztowym i nazwie z usuniêciem znaków)

UPDATE NCB_MIG.hm.Stg_PPE
	SET TERYT_MIEJSCOWOSC =
		 TERYT_MIEJ_SIMC FROM ref.PNA_NazwaMCLR_TerytM
		WHERE MIEJSCOWOSC_CLR = MIEJSCOWOSC_TMP_CLR
			AND PNA = kod_pocztowy_ppe
			AND (TERYT_MIEJSCOWOSC IS NULL OR LEN(TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
			AND CzyMIG > 0;

 --Krok 3 Wyszukiwanie miejscowoœci_CLR i ulicy_CLR z tylko jednym terytem w bazie PNA

--wype³nianie kolumny teryt miejscowosci etap 3 (po unikalnej kombinacji miejscowoœc_CLR ulica_CLR)

UPDATE NCB_MIG.hm.Stg_PPE
	SET TERYT_MIEJSCOWOSC = 
		 LEFT(TERYT_MIEJ_SIMC,255) FROM ref.NazwaMCLR_NazwaUCLR_TerytM
		WHERE MIEJSCOWOSC_TMP_CLR = MIEJSCOWOSC_CLR
			AND ULICE_CLR = ULICE_TMP_CLR
			AND (TERYT_MIEJSCOWOSC IS NULL OR LEN(TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
			AND CzyMIG > 0
			AND LEN(ULICE_CLR) > 0 ;

 --Krok 4 Wyszukiwanie miejscowoœci_CLR i [ULICA_KROTKA_CLR] z tylko jednym terytem w bazie PNA

--wype³nianie kolumny teryt miejscowosci etap 3 (po unikalnej kombinacji miejscowoœc_CLR ulica_CLR)

UPDATE NCB_MIG.hm.Stg_PPE
	SET TERYT_MIEJSCOWOSC = 
		 LEFT(TERYT_MIEJ_SIMC,255) FROM ref.NazwaMCLR_NazwaUKrotkiejCLR_TerytM
		WHERE MIEJSCOWOSC_TMP_CLR = MIEJSCOWOSC_CLR
			AND ULICE_CLR = ULICE_TMP_CLR
			AND (TERYT_MIEJSCOWOSC IS NULL OR LEN(TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
			AND CzyMIG > 0
			AND LEN(ULICE_CLR) > 0 ;

--Krok 5 wyszukanie pojedynczych kombinacji teryt gm. i nazwa miejscowoœci

--  with a as (
--SELECT	distinct TERYT_KOD_TERC,
--		CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
--			THEN N'Warszawa'
--			WHEN TERYT_POW_NAZWA = N'Poznañ'
--			THEN N'Poznañ'
--			WHEN TERYT_POW_NAZWA = N'Kraków'
--			THEN N'Kraków'
--			WHEN TERYT_POW_NAZWA = N'£ódŸ'
--			THEN N'£ódŸ'
--			WHEN TERYT_POW_NAZWA = N'Wroc³aw'
--			THEN N'Wroc³aw'
--			ELSE TERYT_MIEJ_NAZWA
--		END AS TERYT_MIEJ_NAZWA,
--		TERYT_MIEJ_SIMC
--  FROM [NCB_MIG].[dbo].[TERYT_PNA]
--		WHERE LEN(TERYT_MIEJ_NAZWA) > 0	
--			AND LEN(TERYT_KOD_TERC) > 0
--			AND LEN(TERYT_MIEJ_SIMC) > 0
--  ),	
  
--  b as(
--  select TERYT_KOD_TERC, 
--		TERYT_MIEJ_NAZWA,
--		STRING_AGG(TERYT_MIEJ_SIMC, '; ') AS TERYT_MIEJ_SIMC
--  from a
--  GROUP BY TERYT_KOD_TERC, 
--		TERYT_MIEJ_NAZWA
--  )
--  select TERYT_KOD_TERC, 
--		TERYT_MIEJ_NAZWA,
--		TERYT_MIEJ_SIMC
--  INTO ##tmp4
--  from b;
  
--  CREATE NONCLUSTERED INDEX IX_TMP ON ##tmp4 (TERYT_KOD_TERC, TERYT_MIEJ_NAZWA, TERYT_MIEJ_SIMC)
--;
  
----wype³nianie kolumny teryt miejscowosci (po nazwie i gminie)

--UPDATE NCB_MIG.hm.Stg_PPE
--	SET TERYT_MIEJSCOWOSC =
--		 TERYT_MIEJ_SIMC FROM ##tmp4
--		WHERE TERYT_MIEJ_NAZWA = miejscowosc
--			AND (TERYT_MIEJSCOWOSC IS NULL OR LEN(TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
--			AND mscgus = TERYT_KOD_TERC
--			AND CzyMIG > 0;

--Krok 6 wyszukanie pojedynczych kombinacji teryt gm. 6 znaków i nazwa miejscowoœci_CLR i PNA 4 znaki
  
UPDATE NCB_MIG.hm.Stg_PPE
	SET TERYT_MIEJSCOWOSC =
		 TERYT_MIEJ_SIMC FROM ref.PNA4Znaki_NazwaMCLR_GUS6_TerytM
		WHERE MIEJSCOWOSC_TMP_CLR = MIEJSCOWOSC_CLR
			AND (TERYT_MIEJSCOWOSC IS NULL OR LEN(TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
			AND LEFT(gus_ppe,6) = GUS_TMP
			AND LEFT(kod_pocztowy_ppe,4) = PNA
			AND CzyMIG > 0;

----Krok 7 wyszukanie pojedynczych kombinacji teryt gminy i PNA

-- DROP TABLE IF EXISTS ##tmp5;

--  with a as (
--SELECT	distinct TERYT_KOD_TERC,
--		PNA,
--		TERYT_MIEJ_SIMC
--  FROM [NCB_MIG].[dbo].[TERYT_PNA]
--		WHERE LEN(PNA) > 0	
--			AND LEN(TERYT_KOD_TERC) > 0
--			AND LEN(TERYT_MIEJ_SIMC) > 0
--  ),	
  
--  b as(
--  select TERYT_KOD_TERC, 
--		PNA,
--		TERYT_MIEJ_SIMC,
--		COUNT(*) over (partition by TERYT_KOD_TERC, PNA) as ile 
--  from a 
--  )
--  select TERYT_KOD_TERC, 
--		PNA,
--		TERYT_MIEJ_SIMC
--  INTO ##tmp6
--  from b 
--  where ile =1;
  
--  CREATE NONCLUSTERED INDEX IX_TMP ON ##tmp6 (TERYT_KOD_TERC, PNA, TERYT_MIEJ_SIMC)
--;
--  --wype³nianie kolumny teryt miejscowosci (po gminie i PNA)

--UPDATE NCB_MIG.hm.Stg_PPE
--	SET TERYT_MIEJSCOWOSC =
--		 TERYT_MIEJ_SIMC FROM ##tmp6
--		WHERE PNA = kodpocztowy
--			AND (TERYT_MIEJSCOWOSC IS NULL OR LEN(TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
--			AND mscgus = TERYT_KOD_TERC
--			AND CzyMIG > 0;

--Krok 8 wyszukanie pojedynczych kombinacji PNA, Miasto, Ulica

 --DROP TABLE IF EXISTS ##tmp6;

;
  
--wype³nianie kolumny teryt miejscowosci (po PNA, ulicy i miasto)

UPDATE NCB_MIG.hm.Stg_PPE
	SET TERYT_MIEJSCOWOSC =
		 TERYT_MIEJ_SIMC FROM ref.PNA_NazwaM_NazwaU_TerytM
		WHERE PNA = kod_pocztowy_ppe
			AND (TERYT_MIEJSCOWOSC IS NULL OR LEN(TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
			AND TERYT_ULICA_SKLEJONA_1 = ulica_ppe
			AND TERYT_MIEJ_NAZWA = miejscowosc_ppe
			AND CzyMIG > 0
			AND LEN(TERYT_ULICA_SKLEJONA_1) > 0 ;

--Krok 9 wype³nianie kolumny teryt miejscowosci (po PNA, ulicy i miasto z usuniêciem nieliter)

UPDATE NCB_MIG.hm.Stg_PPE
	SET TERYT_MIEJSCOWOSC =
		 TERYT_MIEJ_SIMC FROM ref.PNA_NazwaMCLR_NazwaUCLR_TerytM
		WHERE PNA = kod_pocztowy_ppe
			AND (TERYT_MIEJSCOWOSC IS NULL OR LEN(TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
			AND ULICE_TMP_CLR = ULICE_CLR
			AND MIEJSCOWOSC_CLR = MIEJSCOWOSC_TMP_CLR
			AND CzyMIG > 0
			AND LEN(ULICE_CLR) > 0 ;

  --Krok 10 wyszukanie pojedynczych kombinacji PNA, Miasto_CLR, Ulica krótka_CLR

;   

--wype³nianie kolumny teryt miejscowosci (po PNA, ulicy krótkiej_CLR i miasto_CLR)

UPDATE NCB_MIG.hm.Stg_PPE
	SET TERYT_MIEJSCOWOSC =
		 TERYT_MIEJ_SIMC FROM ref.PNA_NazwaMCLR_NazwaUKrotkaCLR_TerytM
		WHERE PNA = kod_pocztowy_ppe
			AND (TERYT_MIEJSCOWOSC IS NULL OR LEN(TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
			AND ULICA_KROTKA_TMP_CLR = ULICE_CLR
			AND MIEJSCOWOSC_TMP_CLR = MIEJSCOWOSC_CLR
			AND CzyMIG > 0
			AND LEN(ULICE_CLR) > 0;
--Krok 11 wyszukiwanie po kombinacji 4 znaków PNA i nazwie miejscowoœci CLR

UPDATE hm.Stg_PPE
	SET TERYT_MIEJSCOWOSC = 
			TERYT_MIEJ_SIMC FROM ref.PNA4Znaki_NazwaMCLR_TerytM ref
	WHERE hm.Stg_PPE.MIEJSCOWOSC_CLR = ref.MIEJSCOWOSC_TMP_CLR 
		AND LEFT(kod_pocztowy_ppe,4) = ref.pna
		AND (TERYT_MIEJSCOWOSC IS NULL
			OR LEN(TERYT_MIEJSCOWOSC) <> 7)
		AND (TERYT_MIEJSCOWOSC IS NULL OR LEN(TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
		AND CzyMIG > 0

--Krok 12 wyszukiwnie po kombinacji PNA i nazwa miejscowoœci Z UWZGLÊDNIENIEM KODÓW PLACÓWEK!!!!!

UPDATE hm.Stg_PPE
	SET TERYT_MIEJSCOWOSC = 
			TERYT_MIEJ_SIMC FROM ref.Lista_PNA_NazwaM_TerytM
	WHERE miejscowosc_ppe = TERYT_MIEJ_NAZWA 
		AND PNA = kod_pocztowy_ppe
		AND (TERYT_MIEJSCOWOSC IS NULL
			OR LEN(TERYT_MIEJSCOWOSC) <> 7)
		AND (TERYT_MIEJSCOWOSC IS NULL OR LEN(TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
		AND CzyMIG > 0
					   
--Krok13 wyszukiwanie po numerze budynku ulicy_CLR, dla kilku terytów

UPDATE NCB_MIG.hm.Stg_PPE
	SET TERYT_MIEJSCOWOSC = dbo.TERYT_Miasta_z_odcinkow(TERYT_MIEJSCOWOSC,ULICE_CLR,dom_ppe)
		WHERE CzyMIG >0
				AND LEN(TERYT_MIEJSCOWOSC) > 7
				AND LEN(ULICE_CLR) > 0
				AND LEN(dom_ppe) > 0
				AND LEN(TERYT_MIEJSCOWOSC) > LEN(dbo.TERYT_Miasta_z_odcinkow(TERYT_MIEJSCOWOSC,ULICE_CLR,dom_ppe))

-- Krok 14 wyszukiwanie dla przypadków wyboru terytu m. podstawowego gdy znaleziono kilka terytów i tylko 
-- 1 miasto podstawowe (po ustaleniach z biznesem)

UPDATE NCB_MIG.hm.Stg_PPE
	SET TERYT_MIEJSCOWOSC = dbo.TERYT_POD(TERYT_MIEJSCOWOSC,kod_pocztowy_ppe,-1)
		WHERE 
				CzyMIG > 0
				AND LEN(TERYT_MIEJSCOWOSC)> 7
				AND LEN(TERYT_MIEJSCOWOSC) > LEN(dbo.TERYT_POD(TERYT_MIEJSCOWOSC,kod_pocztowy_ppe,-1))



