ALTER FUNCTION dbo.Podobienstwo
(
    @txt1 nvarchar(255),
    @txt2 nvarchar(255)
)
RETURNS decimal(4,2)
AS
BEGIN
    DECLARE @tab1 table (slowo nvarchar(255))
    DECLARE @tab2 table (slowo nvarchar(255))
    SET @txt1 = REPLACE(@txt1, N'.', N' ')
    SET @txt2 = REPLACE(@txt2, N'.', N' ')

    INSERT INTO @tab1(slowo)
    SELECT VALUE FROM STRING_SPLIT(@txt1, N' ') AS slowo

    DELETE @tab1
    WHERE len(slowo) < 3

    INSERT INTO @tab2(slowo)
    SELECT VALUE FROM STRING_SPLIT(@txt2, N' ') AS slowo

    DELETE @tab2
    WHERE len(slowo) < 3
 
    -- Wyznaczamy ilosc slow 1-ciagu
    DECLARE @l1 int = (SELECT COUNT(*) FROM @tab1)
    -- Wyznaczamy ilosc slow 2-ciagu
    DECLARE @l2 int = (SELECT COUNT(*) FROM @tab2)

    -- Wyznaczamy krotszy ciag 
    DECLARE @max int = @l1
    if @l2 > @l1
        BEGIN
        SET @max = @l2
        END

    --Wyznaczamy wyrazy podobne
    DECLARE @pod int = (SELECT COUNT(*) FROM (
        SELECT slowo FROM @tab1
        INTERSECT
        SELECT slowo FROM @tab2
    ) AS I)

    DECLARE @wynik decimal(4,2)
    SET @wynik = CAST(@pod AS DECIMAL(4,2)) / CAST(@max AS DECIMAL(4,2)) 

RETURN @wynik

END