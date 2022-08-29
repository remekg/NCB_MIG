/****** Script for SelectTopNRows command from SSMS  ******/

/** Analiza PH szczególne przypadki - odbiorcy  p³atnicy z ró¿nymi adresami**/

SELECT kl.nrw_kontrahenta
INTO ##tmp1
from
Stage.dbo.HM_Klienci kl
INNER JOIN [Stage].[dbo].[HM_AdresKoresp] ak
ON kl.nrw_kontrahenta = ak.nr_kontrahenta
AND kl.SystemZrodlowyId = ak.SystemZrodlowyId
WHERE LEN(TRIM(nazwa1))>2 
AND LEN(TRIM(nazwa))>2 AND NCB_MIG.dbo.Podobienstwo(TRIM(nazwa),TRIM(nazwa1))<0.5

--DROP TABLE ##tmp1

SELECT um.nr_umowy, um.nr_up, um.platnik, pl.nazwa as nazwa_pl, akpl.nazwa1 as kor_nazwa_pl, 
		um.odbiorca, odb.nazwa as nazwa_odb, akodb.nazwa1 as kor_nazwa_odb
								FROM Stage.dbo.HM_UkladPomiarowy AS up		
							INNER JOIN Stage.dbo.HM_NaglowekUmowy AS um ON um.nr_up = up.nr_ukl_pom		
							AND um.nrw_umowy = up.nrw_umowy	
							AND up.SystemZrodlowyId = um.SystemZrodlowyId	
							AND (	
								um.[data_k_ob] = '00000000'
								OR um.[data_k_ob] > convert(VARCHAR(8), DATEADD(MONTH, -18, GETDATE()), 112)
								)
							AND um.[data_p_ob] <> '00000000'
							INNER JOIN Stage.dbo.HM_Klienci pl
							ON pl.nrw_kontrahenta = um.platnik AND um.SystemZrodlowyId = pl.SystemZrodlowyId
							INNER JOIN [Stage].[dbo].[HM_AdresKoresp] akpl
							ON pl.nrw_kontrahenta = akpl.nr_kontrahenta
							AND pl.SystemZrodlowyId = akpl.SystemZrodlowyId
							INNER JOIN Stage.dbo.HM_Klienci odb
							ON odb.nrw_kontrahenta = um.odbiorca AND um.SystemZrodlowyId = odb.SystemZrodlowyId
							INNER JOIN [Stage].[dbo].[HM_AdresKoresp] akodb
							ON odb.nrw_kontrahenta = akodb.nr_kontrahenta
							AND odb.SystemZrodlowyId = akodb.SystemZrodlowyId

WHERE EXISTS (SELECT 1 FROM ##tmp1 where ##tmp1.nrw_kontrahenta=um.platnik)
	AND um.odbiorca <> um.platnik