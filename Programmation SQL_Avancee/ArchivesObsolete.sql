CREATE PROC ArchiverEvenementsObsoletes
AS
BEGIN
    INSERT INTO HistoriqueEvenements
    SELECT *, GETUTCDATE() FROM Evenements
    WHERE PlannedEndDateUTC < GETUTCDATE() AND EventId NOT IN (SELECT EventId FROM HistoriqueEvenements);

    DELETE FROM Evenements
    WHERE PlannedEndDateUTC < GETUTCDATE();
END;