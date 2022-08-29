USE [NCB_MIG]
GO

/****** Object:  UserDefinedFunction [dbo].[CzyOsobalubGrupa]    Script Date: 2022-08-24 12:48:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[CzyOsobalubGrupa]
(
    @name nvarchar(255)
)

RETURNS INT
AS
BEGIN
    
    DECLARE @tab1 table (imie nvarchar(255))
    DECLARE @m int = 0
    DECLARE @k int = 0
    DECLARE @n int = 0
    DECLARE @wynik int = 0
	DECLARE @i int = 0

    INSERT INTO @tab1 (imie)
        SELECT VALUE FROM STRING_SPLIT(@name, N' ')

    SET @m = (SELECT COUNT(DISTINCT I.imie)
    FROM @tab1 AS T 
    JOIN ref.Imiona AS I 
        on T.imie = I.IMIE 
        AND I.PLEC = N'M'
    )

    SET @k = (SELECT COUNT(DISTINCT I.imie)
    FROM @tab1 AS T 
    JOIN ref.Imiona AS I 
        on T.imie = I.IMIE 
        AND I.PLEC = N'K'
    )

    SET @n = (SELECT COUNT(DISTINCT T.imie)
    FROM @tab1 AS T 
    LEFT JOIN ref.Imiona AS I 
        on T.imie = I.IMIE 
        WHERE I.PLEC IS NULL AND LEN(t.imie) > 2
    )

	SET @i = (SELECT COUNT(*)
	FROM @tab1 AS T
	WHERE T.imie = 'I')

    IF @m > 0 and @k > 0 and @n > 0
        SET @wynik = 3
    ELSE
		IF (@m > 1 or @k > 1) and @i > 0
			SET @wynik = 3
		ELSE
			IF @m > 0 or @k > 0 
        SET @wynik = 1 
    
RETURN @wynik
END
GO

