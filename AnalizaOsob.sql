--Badanie czy są duble na kluczach
--Dystrybucja
SELECT [KEY], COUNT(*)
FROM  en_dys.PH_OSOBA
GROUP BY [KEY]
HAVING  COUNT(*) > 1
--Brak zdublowanych kluczy

--Badanie czy są duble na peselach 
WITH A AS
(
SELECT IDNUMBER
FROM  en_dys.PH_OSOBA
WHERE IDNUMBER IS NOT NULL
GROUP BY [IDNUMBER]
HAVING  COUNT(*) > 1
)
SELECT *
FROM en_dys.PH_OSOBA
WHERE IDNUMBER IN (SELECT IDNUMBER FROM A)
ORDER BY IDNUMBER
