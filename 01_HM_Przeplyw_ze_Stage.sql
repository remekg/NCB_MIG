/* **********************************************
Data :20.07.2022
Obiekt biznesowy : Punkty i Parner Handlowy
Opis : przeladowanie tabel ze stage i wype³nianie dodatkowych kolumn (np CzyMIG)

**************************************************
*/ 

--CREATE NONCLUSTERED INDEX I_X01 ON NCB_MIG.hm.Stg_PH (kodpocztowy)
--CREATE NONCLUSTERED INDEX I_X02 ON NCB_MIG.hm.Stg_PH (KOR_kod_poczt) INCLUDE (koresp) WHERE Czymig > 0 
--CREATE CLUSTERED INDEX I_X03 ON NCB_MIG.hm.Stg_PH (Klucz_PH)
--CREATE NONCLUSTERED INDEX I_X04 ON NCB_MIG.dbo.TERYT_PNA (PNA)
--CREATE NONCLUSTERED INDEX I_X05 ON NCB_MIG.dbo.TERYT_PNA (TERYT_MIEJ_NAZWA)
--CREATE NONCLUSTERED INDEX I_X06 ON NCB_MIG.hm.Stg_PPE (kod_p)
--CREATE NONCLUSTERED INDEX I_X07 ON NCB_MIG.hm.Stg_PPE (Klucz_PH)
--CREATE NONCLUSTERED INDEX I_X08 ON NCB_MIG.hm.Stg_PPE (miejscowosc)
--CREATE NONCLUSTERED INDEX I_X09 ON NCB_MIG.hm.Stg_PH (miejscowosc)


;
TRUNCATE TABLE NCB_MIG.hm.Stg_PH
--TRUNCATE TABLE NCB_MIG.hm.Stg_PPE

SELECT
*
INTO ##tmp1
FROM(SELECT CONCAT_WS('_', um.SystemZrodlowyId, um.platnik) AS platnik
								FROM Stage.dbo.HM_UkladPomiarowy AS up		
							INNER JOIN Stage.dbo.HM_NaglowekUmowy AS um ON um.nr_up = up.nr_ukl_pom		
							AND um.nrw_umowy = up.nrw_umowy	
							AND up.SystemZrodlowyId = um.SystemZrodlowyId	
							AND (	
								um.[data_k_ob] = '00000000'
								OR um.[data_k_ob] > convert(VARCHAR(8), DATEADD(MONTH, -18, GETDATE()), 112)
								)
							AND um.[data_p_ob] <> '00000000'
							UNION
							SELECT CONCAT_WS('_', um.SystemZrodlowyId, um.odbiorca) AS platnik
								FROM Stage.dbo.HM_UkladPomiarowy AS up		
							INNER JOIN Stage.dbo.HM_NaglowekUmowy AS um ON um.nr_up = up.nr_ukl_pom		
							AND um.nrw_umowy = up.nrw_umowy	
							AND up.SystemZrodlowyId = um.SystemZrodlowyId	
							AND (	
								um.[data_k_ob] = '00000000'
								OR um.[data_k_ob] > convert(VARCHAR(8), DATEADD(MONTH, -18, GETDATE()), 112)
								)
							AND um.[data_p_ob] <> '00000000') A

