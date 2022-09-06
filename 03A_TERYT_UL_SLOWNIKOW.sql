USE NCB_MIG;

--Za³o¿enie indeksow
CREATE INDEX ix_ulice_01 ON dbo.Adresy_ALL (Miasto_teryt, Ulica_Nazwa_Pelna)
WHERE [Miasto_teryt] IS NOT NULL


--Wariant 1
-- Teryt miejscowosci i nazwa sklejona 

DROP TABLE IF EXISTS  ##Ulice_01
DROP INDEX IF EXISTS  ix_ulice ON ##Ulice_01;


with a as 
(
	SELECT	distinct TERYT_MIEJ_SIMC, TERYT_ULICA_SKLEJONA_1, TERYT_ULICA
	FROM [NCB_MIG].[dbo].[TERYT_PNA]
	WHERE  LEN(TERYT_ULICA) = 5
  ),	
  
  b as(
  select 
		TERYT_MIEJ_SIMC, 
		TERYT_ULICA_SKLEJONA_1, 
		--TERYT_ULICA,
		--COUNT(*) over (partition by TERYT_MIEJ_SIMC, TERYT_ULICA_SKLEJONA_1) as ile 
		STRING_AGG(TERYT_ULICA, '; ') AS TERYT_ULICA
  from a
  GROUP BY  TERYT_MIEJ_SIMC, 
		TERYT_ULICA_SKLEJONA_1
  )
  select TERYT_MIEJ_SIMC, TERYT_ULICA_SKLEJONA_1, TERYT_ULICA
  INTO ##Ulice_01
  from b 
  --where ile =1 



CREATE INDEX ix_ulice ON ##Ulice_01 (TERYT_MIEJ_SIMC, TERYT_ULICA_SKLEJONA_1)
INCLUDE (TERYT_ULICA);


WITH
A
AS
(
	SELECT P.Miasto_Nazwa, P.Miasto_teryt , P.Ulica_Nazwa_Pelna, P.Ulica_Teryt,
	(SELECT  [TERYT_ULICA]
	FROM ##Ulice_01 AS T
	WHERE T.TERYT_MIEJ_SIMC = P.Miasto_teryt
	AND P.Ulica_Nazwa_Pelna = T.TERYT_ULICA_SKLEJONA_1
	) AS TUL

	FROM dbo.Adresy_ALL AS P
	--JOIN [dbo].[TERYT_PNA] AS T
	WHERE [Miasto_teryt] IS NOT NULL
	AND Ulica_Nazwa_Pelna <> ''
)

UPDATE A
SET Ulica_Teryt = TUL

WITH
A
AS
(
	SELECT P.Miasto_Nazwa, P.Miasto_teryt , P.Ulica_Nazwa_Pelna, P.Ulica_Teryt,
	(SELECT  [TERYT_ULICA]
	FROM ##Ulice_01 AS T
	WHERE T.TERYT_MIEJ_SIMC = P.Miasto_teryt
	AND [dbo].[UsuwanieNieliter](REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(P.Ulica_Nazwa_Pelna, N'ALEJA', 'AL '), N'ALEJE' , N'AL '), 'PLAC', 'PL '), '-GO ',' '),' GO ',' '), N'ŒWIÊTEGO', N'ŒW '), N'ŒWIÊTEJ', N'ŒW '), N'KSIÊDZA', N'KS '), N'BOHATERÓW', N'BOH '), N'GENERA£A', N'GEN '), N'PU£KOWNIKA', N'P£K '),N'OSIEDLE', N'OS ')) = 
			[dbo].[UsuwanieNieliter](REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(T.TERYT_ULICA_SKLEJONA_1, N'ALEJA', 'AL '), N'ALEJE' , N'AL '), 'PLAC', 'PL '), '-GO ',' '),' GO ',' '), N'ŒWIÊTEGO', N'ŒW '), N'ŒWIÊTEJ', N'ŒW '), N'KSIÊDZA', N'KS '), N'BOHATERÓW', N'BOH '), N'GENERA£A', N'GEN '), N'PU£KOWNIKA', N'P£K '),N'OSIEDLE', N'OS '))
	) AS TUL
	
	FROM dbo.Adresy_ALL AS P
	--JOIN [dbo].[TERYT_PNA] AS T
	WHERE [Miasto_teryt] IS NOT NULL
	AND Ulica_Nazwa_Pelna <> ''
	AND (Ulica_Teryt IS NULL OR LEN(Ulica_Teryt) > LEN(Ulica_Teryt))
)

