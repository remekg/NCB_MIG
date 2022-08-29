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
		,NazwaSystemu
		,NULL
		,Oddzial
		,NULL
		,N'Partner Handlowy'
		,NULL
		,NULL
		,COUNT(DISTINCT nrpl)
		,N'Liczba rekordów'
		,NULL
FROM Stage.dbo.EN_Klienci AS K
JOIN META.[dbo].[SystemyZrodlowe] AS S
ON K.SystemZrodlowyId = S.Id
WHERE SystemZrodlowyId > 9
GROUP BY NazwaSystemu
		,Oddzial

--liczba punktów

INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT	SYSDATETIME()
		,NazwaSystemu
		,NULL
		,Oddzial
		,re.nazwa 
		,N'Punkt Poboru'
		,NULL
		,NULL
		,COUNT(*)
		,N'Liczba rekordów'
		,NULL
FROM Stage.dbo.EN_PPE AS K
JOIN META.[dbo].[SystemyZrodlowe] AS S
ON K.SystemZrodlowyId = S.Id
LEFT JOIN Stage.dbo.EN_Rejony re
ON re.SystemZrodlowyId = K.SystemZrodlowyId AND re.nr_rej=K.rej
WHERE k.SystemZrodlowyId > 9
GROUP BY NazwaSystemu
		,Oddzial
		,re.nazwa 

--niew³aœciwy lub brak kodu pocztowego
--brak mo¿liwoœci sprawdzenia kraju!!

INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT	SYSDATETIME()
		,NazwaSystemu
		,NULL
		,Oddzial
		,NULL
		,N'Partner Handlowy'
		,Obiekt
		,NULL
		,COUNT(*)
		,'Brak kodu pocztowego w PNA'
		,'EN_PH_ADR_KOD_POCZTOWY1'
  FROM [NCB_MIG].[en].[Adresy] adr
  WHERE (NOT EXISTS (SELECT 1 FROM Stage.dbo.PNA1_MiejscowosciIUlice pna
		WHERE pna.PNA = adr.kodpocztowy)
		OR adr.kodpocztowy IS NULL)
  GROUP BY NazwaSystemu
		,Oddzial
		,Obiekt


--brak miejscowoœci
INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT	SYSDATETIME()
		,NazwaSystemu
		,NULL
		,Oddzial
		,NULL
		,N'Partner Handlowy'
		,CONCAT(Obiekt, N' - miejscowoœæ')
		,NULL
		,COUNT(*)
		,'Brak miejscowoœci'
		,'EN_PH_ADR_BLEDY1'
  FROM [NCB_MIG].[en].[Adresy]
  WHERE REPLACE(REPLACE(REPLACE(miejscowosc, char(9),''), char(13),''), char(10),'')=''
  OR miejscowosc IS NULL
   GROUP BY NazwaSystemu
		,Oddzial
		,Obiekt

--duble peseli
BEGIN
WITH A AS(
SELECT pesel, COUNT(*) as ile
  FROM [Stage].[dbo].EN_Klienci
  WHERE pesel IS NOT NULL 
	AND REPLACE(REPLACE(REPLACE(pesel, char(9),''), char(13),''), char(10),'')<>''
	AND SystemZrodlowyId>9
  GROUP BY pesel
  HAVING COUNT(*)>1
  )
  INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
  SELECT	SYSDATETIME()
		,NazwaSystemu
		,NULL
		,Oddzial
		,NULL
		,N'Partner Handlowy'
		,'PESEL'
		,NULL
		,COUNT(*)
		,'Duble'
		,'EN_PH_DUBLE_PESEL'
FROM Stage.dbo.EN_Klienci AS K
JOIN META.[dbo].[SystemyZrodlowe] AS S
ON K.SystemZrodlowyId = S.Id
  WHERE SystemZrodlowyId > 9 AND pesel IN (SELECT pesel FROM A)
  GROUP BY S.NazwaSystemu, S.Oddzial

END

--niepoprawny nr PESEL
  INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT
	SYSDATETIME(), 
	S.NazwaSystemu, 
	NULL AS Spolka, 
	S.Oddzial, 
	NULL AS rejon, 
	N'Partner Handlowy', 
	'PESEL', 
	NULL AS Opis, 
	COUNT(DISTINCT nrpl)  , 
	'Niepoprawny numer', 
	N'EN_PH_PESEL'
