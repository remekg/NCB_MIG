

WITH A AS
(
SELECT DISTINCT   k.*, 
TW.WOJ,  TP.POW, TG.GMI,TS.SYM, TS.RM, TS.SYMPOD
INTO ref.lista_pna_teryt
FROM ref.lista_pna AS K
JOIN stage.dbo.TERYT_TERC AS TW
ON K.WOJEWÓDZTWO = TW.NAZWA
AND TW.NAZWA_DOD = 'województwo'

JOIN stage.dbo.TERYT_TERC AS TP
ON K.Powiat = TP.NAZWA
--LEFT(K.POWIAT,4) = LEFT(TP.NAZWA, 4)
AND TP.POW IS NOT NULL
AND TP.GMI IS NULL
AND TW.WOJ = TP.WOJ
JOIN stage.dbo.TERYT_TERC AS TG
ON K.gmina = TG.NAZWA
AND TG.GMI IS NOT NULL
AND TW.WOJ = TG.WOJ 
AND TP.POW = TG.POW
LEFT JOIN Stage.dbo.TERYT_SIMC AS TS
ON CONCAT(TW.WOJ, TP.POW, TG.GMI) = CONCAT(TS.WOJ, TS.POW, TS.GMI)
AND 
K.MIEJSCOWOŒÆ =  TS.NAZWA
WHERE 1=1

AND TS.SYM IS NOT NULL
)


SELECT
FROM en.Stg_PH
WHERE CzyMig > 0
AND 
;

SELECT  *
FROM STage.dbo.TERYT_TERC
WHERE WOJ='14' AND NAZWA = 'MOKOtów' 


SELECT DISTINCT Gmina, Miejscowoœæ
FROM ref.lista_pna
WHERE Miejscowoœæ LIKE N'%(%)%'
AND Powiat IN ('Kraków', 'Poznañ', '£ódŸ', 'Wroc³aw', 'Warszawa')
--'Kraków', Poznañ, £ódŸ, Wroc³aw, Warszawa
UPDATE ref.lista_pna
SET Gmina = 
	SUBSTRING(MIEJSCOWOŒÆ, CHARINDEX('(', MIEJSCOWOŒÆ) + 1, 
	CHARINDEX(')', MIEJSCOWOŒÆ) - CHARINDEX('(', MIEJSCOWOŒÆ) - 1)	
WHERE POWIAT IN ('Kraków', 'Poznañ', '£ódŸ', 'Wroc³aw', 'Warszawa')
AND Miejscowoœæ LIKE N'%(%)%'

UPDATE ref.lista_pna
SET MIEJSCOWOŒÆ = SUBSTRING(MIEJSCOWOŒÆ, CHARINDEX('(', MIEJSCOWOŒÆ) + 1, 
	CHARINDEX(')', MIEJSCOWOŒÆ) - CHARINDEX('(', MIEJSCOWOŒÆ) - 1)
WHERE Miejscowoœæ LIKE N'%(%)%'


SELECT  *
FROM stage.dbo.TERYT_TERC
WHERE RODZ = 8 IS NULL

SELECT distinct UPPER(LEFT(powiat,4))
FROM ref.lista_pna
WHERE UPPER(LEFT(powiat,4)) NOT IN 
(SELECT UPPER(LEFT(NAZWA,4)) 
FROM stage.dbo.TERYT_TERC WHERE NAZWA_DOD = 'powiat')
AND NAZWA = 'olsztyñski')


SELECT *
FROM crs.dbo.PowiazanieTERYTzPNA
WHERE TERYT_MIEJ_NAZWA = 'Olsztyn'

 -1) 



 SELECT COUNT(*)
 FROM ref.lista_pna_teryt