UPDATE A
SET Ulica_Teryt = TUL
WHERE LEN(TUL)> = 5


--Wariant 2
-- Teryt miejscowosci i nazwa sklejona po funkcji usuwanienieliter



WITH
A
AS
(
	SELECT P.Miasto_Nazwa, P.Miasto_teryt , P.Ulica_Nazwa_Pelna, P.Ulica_Teryt,
	(SELECT  [TERYT_ULICA]
	FROM ##Ulice_01 AS T
	WHERE T.TERYT_MIEJ_SIMC = P.Miasto_teryt
	AND dbo.UsuwanieNieliter(p.Ulica_Nazwa_Pelna) = dbo.UsuwanieNieliter(T.TERYT_ULICA_SKLEJONA_1)
	
	) AS TUL

	FROM dbo.Adresy_ALL AS P
	--JOIN [dbo].[TERYT_PNA] AS T
	WHERE LEN([Miasto_teryt]) = 7
	AND Ulica_Nazwa_Pelna <> ''
	AND (Ulica_Teryt IS NULL OR LEN(Ulica_Teryt) > LEN(Ulica_Teryt))
)

UPDATE A
SET Ulica_Teryt  = TUL
WHERE LEN(TUL)> = 5

--Wariant 3
-- Teryt miejscowosci i nazwa1 

DROP TABLE IF EXISTS  ##Ulice_01
DROP INDEX IF EXISTS  ix_ulice ON ##Ulice_01;


with a as 
(
	SELECT	distinct TERYT_MIEJ_SIMC, TERYT_ULICA_NAZWA_1, TERYT_ULICA
	FROM [NCB_MIG].[dbo].[TERYT_PNA]
	WHERE  LEN(TERYT_ULICA) = 5
  ),	
  
  b as(
  select 
		TERYT_MIEJ_SIMC, 
		TERYT_ULICA_NAZWA_1, 
		--TERYT_ULICA,
		--COUNT(*) over (partition by TERYT_MIEJ_SIMC, TERYT_ULICA_NAZWA_1) as ile 
		STRING_AGG(TERYT_ULICA, '; ') AS TERYT_ULICA
  from a 
  GROUP BY TERYT_MIEJ_SIMC, 
		TERYT_ULICA_NAZWA_1
  )
  select TERYT_MIEJ_SIMC, TERYT_ULICA_NAZWA_1, TERYT_ULICA
  INTO ##Ulice_01
  from b 
  --where ile =1 



CREATE INDEX ix_ulice ON ##Ulice_01 (TERYT_MIEJ_SIMC, TERYT_ULICA_NAZWA_1)
INCLUDE (TERYT_ULICA);


WITH
A
AS
(
	SELECT P.Miasto_Nazwa, P.Miasto_teryt , P.Ulica_Nazwa_Pelna, P.Ulica_Teryt,
	(SELECT  [TERYT_ULICA]
	FROM ##Ulice_01 AS T
	WHERE T.TERYT_MIEJ_SIMC = P.Miasto_teryt
	AND p.Ulica_Nazwa_Pelna = T.TERYT_ULICA_NAZWA_1
	
	) AS TUL

	FROM dbo.Adresy_ALL AS P
	--JOIN [dbo].[TERYT_PNA] AS T
	WHERE LEN([Miasto_teryt]) = 7
	AND Ulica_Nazwa_Pelna <> ''
	AND (Ulica_Teryt IS NULL OR LEN(Ulica_Teryt) > LEN(Ulica_Teryt))
)

UPDATE A
SET Ulica_Teryt = TUL
WHERE LEN(TUL) >= 5

