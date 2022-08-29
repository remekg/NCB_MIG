/* **********************************************
Data : 13.07.2022
Obiekt biznesowy : B³êdy
Opis : definiowanie b³êdów

**************************************************
*/ 
--Liczba rekordów

INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT	SYSDATETIME()
		,N_Systemu
		,PGE
		,Oddzial
		,NULL
		,N'Partner Handlowy'
		,NULL
		,NULL
		,COUNT(DISTINCT nrpl)
		,1
		,NULL
FROM NCB_MIG.en.Stg_PH AS KId
WHERE CzyMIG > 0
GROUP BY N_Systemu
		,Oddzial
		,PGE

--liczba punktów

INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT	SYSDATETIME()
		,N_Systemu
		,PGE
		,Oddzial
		,Rejon 
		,N'Punkt Poboru'
		,NULL
		,NULL
		,COUNT(*)
		,1
		,NULL
FROM NCB_MIG.en.Stg_PPE 
WHERE CzyMIG > 0 
	AND PGE<>'E' -- przypadki do wyjasnienia!!!
GROUP BY N_Systemu
		,Oddzial
		,Rejon
		,PGE

--niew³aœciwy lub brak kodu pocztowego
--brak mo¿liwoœci sprawdzenia kraju!!

INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT	SYSDATETIME()
		,N_Systemu
		,PGE
		,Oddzial
		,NULL
		,N'Partner Handlowy'
		,Adres
		,NULL
		,COUNT(*)
		,KodBledu
		,'EN_PH_ADR_KOD_POCZTOWY1'
 FROM NCB_MIG.rs.EN_PH_ADR_KOD_POCZTOWY1 adr
  GROUP BY N_Systemu
		,Oddzial
		,Adres
		,PGE
		,KodBledu


--brak TERYT miejscowoœci
INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT	SYSDATETIME()
		,N_Systemu
		,PGE
		,Oddzial
		,NULL
		,N'Partner Handlowy'
		,Adres
		,NULL
		,COUNT(*)
		,4
		,'EN_PH_ADR_MIEJSCOWOSC1'
  FROM NCB_MIG.rs.EN_PH_ADR_MIEJSCOWOSC1
   GROUP BY N_Systemu
		,Oddzial
		,Adres
		,PGE
		
--brak TERYT ulicy
INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT	SYSDATETIME()
		,N_Systemu
		,PGE
		,Oddzial
		,NULL
		,N'Partner Handlowy'
		,Adres
		,NULL
		,COUNT(*)
		,5
		,'EN_PH_ADR_ULICE1'
  FROM NCB_MIG.rs.EN_PH_ADR_ULICE1
   GROUP BY N_Systemu
		,Oddzial
		,Adres
		,PGE

----duble peseli
--BEGIN
--WITH A AS(
--SELECT pesel, COUNT(*) as ile
--  FROM [Stage].[dbo].EN_Klienci
--  WHERE pesel IS NOT NULL 
--	AND REPLACE(REPLACE(REPLACE(pesel, char(9),''), char(13),''), char(10),'')<>''
--	AND SystemZrodlowyId>9
--  GROUP BY pesel
--  HAVING COUNT(*)>1
--  )
--  INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
--								[KodBledow], [NazwaRaportu])
--  SELECT	SYSDATETIME()
--		,N_Systemu
--		,NULL
--		,Oddzial
--		,NULL
--		,N'Partner Handlowy'
--		,'PESEL'
--		,NULL
--		,COUNT(*)
--		,'Duble'
--		,'EN_PH_DUBLE_PESEL'
--FROM Stage.dbo.EN_Klienci AS K
--JOIN META.[dbo].[SystemyZrodlowe] AS S
--ON K.SystemZrodlowyId = S.Id
--  WHERE SystemZrodlowyId > 9 AND pesel IN (SELECT pesel FROM A)
--  GROUP BY S.N_Systemu, S.Oddzial

--END

--niepoprawny nr PESEL
  INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT
	SYSDATETIME(), 
	N_Systemu, 
	PGE, 
	Oddzial, 
	NULL AS rejon, 
	N'Partner Handlowy', 
	'PESEL', 
	NULL AS Opis, 
	COUNT(DISTINCT nrpl)  , 
	8, 
	N'EN_PH_PESEL'
FROM NCB_MIG.rs.EN_PH_PESEL
GROUP BY N_Systemu, Oddzial, PGE

--niepoprawny nr NIP
  INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT
	SYSDATETIME(), 
	N_Systemu, 
	PGE, 
	Oddzial, 
	NULL AS rejon, 
	N'Partner Handlowy', 
	'NIP', 
	NULL AS Opis, 
	COUNT(DISTINCT nrpl)  , 
	7, 
	N'EN_PH_NIP'
FROM NCB_MIG.rs.EN_PH_NIP
GROUP BY N_Systemu, Oddzial, PGE

--brak identyfikatora
  INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT
	SYSDATETIME(), 
	N_Systemu, 
	PGE, 
	Oddzial, 
	NULL AS rejon, 
	N'Partner Handlowy', 
	'IDENTYFIKATOR', 
	NULL AS Opis, 
	COUNT(DISTINCT nrpl)  , 
	9, 
	N'EN_PH_IDENTYFIKATOR'
FROM NCB_MIG.rs.EN_PH_IDENTYFIKATOR
GROUP BY N_Systemu, Oddzial, PGE

----duble nipów
--BEGIN
--WITH A AS(
--SELECT nip, COUNT(*) as ile
--  FROM [Stage].[dbo].EN_Klienci
--  WHERE nip IS NOT NULL 
--	AND REPLACE(REPLACE(REPLACE(nip, char(9),''), char(13),''), char(10),'')<>''
--	AND SystemZrodlowyId>9
--  GROUP BY nip
--  HAVING COUNT(*)>1
--  )

