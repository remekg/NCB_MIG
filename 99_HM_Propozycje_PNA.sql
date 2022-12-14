--krok 1 wyszukiwanie po terycie miejscowo?ci

WITH A AS
(
SELECT	DISTINCT TERYT_MIEJ_SIMC,
		PNA
FROM dbo.TERYT_PNA
WHERE LEN(TERYT_MIEJ_SIMC) > 0
		AND LEN(PNA) > 0
)

SELECT TERYT_MIEJ_SIMC,
		CASE WHEN LEN(LEFT(STRING_AGG(PNA,';'),255)) < 14
			THEN STRING_AGG(PNA,';') 
			ELSE 'Wi?cej ni? 2 kody'
		END AS PNA
INTO ##tmp
FROM A 
GROUP BY TERYT_MIEJ_SIMC
--adres podstawowy
UPDATE hm.Stg_PH
	SET KOD_POCZTOWY_POP = (SELECT PNA FROM ##tmp WHERE hm.Stg_PH.TERYT_MIEJSCOWOSC = TERYT_MIEJ_SIMC)
WHERE 1=1
	AND CzyMIG > 0
--adres koresp
UPDATE hm.Stg_PH
	SET KOR_KOD_POCZTOWY_POP = (SELECT PNA FROM ##tmp WHERE hm.Stg_PH.KOR_TERYT_MIEJSCOWOSC = TERYT_MIEJ_SIMC)
WHERE 1=1
	AND CzyMIG > 0
	AND LEN([kor_nazwa1]) > 0
--adres PPE
UPDATE hm.Stg_PPE
	SET [KOD_POCZTOWY_POP] = (SELECT PNA FROM ##tmp WHERE hm.Stg_PPE.TERYT_MIEJSCOWOSC = TERYT_MIEJ_SIMC)
WHERE 1=1
	AND CzyMIG > 0

DROP TABLE IF EXISTS ##tmp;

--Krok 2 wyszukiwanie po teryt i nazwie ulicy

WITH B AS
(
SELECT	DISTINCT 
		TERYT_MIEJ_SIMC,
		ULICE_CLR,
		PNA
FROM dbo.TERYT_PNA
WHERE LEN(TERYT_MIEJ_SIMC) > 0
		AND LEN(PNA) > 0
		AND LEN(ULICE_CLR) > 0
)

SELECT TERYT_MIEJ_SIMC AS TERYT_MIEJ_TMP_SIMC,
		ULICE_CLR AS ULICE_TMP_CLR,
		CASE WHEN LEN(LEFT(STRING_AGG(PNA,';'),255)) < 14
			THEN STRING_AGG(PNA,';')
			ELSE 'Wi?cej ni? 2 kody'
		END AS PNA
INTO ##tmp1
FROM B
GROUP BY TERYT_MIEJ_SIMC,
		ULICE_CLR
--adres podstawowy
UPDATE hm.Stg_PH
	SET KOD_POCZTOWY_POP = PNA
FROM ##tmp1 
WHERE 1=1
	AND CzyMIG > 0
	AND (KOD_POCZTOWY_POP IS NULL OR LEN(KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PH.TERYT_MIEJSCOWOSC = ##tmp1.TERYT_MIEJ_TMP_SIMC
	AND hm.Stg_PH.ULICE_CLR = ##tmp1.ULICE_TMP_CLR
	AND LEN(ULICE_CLR) > 0
--adres koresp
UPDATE hm.Stg_PH
	SET KOR_KOD_POCZTOWY_POP = PNA
FROM ##tmp1 
WHERE 1=1
	AND CzyMIG > 0
	AND (KOR_KOD_POCZTOWY_POP IS NULL OR LEN(KOR_KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PH.KOR_TERYT_MIEJSCOWOSC = ##tmp1.TERYT_MIEJ_TMP_SIMC
	AND hm.Stg_PH.KOR_ULICE_CLR = ##tmp1.ULICE_TMP_CLR
	AND LEN(KOR_ULICE_CLR) > 0
--adres PPE
UPDATE hm.Stg_PPE
	SET KOD_POCZTOWY_POP = PNA
FROM ##tmp1 
WHERE 1=1
	AND CzyMIG > 0
	AND (KOD_POCZTOWY_POP IS NULL OR LEN(KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PPE.TERYT_MIEJSCOWOSC = ##tmp1.TERYT_MIEJ_TMP_SIMC
	AND hm.Stg_PPE.ULICE_CLR = ##tmp1.ULICE_TMP_CLR
	AND LEN(ULICE_CLR) > 0
DROP TABLE IF EXISTS ##tmp1;

--Krok 3 wyszukiwanie po nazwie i nazwie ulicy
;
WITH C AS
(
SELECT	DISTINCT 
	CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
			THEN N'Warszawa'
			WHEN TERYT_POW_NAZWA = N'Pozna?'
			THEN N'Pozna?'
			WHEN TERYT_POW_NAZWA = N'Krak?w'
			THEN N'Krak?w'
			WHEN TERYT_POW_NAZWA = N'??d?'
			THEN N'??d?'
			WHEN TERYT_POW_NAZWA = N'Wroc?aw'
			THEN N'Wroc?aw'
			ELSE MIEJSCOWOSC_CLR
		END AS MIEJSCOWOSC_CLR,
		ULICE_CLR,
		PNA
FROM dbo.TERYT_PNA
WHERE LEN(MIEJSCOWOSC_CLR) > 0
		AND LEN(PNA) > 0
		AND LEN(ULICE_CLR) > 0
)

SELECT MIEJSCOWOSC_CLR AS MIEJSCOWOSC_TMP_CLR,
		ULICE_CLR AS ULICE_TMP_CLR,
		CASE WHEN LEN(LEFT(STRING_AGG(PNA,';'),255)) < 14
			THEN STRING_AGG(PNA,';')
			ELSE 'Wi?cej ni? 2 kody'
		END AS PNA
INTO ##tmp2
FROM C
GROUP BY MIEJSCOWOSC_CLR,
		ULICE_CLR

  CREATE NONCLUSTERED INDEX IX_TMP ON ##tmp2 (PNA, MIEJSCOWOSC_TMP_CLR, ULICE_TMP_CLR)
--adres podstawowy
UPDATE hm.Stg_PH
	SET KOD_POCZTOWY_POP =PNA 
FROM ##tmp2
WHERE 1=1
	AND CzyMIG > 0
	AND (KOD_POCZTOWY_POP IS NULL OR LEN(KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PH.MIEJSCOWOSC_CLR = ##tmp2.MIEJSCOWOSC_TMP_CLR
	AND hm.Stg_PH.ULICE_CLR = ##tmp2.ULICE_TMP_CLR
	AND LEN(ULICE_CLR) > 0
--adres koresp
UPDATE hm.Stg_PH
	SET KOR_KOD_POCZTOWY_POP =PNA 
FROM ##tmp2
WHERE 1=1
	AND CzyMIG > 0
	AND (KOR_KOD_POCZTOWY_POP IS NULL OR LEN(KOR_KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PH.KOR_MIEJSCOWOSC_CLR = ##tmp2.MIEJSCOWOSC_TMP_CLR
	AND hm.Stg_PH.KOR_ULICE_CLR = ##tmp2.ULICE_TMP_CLR
	AND LEN(KOR_ULICE_CLR) > 0
--adres PPE
UPDATE hm.Stg_PPE
	SET KOD_POCZTOWY_POP =PNA 
FROM ##tmp2
WHERE 1=1
	AND CzyMIG > 0
	AND (KOD_POCZTOWY_POP IS NULL OR LEN(KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PPE.MIEJSCOWOSC_CLR = ##tmp2.MIEJSCOWOSC_TMP_CLR
	AND hm.Stg_PPE.ULICE_CLR = ##tmp2.ULICE_TMP_CLR
	AND LEN(ULICE_CLR) > 0

DROP TABLE IF EXISTS ##tmp2;

--Krok 4 wyszukiwanie po teryt i nazwie ulicy kr?tkiej

WITH D AS
(
SELECT	DISTINCT 
		TERYT_MIEJ_SIMC,
		ULICA_KROTKA_CLR,
		PNA
FROM dbo.TERYT_PNA
WHERE LEN(TERYT_MIEJ_SIMC) > 0
		AND LEN(PNA) > 0
		AND LEN(ULICA_KROTKA_CLR) > 0
)

SELECT TERYT_MIEJ_SIMC AS TERYT_MIEJ_TMP_SIMC,
		ULICA_KROTKA_CLR,
		CASE WHEN LEN(LEFT(STRING_AGG(PNA,';'),255)) < 14
			THEN STRING_AGG(PNA,';')
			ELSE 'Wi?cej ni? 2 kody'
		END AS PNA
INTO ##tmp3
FROM D
GROUP BY TERYT_MIEJ_SIMC,
		ULICA_KROTKA_CLR
--adres podstawowy
UPDATE hm.Stg_PH
	SET KOD_POCZTOWY_POP =PNA 
FROM ##tmp3
WHERE 1=1
	AND CzyMIG > 0
	AND (KOD_POCZTOWY_POP IS NULL OR LEN(KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PH.TERYT_MIEJSCOWOSC = ##tmp3.TERYT_MIEJ_TMP_SIMC
	AND hm.Stg_PH.ULICE_CLR = ##tmp3.ULICA_KROTKA_CLR
	AND LEN(ULICE_CLR) > 0
--ares koresp
UPDATE hm.Stg_PH
	SET KOR_KOD_POCZTOWY_POP =PNA 
FROM ##tmp3
WHERE 1=1
	AND CzyMIG > 0
	AND (KOR_KOD_POCZTOWY_POP IS NULL OR LEN(KOR_KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PH.KOR_TERYT_MIEJSCOWOSC = ##tmp3.TERYT_MIEJ_TMP_SIMC
	AND hm.Stg_PH.KOR_ULICE_CLR = ##tmp3.ULICA_KROTKA_CLR
	AND LEN(KOR_ULICE_CLR) > 0
--adres PPE
UPDATE hm.Stg_PPE
	SET KOD_POCZTOWY_POP =PNA 
FROM ##tmp3
WHERE 1=1
	AND CzyMIG > 0
	AND (KOD_POCZTOWY_POP IS NULL OR LEN(KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PPE.TERYT_MIEJSCOWOSC = ##tmp3.TERYT_MIEJ_TMP_SIMC
	AND hm.Stg_PPE.ULICE_CLR = ##tmp3.ULICA_KROTKA_CLR
	AND LEN(ULICE_CLR) > 0

DROP TABLE IF EXISTS ##tmp3;

--Krok 5 wyszukiwanie po nazwie i nazwie ulicy kr?tkiej

WITH E AS
(
SELECT	DISTINCT 
	CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
			THEN N'Warszawa'
			WHEN TERYT_POW_NAZWA = N'Pozna?'
			THEN N'Pozna?'
			WHEN TERYT_POW_NAZWA = N'Krak?w'
			THEN N'Krak?w'
			WHEN TERYT_POW_NAZWA = N'??d?'
			THEN N'??d?'
			WHEN TERYT_POW_NAZWA = N'Wroc?aw'
			THEN N'Wroc?aw'
			ELSE MIEJSCOWOSC_CLR
		END AS MIEJSCOWOSC_CLR,
		ULICA_KROTKA_CLR,
		PNA
FROM dbo.TERYT_PNA
WHERE LEN(MIEJSCOWOSC_CLR) > 0
		AND LEN(PNA) > 0
		AND LEN(ULICA_KROTKA_CLR) > 0
)

SELECT MIEJSCOWOSC_CLR AS MIEJSCOWOSC_TMP_CLR,
		ULICA_KROTKA_CLR,
		CASE WHEN LEN(LEFT(STRING_AGG(PNA,';'),255)) < 14
			THEN STRING_AGG(PNA,';')
			ELSE 'Wi?cej ni? 2 kody'
		END AS PNA
INTO ##tmp4
FROM E
GROUP BY MIEJSCOWOSC_CLR,
		ULICA_KROTKA_CLR

  CREATE NONCLUSTERED INDEX IX_TMP ON ##tmp4 (PNA, MIEJSCOWOSC_TMP_CLR, ULICA_KROTKA_CLR)
--adres podstawowy
UPDATE hm.Stg_PH
	SET KOD_POCZTOWY_POP = PNA  
FROM ##tmp4
WHERE 1=1
	AND CzyMIG > 0
	AND (KOD_POCZTOWY_POP IS NULL OR LEN(KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PH.MIEJSCOWOSC_CLR = ##tmp4.MIEJSCOWOSC_TMP_CLR
	AND hm.Stg_PH.ULICE_CLR = ##tmp4.ULICA_KROTKA_CLR
	AND LEN(ULICE_CLR) > 0
--adres koresp
UPDATE hm.Stg_PH
	SET KOR_KOD_POCZTOWY_POP = PNA  
FROM ##tmp4
WHERE 1=1
	AND CzyMIG > 0
	AND (KOR_KOD_POCZTOWY_POP IS NULL OR LEN(KOR_KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PH.KOR_MIEJSCOWOSC_CLR = ##tmp4.MIEJSCOWOSC_TMP_CLR
	AND hm.Stg_PH.KOR_ULICE_CLR = ##tmp4.ULICA_KROTKA_CLR
	AND LEN(KOR_ULICE_CLR) > 0
--adres PPE
UPDATE hm.Stg_PPE
	SET KOD_POCZTOWY_POP = PNA  
FROM ##tmp4
WHERE 1=1
	AND CzyMIG > 0
	AND (KOD_POCZTOWY_POP IS NULL OR LEN(KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PPE.MIEJSCOWOSC_CLR = ##tmp4.MIEJSCOWOSC_TMP_CLR
	AND hm.Stg_PPE.ULICE_CLR = ##tmp4.ULICA_KROTKA_CLR
	AND LEN(ULICE_CLR) > 0

DROP TABLE IF EXISTS ##tmp4;

--Krok 6 wyszukiwanie po teryt i nazwie ulicy i numer budynku

WITH F AS
(
SELECT	DISTINCT 
		TERYT_MIEJ_SIMC,
		ULICE_CLR,
		dbo.nrdomu(OD) AS OD,
		dbo.nrdomu(DO) AS DO,
		PARZYSTOSC,
		PNA
FROM dbo.TERYT_PNA
WHERE LEN(TERYT_MIEJ_SIMC) > 0
		AND LEN(PNA) > 0
		AND LEN(ULICE_CLR) > 0
		AND dbo.nrdomu(DO) > 0
)

SELECT TERYT_MIEJ_SIMC AS TERYT_MIEJ_TMP_SIMC,
		ULICE_CLR AS ULICE_TMP_CLR,
		OD, DO,
		PARZYSTOSC,
		CASE WHEN LEN(LEFT(STRING_AGG(PNA,';'),255)) < 14
			THEN STRING_AGG(PNA,';')
			ELSE 'Wi?cej ni? 2 kody'
		END AS PNA
INTO ##tmp5
FROM F
GROUP BY TERYT_MIEJ_SIMC,
		ULICE_CLR,
		OD, DO,
		PARZYSTOSC


SELECT Klucz_PH AS Klucz_TMP_PH, (SELECT STRING_AGG(PNA,';') FROM ##tmp5 WHERE 
			(KOD_POCZTOWY_POP IS NULL OR LEN(KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PH.TERYT_MIEJSCOWOSC = ##tmp5.TERYT_MIEJ_TMP_SIMC
	AND hm.Stg_PH.ULICE_CLR = ##tmp5.ULICE_TMP_CLR
	AND LEN(ULICE_CLR) > 0
	AND PARZYSTOSC LIKE '%' + dbo.CzyParzysta(dbo.nrdomu(nrdomu)) + '%'
	AND dbo.nrdomu(nrdomu) BETWEEN OD AND DO
										) AS PNA_POP
INTO ##tmp5b
FROM  hm.Stg_PH
WHERE 1=1
	AND CzyMIG > 0		
	AND LEN(nrdomu)>0

SELECT Klucz_PH AS Klucz_TMP_PH, (SELECT STRING_AGG(PNA,';') FROM ##tmp5 WHERE 
			(KOR_KOD_POCZTOWY_POP IS NULL OR LEN(KOR_KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PH.KOR_TERYT_MIEJSCOWOSC = ##tmp5.TERYT_MIEJ_TMP_SIMC
	AND hm.Stg_PH.KOR_ULICE_CLR = ##tmp5.ULICE_TMP_CLR
	AND LEN(KOR_ULICE_CLR) > 0
	AND PARZYSTOSC LIKE '%' + dbo.CzyParzysta(dbo.nrdomu(kor_dom)) + '%'
	AND dbo.nrdomu(kor_dom) BETWEEN OD AND DO
										) AS PNA_POP
INTO ##tmp5b_koresp
FROM  hm.Stg_PH
WHERE 1=1
	AND CzyMIG > 0		
	AND LEN(kor_dom)>0
	AND LEN([kor_nazwa1]) > 0

SELECT Klucz_UP AS Klucz_TMP_UP, 
		(SELECT STRING_AGG(PNA,';') FROM ##tmp5 WHERE 
			(KOD_POCZTOWY_POP IS NULL OR LEN(KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PPE.TERYT_MIEJSCOWOSC = ##tmp5.TERYT_MIEJ_TMP_SIMC
	AND hm.Stg_PPE.ULICE_CLR = ##tmp5.ULICE_TMP_CLR
	AND LEN(ULICE_CLR) > 0
	AND PARZYSTOSC LIKE '%' + dbo.CzyParzysta(dbo.nrdomu(dom_ppe)) + '%'
	AND dbo.nrdomu(dom_ppe) BETWEEN OD AND DO
										) AS PNA_POP
INTO ##tmp5b_ppe
FROM  hm.Stg_PPE
WHERE 1=1
	AND CzyMIG > 0		
	AND LEN(dom_ppe)>0
;
--adres podstawowy
UPDATE hm.Stg_PH
SET KOD_POCZTOWY_POP = PNA_POP
FROM ##tmp5b
WHERE hm.Stg_PH.Klucz_PH = Klucz_TMP_PH
	AND PNA_POP IS NOT NULL
	AND (KOD_POCZTOWY_POP IS NULL OR LEN(KOD_POCZTOWY_POP) > LEN(PNA_POP))
--adres koresp
UPDATE hm.Stg_PH
SET KOR_KOD_POCZTOWY_POP = PNA_POP
FROM ##tmp5b_koresp
WHERE hm.Stg_PH.Klucz_PH = Klucz_TMP_PH
	AND PNA_POP IS NOT NULL
	AND (KOR_KOD_POCZTOWY_POP IS NULL OR LEN(KOR_KOD_POCZTOWY_POP) > LEN(PNA_POP))
	AND LEN([kor_nazwa1]) > 0
--adres PPE
UPDATE hm.Stg_PPE
SET KOD_POCZTOWY_POP = PNA_POP
FROM ##tmp5b_ppe
WHERE hm.Stg_PPE.Klucz_UP = Klucz_TMP_UP
	AND PNA_POP IS NOT NULL
	AND (KOD_POCZTOWY_POP IS NULL OR LEN(KOD_POCZTOWY_POP) > LEN(PNA_POP))

DROP TABLE IF EXISTS ##tmp5;
DROP TABLE IF EXISTS ##tmp5b;
DROP TABLE IF EXISTS ##tmp5b_koresp;
DROP TABLE IF EXISTS ##tmp5b_ppe;

--Krok 7 wyszukiwanie po nazwie

WITH G AS
(
SELECT	DISTINCT 
	CASE WHEN TERYT_POW_NAZWA = N'Warszawa'
			THEN N'Warszawa'
			WHEN TERYT_POW_NAZWA = N'Pozna?'
			THEN N'Pozna?'
			WHEN TERYT_POW_NAZWA = N'Krak?w'
			THEN N'Krak?w'
			WHEN TERYT_POW_NAZWA = N'??d?'
			THEN N'??d?'
			WHEN TERYT_POW_NAZWA = N'Wroc?aw'
			THEN N'Wroc?aw'
			ELSE MIEJSCOWOSC_CLR
		END AS MIEJSCOWOSC_CLR,
		PNA
FROM dbo.TERYT_PNA
WHERE LEN(MIEJSCOWOSC_CLR) > 0
		AND LEN(PNA) > 0
),
--wymuszona tabela tymczasowa - ograniczenia funkcji STRING_AGG
H AS 
(
SELECT DISTINCT MIEJSCOWOSC_CLR,
	CASE WHEN 
		COUNT(*) OVER (PARTITION BY MIEJSCOWOSC_CLR ORDER BY MIEJSCOWOSC_CLR) >2
		THEN 'Wi?cej ni? 2 kody'
		ELSE PNA
		END AS PNA
FROM G
)

SELECT MIEJSCOWOSC_CLR AS MIEJSCOWOSC_TMP_CLR,
		CASE WHEN LEN(LEFT(STRING_AGG(CONVERT(NVARCHAR(max), PNA),';'),255)) < 14
			THEN STRING_AGG(PNA,';')
			ELSE 'Wi?cej ni? 2 kody'
		END AS PNA
INTO ##tmp6
FROM H
GROUP BY MIEJSCOWOSC_CLR

  CREATE NONCLUSTERED INDEX IX_TMP ON ##tmp6 (PNA, MIEJSCOWOSC_TMP_CLR)
--adres podstawowy
UPDATE hm.Stg_PH
	SET KOD_POCZTOWY_POP = PNA  
FROM ##tmp6
WHERE 1=1
	AND CzyMIG > 0
	AND (KOD_POCZTOWY_POP IS NULL OR LEN(KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PH.MIEJSCOWOSC_CLR = ##tmp6.MIEJSCOWOSC_TMP_CLR
--adres koresp
UPDATE hm.Stg_PH
	SET KOR_KOD_POCZTOWY_POP = PNA  
FROM ##tmp6
WHERE 1=1
	AND CzyMIG > 0
	AND (KOR_KOD_POCZTOWY_POP IS NULL OR LEN(KOR_KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PH.KOR_MIEJSCOWOSC_CLR = ##tmp6.MIEJSCOWOSC_TMP_CLR
	AND LEN([kor_nazwa1]) > 0
--adres PPE
UPDATE hm.Stg_PPE
	SET KOD_POCZTOWY_POP = PNA  
FROM ##tmp6
WHERE 1=1
	AND CzyMIG > 0
	AND (KOD_POCZTOWY_POP IS NULL OR LEN(KOD_POCZTOWY_POP) > LEN(PNA))
	AND hm.Stg_PPE.MIEJSCOWOSC_CLR = ##tmp6.MIEJSCOWOSC_TMP_CLR

DROP TABLE IF EXISTS ##tmp6;
