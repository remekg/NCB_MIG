/* 
Data : 2020-09-01 Skrypt do obsługi danych z pola koresp
*/

-- ************* Ogólne zasady pole do_koresp***************************
-- do_koresp tinyint
--Jesli koresp jest pusty to pole do koresp = 0

USE NCB_MIG;

UPDATE En.Stg_PH
SET do_koresp = null

--Jesli koresp jest pusty to pole do koresp = 0
UPDATE En.Stg_PH
SET do_koresp = 0
WHERE CzyMig > 0
AND (koresp IS NULL OR LEN(koresp) < 2);

--******************GRUPA********************************
--DEDUPLIKACJA GRUP OBRÓT
SELECT Grupa_Checksum, COUNT(DISTINCT [KEY]) AS ILE
FROM en_ob.PH_Grupa
GROUP BY Grupa_Checksum

--BRAK DUBLI

--DEDUPLIKACJA GRUP DYSTRYBUCJA
SELECT Grupa_Checksum, COUNT(DISTINCT [KEY]) AS ILE
FROM en_dys.PH_Grupa
GROUP BY Grupa_Checksum

--BRAK DUBLI

--DEDUPLIKACJA OSOBA
--Pesel taki sam imie i nazwisko takie samo Warunki 
/*
 Parametry 
  CzyMig = 1  1000 pkt
  CzyMig = 3  500 pkt
  CzyMig = 2   10 pkt
  Zawiera G_   -1000 pky
  PGE = OD 1000 pkt
  dlugosc terytu miejscowosci = 7 znakow  100 pkt
  dlugosc terytu ulicy = 5 znakow i rozne od '00000' 100 pky
  wypelnione pole mail_pop = 25 pkt
  wypelnione pole telefon = 25 pkt
  za kazdy aktywny pkt = 100 pkt
*/

--//TODO DEDUPLIKACJA OSOBA OBROT
--Przygotowanie tabeli z dublami
DROP TABLE IF EXISTS ##O_Duble;
DROP TABLE IF EXISTS ##O_Zle_Duble;

SELECT IDNUMBER
INTO ##O_Duble
FROM en_ob.PH_Osoba
WHERE IDNUMBER IS NOT NULL
GROUP BY IDNUMBER
HAVING COUNT(DISTINCT [KEY]) > 1;

--Usuwanie peseli dla złych dubli
--
SELECT OD.IDNUMBER
--INTO ##O_Zle_Duble
FROM ##O_Duble AS OD
JOIN en_ob.PH_Osoba AS OO
    ON OD.IDNUMBER = OO.IDNUMBER
GROUP BY OD.IDNUMBER
HAVING 
    COUNT(
        DISTINCT CONVERT(
            NVARCHAR(255), 
            HASHBYTES(
                'SHA2_256', 
                CONCAT_WS('|', NAMEFIRST, NAMELAST)
                ),
        2)
     ) > 1

INSERT INTO TABLE



DROP TABLE IF EXISTS ##O_Duble
DROP TABLE IF EXISTS ##O_Zle_Duble;





--//TODO DEDUPLIKACJA OSOBA DYSTRYBUCJA
----Przygotowanie tabeli z dublami














--Zrodlo en_on.PH_Grupa

TRUNCATE TABLE en_ob.PH_Koresp

--Jesli nazwa <> kor_nazwa
--Insert do tabeli en_ob.koresp

WITH A AS
(
SELECT 
    ROW_NUMBER() OVER ( PARTITION BY KLUCZ_PH ORDER BY kor_nazwa) AS NR

FROM en_ob.PH_Grupa AS OG
JOIN en.Stg_PH AS PH 
    ON OG.[KEY] = PH.Klucz_PH
    AND dbo.Podobienstwo(OG.nazwa, PH.kor_nazwa) < 0.9
    AND PH.do_koresp IS NULL
)



--DYSTRYBUCJA



SELECT nazwa, kor_nazwa
FROM En.Stg_PH
WHERE CzyMIG > 0
AND do_koresp IS NULL
AND SUGEROWANY_TYP = 3


