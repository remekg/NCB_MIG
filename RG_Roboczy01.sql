CREATE TABLE ##rg
(	
	a int identity(1,1)
	, klucz_ph nvarchar(255)
	, nazwa_cz nvarchar(255)
	, ile int
)

insert into ##rg
(nazwa_cz)
select value from string_split('Firma Kowalska "Wariat"', ' ')
, 'GFHGYTR', 
        SUM(len(nazwa_cz) + 1) OVER(order by a ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ile

SELECT * FROM ##rg
WITH A AS
(
SELECT a, nazwa_cz, ile,
SUM(len(nazwa_cz) + 1) OVER(order by a ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ile_1
FROM ##rg
)
UPDATE A
	SET ile = ile_1

SELECT *
FROM ##rg
--DROP TABLE ##rg