/* **********************************************
Data : 21.07.2022
Obiekt biznesowy : Partner Handlowy
Opis : Tworzenie i wype³nianie kolumn teryt

**************************************************
*/ 
/*
ALTER TABLE NCB_MIG.en.Stg_PH
ADD TERYT_MIEJSCOWOSC nvarchar(255),
	KOR_TERYT_MIEJSCOWOSC nvarchar(255),
	TERYT_MIEJSCOWOSC_POD nvarchar(255),
	KOR_TERYT_MIEJSCOWOSC_POD nvarchar(255),
	KRAJ nvarchar(2),
	KOR_KRAJ nvarchar(2),
	TERYT_ULICY nvarchar(255),
	KOR_TERYT_ULICY nvarchar(255),
	 MIEJSCOWOSC_CLR nvarchar(255),
	ULICE_CLR nvarchar(255)
  KOD_POCZTOWY_POP nvarchar(6)
  ALTER TABLE	NCB_MIG.dbo.TERYT_PNA
ADD MIEJSCOWOSC_CLR nvarchar(255),
	ULICE_CLR nvarchar(255)
  */

--Krok 1 wyszukanie pojedynczych kombinacji PNA i nazwa miejscowoœci
  --wype³nianie kolumny teryt miejscowosci etap 1 (po kodzie pocztowym i nazwie)

UPDATE NCB_MIG.en.Stg_PH
	SET KOR_TERYT_MIEJSCOWOSC =
		 TERYT_MIEJ_SIMC FROM [ref].[PNA_NazwaM_TerytM]
		WHERE TERYT_MIEJ_NAZWA = kor_miejsc
			AND PNA = kor_kod_poczt
			AND CzyMIG > 0
			AND LEN(koresp) > 0;

-- Krok 2 wyszukanie pojedynczych kombinacji PNA i nazwa miejscowoœci_CLR
--wype³nianie kolumny teryt miejscowosci etap 2 (po kodzie pocztowym i nazwie z usuniêciem znaków)