--  INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
--								[KodBledow], [NazwaRaportu])
--  SELECT
--	SYSDATETIME(), 
--	S.N_Systemu, 
--	NULL AS Spolka, 
--	S.Oddzial, 
--	NULL AS rejon, 
--	N'Partner Handlowy', 
--	'NIP', 
--	NULL AS Opis, 
--	COUNT(DISTINCT nrpl)  , 
--	'Duble', 
--	N'EN_PH_NIP_DUBLE'
--FROM Stage.dbo.EN_Klienci AS K
--JOIN META.[dbo].[SystemyZrodlowe] AS S
--ON K.SystemZrodlowyId = S.Id
--WHERE SystemZrodlowyId > 9
--  AND nip IN (SELECT nip FROM A)
--GROUP BY S.N_Systemu, S.Oddzial
--  END
--  --Klienci bez punktów
----  INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
----								[KodBledow], [NazwaRaportu])
----  SELECT *
----	FROM stage.dbo.EN_Klienci kl
----	WHERE NOT EXISTS 
----			(SELECT 1 FROM Stage.dbo.EN_PPE ppe WHERE RIGHT(kl.nrpl,6)=ppe.nrpl
----				AND ppe.SystemZrodlowyId>9)
----		AND kl.SystemZrodlowyId>9

------punkty bez klientów

----  SELECT *
----	FROM Stage.dbo.EN_PPE ppe
----	WHERE NOT EXISTS 
----			(SELECT 1 FROM Stage.dbo.EN_Klienci kl WHERE RIGHT(kl.nrpl,6)=ppe.nrpl
----				AND kl.SystemZrodlowyId>9)
----		AND ppe.SystemZrodlowyId>9

----niew³aœciwy lub brak kodu pocztowego
----brak mo¿liwoœci sprawdzenia kraju!!

--INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
--								[KodBledow], [NazwaRaportu])
--SELECT	SYSDATETIME()
--		,N_Systemu
--		,NULL
--		,Oddzial
--		,re.nazwa
--		,N'Punkt Poboru'
--		,N'Kod pocztowy'
--		,NULL
--		,COUNT(*)
--		,'Brak kodu pocztowego w PNA'
--		,'EN_PPE_ADR_KOD_POCZTOWY1'
--  FROM Stage.dbo.EN_PPE ppe
--  JOIN META.[dbo].[SystemyZrodlowe] AS S
--  ON ppe.SystemZrodlowyId = S.Id
--  LEFT JOIN Stage.dbo.EN_Rejony re
--  ON re.SystemZrodlowyId = ppe.SystemZrodlowyId AND re.nr_rej=ppe.rej
--  WHERE ppe.SystemZrodlowyId > 9
--  and (NOT EXISTS (SELECT 1 FROM Stage.dbo.PNA1_MiejscowosciIUlice pna
--		WHERE pna.PNA = ppe.kod_p)
--		OR ppe.kod_p IS NULL)
--  GROUP BY N_Systemu
--		,Oddzial
--		,re.nazwa

--porównanie kod GUS i PNA
  INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT
	SYSDATETIME(), 
	N_Systemu, 
	PGE, 
	Oddzial, 
	NULL AS rejon, 
	N'Partner Handlowy', 
	'Adres Podstawowy', 
	NULL AS Opis, 
	COUNT(DISTINCT nrpl)  , 
	KodBledu, 
	N'EN_PH_POROWNANIE_GUS_PNA'
FROM [rs].[EN_PH_POROWNANIE_GUS_PNA]
GROUP BY N_Systemu, Oddzial, PGE, KodBledu


/*** Punty Poboru***/


--ppe kody pocztowe
INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT	SYSDATETIME()
		,N_Systemu
		,PGE
		,Oddzial
		,Rejon
		,N'Punkt Poboru'
		,NULL
		,NULL
		,COUNT(*)
		,KodBledu
		,'EN_PPE_ADR_KOD_POCZTOWY1'
 FROM NCB_MIG.rs.EN_PPE_ADR_KOD_POCZTOWY1 adr
  GROUP BY N_Systemu
		,Oddzial
		,rejon
		,PGE
		,KodBledu

--ppe miejscowosci
		INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT	SYSDATETIME()
		,N_Systemu
		,PGE
		,Oddzial
		,Rejon
		,N'Punkt Poboru'
		,NULL
		,NULL
		,COUNT(*)
		,4
		,'EN_PPE_ADR_MIEJSCOWOSC1'
  FROM NCB_MIG.rs.EN_PPE_ADR_MIEJSCOWOSC1
   GROUP BY N_Systemu
		,Oddzial
		,Rejon	
		,PGE
		

		-- ppe brak TERYT ulicy
INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT	SYSDATETIME()
		,N_Systemu
		,PGE
		,Oddzial
		,Rejon
		,N'Punkt Poboru'
		,NULL
		,NULL
		,COUNT(*)
		,5
		,'EN_PPE_ADR_ULICE1'
  FROM NCB_MIG.rs.EN_PPE_ADR_ULICE1
   GROUP BY N_Systemu
		,Oddzial
		,Rejon
		,PGE


--porównanie kod GUS i PNA
  INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT
	SYSDATETIME(), 
	N_Systemu, 
	PGE, 
	Oddzial, 
	Rejon, 
	N'Punkt Poboru', 
	NULL, 
	NULL AS Opis, 
	COUNT(*)  , 
	KodBledu, 
	N'EN_PPE_POROWNANIE_GUS_PNA'
FROM [rs].[EN_PPE_POROWNANIE_GUS_PNA]
GROUP BY N_Systemu, Oddzial, PGE, KodBledu,Rejon