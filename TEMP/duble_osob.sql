SELECT * 
FROM en.Stg_PH
WHERE Klucz_PH IN (N'11_2_90294524', N'11_2_90294525',N'11_2_90294976',N'11_2_90294977', N'11_2_90294317', N'11_2_90294318')

SELECT * 
FROM en.Stg_PPE
WHERE Klucz_PH IN (N'11_2_90294524', N'11_2_90294525',N'11_2_90294976',N'11_2_90294977', N'11_2_90294317', N'11_2_90294318')

WITH A AS
(
SELECT IDNUMBER
FROM  en_dys.PH_OSOBA
WHERE IDNUMBER IS NOT NULL --AND [KEY] NOT LIKE N'%G_'
GROUP BY [IDNUMBER]
HAVING  COUNT(*) > 1
)
SELECT [KEY], K.pesel, K.CzyMIG, O.nazwa, P.npp, K.PGE,
CONCAT_WS(N' - ', K.kodpocztowy,   K.miejscowosc,  K.ulica,  K.nrdomu, K.nrmieszkania ) AS Adres, CONCAT(K.TERYT_MIEJSCOWOSC, K.TERYT_ULICY) AS Teryt_Adresu,
CONCAT_WS(N' - ', K.kor_kod_poczt,   K.kor_miejsc, K.kor_ulica,  K.kor_dom, K.kor_mieszk) AS Adres_korespondencyjny, CONCAT( K.KOR_TERYT_MIEJSCOWOSC,K.KOR_TERYT_ULICY) AS Teryt_Adresu_KOR,
CONCAT_WS(N' - ', P.kod_p, P.miejscowosc,  P.ulica, P.dom, P.mieszk) AS Adres_punktu, CONCAT( P.TERYT_MIEJSCOWOSC, P.TERYT_ULICY ) AS Teryt_Adresu_Pkt
FROM en_dys.PH_OSOBA AS O
JOIN en.Stg_PH AS K 
	ON O.[KEY] = K.Klucz_PH
JOIN en.Stg_PPE AS P
	ON O.[KEY] = P.Klucz_PH
WHERE IDNUMBER IN (SELECT IDNUMBER FROM A)
ORDER BY IDNUMBER