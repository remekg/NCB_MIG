USE NCB_MIG;

UPDATE [en].[Stg_PH]
SET email_pop = [dbo].[email](mail)
WHERE 1=1
AND CzyMIG > 0
AND mail IS NOT NULL 
AND mail <> N''

--Wyliczenie pola Grupa_Checksum dla grup
UPDATE en.Stg_PH 
SET Grupa_Checksum = 
    CONVERT(
        NVARCHAR(255)
        ,HASHBYTES(
            'SHA2_512'
            ,CONCAT_WS(
                '|', nazwa, ulica, kodpocztowy, miejscowosc, poczta
                , nrdomu, nrmieszkania
            )
        )
        ,2
    )
WHERE CzyMig > 0
AND SUGEROWANY_TYP = 3