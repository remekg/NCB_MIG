/* **********************************************
Data : 13.07.2022
Obiekt biznesowy : Adres
Opis : Przygotowanie widoku na potrzeby analizy adresów

**************************************************
*/ 

--adresy podstawowe PH

WITH Adresy AS (
SELECT [nrpl]
      ,[ulica]
      ,[kodpocztowy]
      ,[miejscowosc]
      ,[poczta]
      ,[nrdomu]
      ,[nrmieszkania]
      ,[gus]
      ,NULL AS [koresp]
	  ,sz.Oddzial
      ,sz.NazwaSystemu
	  ,'Adres podstawowy' as Obiekt
  FROM [Stage].[dbo].[EN_Klienci] ekl
  LEFT JOIN [Meta].dbo.SystemyZrodlowe sz
  ON ekl.SystemZrodlowyId = sz.Id
  LEFT JOIN [Meta].dbo.SystemyZrodlowe_Rejony szr
  ON ekl.nrrejonu = szr.Rejon
  WHERE ekl.SystemZrodlowyId > 9

  UNION

  --adresy korespondencyjne PH

  SELECT [nrpl]
      ,[kor_ulica]
      ,[kor_kod_poczt]
      ,[kor_miejsc]
      ,[kor_poczta]
      ,[kor_dom]
      ,[kor_mieszk]
      ,NULL AS [gus]
      ,[koresp]
	  ,sz.Oddzial
      ,sz.NazwaSystemu
	  ,'Adres korespondencyjny' as Obiekt
  FROM [Stage].[dbo].[EN_Klienci] ekl
  LEFT JOIN [Meta].dbo.SystemyZrodlowe sz
  ON ekl.SystemZrodlowyId = sz.Id
  WHERE ekl.SystemZrodlowyId > 9
  AND (	REPLACE(REPLACE(REPLACE(kor_dom, char(9),''), char(13),''), char(10),'')<>'' OR
		REPLACE(REPLACE(REPLACE(kor_kod_poczt, char(9),''), char(13),''), char(10),'')<>'' OR
		REPLACE(REPLACE(REPLACE(kor_miejsc, char(9),''), char(13),''), char(10),'')<>'' OR
 		REPLACE(REPLACE(REPLACE(kor_mieszk, char(9),''), char(13),''), char(10),'')<>'' OR
		REPLACE(REPLACE(REPLACE(kor_poczta, char(9),''), char(13),''), char(10),'')<>'' OR
		REPLACE(REPLACE(REPLACE(kor_ulica, char(9),''), char(13),''), char(10),'')<>'' OR
		REPLACE(REPLACE(REPLACE(koresp, char(9),''), char(13),''), char(10),'')<>''
 ))


 INSERT  
 INTO en.Adresy
 
 SELECT * 
 FROM Adresy