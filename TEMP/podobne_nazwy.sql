--Podobieństawa w grupach
USE NCB_MIG;
GO

SELECT 
    CONCAT_WS('K')
    CASE 
       WHEN kor_nazwa = N'' THEN 2
       ELSE dbo.podobienstwo(nazwa, kor_nazwa)
    END AS Podobienstwo
    
FROM En.Stg_PH
WHERE CzyMig > 0
AND Sugerowany_typ = 3
--AND LEN(koresp) > 1



WITH A AS
(
   SELECT 
    nazwa, kor_nazwa, KLUCZ_PH, 
    ROW_NUMBER() OVER ( PARTITION BY KLUCZ_PH ORDER BY kor_nazwa) AS NR
    FROM En.Stg_PH
    WHERE CzyMig > 0
    AND Sugerowany_typ = 3
    AND 
    CASE 
       WHEN kor_nazwa = N'' THEN 2
       WHEN koresp IS NULL THEN 2
       
       ELSE dbo.podobienstwo(nazwa, kor_nazwa)
    END < 0.9 
)

INSERT INTO en_tmp.Koresp
(
    nazwa, 
    kor_nazwa,
    [KEY],
[BPEXT]
)

SELECT 
nazwa, kor_nazwa,
CONCAT_WS('_',Klucz_PH, 'A', RIGHT(CONCAT('0000', CAST(NR AS NVARCHAR(20))),4)),
KLUCZ_PH
FROM A

--Osoba
WITH A AS
(
   SELECT 
    nazwa, kor_nazwa, KLUCZ_PH, 
    ROW_NUMBER() OVER ( PARTITION BY KLUCZ_PH ORDER BY kor_nazwa) AS NR
    FROM En.Stg_PH
    WHERE CzyMig > 0
    AND Sugerowany_typ = 1
    AND 
    CASE 
       WHEN kor_nazwa = N'' THEN 2
       WHEN koresp IS NULL THEN 2
       
       ELSE dbo.podobienstwo(nazwa, kor_nazwa)
    END < 0.9 
)

INSERT INTO en_tmp.Koresp
(
    nazwa, 
    kor_nazwa,
    [KEY],
[BPEXT]
)

SELECT 
nazwa, kor_nazwa,
CONCAT_WS('_',Klucz_PH, 'A', RIGHT(CONCAT('0000', CAST(NR AS NVARCHAR(20))),4)),
KLUCZ_PH
FROM A


