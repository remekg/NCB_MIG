/* **********************************************
Data : 2022-07-14
Obiekt biznesowy : Partner Handlowy
Opis : Prze³adowanie danych do tabeli stagowej (bez adresówki)

**************************************************
*/ 
USE NCB_MIG;

--Usuniêcie starych danych
TRUNCATE TABLE en.PH_Stg;

--Za³adowanie nowego zestawu danych
INSERT INTO en.PH_Stg
(
[nrpl], [nip], [regon], [pesel], [nazwa], [segmentklienta], [nrrejonu], [SystemZrodlowyId], 
[NRKL], [GrPlatnikow], [full_konto_ze], [mail], [telefon], [SKROT], [DataImportu], [konto_NRB_EN_Z]
)
SELECT [nrpl], [nip], [regon], [pesel], [nazwa],  [segmentklienta], [nrrejonu], [SystemZrodlowyId], 
[NRKL], [GrPlatnikow],  [full_konto_ze],  [mail], [telefon], [SKROT],  [DataImportu], [konto_NRB_EN_Z]
FROM Stage.dbo.EN_Klienci
