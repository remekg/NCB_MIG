/* **********************************************
Data : 22.07.2022
Obiekt biznesowy : Bledy
Opis : Uzupe�nianie kod�w b��d�w

**************************************************
*/ 
TRUNCATE TABLE ref.KodyBledow

INSERT INTO ref.KodyBledow (KodBledu, Nazwa)
	VALUES 
	(1, N'Liczba rekord�w'),
	(2, N'Zdublowane warto�ci'),
	(3, N'Brak kodu pocztowego w PNA'),
	(4, N'B��dna miejscowo��'),
	(5, N'B��dna ulica'),
	(6, N'Niepoprawny numer'),
	(7, N'Niepoprawny NIP'),
	(8, N'Niepoprawny PESEL'),
	(9, N'Brak identyfikatora'),
	(10, N'Brak kodu w Miejscowo�ci'),
	(11, N'Niepasuj�ca para kod pocztowy - GUS'),
	(12, N'Nieistniej�cy kod GUS'),
	(13, N'R�nica')