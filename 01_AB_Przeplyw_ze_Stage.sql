--CREATE NONCLUSTERED INDEX I_X01 ON NCB_MIG.en.Stg_PH (kodpocztowy)
--CREATE NONCLUSTERED INDEX I_X02 ON NCB_MIG.en.Stg_PH (KOR_kod_poczt) INCLUDE (koresp) WHERE Czymig > 0 
--CREATE CLUSTERED INDEX I_X03 ON NCB_MIG.en.Stg_PH (Klucz_PH)
--CREATE NONCLUSTERED INDEX I_X04 ON NCB_MIG.dbo.TERYT_PNA (PNA)
--CREATE NONCLUSTERED INDEX I_X05 ON NCB_MIG.dbo.TERYT_PNA (TERYT_MIEJ_NAZWA)
--CREATE NONCLUSTERED INDEX I_X06 ON NCB_MIG.en.Stg_PPE (kod_p)
--CREATE NONCLUSTERED INDEX I_X07 ON NCB_MIG.en.Stg_PPE (Klucz_PH)
--CREATE NONCLUSTERED INDEX I_X08 ON NCB_MIG.en.Stg_PPE (miejscowosc)
--CREATE NONCLUSTERED INDEX I_X09 ON NCB_MIG.en.Stg_PH (miejscowosc)

--TRUNCATE TABLE NCB_MIG.ab.Stg_PH

SELECT
	 [ID_PLATNIKA] = dbo.Czyszczenie([ID_PLATNIKA]),
	 [NR_EWIDENCYJNY] = dbo.Czyszczenie( [NR_EWIDENCYJNY]),
	 [nazwa] = dbo.Czyszczenie( kl.nazwa),
	 [ADRES] = dbo.Czyszczenie([ADRES]),
	 --[ulica] = dbo.Czyszczenie( [ulica]),
	 [kodpocztowy] = dbo.Czyszczenie( CONCAT_WS('-',LEFT([KOD_POCZTOWY],2),RIGHT([KOD_POCZTOWY],3))),
	 [miejscowosc] = dbo.Czyszczenie( [NAZWA_MIEJSCOWOSCI]),
	 [poczta] = dbo.Czyszczenie( [poczta]),
	 --[nrdomu] = dbo.Czyszczenie( [nrdomu]),
	 --[nrmieszkania] = dbo.Czyszczenie( [nrmieszkania]),
	 [gus] = dbo.Czyszczenie([KOD_GUS_MIEJCOW]),
	 [nrrejonu] = dbo.Czyszczenie([REJON]),
	 [SystemZrodlowyId] =  [SystemZrodlowyId],
	 --[GrPlatnikow] =  [GrPlatnikow],
	 [full_konto_ze] = dbo.Czyszczenie( [Numer_Konta_Bankowego]),
	 --[kor_dom] = dbo.Czyszczenie( [kor_dom]),
	 [kor_kod_poczt] = dbo.Czyszczenie( CONCAT_WS('-',LEFT([Kod_miejscow_kores],2),RIGHT([Kod_miejscow_kores],3))),
	 [Adres_kores] = dbo.Czyszczenie([Adres_kores]),
	 [kor_miejsc] = dbo.Czyszczenie( [NAZWA_MIEJSCOWOSCI_KORES]),
	 --[kor_mieszk] = dbo.Czyszczenie( [kor_mieszk]),
	 --[kor_poczta] = dbo.Czyszczenie( [kor_poczta]),
	 --[kor_ulica] = dbo.Czyszczenie( [kor_ulica]),
	 [mail] = dbo.Czyszczenie( [Reprezentant_EMAIL]),
	 [telefon] = dbo.Czyszczenie([Nr_telefonu]),
	 [telefon2] = dbo.Czyszczenie([Nr_telefonu2]),
	 --[SKROT] = dbo.Czyszczenie( [SKROT]),
	 [koresp] = dbo.Czyszczenie([Nazwa_platnika_kores]),
	 [DataImportu] =  [DataImportu],
	 --[kor_nazwa] = replace(replace(replace(dbo.Czyszczenie( [kor_nazwa]),'--','*'),'*-','*'),'*',''),
	 --[typ_konsumenta] =  [typ_konsumenta],
	 --[typ_konsumenta_data] =  [typ_konsumenta_data],
	 --[jr] =  [jr],
	 --[skasowany] =  [skasowany],
	-- Klucz_PH = CONCAT_WS('_', SystemZrodlowyId, jr , nrpl),
	 CzyMIG = 0,
	 PGE = NULL,
	 sz.NazwaSystemu AS N_Systemu,
	 sz.Oddzial
FROM Stage.dbo.AB_Klienci kl
LEFT JOIN Meta.dbo.SystemyZrodlowe sz
ON kl.SystemZrodlowyId = sz.Id