-- LUBANIE 02
SELECT DISTINCT  
  NRPL = P.nrpl
  ,Nazwa_Platnika = K.Nazwa
  ,Nazwa_Punktu = P.npp
  ,k.nip 
  ,Punkt_Miejscowosc = P.miejscowosc
  ,Punkt_ulica = P.ulica
  ,Punkt_Numer = p.dom
  ,Platnik_Miejscowosc = K.miejscowosc
  ,Platnik_Ulica = K.ulica
  ,Platnik_Numer = K.nrdomu
  ,Platnik_Kor_Miejscowosc = K.kor_miejsc
  ,Platnik_Kor_Ulica = k.kor_ulica
  ,Platnik_kor_dom = k.kor_dom
  FROM [Stage].[dbo].[EN_PPE] AS P
  JOIN Stage.dbo.EN_Klienci AS K
  ON CONCAT('90' , P.nrpl) =  K.nrpl
  AND P.SystemZrodlowyId = K.SystemZrodlowyId
  WHERE P.SystemZrodlowyId >= 10
  AND nazwa LIKE N'%gmina lubenia%'
  ORDER BY P.nrpl
-- RZESZÓW 01
 SELECT DISTINCT  
  NRPL = P.nrpl
  ,Nazwa_Platnika = K.Nazwa
  ,Nazwa_Punktu = P.npp
  ,k.nip 
  ,Punkt_Miejscowosc = P.miejscowosc
  ,Punkt_ulica = P.ulica
  ,Punkt_Numer = p.dom
  ,Platnik_Miejscowosc = K.miejscowosc
  ,Platnik_Ulica = K.ulica
  ,Platnik_Numer = K.nrdomu
  ,Platnik_Kor_Miejscowosc = K.kor_miejsc
  ,Platnik_Kor_Ulica = k.kor_ulica
  ,Platnik_kor_dom = k.kor_dom
  FROM [Stage].[dbo].[EN_PPE] AS P
  JOIN Stage.dbo.EN_Klienci AS K
  ON CONCAT('90' , P.nrpl) =  K.nrpl
  AND P.SystemZrodlowyId = K.SystemZrodlowyId
  WHERE P.SystemZrodlowyId >= 10
  AND nazwa = 'GMINA MIASTO RZESZÓW'                                                                                                                                                                                                                                      
  ORDER BY K.kor_ulica
-- BIEDRONKA 03
  SELECT DISTINCT  
  NRPL = P.nrpl
  ,Nazwa_Platnika = K.Nazwa
  ,Nazwa_Punktu = P.npp
  ,k.nip 
  ,K.koresp
  ,Punkt_Miejscowosc = P.miejscowosc
  ,Punkt_ulica = P.ulica
  ,Punkt_Numer = p.dom
  ,Platnik_Miejscowosc = K.miejscowosc
  ,Platnik_Ulica = K.ulica
  ,Platnik_Numer = K.nrdomu
  ,Platnik_Kor_Miejscowosc = K.kor_miejsc
  ,Platnik_Kor_Ulica = k.kor_ulica
  ,Platnik_kor_dom = k.kor_dom
  FROM [Stage].[dbo].[EN_PPE] AS P
  JOIN Stage.dbo.EN_Klienci AS K
  ON CONCAT('90' , P.nrpl) =  K.nrpl
  AND P.SystemZrodlowyId = K.SystemZrodlowyId
  WHERE P.SystemZrodlowyId >= 10
  AND NIP = '7791011327'                                                                                                                                                                                                                                    
  ORDER BY P.nrpl

 SELECT DISTINCT  
  NRPL = P.nrpl
  ,Nazwa_Platnika = K.Nazwa
  ,Nazwa_Punktu = P.npp
  ,k.nip 
  ,k.koresp
  ,k.kor_poczta
  ,Punkt_Miejscowosc = P.miejscowosc
  ,Punkt_ulica = P.ulica
  ,Punkt_Numer = p.dom
  ,Platnik_Miejscowosc = K.miejscowosc
  ,Platnik_Ulica = K.ulica
  ,Platnik_Numer = K.nrdomu
  ,Platnik_Kor_Miejscowosc = K.kor_miejsc
  ,Platnik_Kor_Ulica = k.kor_ulica
  ,Platnik_kor_dom = k.kor_dom
  FROM [Stage].[dbo].[EN_PPE] AS P
  JOIN Stage.dbo.EN_Klienci AS K
  ON CONCAT('90' , P.nrpl) =  K.nrpl
  AND P.SystemZrodlowyId = K.SystemZrodlowyId
  WHERE P.SystemZrodlowyId >= 10
  AND P.nrpl = '007749'
