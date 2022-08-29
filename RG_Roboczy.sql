

WITH A AS
(
SELECT DISTINCT   k.*, 
TW.WOJ,  TP.POW, TG.GMI,TS.SYM, TS.RM, TS.SYMPOD
INTO ref.lista_pna_teryt
FROM ref.lista_pna AS K
JOIN stage.dbo.TERYT_TERC AS TW
ON K.WOJEW�DZTWO = TW.NAZWA
AND TW.NAZWA_DOD = 'wojew�dztwo'

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
K.MIEJSCOWO�� =  TS.NAZWA
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
WHERE WOJ='14' AND NAZWA = 'MOKOt�w' 


SELECT DISTINCT Gmina, Miejscowo��
FROM ref.lista_pna
WHERE Miejscowo�� LIKE N'%(%)%'
AND Powiat IN ('Krak�w', 'Pozna�', '��d�', 'Wroc�aw', 'Warszawa')
--'Krak�w', Pozna�, ��d�, Wroc�aw, Warszawa
UPDATE ref.lista_pna
SET Gmina = 
	SUBSTRING(MIEJSCOWO��, CHARINDEX('(', MIEJSCOWO��) + 1, 
	CHARINDEX(')', MIEJSCOWO��) - CHARINDEX('(', MIEJSCOWO��) - 1)	
WHERE POWIAT IN ('Krak�w', 'Pozna�', '��d�', 'Wroc�aw', 'Warszawa')
AND Miejscowo�� LIKE N'%(%)%'

UPDATE ref.lista_pna
SET MIEJSCOWO�� = SUBSTRING(MIEJSCOWO��, CHARINDEX('(', MIEJSCOWO��) + 1, 
	CHARINDEX(')', MIEJSCOWO��) - CHARINDEX('(', MIEJSCOWO��) - 1)
WHERE Miejscowo�� LIKE N'%(%)%'


SELECT  *
FROM stage.dbo.TERYT_TERC
WHERE RODZ = 8 IS NULL

SELECT distinct UPPER(LEFT(powiat,4))
FROM ref.lista_pna
WHERE UPPER(LEFT(powiat,4)) NOT IN 
(SELECT UPPER(LEFT(NAZWA,4)) 
FROM stage.dbo.TERYT_TERC WHERE NAZWA_DOD = 'powiat')
AND NAZWA = 'olszty�ski')


SELECT *
FROM crs.dbo.PowiazanieTERYTzPNA
WHERE TERYT_MIEJ_NAZWA = 'Olsztyn'

 -1) 



 SELECT COUNT(*)
 FROM ref.lista_pna_teryt