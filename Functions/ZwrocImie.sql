CREATE FUNCTION dbo.ZwrocImie
(
    @name nvarchar(255),
    @delimiter nchar(1)
)

RETURNS @osoba TABLE(
    NAMEFIRST nvarchar(40),
    NAMEMIDDLE nvarchar(40),
    NAMELAST nvarchar(40)
 )

AS
BEGIN
DECLARE @wynik nvarchar(40) = N''
DECLARE @nazwa nvarchar(255) = N''
DECLARE @tab1 TABLE (nr int identity, imie nvarchar(255), oznaczenie nvarchar(255))
DECLARE @start INT = 1, @end INT

SET @nazwa = REPLACE(@name, N' - ', N'-')
SET @end = CHARINDEX(@delimiter, @nazwa)

WHILE @start < LEN(@nazwa) + 1
    BEGIN
        IF @end = 0
            SET @end = LEN(@nazwa) + 1
        INSERT INTO @tab1 (imie)
        VALUES(SUBSTRING(@nazwa, @start, @end-@start))
        SET @start = @end + 1
        SET @end = CHARINDEX(@delimiter, @nazwa, @start)
    END

DELETE @tab1
WHERE LEN(imie) < 2

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


IF @n = 0 and @x = 0

WITH A AS
(
    SELECT TOP 1 Imie 
    FROM @tab1
    WHERE imie in (SELECT nazwisko from ref.Nazwiska)
    ORDER BY nr desc
)
UPDATE @tab1 
    SET Oznaczenie = N'Nazwisko'
    WHERE imie = A.Imie

SET @n = (SELECT COUNT(*) FROM @tab1 WHERE Oznaczenie = N'Nazwisko')
SET @i = (SELECT COUNT(*) FROM @tab1 WHERE Oznaczenie = N'Imie')



DECLARE @nf nvarchar(40), @nm nvarchar(40), @nl nvarchar(40)

IF @n > 0
    SET @nl = (SELECT STRING_AGG(imie, ' ') FROM @tab1 WHERE Oznaczenie = 'Nazwisko')
ELSE
    IF @x > 0 
        SET @nl = (SELECT STRING_AGG(imie, ' ') FROM @tab1 WHERE Oznaczenie = 'Inne')
    ELSE 
        SET @nl = (SELECT TOP 1 imie from @tab1 WHERE Oznaczenie = 'Imie' order by nr desc)

DELETE @tab1
WHERE imie = @nl
    
SET @nf = (SELECT TOP 1 imie from @tab1 WHERE Oznaczenie = 'Imie' order by nr)

DELETE @tab1
WHERE imie = @nf

SET @nm = (SELECT TOP 1 imie from @tab1 WHERE Oznaczenie = 'Imie' order by nr)


INSERT INTO @osoba (NAMEFIRST, NAMEMIDDLE, NAMELAST)
VALUES (@nf, @nm, @nl)

RETURN ;
END
