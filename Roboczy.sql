SELECT
	SYSDATETIME(), S.NazwaSystemu, NULL AS Spolka, S.Oddzial, NULL AS rejon, N'Partner Handlowy', 'NIP', NULL AS Opis, COUNT(DISTINCT nrpl)  , 'Niepoprawny numer', N'PH_NIP'
FROM Stage.dbo.EN_Klienci AS K
JOIN META.[dbo].[SystemyZrodlowe] AS S
ON K.SystemZrodlowyId = S.Id
WHERE SystemZrodlowyId > 9
AND dbo.Czyszczenie(nip) <> N''
--AND dbo.nip(dbo.Czyszczenie(nip)) < 0
AND dbo.nip(dbo.Czyszczenie(nip)) = 0
GROUP BY S.NazwaSystemu, S.Oddzial





-- duble kluczy PH

select * from NCB_MIG.en.Stg_PH
   where
   Klucz_PH in (
   select klucz_ph   FROM NCB_MIG.en.Stg_PH 
   where CzyMIG>0
   group by Klucz_PH
   having count(*)>1

   )
   order by Klucz_PH


   --duble poczta nazwa miejscowoœci
   with a as (
SELECT distinct PNA,TERYT_MIEJ_NAZWA,TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
  )
  select pna, TERYT_MIEJ_NAZWA, count(*) from a 
  group by pna,TERYT_MIEJ_NAZWA
  having count(*)>1
  order by pna,TERYT_MIEJ_NAZWA


  with a as (
SELECT distinct PNA,TERYT_MIEJ_NAZWA,TERYT_MIEJ_SIMC
  FROM [NCB_MIG].[dbo].[TERYT_PNA]
  ), b as(
  select pna, TERYT_MIEJ_NAZWA, 
  count(*) over (partition by pna,TERYT_MIEJ_NAZWA) as ile from a 
  )
  select * from b where ile =1


  --statystyka terytowania

select
N'EnergOS PH CzyMIG adr podstawowy' as obiekt,
(select count(*)from [en].[Stg_PH] where czymig>0 ) as liczba_rekordow,
(select count(*)from [en].[Stg_PH] where czymig>0 and len(TERYT_MIEJSCOWOSC) =7 ) as teryt_miasta,
(select count(*)from [en].[Stg_PH] where czymig>0 and (len(TERYT_MIEJSCOWOSC) <>7 OR TERYT_MIEJSCOWOSC IS NULL)) as do_poprawy,
CAST((select count(*)from [en].[Stg_PH] where czymig>0 and len(TERYT_MIEJSCOWOSC) =7 )*100./(select count(*)from [en].[Stg_PH] where czymig>0 ) as decimal(6,2)) as Procent_miasto,
(select count(*)from [en].[Stg_PH] where czymig>0 and len(TERYT_ULICY) =5 ) as teryt_ulicy,
(select count(*)from [en].[Stg_PH] where czymig>0 and (len(TERYT_ULICY) <>5 OR TERYT_ULICY IS NULL)) as ul_do_poprawy,
CAST(((select count(*)from [en].[Stg_PH] where czymig>0 and len(TERYT_ULICY) =5 )*100./(select count(*)from [en].[Stg_PH] where czymig>0 )) as decimal(6,2))  as Procent_ulica

UNION ALL
  select
N's³owniki adr HandelMAX' as obiekt,
(select count(*)from [dbo].[Adresy_ALL] where SystemZrodlowyId IN (1,4)) as liczba_rekordow,
(select count(*)from [dbo].[Adresy_ALL] where len(Miasto_Teryt) =7 AND SystemZrodlowyId IN (1,4)) as teryt_miasta,
(select count(*)from [dbo].[Adresy_ALL] where (len(Miasto_Teryt) <>7 OR Miasto_Teryt IS NULL) AND SystemZrodlowyId IN (1,4)) as do_poprawy,
CAST((select count(*)from [dbo].[Adresy_ALL] where len(Miasto_Teryt) =7 AND SystemZrodlowyId IN (1,4))*100./(select count(*)from [dbo].[Adresy_ALL] WHERE SystemZrodlowyId IN (1,4)) as decimal(6,2)) as Procent_miasto,
(select count(*)from [dbo].[Adresy_ALL] where len(ulica_Teryt) =5 AND SystemZrodlowyId IN (1,4)) as teryt_ulicy,
(select count(*)from [dbo].[Adresy_ALL] where (len(ulica_Teryt) <> 5 OR ulica_Teryt IS NULL) AND SystemZrodlowyId IN (1,4)) as ul_do_poprawy,
CAST((select count(*)from [dbo].[Adresy_ALL] where len(ulica_Teryt) =5 AND SystemZrodlowyId IN (1,4))*100./(select count(*)from [dbo].[Adresy_ALL] WHERE SystemZrodlowyId IN (1,4)) as decimal(6,2)) as Procent_ulica

UNION ALL
  select
N's³owniki adr MultiZbyt' as obiekt,
(select count(*)from [dbo].[Adresy_ALL] where SystemZrodlowyId IN (2,3,5,6)) as liczba_rekordow,
(select count(*)from [dbo].[Adresy_ALL] where len(Miasto_Teryt) =7 AND SystemZrodlowyId IN (2,3,5,6)) as teryt_miasta,
(select count(*)from [dbo].[Adresy_ALL] where (len(Miasto_Teryt) <>7 OR Miasto_Teryt IS NULL) AND SystemZrodlowyId IN (2,3,5,6)) as do_poprawy,
CAST((select count(*)from [dbo].[Adresy_ALL] where len(Miasto_Teryt) =7 AND SystemZrodlowyId IN (2,3,5,6))*100./(select count(*)from [dbo].[Adresy_ALL] WHERE SystemZrodlowyId IN (2,3,5,6)) as decimal(6,2)) as Procent_miasto,
(select count(*)from [dbo].[Adresy_ALL] where len(ulica_Teryt) =5 AND SystemZrodlowyId IN (2,3,5,6)) as teryt_ulicy,
(select count(*)from [dbo].[Adresy_ALL] where (len(ulica_Teryt) <> 5 OR ulica_Teryt IS NULL) AND SystemZrodlowyId IN (2,3,5,6)) as ul_do_poprawy,
CAST((select count(*)from [dbo].[Adresy_ALL] where len(ulica_Teryt) =5 AND SystemZrodlowyId IN (2,3,5,6))*100./(select count(*)from [dbo].[Adresy_ALL] WHERE SystemZrodlowyId IN (2,3,5,6)) as decimal(6,2)) as Procent_ulica
