/* **********************************************
Data : 2022-07-14
Obiekt biznesowy : Partner Handlowy
Opis : Prze�adowanie danych do tabeli stagowej (bez adres�wki)

**************************************************
*/ 
USE NCB_MIG;

--Usuni�cie starych danych
TRUNCATE TABLE en.PH_Stg;

--Za�adowanie nowego zestawu danych
INSERT INTO en.PH_Stg
(
[nrpl], [nip], [regon], [pesel], [nazwa], [segmentklienta], [nrrejonu], [SystemZrodlowyId], 
[NRKL], [GrPlatnikow], [full_konto_ze], [mail], [telefon], [SKROT], [DataImportu], [konto_NRB_EN_Z]
)
SELECT [nrpl], [nip], [regon], [pesel], [nazwa],  [segmentklienta], [nrrejonu], [SystemZrodlowyId], 
[NRKL], [GrPlatnikow],  [full_konto_ze],  [mail], [telefon], [SKROT],  [DataImportu], [konto_NRB_EN_Z]
FROM Stage.dbo.EN_Klienci