WITH
A
AS
(
	SELECT P.Miasto_Nazwa, P.Miasto_teryt , P.Ulica_Nazwa_Pelna, P.Ulica_Teryt,
	(SELECT  [TERYT_ULICA]
	FROM ##Ulice_01 AS T
	WHERE T.TERYT_MIEJ_SIMC = P.Miasto_teryt
	AND [dbo].[UsuwanieNieliter](REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(P.Ulica_Nazwa_Pelna, N'ALEJA', 'AL '), N'ALEJE' , N'AL '), 'PLAC', 'PL '), '-GO ',' '),' GO ',' '), N'ŒWIÊTEGO', N'ŒW '), N'ŒWIÊTEJ', N'ŒW '), N'KSIÊDZA', N'KS '), N'BOHATERÓW', N'BOH '), N'GENERA£A', N'GEN '), N'PU£KOWNIKA', N'P£K '),N'OSIEDLE', N'OS ')) = 
			[dbo].[UsuwanieNieliter](REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(T.TERYT_ULICA_NAZWA_1, N'ALEJA', 'AL '), N'ALEJE' , N'AL '), 'PLAC', 'PL '), '-GO ',' '),' GO ',' '), N'ŒWIÊTEGO', N'ŒW '), N'ŒWIÊTEJ', N'ŒW '), N'KSIÊDZA', N'KS '), N'BOHATERÓW', N'BOH '), N'GENERA£A', N'GEN '), N'PU£KOWNIKA', N'P£K '),N'OSIEDLE', N'OS '))
	) AS TUL
	
	FROM dbo.Adresy_ALL AS P
	--JOIN [dbo].[TERYT_PNA] AS T
	WHERE [Miasto_teryt] IS NOT NULL
	AND Ulica_Nazwa_Pelna <> ''
	AND (Ulica_Teryt IS NULL OR LEN(Ulica_Teryt) > LEN(Ulica_Teryt))
)

UPDATE A
SET Ulica_Teryt  = TUL
WHERE LEN(TUL)> = 5


--Wariant 4
-- Teryt miejscowosci i nazwa1  po funkcji usuwanienieliter


WITH
A
AS
(
	SELECT P.Miasto_Nazwa, P.Miasto_teryt , P.Ulica_Nazwa_Pelna, P.Ulica_Teryt,
	(SELECT  [TERYT_ULICA]
	FROM ##Ulice_01 AS T
	WHERE T.TERYT_MIEJ_SIMC = P.Miasto_teryt
	AND dbo.UsuwanieNieliter(p.Ulica_Nazwa_Pelna) = dbo.UsuwanieNieliter(T.TERYT_ULICA_NAZWA_1)
	
	) AS TUL

	FROM dbo.Adresy_ALL AS P
	--JOIN [dbo].[TERYT_PNA] AS T
	WHERE LEN([Miasto_teryt]) = 7
	AND Ulica_Nazwa_Pelna <> ''
	AND Ulica_Teryt IS NULL
)

UPDATE A
SET Ulica_Teryt  = TUL
WHERE LEN(TUL) >= 5



--Wariant 5
-- Teryt miejscowosci i cecha+nazwa_sklejona_1 po funkcji usuwanienieliter

DROP TABLE IF EXISTS  ##Ulice_01
DROP INDEX IF EXISTS  ix_ulice ON ##Ulice_01;


with a as 
(
	SELECT	distinct TERYT_MIEJ_SIMC, concat(TERYT_ULICA_CECHA,TERYT_ULICA_SKLEJONA_1) as NAZWA, TERYT_ULICA
	FROM [NCB_MIG].[dbo].[TERYT_PNA]
	WHERE  LEN(TERYT_ULICA) = 5
  ),	
  
  b as(
  select 
		TERYT_MIEJ_SIMC, 
		NAZWA, 
		--TERYT_ULICA,
		--COUNT(*) over (partition by TERYT_MIEJ_SIMC, NAZWA) as ile 
		STRING_AGG(TERYT_ULICA, '; ') AS TERYT_ULICA
  from a 
  GROUP BY TERYT_MIEJ_SIMC, 
		NAZWA
  )
  select TERYT_MIEJ_SIMC, NAZWA, TERYT_ULICA
  INTO ##Ulice_01
  from b 
  --where ile =1 