INSERT INTO NCB_MIG.hm.Stg_PH ([nrpl], [nip], [regon], [pesel], [nazwa], [ulica], [kodpocztowy], [miejscowosc], [poczta], [nrdomu], [nrmieszkania], [gus], [nrrejonu], [SystemZrodlowyId], id_grupa_wind, biuro, [kor_dom], [kor_kod_poczt], [kor_miejsc], [kor_mieszk], [kor_poczta], [kor_ulica], [tryb_koresp], [mail], [telefon],[telefon_kom],[fax], odbior, id_sprzedawcy,obrot_dystrybucja,nr_seria_dowodu,branza,saldo, [DataImportu],[kor_nazwa1], [kor_nazwa2], [Klucz_PH], [CzyMIG], [PGE], [N_Systemu], [Oddzial])
SELECT 
	 [nrpl] = dbo.Czyszczenie(nrw_kontrahenta),
	 [nip] = dbo.Czyszczenie( [nip]),
	 [regon] = dbo.Czyszczenie( [regon]),
	 [pesel] = dbo.Czyszczenie( [pesel]),
	 [nazwa] = dbo.Czyszczenie( kl.nazwa),
	 [ulica] = dbo.Czyszczenie( kl.[ulica]),
	 [kodpocztowy] = dbo.Czyszczenie( kl.[kod_pocztowy]),
	 [miejscowosc] = dbo.Czyszczenie( kl.miasto),
	 [poczta] = dbo.Czyszczenie( kl.[poczta]),
	 [nrdomu] = dbo.Czyszczenie( kl.dom),
	 [nrmieszkania] = dbo.Czyszczenie( kl.lokal),
	 [gus] = dbo.Czyszczenie( kl.nr_gus_miasta),
	 [nrrejonu] = dbo.Czyszczenie( kl.rejon_nr),
	 [SystemZrodlowyId] =  kl.[SystemZrodlowyId],
	 id_grupa_wind =  id_grupa_wind,
	 biuro = dbo.Czyszczenie( biuro),
	 [kor_dom] = dbo.Czyszczenie( ak.nr_domu),
	 [kor_kod_poczt] = dbo.Czyszczenie( ak.kod),
	 [kor_miejsc] = dbo.Czyszczenie( ak.miejscowosc),
	 [kor_mieszk] = dbo.Czyszczenie( ak.nr_lokalu),
	 [kor_poczta] = dbo.Czyszczenie( ak.poczta),
	 [kor_ulica] = dbo.Czyszczenie( ak.ulica),
	 [tryb_koresp] = dbo.Czyszczenie( ak.tryb_koresp),
	 [mail] = dbo.Czyszczenie( kl.email),
	 [telefon] = dbo.Czyszczenie( kl.telefon),
 	 [telefon_kom] = dbo.Czyszczenie( kl.[telefon_kom]),
	 fax = dbo.Czyszczenie( kl.[fax]),
	 odbior = dbo.Czyszczenie( kl.[odbior]),
	 id_sprzedawcy = dbo.Czyszczenie( kl.id_sprzedawcy),
	 obrot_dystrybucja = dbo.Czyszczenie( kl.obrot_dystrybucja),
	 nr_seria_dowodu = dbo.Czyszczenie( kl.nr_seria_dowodu),
	 branza = dbo.Czyszczenie(kl.branza),
	 saldo = dbo.Czyszczenie(kl.saldo),
	 kl.[DataImportu],
	 [kor_nazwa1] = dbo.Czyszczenie( ak.nazwa1),
	 [kor_nazwa2] = dbo.Czyszczenie( ak.nazwa2),
	 --[typ_konsumenta] =  [typ_konsumenta],
	 --[typ_konsumenta_data] =  [typ_konsumenta_data],
	 --[jr] =  [jr],
	 --[skasowany] =  [skasowany],
	 Klucz_PH = CONCAT_WS('_', kl.SystemZrodlowyId, kl.nrw_kontrahenta),
	 CzyMIG = 0,
	 PGE = NULL,
	 sz.NazwaSystemu AS N_Systemu,
	 sz.Oddzial
