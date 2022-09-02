/*
Plik przenosi PH do tabel
(en_dys.PH_OSOBA, en_dys.PH_GRUPA, en_dys.PH_FIRMA oraz tworzy plik z relacjami en_dys.relacjegrupy)
*/

-- Osoby 
TRUNCATE TABLE en_dys.PH_OSOBA 

INSERT INTO en_dys.PH_OSOBA
(
    [KEY], [BPEXT], [TITLE], [NAMEFIRST], [NAMEMIDDLE], [NAMELAST], [Nazwa],
    [TELNUMBER], [TELEXTENS], [TELKOM], [FAXNUMBER], [SMTPADDR], [IDTYPE], [IDNUMBER], [TAXNUM], [PLEC]
)
SELECT
    [KEY] = Klucz_PH
    ,[BPEXT] = Klucz_PH
    ,[TITLE] = NULL
    ,[NAMEFIRST] = I.NAMEFIRST
    ,[NAMEMIDDLE] = I.NAMEMIDDLE
    ,[NAMELAST] = I.NAMELAST
    ,[Nazwa] 
    ,[TELNUMBER] = telefon
    ,[TELEXTENS] = NULL
    ,[TELKOM] = NULL
    ,[FAXNUMBER] = NULL
    ,[SMTPADDR] = email_pop
    ,[IDTYPE] = NULL
    ,[IDNUMBER] = pesel
    ,[TAXNUM] = nip
    ,[PLEC] = NULL
FROM en.Stg_PH AS P
CROSS APPLY dbo.ZwrocImie(P.nazwa, N' ') AS I
WHERE P.CzyMig > 0 AND P.Sugerowany_typ = 1
AND PGE LIKE N'%D%'

--Grupy
TRUNCATE TABLE en_dys.PH_GRUPA

INSERT INTO en_dys.PH_GRUPA
(
    [KEY], [BPEXT],  [NAMEGRP1], [NAMEGRP2],  [Nazwa], [TELNUMBER], [TELEXTENS], [TELKOM],
     [FAXNUMBER], [SMTPADDR], [IDTYPE], [IDNUMBER], [TAXNUM], [PESEL_1], [PESEL_2], Grupa_Checksum
)
SELECT
     [KEY] = Klucz_PH
    ,[BPEXT] = Klucz_PH
    ,[NAMEGRP1] = CONCAT_WS(N' ', G.first_name_1, G.last_name_1)
    ,[NAMEGRP1] = CONCAT_WS(N' ', G.first_name_2, G.last_name_2)
    ,[Nazwa] 
    ,[TELNUMBER] = telefon
    ,[TELEXTENS] = NULL
    ,[TELKOM] = NULL
    ,[FAXNUMBER] = NULL
    ,[SMTPADDR] = email_pop
    ,[IDTYPE] = NULL
    ,[IDNUMBER] = NULL
    ,[TAXNUM] = nip
    ,[PESEL_1] = G.pesel_1
    ,[PESEL_2] = G.pesel_2
    ,[Grupa_Checksum] = P.Grupa_Checksum
FROM en.Stg_PH AS P
CROSS APPLY dbo.udfgrupa(P.nazwa, P.pesel, N' ') AS G
WHERE P.CzyMig > 0 AND P.Sugerowany_typ = 3
AND PGE LIKE N'%D%'

--Dodanie osób  z grup z 1
INSERT INTO en_dys.PH_OSOBA
(
    [KEY], [BPEXT], [TITLE], [NAMEFIRST], [NAMEMIDDLE], [NAMELAST], [Nazwa],
    [TELNUMBER], [TELEXTENS], [TELKOM], [FAXNUMBER], [SMTPADDR], [IDTYPE], [IDNUMBER], [TAXNUM], [PLEC]
) 
SELECT [KEY] = CONCAT_WS(N'_', Klucz_PH, N'G1')
    ,[BPEXT] = Klucz_PH
    ,[TITLE] = NULL
    ,[NAMEFIRST] = G.first_name_1
    ,[NAMEMIDDLE] = NULL
    ,[NAMELAST] = G.last_name_1
    ,[Nazwa] 
    ,[TELNUMBER] = telefon
    ,[TELEXTENS] = NULL
    ,[TELKOM] = NULL
    ,[FAXNUMBER] = NULL
    ,[SMTPADDR] = email_pop
    ,[IDTYPE] = NULL
    ,[IDNUMBER] = G.PESEL_1
    ,[TAXNUM] = nip
    ,[PLEC] = NULL