CREATE INDEX ix_ulice ON ##Ulice_01 (TERYT_MIEJ_SIMC, NAZWA)
INCLUDE (TERYT_ULICA);


WITH
A
AS
(
	SELECT P.Miasto_Nazwa, P.Miasto_teryt , P.Ulica_Nazwa_Pelna, P.Ulica_Teryt,
	(SELECT  [TERYT_ULICA]
	FROM ##Ulice_01 AS T
	WHERE T.TERYT_MIEJ_SIMC = P.Miasto_teryt
	AND dbo.UsuwanieNieliter(p.Ulica_Nazwa_Pelna) = dbo.UsuwanieNieliter(T.NAZWA)
	
	) AS TUL

	FROM dbo.Adresy_ALL AS P
	--JOIN [dbo].[TERYT_PNA] AS T
	WHERE LEN([Miasto_teryt]) = 7
	AND Ulica_Nazwa_Pelna<> ''
	AND Ulica_Teryt  IS NULL
)

UPDATE A
SET Ulica_Teryt  = TUL
WHERE LEN(TUL) > = 5


--Wariant 6
-- Teryt miejscowosci i cecha+nazwa_1 po funkcji usuwanienieliter

DROP TABLE IF EXISTS  ##Ulice_01
DROP INDEX IF EXISTS  ix_ulice ON ##Ulice_01;


with a as 
(
	SELECT	distinct TERYT_MIEJ_SIMC, concat(TERYT_ULICA_CECHA,TERYT_ULICA_NAZWA_1) as NAZWA, TERYT_ULICA
	FROM [NCB_MIG].[dbo].[TERYT_PNA]
	WHERE  LEN(TERYT_ULICA) = 5
  ),	
  
  b as(
  select 
		TERYT_MIEJ_SIMC, 
		NAZWA, 
		--TERYT_ULICA,
		--COUNT(*) over (partition by TERYT_MIEJ_SIMC, NAZWA) as ile 
		STRING_AGG(TERYT_ULICA, '; ') AS TERYT_ULICA
  from a 
  GROUP BY TERYT_MIEJ_SIMC, 
		NAZWA
  )
  select TERYT_MIEJ_SIMC, NAZWA, TERYT_ULICA
  INTO ##Ulice_01
  from b 
  --where ile =1 



CREATE INDEX ix_ulice ON ##Ulice_01 (TERYT_MIEJ_SIMC, NAZWA)
INCLUDE (TERYT_ULICA);


WITH
A
AS
(
	SELECT P.Miasto_Nazwa, P.Miasto_teryt , P.Ulica_Nazwa_Pelna, P.Ulica_Teryt,
	(SELECT  [TERYT_ULICA]
	FROM ##Ulice_01 AS T
	WHERE T.TERYT_MIEJ_SIMC = P.Miasto_teryt
	AND dbo.UsuwanieNieliter(p.Ulica_Nazwa_Pelna) = dbo.UsuwanieNieliter(T.NAZWA)
	
	) AS TUL

	FROM dbo.Adresy_ALL AS P
	--JOIN [dbo].[TERYT_PNA] AS T
	WHERE LEN([Miasto_teryt]) = 7
	AND Ulica_Nazwa_Pelna<> ''
	AND Ulica_Teryt  IS NULL
)

UPDATE A
SET Ulica_Teryt  = TUL
WHERE LEN(TUL)> = 5



--Uzupe³nienie terytu 00000 miejscowoœci bez ulic

UPDATE dbo.Adresy_ALL
SET Ulica_Teryt = '00000'
WHERE (Ulica_Nazwa_Pelna IS NULL OR Ulica_Nazwa_Pelna = '' OR Ulica_Nazwa_Pelna = Miasto_Nazwa)