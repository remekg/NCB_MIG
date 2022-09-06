USE NCB_MIG;

--Za�o�enie indeksow
--DROP INDEX IF EXISTS  ix_ulice_01 ON [hm].[Stg_PH];
--CREATE INDEX ix_ulice_01 ON [hm].[Stg_PH] (TERYT_MIEJSCOWOSC,  kor_ulica)
--WHERE [KOR_TERYT_MIEJSCOWOSC] IS NOT NULL


--Wariant 1
-- Teryt miejscowosci i nazwa sklejona 
--lista ulic z GUS z istniej�cym terytem

WITH
A
AS
(
	SELECT P.kor_miejsc, P.KOR_TERYT_MIEJSCOWOSC , P.kor_ulica, P.KOR_TERYT_ULICY,
	(SELECT  [TERYT_ULICA]
	FROM [ref].[TerytM_NazwaU_TerytU] AS T
	WHERE T.TERYT_MIEJ_SIMC = P.KOR_TERYT_MIEJSCOWOSC
	AND P.kor_ulica = T.TERYT_ULICA_SKLEJONA_1
	) AS TUL

	FROM [hm].[Stg_PH] AS P
	--JOIN [dbo].[TERYT_PNA] AS T
	WHERE CZyMig > 0
	AND [KOR_TERYT_MIEJSCOWOSC] IS NOT NULL
	AND LEN(kor_ulica) > 0 
	AND  kor_ulica IS NOT NULL
)

UPDATE A
SET KOR_TERYT_ULICY = TUL;

--Krok 2 Wyszukiwanie po teryt miejscowo�ci i  kor_ulica_CLR

WITH
E
AS
(
	SELECT P.kor_miejsc, P.KOR_TERYT_MIEJSCOWOSC, P.kor_ulica, P.KOR_TERYT_ULICY,
	(SELECT  [TERYT_ULICA]
	FROM [ref].[TerytM_NazwaUCLR_TerytU] AS T
	WHERE T.TERYT_MIEJ_SIMC = P.KOR_TERYT_MIEJSCOWOSC
	AND T.ULICE_TMP_CLR = P.KOR_ULICE_CLR
	) AS TUL
	
	FROM [hm].[Stg_PH] AS P
	WHERE CZyMig > 0
	AND [KOR_TERYT_MIEJSCOWOSC] IS NOT NULL
	AND LEN(kor_ulica) > 0 
	AND  kor_ulica IS NOT NULL
)

UPDATE E
SET KOR_TERYT_ULICY = TUL
WHERE LEN(TUL)> = 5
	AND (KOR_TERYT_ULICY IS NULL OR LEN(KOR_TERYT_ULICY) > LEN(TUL));

--Wariant 3
-- Teryt miejscowosci i nazwa1 

WITH
H
AS
(
	SELECT P.kor_miejsc, P.KOR_TERYT_MIEJSCOWOSC, P.kor_ulica, P.KOR_TERYT_ULICY,
	(SELECT  [TERYT_ULICA]
	FROM [ref].[TerytM_NazwaUKrotka_TerytU] AS T
	WHERE T.TERYT_MIEJ_SIMC = P.KOR_TERYT_MIEJSCOWOSC
	AND P.kor_ulica = T.TERYT_ULICA_NAZWA_1
	
	) AS TUL

	FROM [hm].[Stg_PH] AS P
	WHERE CZyMig > 0
	AND LEN([KOR_TERYT_MIEJSCOWOSC]) = 7
	AND LEN(kor_ulica) > 0 
	AND  kor_ulica IS NOT NULL
)

UPDATE H
SET KOR_TERYT_ULICY = TUL
WHERE LEN(TUL) >= 5
	AND (KOR_TERYT_ULICY IS NULL OR LEN(KOR_TERYT_ULICY) > LEN(TUL));

--Krok wyszukiwanie po terycie i ulicy kr�tkiej_CLR

WITH
K
AS
(
	SELECT P.kor_miejsc, P.KOR_TERYT_MIEJSCOWOSC, P.kor_ulica, P.KOR_TERYT_ULICY,
	(SELECT  [TERYT_ULICA]
	FROM [ref].[TerytM_NazwaUKrotkaCLR_TerytU] AS T
	WHERE T.TERYT_MIEJ_SIMC = P.KOR_TERYT_MIEJSCOWOSC
	AND T.ULICA_KROTKA_CLR = P.KOR_ULICE_CLR
	) AS TUL
	
	FROM [hm].[Stg_PH] AS P
	WHERE CZyMig > 0
	AND [KOR_TERYT_MIEJSCOWOSC] IS NOT NULL
	AND LEN(kor_ulica) > 0 
	AND  kor_ulica IS NOT NULL
)

UPDATE K
SET KOR_TERYT_ULICY = TUL
WHERE LEN(TUL)> = 5
	AND (KOR_TERYT_ULICY IS NULL OR LEN(KOR_TERYT_ULICY) > LEN(TUL));

--Wariant 5
-- Teryt miejscowosci i cecha+nazwa_sklejona_1 po funkcji usuwanienieliter

WITH
N
AS
(
	SELECT P.kor_miejsc, P.KOR_TERYT_MIEJSCOWOSC, P.kor_ulica, P.KOR_TERYT_ULICY,
	(SELECT  [TERYT_ULICA]
	FROM [ref].[TerytM_NazwaUzCecha_TerytU] AS T
	WHERE T.TERYT_MIEJ_SIMC = P.KOR_TERYT_MIEJSCOWOSC
	AND P.KOR_ULICE_CLR = T.NAZWA
	
	) AS TUL

	FROM [hm].[Stg_PH] AS P
	WHERE CZyMig > 0
	AND LEN([KOR_TERYT_MIEJSCOWOSC]) = 7
	AND LEN(kor_ulica) > 0 
	AND  kor_ulica IS NOT NULL
)

UPDATE N
SET KOR_TERYT_ULICY = TUL
WHERE LEN(TUL) > = 5
	AND (KOR_TERYT_ULICY IS NULL OR LEN(KOR_TERYT_ULICY) > LEN(TUL));

--Wariant 6
-- Teryt miejscowosci i cecha+nazwa_1 po funkcji usuwanienieliter

WITH
Q
AS
(
	SELECT P.kor_miejsc, P.KOR_TERYT_MIEJSCOWOSC, P.kor_ulica, P.KOR_TERYT_ULICY,
	(SELECT  [TERYT_ULICA]
	FROM [ref].[TerytM_NazwaUKrotkazCecha_TerytU] AS T
	WHERE T.TERYT_MIEJ_SIMC = P.KOR_TERYT_MIEJSCOWOSC
	AND P.KOR_ULICE_CLR = T.NAZWA
	
	) AS TUL

	FROM [hm].[Stg_PH] AS P
	WHERE CZyMig > 0
	AND LEN([KOR_TERYT_MIEJSCOWOSC]) = 7
	AND LEN(kor_ulica) > 0 
	AND  kor_ulica IS NOT NULL
)

UPDATE Q
SET KOR_TERYT_ULICY = TUL
WHERE LEN(TUL)> = 5
	AND (KOR_TERYT_ULICY IS NULL OR LEN(KOR_TERYT_ULICY) > LEN(TUL));

--Uzupe�nienie terytu 00000 miejscowo�ci bez ulic

UPDATE hm.Stg_PH
SET KOR_TERYT_ULICY = '00000'
WHERE (kor_ulica IS NULL OR LEN(kor_ulica) = 0 OR KOR_ULICE_CLR = KOR_MIEJSCOWOSC_CLR)
AND CzyMIG > 0
AND LEN([kor_nazwa1]) > 0