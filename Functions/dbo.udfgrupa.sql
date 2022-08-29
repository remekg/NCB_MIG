ALTER FUNCTION dbo.udfgrupa
(
    @nazwa nvarchar(255),
    @pesel nvarchar(255),
    @delimiter nchar(1)
)
/*
Funkcja zwraca na podstawie nazwy oraz pesela osoby fizyczne z przypisanym peselem
*/

RETURNS @grupa TABLE (
    first_name_1 nvarchar(80)
    ,last_name_1 nvarchar(80)
    ,pesel_1 nvarchar(12)
    ,first_name_2 nvarchar(80)
    ,last_name_2 nvarchar(80)
    ,pesel_2 nvarchar(12)
)
AS
BEGIN
    DECLARE @tab1 TABLE(nr int identity, imie nvarchar(255), oznaczenie nvarchar(255), plec nchar(1))
    SET @nazwa = REPLACE(REPLACE(REPLACE(@nazwa, N' i ', N' '), N',', N' '),N' - ',N'-');
    SET @nazwa = dbo.spacje(@nazwa);
    DECLARE @start INT = 1;
    DECLARE @end INT = CHARINDEX(@delimiter, @nazwa)
	DECLARE @tab2 TABLE (pesel nchar(11), plec nchar(1))

    --Napełnianie tabeli pomocniczej
    WHILE @start < LEN(@nazwa) + 1
        BEGIN
            IF @end = 0
                SET @end = LEN(@nazwa) + 1
            INSERT INTO @tab1 (imie)
            VALUES(SUBSTRING(@nazwa, @start, @end - @start))
            SET @start = @end + 1
            SET @end = CHARINDEX(@delimiter, @nazwa, @start)
        END

    SET @pesel = REPLACE(@pesel, N' ', N',')

	INSERT INTO @tab2(pesel)
	SELECT VALUE FROM STRING_SPLIT(@pesel, N',')

    DELETE @tab2
    WHERE dbo.pesel(pesel) <> 1

    UPDATE @tab2
    SET PLEC = 
     CASE 
       WHEN CAST(SUBSTRING(pesel,10,1) AS INT) % 2 = 1 THEN 'M'
       WHEN CAST(SUBSTRING(pesel,10,1) AS INT) % 2 = 0 THEN 'K'
     END

    --Przygotowanie tabeli pomocniczej
    DELETE @tab1
    WHERE LEN(imie) < 3

    --Dopisanie czy imie czy nazwisko
  UPDATE @tab1
    SET Oznaczenie = 
    CASE
        WHEN imie in (SELECT imie from ref.Imiona ) Then N'Imie'
        WHEN imie in (SELECT nazwisko from ref.Nazwiska ) Then N'Nazwisko'
        ELSE N'Inne'
    END,
    PLEC = (SELECT TOP 1 plec from ref.Imiona AS I WHERE I.imie = imie)

DECLARE @i int = (SELECT COUNT(*) FROM @tab1 WHERE Oznaczenie = N'Imie')
DECLARE @n int = (SELECT COUNT(*) FROM @tab1 WHERE Oznaczenie = N'Nazwisko')
DECLARE @x int = (SELECT COUNT(*) FROM @tab1 WHERE Oznaczenie = N'Inne')

--Usuwanie innych slow 
IF @n > 0 and @x > 0
    DELETE @tab1
    WHERE Oznaczenie = N'Inne'

IF @n = 0 and @x = 0
--Wyszukanie nazwiska z imion
WITH A AS
(
    SELECT TOP 1 Imie , Oznaczenie
    FROM @tab1
    WHERE imie in (SELECT nazwisko from ref.Nazwiska)
    ORDER BY nr desc
)
UPDATE A 
    SET Oznaczenie = N'Nazwisko'
--Przeliczenie ilości nazwisk i imion
SET @n = (SELECT COUNT(*) FROM @tab1 WHERE Oznaczenie = N'Nazwisko')
SET @i = (SELECT COUNT(*) FROM @tab1 WHERE Oznaczenie = N'Imie')
DECLARE @p INT = (SELECT COUNT(DISTINCT PLEC) FROM @tab1 WHERE Oznaczenie = N'Imie')


DECLARE @n1 NVARCHAR(80) = (SELECT TOP 1 imie FROM @tab1
WHERE oznaczenie = N'Nazwisko'
ORDER by nr)

DELETE @tab1
WHERE Imie = @n1

DECLARE @n2 NVARCHAR(80) = COALESCE(
    (SELECT TOP 1 imie FROM @tab1
    WHERE oznaczenie = N'Nazwisko' order by nr), @n1
)

DELETE @tab1
WHERE Imie = @n2

DECLARE @i1 NVARCHAR(80) = (SELECT TOP 1 imie FROM @tab1
WHERE oznaczenie = N'Imie')
DECLARE @p1 NCHAR(1) = (SELECT TOP 1 plec from ref.Imiona AS I WHERE I.imie = @i1)
DELETE @tab1
WHERE Imie = @i1

DECLARE @i2 NVARCHAR(80) = (SELECT TOP 1 imie FROM @tab1
WHERE oznaczenie = N'Imie')
DECLARE @p2 NCHAR(1) = (SELECT TOP 1 plec from ref.Imiona AS I WHERE I.imie = @i2)

DELETE @tab1
WHERE Imie = @i2

DECLARE @pesel_1 nvarchar(11)
DECLARE @pesel_2 nvarchar(11)

IF @pesel IS NOT NULL AND @p1 <> @p2
    BEGIN
       SET @pesel_1 = (SELECT TOP 1 Pesel FROM @tab2 WHERE plec = @p1)
       SET @pesel_2 = (SELECT TOP 1 Pesel FROM @tab2 WHERE plec = @p2)
    END
INSERT INTO @grupa(
    first_name_1 
    ,last_name_1 
    ,pesel_1 
    ,first_name_2 
    ,last_name_2 
    ,pesel_2 
)
VALUES(
    @i1, @n1, @pesel_1, @i2, @n2, @pesel_2
)

RETURN
END