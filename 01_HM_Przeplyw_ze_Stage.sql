/* **********************************************
Data :20.07.2022
Obiekt biznesowy : Punkty i Parner Handlowy
Opis : przeladowanie tabel ze stage i wype�nianie dodatkowych kolumn (np CzyMIG)

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
TRUNCATE TABLE NCB_MIG.hm.Stg_PPE;

INSERT INTO NCB_MIG.hm.Stg_PPE ([ppeid], [nrw_umowy], [ulica_up], [ulica_ppe], [miejscowosc_up], [miejscowosc_ppe], [gus_up], [gus_ppe], [rej_up], [rej_ppe], [ppe], [nazwa_up], [opis_ppe], [kod_pocztowy_up], [kod_pocztowy_ppe], [dom_up], [dom_ppe], [mieszk_up], [mieszk_ppe], [nr_dzialki_up], [nr_dzialki_ppe], [aktualny], [id_dostawcy], [rodzaj_umowy], [SystemZrodlowyId], [blokada], [data_blokady], [data_ost], [data_nast], [data_ost_eksp], [nr_ksiazki], [marszruta], [obwod], [zlacze], [posterunek], [lokalizacja], [przezn_lok], [typ_odbioru], [eksp_symbol], [flaga_1], [flaga_2], [flaga_3], [flaga_4], [autor], [rodzaj_up], [typ], [nrw_schematu], [nr_obcy], [klasa_up], [nrw_fpp], [zastosowanie], [stacja], nr_ukladu_pom , [Klucz_UP], [Klucz_UM], [DataImportu], CzyMIG, [PGE], [N_Systemu], [Oddzial], [Rejon])
SELECT 
	 [ppeid] = ppe.[nrw_ppe],
	 up.nrw_umowy,
	 [ulica_up] = dbo.Czyszczenie( aup.ulica),
	 [ulica_ppe] = dbo.Czyszczenie( a.ulica),
	 [miejscowosc_up] = dbo.Czyszczenie( mup.nazwa),
	 [miejscowosc_ppe] = dbo.Czyszczenie( m.nazwa),
	 [gus_up] = dbo.Czyszczenie( aup.kod_gus),
	 [gus_ppe] = dbo.Czyszczenie( a.kod_gus),
	 [rej_up] = up.rejon,
	 [rej_ppe] = ppe.nr_rejonu,
	 [ppe] = dbo.Czyszczenie( ppe.nr_ppe),
	 [nazwa_up] = dbo.Czyszczenie(up.nazwa),
	 [opis_ppe] = dbo.Czyszczenie(ppe.opis),
	 [kod_pocztowy_up] = dbo.Czyszczenie(aup.kod_pocztowy),
	 [kod_pocztowy_ppe] = dbo.Czyszczenie(a.kod_pocztowy),
	 [dom_up] = dbo.Czyszczenie(up.nr_domu),
	 [dom_ppe] = dbo.Czyszczenie(ppe.nr_domu),
	 [mieszk_up] = dbo.Czyszczenie(up.nr_lokalu),
	 [mieszk_ppe] = dbo.Czyszczenie(ppe.nr_lokalu),
	 [nr_dzialki_up] = up.nr_dzialki,
	 [nr_dzialki_ppe] = ppe.nr_dzialki,
	 ppe.aktualny,
	 ppe.id_dostawcy,
	 ppe.rodzaj_umowy,
	 ppe.SystemZrodlowyId,
	 up.blokada,
	 up.data_blokady,
	 up.data_ost,
	 up.data_nast,
	 up.data_ost_eksp,
	 up.nr_ksiazki,
	 up.marszruta,
	 up.obwod,
	 up.zlacze,
	 up.[posterunek],
     up.[lokalizacja],
     up.[przezn_lok],
     up.[typ_odbioru],
     up.[eksp_symbol],
     up.[flaga_1],
     up.[flaga_2],
     up.[flaga_3],
     up.[flaga_4],
     up.[autor],
	 up.[rodzaj_up],
     up.[typ],
     up.[nrw_schematu],
     up.[nr_obcy],
     up.[klasa_up],
     up.[nrw_fpp],
     up.[zastosowanie],
	 up.stacja,
	 up.nr_ukl_pom,
	 Klucz_UP = CONCAT(up.SystemZrodlowyId,'_',up.nr_ukl_pom),
	 Klucz_UM = CONCAT(up.SystemZrodlowyId,'_',up.nr_ukl_pom,'_',up.nrw_umowy),
	 [DataImportu] =  ppe.DataImportu,
	 CzyMIG=0,
	 PGE = NULL,
	 REPLACE(sz.NazwaSystemu,' II','') AS N_Systemu,
	 sz.Oddzial,
	 re.expression AS Rejon
FROM stage.[dbo].[HM_EwidencjaPPE] ppe
LEFT JOIN Meta.dbo.SystemyZrodlowe sz
ON ppe.SystemZrodlowyId = sz.Id
LEFT JOIN [Stage].dbo.[HM_Rejony] re
ON re.SystemZrodlowyId = ppe.SystemZrodlowyId 
	AND re.rejon_nr = ppe.nr_rejonu
LEFT JOIN Stage.[dbo].[HM_UkladPomiarowy] up
ON up.nrw_ppe = ppe.nrw_ppe
AND up.SystemZrodlowyId = ppe.SystemZrodlowyId
left join stage.dbo.HM_Adres a 
on a.nrw_adresu=ppe.nr_adresu 
and a.SystemZrodlowyId=ppe.SystemZrodlowyId
left join stage.dbo.HM_Miejscowosc m 
on m.nrw_miejscowosci =a.nrw_miejscowosci 
and a.SystemZrodlowyId =m.SystemZrodlowyId
left join stage.dbo.HM_Adres aup 
on aup.nrw_adresu=up.nr_adresu 
and aup.SystemZrodlowyId=up.SystemZrodlowyId
left join stage.dbo.HM_Miejscowosc mup 
on mup.nrw_miejscowosci =aup.nrw_miejscowosci 
and aup.SystemZrodlowyId =mup.SystemZrodlowyId

/*uzupełnianie kolumny max_data_bod*/
WITH A AS(
SELECT	f.data_bod, p.Klucz_UP
					FROM [NCB_MIG].hm.Stg_PPE p
					left join (select max(f.data_bod) data_bod, 
								nr_ukladu_pom, 
								f.SystemZrodlowyId 
						from Stage.[dbo].[HM_jp_fakturyz] f 
						group by nr_ukladu_pom, 
						f.SystemZrodlowyId) f
						on p.Klucz_UP = concat(f.SystemZrodlowyId,'_', f.nr_ukladu_pom)
					  where p.CzyMIG>0
)

