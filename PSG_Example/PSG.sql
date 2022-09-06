--Klienci z NIP-em PSG
USE NCB_MIG;


SELECT DISTINCT klucz_PH
INTO tst.PH_PSG
FROM hm.Stg_PH
WHERE NIP = N'5252496411'

--Dodanie pola lider

ALTER TABLE tst.PH_PSG
ADD Lider nvarchar(255)

UPDATE tst.PH_PSG
    SET Lider = N'1_11093755'


CREATE TABLE tst.GOLDRECORD
(
    NIP nvarchar(10), 
    Nazwa nvarchar(255),
    Adres nvarchar(255),
)

--Zapisanie zlotego rekordu
INSERT INTO tst.GOLDRECORD (NIP, Nazwa, Adres)
SELECT NIP, UPPER(nazwa) AS Nazwa, 
UPPER(CONCAT_WS(N'|', kodpocztowy, miejscowosc, poczta, ulica, nrdomu, nrmieszkania)) AS Adres
FROM hm.Stg_PH
WHERE Klucz_PH = N'1_11093755'

DROP TABLE IF EXISTS tst.PSG_KORESP

--Tworzenie tabeli korespow
CREATE TABLE tst.PSG_KORESP
(
    Klucz_PH nvarchar(255),
    Nazwa nvarchar(255),
    Adres nvarchar(255),
    TypPH nvarchar(255), --Podstawowy or Koresp
    Lider nvarchar(255)
)

--Zapisanie korespow z głównego
INSERT INTO tst.PSG_KORESP
(
    P.Klucz_PH, Nazwa, Adres, TypPH
)
SELECT Klucz_PH, 
    UPPER(P.Nazwa)
         As Nazwa,
    UPPER(CONCAT_WS(N'|', kodpocztowy,  miejscowosc, poczta, ulica, nrdomu, nrmieszkania)
    ) As Adres, N'Podstawowy'

FROM hm.Stg_PH AS P
JOIN tst.GOLDRECORD AS G 
    ON G.NIP = P.NIP
WHERE EXISTS (SELECT 1 FROM tst.PH_PSG AS T WHERE T.klucz_PH = P.klucz_PH)
AND dbo.Podobienstwo(G.Nazwa, P.Nazwa) < 0.5



--Zapisanie korespow z korespow

INSERT INTO tst.PSG_KORESP
(
    Klucz_PH, Nazwa, Adres, TypPH
)
SELECT Klucz_PH, 
    UPPER(CONCAT_WS(N' ', kor_nazwa1, kor_nazwa2))
         As Nazwa,
    UPPER(CONCAT_WS(N'|', kor_kod_poczt, kor_miejsc, kor_poczta, kor_ulica, kor_dom, kor_mieszk)
    ) As Adres, N'Korespondencyjny'

FROM hm.Stg_PH AS P
JOIN tst.GOLDRECORD AS G 
    ON G.NIP = P.NIP
WHERE EXISTS (SELECT 1 FROM tst.PH_PSG AS T WHERE T.klucz_PH = P.klucz_PH)
AND LEN(CONCAT_WS(N' ', kor_nazwa1, kor_nazwa2)) > 2

--Deduplikacja korespow 
WITH
A
AS
(
SELECT CONCAT_WS(N'|', nazwa, adres) AS ADRES ,
ROW_NUMBER() OVER (PARTITION BY CONCAT_WS(N'|', nazwa, adres) ORDER BY Klucz_PH) AS LP,
Klucz_PH
FROM tst.PSG_KORESP
),
B AS
(
SELECT K.Klucz_PH, K.LIDER, A.KLUCZ_PH AS alider
FROM tst.PSG_KORESP AS K
JOIN A
ON CONCAT_WS(N'|', K.nazwa, K.adres) = A.ADRES
WHERE A.LP = 1
)
UPDATE B
SET Lider = alider;

--Dodanie do korespa - Odbiorcy korespondencyjnego
USE Stage;
WITH A AS
(

SELECT U.nr_umowy, U.platnik, P.Lider , PA.Lider AS Platnik_Alternatywny
,CONCAT_WS('_', U.SystemZrodlowyId, U.odbiorca) AS Odbiorca, O.Klucz_PH, O.NIP

, ROW_NUMBER() OVER(PARTITION BY nr_umowy ORDER BY platnik) AS LP
FROM dbo.HM_NaglowekUmowy AS U --naglowek umowy
JOIN NCB_MIG.tst.PH_PSG AS P -- dodajemy platnikow glownych
	ON P.klucz_PH = CONCAT_WS('_', U.SystemZrodlowyId, U.platnik)
LEFT JOIN NCB_MIG.tst.PSG_KORESP AS PA
 ON CONCAT_WS('_', U.SystemZrodlowyId, U.platnik) = PA.Klucz_PH
 AND PA.Klucz_PH = PA.Lider
 AND Pa.TypPH = N'Podstawowy'
 LEFT JOIN NCB_MIG.hm.Stg_PH AS O
 ON CONCAT_WS('_', U.SystemZrodlowyId, U.odbiorca) = O.Klucz_PH


WHERE 
U.data_k_ob = N'00000000'


)

SELECT DISTINCT Odbiorca
INTO NCB_MIG.tst.Odbiorca
FROM A 

USE NCB_MIG;
--Usuwanie odbiorcow istniejacych w bazie
WITH A AS
(
SELECT Klucz_PH
FROM tst.PSG_KORESP
INTERSECT
SELECT Odbiorca
FROM tst.Odbiorca
)
DELETE tst.Odbiorca
WHERE Odbiorca  IN (SELECT Klucz_PH AS Odbiorca FROM A)

--Dodanie odbiorców koresp do bazy





