USE NCB_MIG;

--Za³o¿enie ulicy 
/*
DROP TABLE IF EXISTS dbo.Adresy_ALL

CREATE TABLE  dbo.Adresy_ALL
(
SystemZrodlowyId tinyint, 
SystemZrodlowy_RejonId smallint,
Adres_Id nvarchar(255),
Kraj nvarchar(255),
Kraj_ID nvarchar(255),
Gmina_7 nvarchar(255),
Miasto_ID nvarchar(255),
Miasto_Nazwa nvarchar(255),
Miasto_Teryt nvarchar(255),
Miasto_Nadrzedne_Nazwa nvarchar(255),
Miasto_Nadrzedne_ID nvarchar(255),
Miasto_Nadrzedne_Teryt nvarchar(255),
Kod_Pocztowy nvarchar(255),
Poczta nvarchar(255),
Ulica_Id nvarchar(255),
Ulica_Nazwa_Pelna nvarchar(255),
Ulica_Nazwa_Skrocona nvarchar(255),
Ulica_Rodzaj_ulicy nvarchar(255),
Ulica_Teryt nvarchar(255),

)
*/

--MULTIZBYT £adowanie danych
--Widok ze z³¹czeniem danych
WITH A AS
(
SELECT
	dbo.czyszczenie(M.SystemZrodlowyId) AS  SystemZrodlowyId
	,dbo.czyszczenie(M.SystemZrodlowy_RejonId) AS SystemZrodlowy_RejonId
	,Adres_Id = CONCAT_WS(N'-', dbo.czyszczenie(M.SystemZrodlowyId), dbo.czyszczenie(M.SystemZrodlowy_RejonId), dbo.czyszczenie(M.ID), dbo.czyszczenie(U.ID))
		
	,dbo.czyszczenie(m.kraj) AS Kraj
	,dbo.czyszczenie(m.KRAJ_ID) AS Kraj_ID
	,Gmina_7 = dbo.czyszczenie(SYMBOL_MIEJ_GUS) 
	,Miasto_Id = dbo.czyszczenie(CAST(m.id AS nvarchar(255))) 
	,Miasto_Nazwa = dbo.czyszczenie(m.NAZWA)
	,Miasto_teryt = NULL
	,Miasto_Nadrzedne_nazwa = dbo.czyszczenie(m.mias_nazwa_nadrzedne)
	,Miasto_Nadrzedne_Id = dbo.czyszczenie(CAST(m.MIAS_ID_NADRZEDNE AS nvarchar(255)))
	,Miasto_Nadrzedne_Teryt = NULL
	,Kod_Pocztowy = COALESCE(dbo.czyszczenie(u.kod_pocztowy_ul), dbo.czyszczenie(m.kod_pocztowy))
	,Poczta = NULL
	,Ulica_Id = dbo.czyszczenie(CAST(u.id AS nvarchar(255)))
	,Ulica_Nazwa_Pelna = dbo.czyszczenie(U.NAZWA)
	,Ulica_Nazwa_Skrocona = NULL
	,Ulica_Rodzaj_ulicy = NULL
	,Ulica_Teryt = NULL

FROM [Stage].[dbo].[ZB_MIASTA] AS M
 JOIN Stage.[dbo].[ZB_ULICA] AS U
 ON M.ID = U.MIAS_ID
 AND M.SystemZrodlowyId = U.SystemZrodlowyId
 AND M.SystemZrodlowy_RejonId = U.SystemZrodlowy_RejonId
 WHERE 1=1
)

INSERT INTO dbo.Adresy_ALL
SELECT *
FROM A;

--MULTIZBYT £adowanie danych
--Widok ze z³¹czeniem danych

WITH A AS
(
	SELECT
	 SystemZrodlowyId = dbo.Czyszczenie(M.SystemZrodlowyId)
	,SystemZrodlowy_RejonId = NULL
	,Adres_Id = CONCAT_WS(N'-', dbo.czyszczenie(M.SystemZrodlowyId),  dbo.czyszczenie(M.nrw_miejscowosci), dbo.czyszczenie(U.nrw_adresu))
	,kraj = NULL
	,KRAJ_ID = NULL
	,Gmina_7 = dbo.czyszczenie(U.kod_gus)
	,Miasto_Id = dbo.czyszczenie(M.nrw_miejscowosci)
	,Miasto_Nazwa = dbo.czyszczenie(M.nazwa)
	,Miasto_teryt = NULL
	,Miasto_Nadrzedne_nazwa = NULL
	,Miasto_Nadrzedne_Id = NULL
	,Miasto_Nadrzedne_Teryt = NULL
	,Kod_Pocztowy = dbo.czyszczenie(U.kod_pocztowy)
	,Poczta = dbo.czyszczenie(U.poczta)
	,Ulica_Id = dbo.czyszczenie(u.nrw_adresu)
	,Ulica_Nazwa_Pelna = dbo.czyszczenie(U.ulica)
	,Ulica_Nazwa_Skrocona = NULL
	,Ulica_Rodzaj_ulicy = NULL
	,Ulica_Teryt = NULL

	FROM Stage.dbo.[HM_Miejscowosc] AS M
	JOIN Stage.[dbo].[HM_Adres] AS U
	ON M.SystemZrodlowyId = U.SystemZrodlowyId
	AND M.nrw_miejscowosci = U.nrw_miejscowosci
)

INSERT INTO dbo.Adresy_ALL
SELECT *
FROM A;

--SELEN PRZYLACZA
SELECT distinct 
[Nr-MSC]
,[Miejscowoœæ]
,[NR-GUS]    
,[Poczta_Msc] 
,[NR-UL]     
,[Ulica]
  FROM [Stage].[dbo].[SEL_przyl];

