CREATE TRIGGER TR_HistoriqueEvenements
ON Evenements
AFTER UPDATE, DELETE
AS
BEGIN
    INSERT INTO HistoriqueEvenements (EventId, Source, Highway, Direction, Description, StartDateUTC, LastUpdatedUTC, PlannedStartDateUTC, PlannedEndDateUTC, EventType, Latitude, Longitude, Region, Organization)
    SELECT d.EventId, d.Source, d.Highway, d.Direction, d.Description, d.StartDateUTC, d.LastUpdatedUTC, d.PlannedStartDateUTC, d.PlannedEndDateUTC, d.EventType, d.Latitude, d.Longitude, d.Region, d.Organization
    FROM deleted d;
END;