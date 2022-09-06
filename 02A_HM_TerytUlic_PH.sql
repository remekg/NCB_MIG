USE NCB_MIG;

--Za³o¿enie indeksow
--DROP INDEX IF EXISTS  ix_ulice_01 ON [hm].[Stg_PH];
--CREATE INDEX ix_ulice_01 ON [hm].[Stg_PH] (TERYT_MIEJSCOWOSC, ulica)
--WHERE [TERYT_MIEJSCOWOSC] IS NOT NULL


--Wariant 1
-- Teryt miejscowosci i nazwa sklejona 
--lista ulic z GUS z istniej¹cym terytem


WITH
A
AS
(
	SELECT P.miejscowosc, P.TERYT_MIEJSCOWOSC , P.ulica, P.Teryt_Ulicy,
	(SELECT  [TERYT_ULICA]
	FROM ref.TerytM_NazwaU_TerytU AS T
	WHERE T.TERYT_MIEJ_SIMC = P.TERYT_MIEJSCOWOSC
	AND P.ulica = T.TERYT_ULICA_SKLEJONA_1
	) AS TUL

	FROM [hm].[Stg_PH] AS P
	WHERE CZyMig > 0
	AND [TERYT_MIEJSCOWOSC] IS NOT NULL
	AND LEN(ulica) > 0 
	AND ulica IS NOT NULL
)

UPDATE A
SET TERYT_ULICY = TUL;

--Krok 2 Wyszukiwanie po teryt miejscowoœci i ulica_CLR

WITH
E
AS
(
	SELECT P.miejscowosc, P.TERYT_MIEJSCOWOSC , P.ulica, P.Teryt_Ulicy,
	(SELECT  [TERYT_ULICA]
	FROM ref.TerytM_NazwaUCLR_TerytU AS T
	WHERE T.TERYT_MIEJ_SIMC = P.TERYT_MIEJSCOWOSC
	AND T.ULICE_TMP_CLR = P.ULICE_CLR
	) AS TUL
	
	FROM [hm].[Stg_PH] AS P
	WHERE CZyMig > 0
	AND [TERYT_MIEJSCOWOSC] IS NOT NULL
	AND LEN(ulica) > 0 
	AND ulica IS NOT NULL
)

UPDATE E
SET TERYT_ULICY = TUL
WHERE LEN(TUL)> = 5
	AND (TERYT_ULICY IS NULL OR LEN(TERYT_ULICY) > LEN(TUL));

--Wariant 3
-- Teryt miejscowosci i nazwa1 
WITH
H
AS
(
	SELECT P.miejscowosc, P.TERYT_MIEJSCOWOSC , P.ulica, P.Teryt_Ulicy,
	(SELECT  [TERYT_ULICA]
	FROM ref.TerytM_NazwaUKrotka_TerytU AS T
	WHERE T.TERYT_MIEJ_SIMC = P.TERYT_MIEJSCOWOSC
	AND p.ulica = T.TERYT_ULICA_NAZWA_1
	
	) AS TUL

	FROM [hm].[Stg_PH] AS P
	WHERE CZyMig > 0
	AND LEN([TERYT_MIEJSCOWOSC]) = 7
	AND LEN(ulica) > 0 
	AND ulica IS NOT NULL
)

UPDATE H
SET TERYT_ULICY = TUL
WHERE LEN(TUL) >= 5
	AND (TERYT_ULICY IS NULL OR LEN(TERYT_ULICY) > LEN(TUL));

--Krok wyszukiwanie po terycie i ulicy krótkiej_CLR

WITH
K
AS
(
	SELECT P.miejscowosc, P.TERYT_MIEJSCOWOSC , P.ulica, P.Teryt_Ulicy,
	(SELECT  [TERYT_ULICA]
	FROM ref.TerytM_NazwaUKrotkaCLR_TerytU AS T
	WHERE T.TERYT_MIEJ_SIMC = P.TERYT_MIEJSCOWOSC
	AND T.ULICA_KROTKA_CLR = P.ULICE_CLR
	) AS TUL
	
	FROM [hm].[Stg_PH] AS P
	WHERE CZyMig > 0
	AND [TERYT_MIEJSCOWOSC] IS NOT NULL
	AND LEN(ulica) > 0 
	AND ulica IS NOT NULL
)

UPDATE K
SET TERYT_ULICY = TUL
WHERE LEN(TUL)> = 5
	AND (TERYT_ULICY IS NULL OR LEN(TERYT_ULICY) > LEN(TUL));