UPDATE NCB_MIG.hm.Stg_PPE
SET max_data_bod = data_bod FROM A
WHERE A.Klucz_UP = hm.Stg_PPE.Klucz_UP

/*wypełnianie tabeli umów*/

TRUNCATE TABLE NCB_MIG.[hm].[Stg_Umowy]

INSERT INTO NCB_MIG.hm.Stg_Umowy([nrw_umowy], [nr_up], [platnik], [przezn_lok], [r_umowy], [id_dostawcy], [id_sprzedawcy], [data_p_ob], [data_k_ob], [taryfa], [rejon], [status_zadania], [SystemZrodlowyId], [obrot_dystrybucja], [nr_umowy], [odbiorca], [data_zaw], [nr_war_tech], [status], [symbol_konta], [zatwierdzona], [data_odcz_fin], [rodz_aneksu], [data_aneksu], [blokada], [data_wersji], [DataImportu], [nr_zest_alg], [id_sprz_rez], [r_sprz_rez], wspolna_faktura, [Klucz_UP], [Klucz_UM], [Klucz_PH], [Klucz_ODB], [N_Systemu], [Oddzial], [CzyMIG], [CzyAktywna])
SELECT	[nrw_umowy], 
		[nr_up], 
		[platnik], 
		[przezn_lok], 
		[r_umowy], 
		[id_dostawcy], 
		[id_sprzedawcy], 
		[data_p_ob], 
		[data_k_ob] = REPLACE([data_k_ob],'00000000','99991231'), 
		[taryfa], 
		[rejon], 
		[status_zadania], 
		[SystemZrodlowyId], 
		[obrot_dystrybucja], 
		[nr_umowy], 
		[odbiorca], 
		[data_zaw], 
		[nr_war_tech], 
		[status], 
		[symbol_konta], 
		[zatwierdzona], 
		[data_odcz_fin], 
		[rodz_aneksu], 
		[data_aneksu], 
		[blokada], 
		[data_wersji], 
		[DataImportu], 
		[nr_zest_alg], 
		[id_sprz_rez], 
		[r_sprz_rez],
		wspolna_faktura,
		Klucz_UP = CONCAT(um.SystemZrodlowyId,'_',um.nr_up),
		Klucz_UM = CONCAT(um.SystemZrodlowyId,'_',um.nr_up,'_',um.nrw_umowy),
		Klucz_PH = CONCAT_WS('_', um.SystemZrodlowyId, um.platnik),
		Klucz_ODB = CONCAT_WS('_', um.SystemZrodlowyId, um.odbiorca),
		REPLACE(sz.NazwaSystemu,' II','') AS N_Systemu,
		sz.Oddzial,
		CzyMIG = 0,
		CzyAktywna = 0
