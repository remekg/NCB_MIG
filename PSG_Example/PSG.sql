--Klienci z NIP-em PSG
USE NCB_MIG;

--Kasowanie tabel
TRUNCATE TABLE tst.PH_PSG;
TRUNCATE TABLE tst.GOLDRECORD;
TRUNCATE TABLE  tst.PSG_KORESP;
TRUNCATE TABLE tst.Odbiorca;

--Załadowanie PH z NIPEM PSGAZ-a
INSERT INTO tst.PH_PSG (klucz_PH)
SELECT DISTINCT klucz_PH
FROM hm.Stg_PH
WHERE NIP = N'5252496411';

SELECT *
FROM tst.PH_PSG


--Ręczne wskazanie lidera #TODO Przygotowanie funkcji goldrekord dla poszczególnych typów
UPDATE tst.PH_PSG
    SET Lider = N'1_11093755';


--Zapisanie zlotego rekordu
INSERT INTO tst.GOLDRECORD (NIP, Nazwa, Adres, Klucz_PH)
SELECT	NIP, 
		UPPER(nazwa) AS Nazwa, 
		UPPER(CONCAT_WS(N'|', kodpocztowy, miejscowosc, poczta, ulica, nrdomu, nrmieszkania)) AS Adres,
		Klucz_PH
FROM hm.Stg_PH
WHERE Klucz_PH = N'1_11093755';

SELECT * FROM tst.GOLDRECORD


--Zapisanie korespow z głównego płatnika różnego od lidera po nazwie
INSERT INTO tst.PSG_KORESP
(
    P.Klucz_PH, Nazwa, Adres, TypPH
)
SELECT	P.Klucz_PH, 
		UPPER(P.Nazwa) As Nazwa,
		UPPER(CONCAT_WS(N'|', kodpocztowy,  miejscowosc, poczta, ulica, nrdomu, nrmieszkania)) As Adres, 
		N'Podstawowy'
FROM hm.Stg_PH AS P
JOIN tst.GOLDRECORD AS G 
    ON G.NIP = P.NIP
WHERE EXISTS (SELECT 1 FROM tst.PH_PSG AS T WHERE T.klucz_PH = P.klucz_PH)
AND dbo.Podobienstwo(G.Nazwa, P.Nazwa) < 0.5;

SELECT * FROM tst.PSG_KORESP



--Zapisanie korespow adresow korespondencyjnych platnika

INSERT INTO tst.PSG_KORESP
(
    Klucz_PH, Nazwa, Adres, TypPH
)
SELECT	Klucz_PH, 
		UPPER(CONCAT_WS(N' ', kor_nazwa1, kor_nazwa2)) As Nazwa,
		UPPER(CONCAT_WS(N'|', kor_kod_poczt, kor_miejsc, kor_poczta, kor_ulica, kor_dom, kor_mieszk)) As Adres, 
		N'Korespondencyjny'
FROM hm.Stg_PH AS P
WHERE EXISTS (SELECT 1 FROM tst.PH_PSG AS T WHERE T.klucz_PH = P.klucz_PH)
		AND LEN(CONCAT_WS(N' ', kor_nazwa1, kor_nazwa2)) > 2;

SELECT * FROM tst.PSG_KORESP

--Dodanie do korespa - Odbiorcy korespondencyjnego
--Założenie odbiorca służy tylko jako adres więc 
--jeśli ma adres korespondencyjny to bierzemy dane z
--adresy korespondencyjne
--jesli nie ma to bierzemy dane z odbiorcy podstawowego
--USE Stage;

--Zapisanie wszystkich odbiorców występujących na umowach z platnikiem psgaz odbiorców 
-- #TODO Zrobić funkcję działającą dla NIP-u
--WITH A AS
--(
--SELECT	U.nr_umowy, 
--		U.platnik, 
--		P.Lider , 
--		PA.Lider AS Platnik_Alternatywny,
--		CONCAT_WS('_', U.SystemZrodlowyId, U.odbiorca) AS Odbiorca, 
--		O.Klucz_PH, 
--		O.NIP,
--		ROW_NUMBER() OVER(PARTITION BY nr_umowy ORDER BY platnik) AS LP
--FROM Stage.dbo.HM_NaglowekUmowy AS U --naglowek umowy
--JOIN NCB_MIG.tst.PH_PSG AS P -- dodajemy platnikow glownych
--	ON P.klucz_PH = CONCAT_WS('_', U.SystemZrodlowyId, U.platnik)
--LEFT JOIN NCB_MIG.tst.PSG_KORESP AS PA
--	 ON CONCAT_WS('_', U.SystemZrodlowyId, U.platnik) = PA.Klucz_PH
--	 AND PA.Klucz_PH = PA.Lider
--	 AND Pa.TypPH = N'Podstawowy'
--LEFT JOIN NCB_MIG.hm.Stg_PH AS O
--	ON CONCAT_WS('_', U.SystemZrodlowyId, U.odbiorca) = O.Klucz_PH
--WHERE 
--	U.data_k_ob = N'00000000'


--)
--INSERT INTO NCB_MIG.tst.Odbiorca
--SELECT DISTINCT Odbiorca
--FROM A ;

