/*
Data : 2022.08.29
Opis : Próba wyznaczania adresu koresp dla PH, tak aby obsłuzyć wszystkie przypadki
*/
USE NCB_MIG;
GO

--Założenie schematu en_tmp
CREATE SCHEMA en_tmp;
GO

--DROP TABLE en_tmp.Adresy
--Założenie bazy adresowej z identyfikatorem adresu
CREATE TABLE en_tmp.Adresy
(
    Id int IDENTITY(1,1)
    ,Klucz_PH nvarchar (255)
    ,Nazwa nvarchar(255)
    ,Kraj nvarchar(2)
    ,kod_pocztowy nvarchar(20)
    ,TER_miasto nvarchar(255)
    ,miasto_nazwa nvarchar(255)
    ,TER_miasto_pod nvarchar(255)
    ,miasto_pod_nazwa nvarchar(255)
    ,TER_ulica nvarchar(255)
    ,ulica_nazwa nvarchar(255)
    ,nr_domu nvarchar(20)
    ,nr_lokalu nvarchar(20)
    ,typ_adresu nvarchar(1) --(P podstawowy, K-korespondencyjny)
    
)

TRUNCATE TABLE en_tmp.Adresy
--Ladowanie adresow podstawowych
INSERT INTO en_tmp.Adresy
(
    Klucz_PH 
    ,Nazwa 
    ,Kraj 
    ,kod_pocztowy 
    ,TER_miasto 
    ,miasto_nazwa 
    ,TER_miasto_pod 
    ,miasto_pod_nazwa
    ,TER_ulica 
    ,ulica_nazwa 
    ,nr_domu 
    ,nr_lokalu 
    ,typ_adresu
    )
SELECT
    Klucz_PH 
    ,Nazwa 
    ,KRAJ
    ,kod_pocztowy = kodpocztowy
    ,TER_miasto = TERYT_MIEJSCOWOSC
    ,miasto_nazwa = miejscowosc
    ,TER_miasto_pod = TERYT_MIEJSCOWOSC_POD
    ,miasto_pod = NULL
    ,TER_ulica = TERYT_ULICY
    ,ulica_nazwa = ulica
    ,nr_domu = nrdomu
    ,nr_lokalu = nrmieszkania
    ,typ_adresu = N'P'
FROM en.Stg_PH
WHERE CzyMig > 0

--Adresy koresp 
INSERT INTO en_tmp.Adresy
(
    Klucz_PH 
    ,Nazwa 
    ,Kraj 
    ,kod_pocztowy 
    ,TER_miasto 
    ,miasto_nazwa 
    ,TER_miasto_pod 
    ,miasto_pod_nazwa
    ,TER_ulica 
    ,ulica_nazwa 
    ,nr_domu 
    ,nr_lokalu 
    ,typ_adresu
    )
SELECT
    Klucz_PH 
    ,Nazwa = kor_nazwa
    ,KRAJ = kor_kraj
    ,kod_pocztowy = kor_kod_poczt
    ,TER_miasto = KOR_TERYT_MIEJSCOWOSC
    ,miasto_nazwa = kor_miejsc
    ,TER_miasto_pod = KOR_TERYT_MIEJSCOWOSC_POD
    ,miasto_pod = NULL
    ,TER_ulica = KOR_TERYT_ULICY
    ,ulica_nazwa = kor_ulica
    ,nr_domu = kor_dom
    ,nr_lokalu = kor_mieszk
    ,typ_adresu = N'K'
FROM en.Stg_PH
WHERE CzyMig > 0
AND LEN(koresp) > 1

SELECT typ_adresu, COUNT(*)
FROM en_tmp.Adresy
GROUP BY typ_adresu







