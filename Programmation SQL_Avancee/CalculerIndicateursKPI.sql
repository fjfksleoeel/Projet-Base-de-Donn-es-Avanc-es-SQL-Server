CREATE PROC CalculerIndicateursKPI
AS
BEGIN
    DECLARE 
        @TotalActive INT,
        @AvgPerDay DECIMAL(10,2),
        @AvgDuration DECIMAL(10,2),
        @TotalCams INT,
        @AvgConstr DECIMAL(10,2);

    SELECT @TotalActive = COUNT(*) FROM Evenements WHERE PlannedEndDateUTC > GETUTCDATE();
    SELECT @AvgPerDay = AVG(cnt) FROM (SELECT CAST(LastUpdatedUTC AS DATE) AS dt, COUNT(*) AS cnt FROM Evenements GROUP BY CAST(LastUpdatedUTC AS DATE)) t;
    SELECT @AvgDuration = AVG(DATEDIFF(HOUR, StartDateUTC, PlannedEndDateUTC)) FROM Evenements WHERE PlannedEndDateUTC IS NOT NULL;
    SELECT @TotalCams = COUNT(*) FROM Cameras WHERE IsActive = 1;
    SELECT @AvgConstr = AVG(cnt) FROM (SELECT CAST(PlannedStartDateUTC AS DATE) AS dt, COUNT(*) AS cnt FROM Constructions GROUP BY CAST(PlannedStartDateUTC AS DATE)) t;

    INSERT INTO Statistiques (TotalActiveEvents, AvgEventsPerDay, AvgEventDurationHours, TotalCameras, AvgActiveConstructionsPerDay)
    VALUES (@TotalActive, @AvgPerDay, @AvgDuration, @TotalCams, @AvgConstr);
END;