--USE NCB_MIG;
----Usuwanie odbiorcow istniejacych w bazie korespow
--WITH A AS
--(
--SELECT Klucz_PH
--FROM tst.PSG_KORESP
--INTERSECT
--SELECT Odbiorca
--FROM tst.Odbiorca
--)
--DELETE tst.Odbiorca
--WHERE Odbiorca  IN (SELECT Klucz_PH AS Odbiorca FROM A);

--Dodanie odbiorców koresp do bazy 14.09.2022 nie uzupełniamy tabeli koresp (wspolna_faktura)

--INSERT INTO tst.PSG_KORESP
--(
--    Klucz_PH, Nazwa, Adres, TypPH
--)
--SELECT P.Klucz_PH, 
--CASE
--	WHEN LEN(CONCAT_WS(N' ', kor_nazwa1, kor_nazwa2)) > 2
--		THEN UPPER(CONCAT_WS(N' ', kor_nazwa1, kor_nazwa2))
--	ELSE UPPER(Nazwa)	
--END AS Nazwa,
--CASE
--	WHEN LEN(CONCAT_WS(N' ', kor_nazwa1, kor_nazwa2)) > 2
--		THEN UPPER(CONCAT_WS(N'|', kor_kod_poczt, kor_miejsc, kor_poczta, kor_ulica, kor_dom, kor_mieszk))
--	ELSE UPPER(CONCAT_WS(N'|', kodpocztowy,  miejscowosc, poczta, ulica, nrdomu, nrmieszkania))
--END AS Adres, N'Korespondencyjny'
--FROM hm.Stg_PH AS P
--WHERE EXISTS (SELECT 1 FROM tst.Odbiorca AS O WHERE O.Odbiorca = P.Klucz_PH);

--Deduplikacja korespow 
;
WITH
A
AS
(
SELECT	CONCAT_WS(N'|', dbo.UsuwanieNieliter(REPLACE(REPLACE(REPLACE(nazwa,'"',''),'Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ','Z O.O.'),'SPÓŁKA','SP.')), adres) AS ADRES ,
		ROW_NUMBER() OVER (PARTITION BY CONCAT_WS(N'|', dbo.UsuwanieNieliter(REPLACE(REPLACE(REPLACE(nazwa,'"',''),'Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ','Z O.O.'),'SPÓŁKA','SP.')), adres) ORDER BY TypPH DESC) AS LP,
		Klucz_PH
FROM tst.PSG_KORESP
),
B AS
(
SELECT	K.Klucz_PH, 
		K.LIDER, 
		A.KLUCZ_PH AS alider
FROM tst.PSG_KORESP AS K
JOIN A
ON CONCAT_WS(N'|', dbo.UsuwanieNieliter(REPLACE(REPLACE(REPLACE(K.nazwa,'"',''),'Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ','Z O.O.'),'SPÓŁKA','SP.')), K.adres) = A.ADRES
WHERE A.LP = 1
)
UPDATE B
SET Lider = alider;

--Tworzenie umów

SELECT distinct
--Pola z konta umowy
	CONCAT_WS('_', U.SystemZrodlowyId, U.platnik, U.wspolna_faktura) AS KontoUmowy,
--Pola z umowy
	U.nr_umowy, 
	CONCAT_WS('_', U.SystemZrodlowyId, U.platnik) AS PlatnikzUmowy, 
--Pola z płatnika głownego
	P.Lider AS Platnik, 
	(SELECT nazwa from hm.Stg_PH where Klucz_PH = P.LIDER) As nazwa,
--Pola z Platnika alternatywnego
	PA.LIDER AS PlatnikAlternatywny, 
	PA.nazwa as pa_nazwa, 
	PA.adres AS pa_adres,
--Pola z odbiorcy
	AOF.Lider AS A_Odbiorca, 
	AOF.nazwa AS A_nazwa, 
	AOF.adres as A_dadres,
--wspólna umowa
	U.wspolna_faktura
FROM NCB_MIG.hm.Stg_Umowy AS U --umowa
JOIN tst.PH_PSG AS P --Platnicy glowni
    ON P.klucz_PH = U.Klucz_PH
LEFT JOIN tst.PSG_KORESP AS PA --Platnicy alternatywni
	ON U.Klucz_PH = PA.Klucz_PH
	AND Pa.TypPH = N'Podstawowy'
LEFT JOIN tst.PSG_KORESP AS AOF --Alternatywni ODB faktury
	ON U.Klucz_PH = AOF.Klucz_PH
	AND AOF.TypPH = N'Korespondencyjny'
WHERE U.CzyMIG > 0
ORDER BY KontoUmowy