FROM [Stage].[dbo].[HM_Klienci] kl
LEFT JOIN Meta.dbo.SystemyZrodlowe sz
ON kl.SystemZrodlowyId = sz.Id
LEFT JOIN Stage.dbo.HM_AdresKoresp ak
ON ak.nr_kontrahenta = kl.nrw_kontrahenta
AND ak.SystemZrodlowyId = kl.SystemZrodlowyId
WHERE EXISTS (SELECT 1 FROM ##tmp1 WHERE CONCAT_WS('_', kl.SystemZrodlowyId, kl.nrw_kontrahenta) = platnik) OR CAST(kl.saldo as decimal) > 0

DROP TABLE IF EXISTS ##tmp1;

--INSERT INTO NCB_MIG.hm.Stg_PPE ([ppeid], [przylaczeid], [nrpl], [ulica], [miejscowosc], [gus], [rej], [strona], [ppe], [npp], [mscgus], [pdgrp], [pum04], [otp], [kod_p], [adres_poczty], [dom], [mieszk], [dinit], [dend], [tar], [is_koncesja], [nrpr], [SystemZrodlowyId], [rej_src], [nrpre], [id_dos], [skasowany], [potrzeby], [ID_ODBIORCA_TPA], [mc_roz], [PUM01], [PUM02], [PUM03], [PUM05], [PUM06], [PUM07], [PUM08], [PUM09], [PUM10], [PUM11], [PUM12], [DataImportu], [epr], [nr_um_przes], [data_um_przes], [data_wyg_um_przes], [cennik], [dpocz], [cennik2], [cennikd], [id_spr_rezer], [notes], [dpor], [dkor], [Przylacz_skasowany], [jr], [Klucz_PH], [CzyMIG], [PGE], [N_Systemu], [Oddzial], [Rejon])
--SELECT 
--	 [ppeid] = [ppeid],
--	 [przylaczeid] =  [przylaczeid],
--	 [nrpl] = dbo.Czyszczenie( [nrpl]),
--	 [ulica] = dbo.Czyszczenie( [ulica]),
--	 [miejscowosc] = dbo.Czyszczenie( [miejscowosc]),
--	 [gus] = dbo.Czyszczenie( [gus]),
--	 [rej] = dbo.Czyszczenie( [rej]),
--	 [strona] =  [strona],
--	 [ppe] = dbo.Czyszczenie( [ppe]),
--	 [npp] = dbo.Czyszczenie( [npp]),
--	 [mscgus] = dbo.Czyszczenie( [mscgus]),
--	 [pdgrp] = dbo.Czyszczenie( [pdgrp]),
--	 [pum04] =  [pum04],
--	 [otp] =  [otp],
--	 [kod_p] = dbo.Czyszczenie( [kod_p]),
--	 [adres_poczty] = dbo.Czyszczenie( [adres_poczty]),
--	 [dom] = dbo.Czyszczenie( [dom]),
--	 [mieszk] = dbo.Czyszczenie( [mieszk]),
--	 [dinit] =  [dinit],
--	 [dend] =  [dend],
--	 [tar] = dbo.Czyszczenie( [tar]),
--	 [is_koncesja] =  [is_koncesja],
--	 [nrpr] =  [nrpr],
--	 [SystemZrodlowyId] =  ppe.SystemZrodlowyId,
--	 [rej_src] = dbo.Czyszczenie( [rej_src]),
--	 [nrpre] =  [nrpre],
--	 [id_dos] =  [id_dos],
--	 [skasowany] =  [skasowany],
--	 [potrzeby] =  [potrzeby],
--	 [ID_ODBIORCA_TPA] =  [ID_ODBIORCA_TPA],
--	 [mc_roz] =  [mc_roz],
--	 [PUM01] =  [PUM01],
--	 [PUM02] =  [PUM02],
--	 [PUM03] =  [PUM03],
--	 [PUM05] =  [PUM05],
--	 [PUM06] =  [PUM06],
--	 [PUM07] =  [PUM07],
--	 [PUM08] =  [PUM08],
--	 [PUM09] =  [PUM09],
--	 [PUM10] =  [PUM10],
--	 [PUM11] =  [PUM11],
--	 [PUM12] =  [PUM12],
--	 [DataImportu] =  ppe.DataImportu,
--	 [epr] =  [epr],
--	 [nr_um_przes] = dbo.Czyszczenie( [nr_um_przes]),
--	 [data_um_przes] =  [data_um_przes],
--	 [data_wyg_um_przes] =  [data_wyg_um_przes],
--	 [cennik] =  [cennik],
--	 [dpocz] =  [dpocz],
--	 [cennik2] =  [cennik2],
--	 [cennikd] =  [cennikd],
--	 [id_spr_rezer] =  [id_spr_rezer],
--	 [notes] = dbo.Czyszczenie( [notes]),
--	 [dpor] =  [dpor],
--	 [dkor] =  [dkor],
--	 [Przylacz_skasowany] =  [Przylacz_skasowany],
--	 jr =  ppe.jr,
--	 Klucz_PH = CONCAT(ppe.SystemZrodlowyId,'_', ppe.jr, '_90', nrpl),
--	 CzyMIG = 0,
--	 PGE = NULL,
--	 sz.NazwaSystemu AS N_Systemu,
--	 sz.Oddzial,
--	 re.nazwa AS Rejon
--FROM Stage.dbo.EN_PPE ppe
--LEFT JOIN Meta.dbo.SystemyZrodlowe sz
--ON ppe.SystemZrodlowyId = sz.Id
--LEFT JOIN Stage.dbo.EN_Rejony re
--ON re.SystemZrodlowyId = ppe.SystemZrodlowyId 
--	AND re.nr_rej = ppe.rej
--	AND re.jr = ppe.jr
--WHERE ppe.SystemZrodlowyId > 9

--ALTER TABLE NCB_MIG.hm.Stg_PPE
--ADD CzyMIG smallint,
--	PGE nvarchar(2)

--ALTER TABLE NCB_MIG.hm.Stg_PH
--ADD CzyMIG smallint,
--	PGE nvarchar(2)

--UPDATE NCB_MIG.hm.Stg_PPE
--SET PGE = NULL

UPDATE NCB_MIG.hm.Stg_PH
SET PGE = NULL

--UPDATE NCB_MIG.hm.Stg_PPE
--SET CzyMIG = 
--	CASE 
--			WHEN	skasowany IS NULL 
--					AND przylacz_skasowany IS NULL
--		THEN 1
--			WHEN skasowany IS NOT NULL
--					AND (dend >= DATEADD(MONTH, -18, GETDATE()) 
--						OR dkor >= DATEADD(MONTH, -18, GETDATE())) 
--		THEN 2
--		--3 jak bêdzie algorytm rozliczeñ
--	ELSE 0
--	END

SELECT * 
INTO ##aktywni 
FROM (
SELECT CONCAT_WS('_', um.SystemZrodlowyId, um.platnik) AS PH
FROM Stage.dbo.HM_NaglowekUmowy um
WHERE 	(	
								um.[data_k_ob] = '00000000'
								OR um.[data_k_ob] >= convert(VARCHAR(8), GETDATE(), 112)
								)
							AND um.[data_p_ob] <> '00000000'
UNION
SELECT CONCAT_WS('_', um.SystemZrodlowyId, um.odbiorca) AS PH
FROM Stage.dbo.HM_NaglowekUmowy um
WHERE 	(	
								um.[data_k_ob] = '00000000'
								OR um.[data_k_ob] >= convert(VARCHAR(8), GETDATE(), 112)
								)
							AND um.[data_p_ob] <> '00000000') A;

UPDATE NCB_MIG.hm.Stg_PH
SET CzyMIG = 1
WHERE EXISTS (SELECT 1 FROM ##aktywni ak WHERE Klucz_PH = ak.PH)

DROP TABLE IF EXISTS ##aktywni
;

SELECT * 
INTO ##aktywni18 
FROM (
SELECT CONCAT_WS('_', um.SystemZrodlowyId, um.platnik) AS PH
FROM Stage.dbo.HM_NaglowekUmowy um
WHERE 	(	
								um.[data_k_ob] = '00000000'
								OR um.[data_k_ob] >= convert(VARCHAR(8), DATEADD(MONTH, -18, GETDATE()), 112)
								)
							AND um.[data_p_ob] <> '00000000'
UNION
SELECT CONCAT_WS('_', um.SystemZrodlowyId, um.odbiorca) AS PH
FROM Stage.dbo.HM_NaglowekUmowy um
WHERE 	(	
								um.[data_k_ob] = '00000000'
								OR um.[data_k_ob] >= convert(VARCHAR(8), DATEADD(MONTH, -18, GETDATE()), 112)
								)
							AND um.[data_p_ob] <> '00000000') A;

UPDATE NCB_MIG.hm.Stg_PH
SET CzyMIG = 2
WHERE EXISTS (SELECT 1 FROM ##aktywni18 ak WHERE Klucz_PH = ak.PH)
AND CzyMIG = 0

DROP TABLE IF EXISTS ##aktywni18;

UPDATE NCB_MIG.hm.Stg_PH
SET CzyMIG = 3 
WHERE CAST(saldo as decimal) <> 0
AND Czymig = 0

--Wypelnianie kolumny PGE w PPE informacj¹ o przypisanie danych do obszaru (O, D i OD) zalo¿enia:
--JR=1 i otp=1 obrót
--JR=2 dystrybucyjne
--JR=3 obrót
--JR=1 i otp=0 wspólne
;
--WITH A AS
--(
--SELECT  otp,  dy.PGE_D, ppe.PGE, id_dos
--	--,CASE	WHEN otp <> 1 AND dy.PGE_D = 1
--	--		THEN 'OD'
--	--		WHEN otp <> 1 AND (dy.PGE_D IS NULL OR dy.PGE_D = 0) 
--	--		THEN 'O'
--	--		WHEN otp = 1 AND dy.PGE_D = 1
--	--		THEN 'D'
--	--END AS PGE_EN
--	,CASE	WHEN jr = 1 AND otp = 0
--			THEN 'OD'
--			WHEN jr = 2
--			THEN 'D'
--			WHEN jr = 3
--			THEN 'O'
--			WHEN jr = 1 AND otp = 1
--			THEN 'O'
--			ELSE 'E'
--	END AS PGE_EN
--FROM NCB_MIG.hm.Stg_PPE ppe
--	LEFT JOIN NCB_MIG.ref.Dystrybutor dy
--ON ppe.SystemZrodlowyId = dy.SystemZrodlowyID 
--	AND ppe.id_dos = dy.id
----WHERE CzyMIG > 0
--)

--UPDATE A
--SET PGE = PGE_EN 
--;
----Wypelnianie kolumny PGE w PH informacj¹ o przypisanie danych do obszaru (O, D i OD)
--WITH A AS(
--SELECT	ppe.Klucz_PH,
--		CASE WHEN STRING_AGG(ppe.PGE, ' ') LIKE '%D%' AND STRING_AGG(ppe.PGE, ' ') LIKE '%O%'
--				THEN 'OD'
--			WHEN STRING_AGG(ppe.PGE, ' ') LIKE '%D%'
--				THEN 'D'
--			WHEN STRING_AGG(ppe.PGE, ' ') LIKE '%O%'
--				THEN 'O'
--		END AS PGE_EN,
--		ph.PGE
--FROM NCB_MIG.hm.Stg_PPE ppe
--JOIN NCB_MIG.hm.Stg_PH ph
--ON ppe.Klucz_PH = ph.Klucz_PH
----WHERE ppe.CzyMIG > 0 AND ph.CzyMIG > 0
--GROUP BY ppe.Klucz_PH, ph.PGE
--)

--UPDATE NCB_MIG.hm.Stg_PH
--SET PGE = 
--(SELECT PGE_EN FROM A WHERE NCB_MIG.hm.Stg_PH.Klucz_PH = A.Klucz_PH)

--UPDATE NCB_MIG.hm.Stg_PH
--SET PGE = 'O'
--WHERE jr = 1 AND PGE IS NULL
--;
--czyszczenie NIPów

UPDATE NCB_MIG.hm.Stg_PH
SET nip = REPLACE(dbo.UsuwanieNieliter(nip),' ','')

;

--uzupe³nienie obecnoœci w bazach dzia³¹lnoœci gospodarczej

UPDATE NCB_MIG.hm.Stg_PH
SET CEIDG = 1
WHERE EXISTS(SELECT 1 FROM ref.FIRMY f WHERE f.NIP = REPLACE(NCB_MIG.hm.Stg_PH.nip,'-',''))
;

--ustalenie typu 1-osoba fizyczna , 2-firma, 3-grupa. Pole ty_konsumenta 1-konsument, 2-quasi-konsument, 3-niekonsument 

--PO CEIDG
--UPDATE NCB_MIG.hm.Stg_PH
--	SET SUGEROWANY_TYP = 2
--	WHERE (typ_konsumenta > 1 OR typ_konsumenta = 0) 
--	AND CEIDG = 1
--	AND SUGEROWANY_TYP IS NULL 
--	AND CzyMIG > 0

----PO FUNKCJI dbo.CzyFirma
--UPDATE NCB_MIG.hm.Stg_PH
--	SET SUGEROWANY_TYP = 2
--	WHERE (typ_konsumenta > 1 OR typ_konsumenta = 0) 
--	AND SUGEROWANY_TYP IS NULL 
--	AND CzyMIG > 0	
--	AND dbo.CzyFirma(regon, nazwa, typ_konsumenta) = 2

----PO Funkcji [dbo].[CzyOsobalubGrupa]
--UPDATE NCB_MIG.hm.Stg_PH
--	SET SUGEROWANY_TYP = [dbo].[CzyOsobalubGrupa](nazwa)
--	WHERE (typ_konsumenta = 1 OR typ_konsumenta = 0) 
--	AND SUGEROWANY_TYP IS NULL 
--	AND CzyMIG > 0	
	


--UPDATE NCB_MIG.hm.Stg_PH
--SET SUGEROWANY_TYP = 
--		CASE WHEN (typ_konsumenta > 1 OR typ_konsumenta = 0) AND CEIDG = 1
--				THEN 2
--			WHEN dbo.CzyFirma(regon, nazwa, typ_konsumenta) = 2 THEN 2
--			WHEN (typ_konsumenta = 1 OR typ_konsumenta = 0) AND CEIDG IS NULL 
--				THEN [dbo].[CzyOsobalubGrupa](nazwa)			
--			ELSE 4
--	END

--UPDATE hm.stg_PH
--SET ZGODNY_KORESP = 1
--WHERE 	len(kor_nazwa) > 0	
--		AND TRIM(dbo.UsuwanieNieliter(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(nazwa,'SP. KOMANDYTOWA', 'SP. K.'),'SPÓ£KA KOMANDYTOWA', 'SP. K.'),'PRZEDSIÊBIORSTWO HANDLOWO US£UGOWE','P.H.U'),'SPÓ£KA AKCYJNA','S.A.'),'SPÓ£KA Z O.O.','SP. Z O.O.'),'SPÓ£KA Z OGRANICZON¥ ODPOWIEDZIALNOŒCI¥','SP. Z O.O.'))) 
--			= TRIM(dbo.UsuwanieNieliter(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(kor_nazwa,'SP. KOMANDYTOWA', 'SP. K.'),'SPÓ£KA KOMANDYTOWA', 'SP. K.'),'PRZEDSIÊBIORSTWO HANDLOWO US£UGOWE','P.H.U'),'SPÓ£KA AKCYJNA','S.A.'),'SPÓ£KA Z O.O.','SP. Z O.O.'),'SPÓ£KA Z OGRANICZON¥ ODPOWIEDZIALNOŒCI¥','SP. Z O.O.'))) 
--		AND kodpocztowy = kor_kod_poczt
--		AND miejscowosc = kor_miejsc
--		AND ulica = kor_ulica
--		AND nrdomu = kor_dom