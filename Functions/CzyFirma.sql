USE [NCB_MIG]
GO

/****** Object:  UserDefinedFunction [dbo].[CzyFirma]    Script Date: 2022-08-25 07:44:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[CzyFirma]
(
    @regon nvarchar(255), @nazwa nvarchar(255)
)
--Funkcja przyjmuje wartość 2 jeśli to jest firma
RETURNS int 
AS
BEGIN
    DECLARE @wynik int = 0
    DECLARE @tab TABLE (slowo nvarchar(255))
    DECLARE @pom int = 0
	DECLARE @x int = 0
    DECLARE @n int = 0
    
    
    
        
    --REGON 
    IF LEN(@regon)=9 OR LEN(@regon)=14
        BEGIN
            SET @wynik = 2
        END 
    --NAZWA
    IF @wynik = 0
        BEGIN


            INSERT INTO @tab (slowo) 
            SELECT VALUE FROM STRING_SPLIT(@nazwa, ' ')
           
            SET @pom = (SELECT COUNT(*) FROM @tab 
            WHERE slowo IN (N'Spółka', N'Przedsiębiorstwo', N'Sp.', N'P.H.',
            N'Oddział', N'Związek', N'Pomocy', N'Zakład', N'Stowarzyszenie',
            N'Wydawnictwo',N'Lunapark', N'Ośrodek', N'Szkoła', N'Przedszkole', N'Zgromadzenie', 
            N'Placówka','Spółdzielnia', N'Dyrekcja', N'Gospodarstwo')
            )
            
            SET @n = 
            (SELECT COUNT(DISTINCT slowo) FROM @tab AS T 
            JOIN ref.Nazwiska AS N on T.slowo = N.Nazwisko)

            SET @x = (SELECT COUNT(*) FROM @tab AS T 
            LEFT JOIN ref.Nazwiska AS N on T.slowo = N.Nazwisko
            WHERE N.plec IS NULL)

            IF @x > @n and @pom > 1
                SET @wynik = 2

        END  
         
RETURN @wynik
END
GO