FROM Stage.dbo.HM_NaglowekUmowy um
LEFT JOIN Meta.dbo.SystemyZrodlowe sz
ON um.SystemZrodlowyId = sz.Id
--WHERE	((um.SystemZrodlowyId = 4
--		AND um.rejon NOT LIKE '6%') OR um.SystemZrodlowyId = 1)
--		AND status_zadania NOT IN ('8A','8X','8Z')

/*ustalenie CzyAktywna w Umowach*/

UPDATE NCB_MIG.hm.Stg_Umowy
	SET CzyAktywna = 1,
		CzyMIG = 1
WHERE	[data_k_ob] > convert(VARCHAR(8),  DataImportu, 112)
		AND [data_p_ob] <= convert(VARCHAR(8),  DataImportu, 112)
		AND ((SystemZrodlowyId = 4
		AND rejon NOT LIKE '6%') OR SystemZrodlowyId = 1)
		AND status_zadania NOT IN ('1S','1A','8A','8X','8Z') -- w przygotowaniu

/*ustalenie CzyMIG w Umowach*/

UPDATE NCB_MIG.hm.Stg_Umowy
	SET CzyMIG = 4
WHERE status_zadania IN ('1S','1A')
		AND ((SystemZrodlowyId = 4
		AND rejon NOT LIKE '6%') OR SystemZrodlowyId = 1)

UPDATE NCB_MIG.hm.Stg_Umowy
	SET CzyMIG = 2
WHERE [data_k_ob] > convert(VARCHAR(8),  DATEADD(MONTH, -18, DataImportu), 112)
		AND CzyMIG = 0
		AND ((SystemZrodlowyId = 4
		AND rejon NOT LIKE '6%') OR SystemZrodlowyId = 1)
		AND status_zadania NOT IN ('8A','8X','8Z')

/*Ustalenie Czymig w PPE*/

UPDATE NCB_MIG.hm.Stg_PPE
SET CzyMIG = 1
WHERE EXISTS (SELECT 1 FROM NCB_MIG.hm.Stg_Umowy um 
				WHERE	NCB_MIG.hm.Stg_PPE.Klucz_UM = um.Klucz_UM 
						AND um.CzyMIG > 0) 
	  OR (blokada <> 'L' 
			AND EXISTS (SELECT 1 FROM NCB_MIG.hm.Stg_Umowy um
				WHERE	NCB_MIG.hm.Stg_PPE.Klucz_UM = um.Klucz_UM
						AND ((SystemZrodlowyId = 4
							AND rejon NOT LIKE '6%') OR SystemZrodlowyId = 1)))

/*uzupełnianie CzyMIG w Umowach*/

UPDATE NCB_MIG.hm.Stg_Umowy
	SET CzyMIG = 2
	WHERE EXISTS (SELECT 1 FROM NCB_MIG.hm.Stg_PPE ppe 
					WHERE	ppe.Klucz_UM = NCB_MIG.hm.Stg_Umowy.Klucz_UM
							AND ppe.CzyMIG > 0)
			AND NCB_MIG.hm.Stg_Umowy.CzyMIG = 0

/*wypełnianie PH*/

TRUNCATE TABLE NCB_MIG.hm.Stg_PH

SELECT
*
INTO ##tmp1
FROM(SELECT platnik, SystemZrodlowyId
								FROM NCB_MIG.hm.Stg_Umowy AS up
								WHERE CzyMIG > 0
							UNION
							SELECT platnik , SystemZrodlowyId
								FROM NCB_MIG.hm.Stg_Umowy AS up
								WHERE CzyMIG > 0) A

CREATE NONCLUSTERED INDEX IX_TMP ON ##tmp1 (platnik, SystemZrodlowyId)

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
	 REPLACE(sz.NazwaSystemu,' II','') AS N_Systemu,
	 sz.Oddzial