FROM en.Stg_PH AS P
CROSS APPLY dbo.udfgrupa(P.nazwa, P.pesel, N' ') AS G
WHERE P.CzyMig > 0 AND P.Sugerowany_typ = 3
AND PGE LIKE N'%D%';

--Dodanie osób  z grup z 1
INSERT INTO en_dys.PH_OSOBA
(
    [KEY], [BPEXT], [TITLE], [NAMEFIRST], [NAMEMIDDLE], [NAMELAST], [Nazwa],
    [TELNUMBER], [TELEXTENS], [TELKOM], [FAXNUMBER], [SMTPADDR], [IDTYPE], [IDNUMBER], [TAXNUM], [PLEC]
) 
SELECT [KEY] = CONCAT_WS(N'_', Klucz_PH, N'G2')
    ,[BPEXT] = Klucz_PH
    ,[TITLE] = NULL
    ,[NAMEFIRST] = G.first_name_2
    ,[NAMEMIDDLE] = NULL
    ,[NAMELAST] = G.last_name_2
    ,[Nazwa] 
    ,[TELNUMBER] = telefon
    ,[TELEXTENS] = NULL
    ,[TELKOM] = NULL
    ,[FAXNUMBER] = NULL
    ,[SMTPADDR] = email_pop
    ,[IDTYPE] = NULL
    ,[IDNUMBER] = G.PESEL_2
    ,[TAXNUM] = nip
    ,[PLEC] = NULL
FROM en.Stg_PH AS P
CROSS APPLY dbo.udfgrupa(P.nazwa, P.pesel, N' ') AS G
WHERE P.CzyMig > 0 AND P.Sugerowany_typ = 3
AND PGE LIKE N'%D%';




--Dopisanie płci na podstawie imienia
WITH A AS
(
 SELECT NAMEFIRST, PLEC, (SELECT STRING_AGG(PLEC, '') FROM ref.Imiona AS I WHERE I.IMIE = O.NAMEFIRST) as PLEC_I
 FROM en_dys.PH_OSOBA AS O
)
UPDATE A
SET PLEC = PLEC_I;

--Weryfikacja Pesela po sumie kontrolnej i płci
--Kasowanie błędnych PESELI po sumie kontrolnej
UPDATE en_dys.PH_OSOBA
SET IDNUMBER = NULL
WHERE dbo.pesel(IDNUMBER) <> 1 

--Kasowanie Peseli niepasujących do płci
--M
UPDATE en_dys.PH_OSOBA
SET IDNUMBER = NULL
WHERE PLEC = N'M'
AND CAST(SUBSTRING(IDNUMBER, 10, 1) AS INT) % 2 = 0

--K
UPDATE en_dys.PH_OSOBA
SET IDNUMBER = NULL
WHERE PLEC = N'K'
AND CAST(SUBSTRING(IDNUMBER, 10, 1) AS INT) % 2 = 1



-- SELECT SUGEROWANY_TYP, nazwa, kor_nazwa, miejscowosc, kor_miejsc, dbo.Podobienstwo(CONCAT_WS(' ', nazwa, miejscowosc), CONCAT_WS(' ', kor_nazwa,kor_miejsc))
-- FROM en_dys.Stg_PH AS P
-- WHERE 
-- LEN(KORESP) > 1
-- AND CZYMIG > 0
-- AND SUGEROWANY_TYP = 1
-- AND dbo.Podobienstwo(CONCAT_WS(' ', nazwa, miejscowosc), CONCAT_WS(' ', kor_nazwa,kor_miejsc)) < 0.5

-- SELECT nazwa
-- FROM en_dys.Stg_PH AS P
-- WHERE nazwa like N'%,%'
-- AND CzyMig > 0


--PLIK RELACJI
DROP TABLE IF EXISTS en_dys.relacjegrupy

SELECT O.[KEY], G.[KEY] AS KEY_1, O.[KEY] AS KEY_2
INTO en_dys.relacjegrupy
FROM en_dys.PH_GRUPA AS G
JOIN en_dys.PH_OSOBA AS O
ON G.[KEY] = O.BPEXT