UPDATE NCB_MIG.en.Stg_PH
	SET KOR_TERYT_MIEJSCOWOSC = 
		 TERYT_MIEJ_SIMC FROM [ref].[PNA_NazwaMCLR_TerytM]
		WHERE KOR_MIEJSCOWOSC_CLR = MIEJSCOWOSC_TMP_CLR
			AND PNA = kor_kod_poczt
			AND (KOR_TERYT_MIEJSCOWOSC IS NULL OR LEN(KOR_TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
			AND CzyMIG > 0
			AND LEN(koresp) > 0;

 --Krok 3 Wyszukiwanie miejscowoœci_CLR i ulicy_CLR z tylko jednym terytem w bazie PNA
--wype³nianie kolumny teryt miejscowosci etap 3 (po unikalnej kombinacji miejscowoœc_CLR ulica_CLR)

UPDATE NCB_MIG.en.Stg_PH
	SET KOR_TERYT_MIEJSCOWOSC = 
		 LEFT(TERYT_MIEJ_SIMC,255) FROM [ref].[NazwaMCLR_NazwaUCLR_TerytM]
		WHERE MIEJSCOWOSC_TMP_CLR = KOR_MIEJSCOWOSC_CLR
			AND KOR_ULICE_CLR = ULICE_TMP_CLR
			AND (KOR_TERYT_MIEJSCOWOSC IS NULL OR LEN(KOR_TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
			AND CzyMIG > 0
			AND LEN(koresp) > 0;

 --Krok 4 Wyszukiwanie miejscowoœci_CLR i [ULICA_KROTKA_CLR] z tylko jednym terytem w bazie PNA
--wype³nianie kolumny teryt miejscowosci etap 3 (po unikalnej kombinacji miejscowoœc_CLR ulica_CLR)

UPDATE NCB_MIG.en.Stg_PH
	SET KOR_TERYT_MIEJSCOWOSC = 
		 LEFT(TERYT_MIEJ_SIMC,255) FROM [ref].[NazwaMCLR_NazwaUKrotkiejCLR_TerytM]
		WHERE MIEJSCOWOSC_TMP_CLR = KOR_MIEJSCOWOSC_CLR
			AND KOR_ULICE_CLR = ULICE_TMP_CLR
			AND (KOR_TERYT_MIEJSCOWOSC IS NULL OR LEN(KOR_TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
			AND CzyMIG > 0
			AND LEN(koresp) > 0;

--Krok 8 wyszukanie pojedynczych kombinacji PNA, Miasto, Ulica  
--wype³nianie kolumny teryt miejscowosci (po PNA, ulicy i miasto)

UPDATE NCB_MIG.en.Stg_PH
	SET KOR_TERYT_MIEJSCOWOSC =
		 TERYT_MIEJ_SIMC FROM [ref].[PNA_NazwaM_NazwaU_TerytM]
		WHERE PNA = kor_kod_poczt
			AND (KOR_TERYT_MIEJSCOWOSC IS NULL OR LEN(KOR_TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
			AND TERYT_ULICA_SKLEJONA_1 = kor_ulica
			AND TERYT_MIEJ_NAZWA = kor_miejsc
			AND CzyMIG > 0
			AND LEN(koresp) > 0;

--Krok 9 wype³nianie kolumny teryt miejscowosci (po PNA, ulicy i miasto z usuniêciem nieliter)

UPDATE NCB_MIG.en.Stg_PH
	SET KOR_TERYT_MIEJSCOWOSC =
		 TERYT_MIEJ_SIMC FROM [ref].[PNA_NazwaMCLR_NazwaUCLR_TerytM]
		WHERE PNA = kor_kod_poczt
			AND (KOR_TERYT_MIEJSCOWOSC IS NULL OR LEN(KOR_TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
			AND ULICE_TMP_CLR = KOR_ULICE_CLR
			AND KOR_MIEJSCOWOSC_CLR = MIEJSCOWOSC_TMP_CLR
			AND CzyMIG > 0
			AND LEN(koresp) > 0;

  --Krok 10 wyszukanie pojedynczych kombinacji PNA, Miasto_CLR, Ulica krótka_CLR
--wype³nianie kolumny teryt miejscowosci (po PNA, ulicy krótkiej_CLR i miasto_CLR)

UPDATE NCB_MIG.en.Stg_PH
	SET KOR_TERYT_MIEJSCOWOSC =
		 TERYT_MIEJ_SIMC FROM [ref].[PNA_NazwaMCLR_NazwaUKrotkaCLR_TerytM]
		WHERE PNA = kor_kod_poczt
			AND (KOR_TERYT_MIEJSCOWOSC IS NULL OR LEN(KOR_TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
			AND ULICA_KROTKA_TMP_CLR = KOR_ULICE_CLR
			AND MIEJSCOWOSC_TMP_CLR = KOR_MIEJSCOWOSC_CLR
			AND CzyMIG > 0
			AND LEN(koresp) > 0;
--Krok 11 wyszukiwanie po kombinacji 4 znaków PNA i nazwie miejscowoœci CLR

UPDATE en.Stg_PH
	SET KOR_TERYT_MIEJSCOWOSC =
			TERYT_MIEJ_SIMC FROM ref.PNA4Znaki_NazwaMCLR_TerytM ref
	WHERE en.Stg_PH.KOR_MIEJSCOWOSC_CLR = ref.MIEJSCOWOSC_TMP_CLR 
		AND LEFT(en.Stg_PH.kor_kod_poczt,4) = ref.pna
		AND (KOR_TERYT_MIEJSCOWOSC IS NULL
			OR LEN(KOR_TERYT_MIEJSCOWOSC) <> 7)
		AND (KOR_TERYT_MIEJSCOWOSC IS NULL OR LEN(KOR_TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
		AND CzyMIG > 0
		AND LEN(koresp) > 0;

--Krok 12 wyszukiwnie po kombinacji PNA i nazwa miejscowoœci Z UWZGLÊDNIENIEM KODÓW PLACÓWEK!!!!!

UPDATE en.Stg_PH
	SET KOR_TERYT_MIEJSCOWOSC =
			TERYT_MIEJ_SIMC FROM [ref].[Lista_PNA_NazwaM_TerytM]
	WHERE kor_miejsc = TERYT_MIEJ_NAZWA 
		AND PNA = kor_kod_poczt
		AND (KOR_TERYT_MIEJSCOWOSC IS NULL OR LEN(KOR_TERYT_MIEJSCOWOSC) > LEN(TERYT_MIEJ_SIMC))
		AND CzyMIG > 0
		AND LEN(koresp) > 0;

--Krok13 wyszukiwanie po numerze budynku ulicy_CLR, dla kilku terytów

UPDATE NCB_MIG.en.Stg_PH
	SET KOR_TERYT_MIEJSCOWOSC = dbo.TERYT_Miasta_z_odcinkow(KOR_TERYT_MIEJSCOWOSC,KOR_ULICE_CLR,kor_dom)
		WHERE CzyMIG >0
				AND LEN(KOR_TERYT_MIEJSCOWOSC) > 7
				AND LEN(KOR_ULICE_CLR) > 0
				AND LEN(kor_dom) > 0
				AND LEN(koresp) > 0;

-- Krok 14 wyszukiwanie dla przypadków wyboru terytu m. podstawowego gdy znaleziono kilka terytów i tylko 
-- 1 miasto podstawowe (po ustaleniach z biznesem)

UPDATE NCB_MIG.en.Stg_PH
	SET KOR_TERYT_MIEJSCOWOSC =  dbo.TERYT_POD(KOR_TERYT_MIEJSCOWOSC,kor_kod_poczt,-1)
		WHERE 
				CzyMIG > 0
				AND LEN(KOR_TERYT_MIEJSCOWOSC)> 7
				AND (KOR_TERYT_MIEJSCOWOSC IS NULL OR LEN(KOR_TERYT_MIEJSCOWOSC) > LEN(dbo.TERYT_POD(KOR_TERYT_MIEJSCOWOSC,kor_kod_poczt,-1)))
				AND LEN(koresp) > 0;

