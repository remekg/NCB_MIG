USE [NCB_MIG]
GO

CREATE TABLE [en].[Stg_PH](
	[nrpl] [nvarchar](255) NULL,
	[nip] [nvarchar](255) NULL,
	[regon] [nvarchar](255) NULL,
	[pesel] [nvarchar](255) NULL,
	[nazwa] [nvarchar](255) NULL,
	[ulica] [nvarchar](255) NULL,
	[kodpocztowy] [nvarchar](255) NULL,
	[miejscowosc] [nvarchar](255) NULL,
	[poczta] [nvarchar](255) NULL,
	[nrdomu] [nvarchar](255) NULL,
	[nrmieszkania] [nvarchar](255) NULL,
	[gus] [nvarchar](255) NULL,
	[nrrejonu] [nvarchar](255) NULL,
	[SystemZrodlowyId] [tinyint] NULL,
	--[GrPlatnikow] [int] NULL,
	--[full_konto_ze] [nvarchar](255) NULL,
	[kor_dom] [nvarchar](255) NULL,
	[kor_kod_poczt] [nvarchar](255) NULL,
	[kor_miejsc] [nvarchar](255) NULL,
	[kor_mieszk] [nvarchar](255) NULL,
	[kor_poczta] [nvarchar](255) NULL,
	[kor_ulica] [nvarchar](255) NULL,
	
    [mail] [nvarchar](255) NULL,
	[telefon] [nvarchar](255) NULL,
	
    [SKROT] [nvarchar](255) NULL,
	[koresp] [nvarchar](255) NULL,
	[DataImportu] [datetime] NULL,
	[kor_nazwa] [nvarchar](255) NULL,
	[typ_konsumenta] [int] NULL,
	[typ_konsumenta_data] [datetime] NULL,
	[jr] [int] NULL,
	[skasowany] [int] NULL,
	[Klucz_PH] [nvarchar](255) NOT NULL,
	[CzyMIG] [int] NULL,
	[PGE] [nvarchar](2) NULL,
	[N_Systemu] [nvarchar](255) NULL,
	[Oddzial] [nvarchar](255) NULL,
	[TERYT_MIEJSCOWOSC] [nvarchar](255) NULL,
	[KOR_TERYT_MIEJSCOWOSC] [nvarchar](255) NULL,
	[TERYT_MIEJSCOWOSC_POD] [nvarchar](255) NULL,
	[KOR_TERYT_MIEJSCOWOSC_POD] [nvarchar](255) NULL,
	[KRAJ] [nvarchar](2) NULL,
	[KOR_KRAJ] [nvarchar](2) NULL,
	[TERYT_ULICY] [nvarchar](255) NULL,
	[KOR_TERYT_ULICY] [nvarchar](255) NULL,
	[KOD_POCZTOWY_POP] [nvarchar](255) NULL,
	[CEIDG] [smallint] NULL,
	[SUGEROWANY_TYP] [smallint] NULL,
	[MIEJSCOWOSC_CLR] [nvarchar](255) NULL,
	[ULICE_CLR] [nvarchar](255) NULL,
	[KOR_MIEJSCOWOSC_CLR] [nvarchar](255) NULL,
	[KOR_ULICE_CLR] [nvarchar](255) NULL,
	[KOR_KOD_POCZTOWY_POP] [nvarchar](255) NULL,
	[email_pop] [nvarchar](150) NULL,
	[ZGODNY_KORESP] [int] NULL,
	[do_koresp] [tinyint] NULL,
	[Grupa_Checksum] [nvarchar](255) NULL
) 
GO
