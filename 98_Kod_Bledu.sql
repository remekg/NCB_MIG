/* **********************************************
Data : 22.07.2022
Obiekt biznesowy : Bledy
Opis : Uzupe³nianie kodów b³êdów

**************************************************
*/ 
TRUNCATE TABLE ref.KodyBledow

INSERT INTO ref.KodyBledow (KodBledu, Nazwa)
	VALUES 
	(1, N'Liczba rekordów'),
	(2, N'Zdublowane wartoœci'),
	(3, N'Brak kodu pocztowego w PNA'),
	(4, N'B³êdna miejscowoœæ'),
	(5, N'B³êdna ulica'),
	(6, N'Niepoprawny numer'),
	(7, N'Niepoprawny NIP'),
	(8, N'Niepoprawny PESEL'),
	(9, N'Brak identyfikatora'),
	(10, N'Brak kodu w Miejscowoœci'),
	(11, N'Niepasuj¹ca para kod pocztowy - GUS'),
	(12, N'Nieistniej¹cy kod GUS'),
	(13, N'Ró¿nica')