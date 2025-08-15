CREATE FUNCTION fn_NombreEvenementsParJour (@Date DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM Evenements
    WHERE CAST(StartDateUTC AS DATE) = @Date;
    RETURN @Count;
END;