FROM Stage.dbo.EN_Klienci AS K
JOIN META.[dbo].[SystemyZrodlowe] AS S
ON K.SystemZrodlowyId = S.Id
WHERE SystemZrodlowyId > 9
AND dbo.Czyszczenie(pesel) <> N''
AND dbo.pesel(dbo.Czyszczenie(pesel)) = 0
GROUP BY S.NazwaSystemu, S.Oddzial

--niepoprawny nr NIP
  INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT
	SYSDATETIME(), 
	S.NazwaSystemu, 
	NULL AS Spolka, 
	S.Oddzial, 
	NULL AS rejon, 
	N'Partner Handlowy', 
	'NIP', 
	NULL AS Opis, 
	COUNT(DISTINCT nrpl)  , 
	'Niepoprawny numer', 
	N'EN_PH_NIP'
FROM Stage.dbo.EN_Klienci AS K
JOIN META.[dbo].[SystemyZrodlowe] AS S
ON K.SystemZrodlowyId = S.Id
WHERE SystemZrodlowyId > 9
AND dbo.Czyszczenie(nip) <> N''
AND dbo.nip(dbo.Czyszczenie(nip)) = 0
GROUP BY S.NazwaSystemu, S.Oddzial

--duble nipów
BEGIN
WITH A AS(
SELECT nip, COUNT(*) as ile
  FROM [Stage].[dbo].EN_Klienci
  WHERE nip IS NOT NULL 
	AND REPLACE(REPLACE(REPLACE(nip, char(9),''), char(13),''), char(10),'')<>''
	AND SystemZrodlowyId>9
  GROUP BY nip
  HAVING COUNT(*)>1
  )

  INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
  SELECT
	SYSDATETIME(), 
	S.NazwaSystemu, 
	NULL AS Spolka, 
	S.Oddzial, 
	NULL AS rejon, 
	N'Partner Handlowy', 
	'NIP', 
	NULL AS Opis, 
	COUNT(DISTINCT nrpl)  , 
	'Duble', 
	N'EN_PH_NIP_DUBLE'
FROM Stage.dbo.EN_Klienci AS K
JOIN META.[dbo].[SystemyZrodlowe] AS S
ON K.SystemZrodlowyId = S.Id
WHERE SystemZrodlowyId > 9
  AND nip IN (SELECT nip FROM A)
GROUP BY S.NazwaSystemu, S.Oddzial
  END
  --Klienci bez punktów
--  INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
--								[KodBledow], [NazwaRaportu])
--  SELECT *
--	FROM stage.dbo.EN_Klienci kl
--	WHERE NOT EXISTS 
--			(SELECT 1 FROM Stage.dbo.EN_PPE ppe WHERE RIGHT(kl.nrpl,6)=ppe.nrpl
--				AND ppe.SystemZrodlowyId>9)
--		AND kl.SystemZrodlowyId>9

----punkty bez klientów

--  SELECT *
--	FROM Stage.dbo.EN_PPE ppe
--	WHERE NOT EXISTS 
--			(SELECT 1 FROM Stage.dbo.EN_Klienci kl WHERE RIGHT(kl.nrpl,6)=ppe.nrpl
--				AND kl.SystemZrodlowyId>9)
--		AND ppe.SystemZrodlowyId>9

--niew³aœciwy lub brak kodu pocztowego
--brak mo¿liwoœci sprawdzenia kraju!!

INSERT INTO dbo.BledyProgres ([DataCzasAnalizy], [System], [Spolka], [Oddzial], [Rejon], [Obiekt], [Pole], [Opis], [Ilosc], 
								[KodBledow], [NazwaRaportu])
SELECT	SYSDATETIME()
		,NazwaSystemu
		,NULL
		,Oddzial
		,re.nazwa
		,N'Punkt Poboru'
		,N'Kod pocztowy'
		,NULL
		,COUNT(*)
		,'Brak kodu pocztowego w PNA'
		,'EN_PPE_ADR_KOD_POCZTOWY1'
  FROM Stage.dbo.EN_PPE ppe
  JOIN META.[dbo].[SystemyZrodlowe] AS S
  ON ppe.SystemZrodlowyId = S.Id
  LEFT JOIN Stage.dbo.EN_Rejony re
  ON re.SystemZrodlowyId = ppe.SystemZrodlowyId AND re.nr_rej=ppe.rej
  WHERE ppe.SystemZrodlowyId > 9
  and (NOT EXISTS (SELECT 1 FROM Stage.dbo.PNA1_MiejscowosciIUlice pna
		WHERE pna.PNA = ppe.kod_p)
		OR ppe.kod_p IS NULL)
  GROUP BY NazwaSystemu
		,Oddzial
		,re.nazwa