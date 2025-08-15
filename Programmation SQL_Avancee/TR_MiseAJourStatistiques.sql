CREATE TRIGGER TR_MiseAJourStatistiques
ON Evenements
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    EXEC CalculerIndicateursKPI;
END;