--Wariant 5
-- Teryt miejscowosci i cecha+nazwa_sklejona_1 po funkcji usuwanienieliter

WITH
N
AS
(
	SELECT P.miejscowosc, P.TERYT_MIEJSCOWOSC , P.ulica, P.Teryt_Ulicy,
	(SELECT  [TERYT_ULICA]
	FROM ref.TerytM_NazwaUzCecha_TerytU AS T
	WHERE T.TERYT_MIEJ_SIMC = P.TERYT_MIEJSCOWOSC
	AND P.ULICE_CLR = T.NAZWA
	
	) AS TUL

	FROM [hm].[Stg_PH] AS P
	WHERE CZyMig > 0
	AND LEN([TERYT_MIEJSCOWOSC]) = 7
	AND LEN(ulica) > 0 
	AND ulica IS NOT NULL
)

UPDATE N
SET TERYT_ULICY = TUL
WHERE LEN(TUL) > = 5
	AND (TERYT_ULICY IS NULL OR LEN(TERYT_ULICY) > LEN(TUL));

--Wariant 6
-- Teryt miejscowosci i cecha+nazwa_1 po funkcji usuwanienieliter

WITH
Q
AS
(
	SELECT P.miejscowosc, P.TERYT_MIEJSCOWOSC , P.ulica, P.Teryt_Ulicy,
	(SELECT  [TERYT_ULICA]
	FROM ref.TerytM_NazwaUKrotkazCecha_TerytU AS T
	WHERE T.TERYT_MIEJ_SIMC = P.TERYT_MIEJSCOWOSC
	AND ULICE_CLR = T.NAZWA
	
	) AS TUL

	FROM [hm].[Stg_PH] AS P
	WHERE CZyMig > 0
	AND LEN([TERYT_MIEJSCOWOSC]) = 7
	AND LEN(ulica) > 0 
	AND ulica IS NOT NULL
)

UPDATE Q
SET TERYT_ULICY = TUL
WHERE LEN(TUL)> = 5
	AND (TERYT_ULICY IS NULL OR LEN(TERYT_ULICY) > LEN(TUL));

--Wariant 7
-- PNA Teryt miejscowosci i ulica CLR

WITH
R
AS
(
	SELECT P.miejscowosc, P.kodpocztowy ,P.TERYT_MIEJSCOWOSC , P.ulica, P.Teryt_Ulicy,
	(SELECT  [TERYT_ULICA]
	FROM [ref].[TerytM_PNA_NazwaUCLR_TerytU] AS T
	WHERE T.TERYT_MIEJ_SIMC = P.TERYT_MIEJSCOWOSC
	AND ULICE_CLR = T.NAZWA
	AND T.PNA = P.kodpocztowy
	
	) AS TUL

	FROM [hm].[Stg_PH] AS P
	WHERE CZyMig > 0
	AND LEN([TERYT_MIEJSCOWOSC]) = 7
	AND LEN(ulica) > 0 
	AND ulica IS NOT NULL
)

UPDATE R
SET TERYT_ULICY = TUL
WHERE LEN(TUL)> = 5
	AND (TERYT_ULICY IS NULL OR LEN(TERYT_ULICY) > LEN(TUL));

--Wariant 8
-- PNA Teryt miejscowosci i ulica krótka CLR

WITH
S
AS
(
	SELECT P.miejscowosc, P.kodpocztowy ,P.TERYT_MIEJSCOWOSC , P.ulica, P.Teryt_Ulicy,
	(SELECT  [TERYT_ULICA]
	FROM [ref].[TerytM_PNA_NazwaUKrotkaCLR_TerytU] AS T
	WHERE T.TERYT_MIEJ_SIMC = P.TERYT_MIEJSCOWOSC
	AND ULICE_CLR = T.NAZWA
	AND T.PNA = P.kodpocztowy
	
	) AS TUL

	FROM [hm].[Stg_PH] AS P
	WHERE CZyMig > 0
	AND LEN([TERYT_MIEJSCOWOSC]) = 7
	AND LEN(ulica) > 0 
	AND ulica IS NOT NULL
)

UPDATE S
SET TERYT_ULICY = TUL
WHERE LEN(TUL)> = 5
	AND (TERYT_ULICY IS NULL OR LEN(TERYT_ULICY) > LEN(TUL));

--Uzupe³nienie terytu 00000 miejscowoœci bez ulic

UPDATE hm.Stg_PH
SET TERYT_ULICY = '00000'
WHERE (ulica IS NULL OR LEN(ulica) = 0 OR ULICE_CLR = MIEJSCOWOSC_CLR)
AND CzyMIG > 0;