FROM [Stage].[dbo].[HM_Klienci] kl
LEFT JOIN Meta.dbo.SystemyZrodlowe sz
ON kl.SystemZrodlowyId = sz.Id
LEFT JOIN Stage.dbo.HM_AdresKoresp ak
ON ak.nr_kontrahenta = kl.nrw_kontrahenta
AND ak.SystemZrodlowyId = kl.SystemZrodlowyId
WHERE EXISTS (SELECT 1 FROM ##tmp1 
				WHERE	kl.SystemZrodlowyId = ##tmp1.SystemZrodlowyId
						AND kl.nrw_kontrahenta = ##tmp1.platnik) 
	OR EXISTS(SELECT 1  FROM [Stage].[dbo].[HM_Rozrachunki] r
				WHERE r.SystemZrodlowyId = kl.SystemZrodlowyId 
						AND r.nr_kontrah = kl.nrw_kontrahenta) 

DROP TABLE IF EXISTS ##tmp1;

--JOIN Stage.dbo.HM_NaglowekUmowy um
--ON um.nrw_umowy = up.nrw_umowy
--AND um.SystemZrodlowyId = up.SystemZrodlowyId
--AND um.nr_up = up.nr_ukl_pom
--WHERE (	
--								um.[data_k_ob] = '00000000'
--								OR um.[data_k_ob] > convert(VARCHAR(8), DATEADD(MONTH, -18, GETDATE()), 112)
--								)
--							AND um.[data_p_ob] <> '00000000'

UPDATE NCB_MIG.hm.Stg_PH
SET PGE = NULL

SELECT * 
INTO ##aktywni 
FROM (
SELECT Klucz_PH AS PH
FROM NCB_MIG.hm.Stg_Umowy um
WHERE CzyAktywna = 1
UNION
SELECT Klucz_ODB AS PH
FROM NCB_MIG.hm.Stg_Umowy um
WHERE CzyAktywna = 1) A;

UPDATE NCB_MIG.hm.Stg_PH
SET CzyMIG = 1
WHERE EXISTS (SELECT 1 FROM ##aktywni ak WHERE Klucz_PH = ak.PH)

DROP TABLE IF EXISTS ##aktywni
;

SELECT * 
INTO ##aktywni18 
FROM (
SELECT Klucz_PH AS PH
FROM NCB_MIG.hm.Stg_Umowy um
WHERE CzyMIG > 1
UNION
SELECT Klucz_ODB AS PH
FROM NCB_MIG.hm.Stg_Umowy um
WHERE CzyMIG > 1) A;

UPDATE NCB_MIG.hm.Stg_PH
SET CzyMIG = 2
WHERE EXISTS (SELECT 1 FROM ##aktywni18 ak WHERE Klucz_PH = ak.PH)
AND CzyMIG = 0

DROP TABLE IF EXISTS ##aktywni18;

UPDATE NCB_MIG.hm.Stg_PH
SET CzyMIG = 3 
WHERE EXISTS(SELECT 1  FROM [Stage].[dbo].[HM_Rozrachunki] r
				WHERE r.SystemZrodlowyId = NCB_MIG.hm.Stg_PH.SystemZrodlowyId 
						AND r.nr_kontrah = NCB_MIG.hm.Stg_PH.nrpl) 
AND Czymig = 0

--Wypelnianie kolumny PGE w PPE informacją o przypisanie danych do obszaru (O, D i OD) zalożenia:
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
----Wypelnianie kolumny PGE w PH informacją o przypisanie danych do obszaru (O, D i OD)
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

--uzupełnienie obecności w bazach działalności gospodarczej

UPDATE NCB_MIG.hm.Stg_PH
SET CEIDG = 1
WHERE EXISTS(SELECT 1 FROM ref.FIRMY f WHERE f.NIP = REPLACE(NCB_MIG.hm.Stg_PH.nip,'-',''))
;

--ustalenie typu 1-osoba fizyczna , 2-firma, 3-grupa. Pole ty_konsumenta 1-konsument, 2-quasi-konsument, 3-niekonsument 

--PO CEIDG
UPDATE NCB_MIG.hm.Stg_PH
	SET SUGEROWANY_TYP = 2
	WHERE 1=1 
	--AND(typ_konsumenta > 1 OR typ_konsumenta = 0) 
	AND CEIDG = 1
	AND SUGEROWANY_TYP IS NULL 
	AND CzyMIG > 0

--PO FUNKCJI dbo.CzyFirma
UPDATE NCB_MIG.hm.Stg_PH
	SET SUGEROWANY_TYP = 2
	WHERE CzyMIG > 0
	AND SUGEROWANY_TYP IS NULL 
	--AND (typ_konsumenta > 1 OR typ_konsumenta = 0)	
	AND dbo.CzyFirma(regon, nazwa) = 2

--PO Funkcji [dbo].[CzyOsobalubGrupa]
UPDATE NCB_MIG.hm.Stg_PH
	SET SUGEROWANY_TYP = [dbo].[CzyOsobalubGrupa](nazwa)
	WHERE CzyMIG > 0
	-- AND (typ_konsumenta = 1 OR typ_konsumenta = 0) 
	AND SUGEROWANY_TYP IS NULL 
		
--UPDATE NCB_MIG.hm.Stg_PH
--SET SUGEROWANY_TYP = 
--		CASE WHEN (typ_konsumenta > 1 OR typ_konsumenta = 0) AND CEIDG = 1
--				THEN 2
--			WHEN dbo.CzyFirma(regon, nazwa, typ_konsumenta) = 2 THEN 2
--			WHEN (typ_konsumenta = 1 OR typ_konsumenta = 0) AND CEIDG IS NULL 
--				THEN [dbo].[CzyOsobalubGrupa](nazwa)			
--			ELSE 4
--	END

/*korekta kod ow pocztowych w PH*/

UPDATE NCB_MIG.hm.Stg_PH
	SET kodpocztowy = CONCAT(LEFT(kodpocztowy,2),'-',RIGHT(kodpocztowy,3))
	WHERE kodpocztowy LIKE '[0-9][0-9][0-9][0-9][0-9]'
UPDATE NCB_MIG.hm.Stg_PH
	SET [kor_kod_poczt] = CONCAT(LEFT([kor_kod_poczt] ,2),'-',RIGHT([kor_kod_poczt] ,3))
	WHERE [kor_kod_poczt] LIKE '[0-9][0-9][0-9][0-9][0-9]'

/*korygowanie kodów pocztowych w PPE*/

UPDATE NCB_MIG.hm.Stg_PPE
	SET kod_pocztowy_ppe = CONCAT(LEFT(kod_pocztowy_ppe,2),'-',RIGHT(kod_pocztowy_ppe,3))
	WHERE kod_pocztowy_ppe LIKE '[0-9][0-9][0-9][0-9][0-9]'
UPDATE NCB_MIG.hm.Stg_PPE
	SET kod_pocztowy_up = CONCAT(LEFT(kod_pocztowy_up ,2),'-',RIGHT(kod_pocztowy_up ,3))
	WHERE kod_pocztowy_up LIKE '[0-9][0-9][0-9][0-9][0-9]'
/*ustalenie PGE z Umów*/

UPDATE NCB_MIG.hm.Stg_PPE
SET PGE = obrot_dystrybucja 
FROM hm.Stg_Umowy um 
WHERE um.Klucz_UM = NCB_MIG.hm.Stg_PPE.Klucz_UM

--UPDATE hm.stg_PH
--SET ZGODNY_KORESP = 1
--WHERE 	len(kor_nazwa) > 0	
--		AND TRIM(dbo.UsuwanieNieliter(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(nazwa,'SP. KOMANDYTOWA', 'SP. K.'),'SPӣKA KOMANDYTOWA', 'SP. K.'),'PRZEDSI�BIORSTWO HANDLOWO US�UGOWE','P.H.U'),'SPӣKA AKCYJNA','S.A.'),'SPӣKA Z O.O.','SP. Z O.O.'),'SPӣKA Z OGRANICZON� ODPOWIEDZIALNO�CI�','SP. Z O.O.'))) 
--			= TRIM(dbo.UsuwanieNieliter(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(kor_nazwa,'SP. KOMANDYTOWA', 'SP. K.'),'SPӣKA KOMANDYTOWA', 'SP. K.'),'PRZEDSI�BIORSTWO HANDLOWO US�UGOWE','P.H.U'),'SPӣKA AKCYJNA','S.A.'),'SPӣKA Z O.O.','SP. Z O.O.'),'SPӣKA Z OGRANICZON� ODPOWIEDZIALNO�CI�','SP. Z O.O.'))) 
--		AND kodpocztowy = kor_kod_poczt
--		AND miejscowosc = kor_miejsc
--		AND ulica = kor_ulica
--		AND nrdomu = kor_dom