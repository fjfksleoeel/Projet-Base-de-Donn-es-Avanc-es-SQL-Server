CREATE OR ALTER PROC ImporterDonneesDepuisTemp
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Type VARCHAR(50);
    DECLARE @Count INT;
    DECLARE @ErrorMessage NVARCHAR(500);

    -- ====================================================
    -- 1. IMPORT : EVENEMENTS
    -- ====================================================
    SET @Type = 'evenements';

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Vider la table temporaire
        DELETE FROM Temp_Evenements;

        -- BULK INSERT depuis le fichier CSV
        BULK INSERT Temp_Evenements
        FROM 'C:\Ontario511_Data\evenements_ontario_511.csv'
        WITH (
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            FIRSTROW = 2,
            CODEPAGE = '65001',
            KEEPNULLS,
            TABLOCK
        );

        -- MERGE vers la table finale
        MERGE Evenements AS target
        USING Temp_Evenements AS source
            ON target.EventId = source.EventId
        WHEN MATCHED THEN
            UPDATE SET
                Source = source.Source,
                Highway = source.Highway,
                Direction = source.Direction,
                Description = source.Description,
                StartDateUTC = source.StartDateUTC,
                LastUpdatedUTC = source.LastUpdatedUTC,
                PlannedStartDateUTC = source.PlannedStartDateUTC,
                PlannedEndDateUTC = source.PlannedEndDateUTC,
                EventType = source.EventType,
                Latitude = source.Latitude,
                Longitude = source.Longitude,
                Region = source.Region,
                Organization = source.Organization
        WHEN NOT MATCHED THEN
            INSERT (EventId, Source, Highway, Direction, Description,
                    StartDateUTC, LastUpdatedUTC, PlannedStartDateUTC, PlannedEndDateUTC,
                    EventType, Latitude, Longitude, Region, Organization)
            VALUES (
                source.EventId, source.Source, source.Highway, source.Direction, source.Description,
                source.StartDateUTC, source.LastUpdatedUTC, source.PlannedStartDateUTC, source.PlannedEndDateUTC,
                source.EventType, source.Latitude, source.Longitude, source.Region, source.Organization
            );

        SET @Count = @@ROWCOUNT;
        INSERT INTO LogsExecution (DataType, RecordCount, Status)
        VALUES (@Type, @Count, 'Success');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ErrorMessage = ERROR_MESSAGE();
        INSERT INTO LogsExecution (DataType, RecordCount, Status, ErrorMessage)
        VALUES (@Type, 0, 'Error', LEFT(@ErrorMessage, 500));
    END CATCH


    -- ====================================================
    -- 2. IMPORT : CONSTRUCTIONS
    -- ====================================================
    SET @Type = 'constructions';

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM Temp_Constructions;

        BULK INSERT Temp_Constructions
        FROM 'C:\Ontario511_Data\constructions_ontario_511.csv'
        WITH (
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            FIRSTROW = 2,
            CODEPAGE = '65001',
            KEEPNULLS,
            TABLOCK
        );

        -- MERGE vers Constructions (lien avec Evenements via WorkId = EventId ? ou indépendant)
        -- Ici, on suppose que WorkId est unique et indépendant
        MERGE Constructions AS target
        USING Temp_Constructions AS source
            ON target.WorkId = source.WorkId
        WHEN MATCHED THEN
            UPDATE SET
                Highway = source.Highway,
                Direction = source.Direction,
                Description = source.Description,
                PlannedStartDateUTC = source.PlannedStartDateUTC,
                PlannedEndDateUTC = source.PlannedEndDateUTC,
                Status = source.Status
        WHEN NOT MATCHED THEN
            INSERT (WorkId, EventId, Highway, Direction, Description,
                    PlannedStartDateUTC, PlannedEndDateUTC, Status)
            VALUES (
                source.WorkId, source.WorkId, source.Highway, source.Direction, source.Description,
                source.PlannedStartDateUTC, source.PlannedEndDateUTC, source.Status
            );

        SET @Count = @@ROWCOUNT;
        INSERT INTO LogsExecution (DataType, RecordCount, Status)
        VALUES (@Type, @Count, 'Success');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ErrorMessage = ERROR_MESSAGE();
        INSERT INTO LogsExecution (DataType, RecordCount, Status, ErrorMessage)
        VALUES (@Type, 0, 'Error', LEFT(@ErrorMessage, 500));
    END CATCH


    -- ====================================================
    -- 3. IMPORT : CAMERAS
    -- ====================================================
    SET @Type = 'cameras';

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM Temp_Cameras;

        BULK INSERT Temp_Cameras
        FROM 'C:\Ontario511_Data\cameras_ontario_511.csv'
        WITH (
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            FIRSTROW = 2,
            CODEPAGE = '65001',
            KEEPNULLS,
            TABLOCK
        );

        MERGE Cameras AS target
        USING Temp_Cameras AS source
            ON target.CameraId = source.CameraId
        WHEN MATCHED THEN
            UPDATE SET
                Name = source.Name,
                Highway = source.Highway,
                Direction = source.Direction,
                Latitude = source.Latitude,
                Longitude = source.Longitude,
                IsActive = source.IsActive,
                LastUpdatedUTC = source.LastUpdatedUTC
        WHEN NOT MATCHED THEN
            INSERT (CameraId, Name, Highway, Direction, Latitude, Longitude, IsActive, LastUpdatedUTC)
            VALUES (
                source.CameraId, source.Name, source.Highway, source.Direction,
                source.Latitude, source.Longitude, source.IsActive, source.LastUpdatedUTC
            );

        SET @Count = @@ROWCOUNT;
        INSERT INTO LogsExecution (DataType, RecordCount, Status)
        VALUES (@Type, @Count, 'Success');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ErrorMessage = ERROR_MESSAGE();
        INSERT INTO LogsExecution (DataType, RecordCount, Status, ErrorMessage)
        VALUES (@Type, 0, 'Error', LEFT(@ErrorMessage, 500));
    END CATCH


    -- ====================================================
    -- 4. IMPORT : ROADCONDITION
    -- ====================================================
    SET @Type = 'roadcondition';

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM Temp_RoadCondition;

        BULK INSERT Temp_RoadCondition
        FROM 'C:\Ontario511_Data\roadconditions_ontario_511.csv'
        WITH (
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a', -- \n
            FIRSTROW = 1, -- Le fichier est corrompu, pas d'en-tête propre
            CODEPAGE = '65001',
            KEEPNULLS,
            TABLOCK
        );

        -- Nettoyage partiel des données (cas particulier pour roadcondition)
        -- On suppose que le format est : Description,Weather,Visibility,IsActive,Region,RoadNumber,Geometry,LastUpdatedUTC
        -- Mais certaines lignes sont mal formatées → on filtre par date

        -- On insère seulement les lignes avec LastUpdatedUTC valide
        MERGE RoadCondition AS target
        USING (
            SELECT 
                RoadwayName,
                WeatherCondition,
                Visibility,
                Temperature,
                LastUpdatedUTC,
                Region,
                RoadNumber,
                Geometry,
                Description
            FROM Temp_RoadCondition
            WHERE LastUpdatedUTC IS NOT NULL
        ) AS source
            ON target.RoadwayName = source.RoadwayName
            AND ABS(ISNULL(target.Latitude, 0) - ISNULL(source.Latitude, 0)) < 0.01 -- Approximation
        WHEN MATCHED THEN
            UPDATE SET
                WeatherCondition = source.WeatherCondition,
                Visibility = source.Visibility,
                Temperature = source.Temperature,
                LastUpdatedUTC = source.LastUpdatedUTC,
                Region = source.Region,
                RoadNumber = source.RoadNumber,
                Geometry = source.Geometry,
                Description = source.Description
        WHEN NOT MATCHED THEN
            INSERT (RoadwayName, WeatherCondition, Visibility, Temperature,
                    LastUpdatedUTC, Region, RoadNumber, Geometry, Description)
            VALUES (
                source.RoadwayName, source.WeatherCondition, source.Visibility, source.Temperature,
                source.LastUpdatedUTC, source.Region, source.RoadNumber, source.Geometry, source.Description
            );

        SET @Count = @@ROWCOUNT;
        INSERT INTO LogsExecution (DataType, RecordCount, Status)
        VALUES (@Type, @Count, 'Success');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ErrorMessage = ERROR_MESSAGE();
        INSERT INTO LogsExecution (DataType, RecordCount, Status, ErrorMessage)
        VALUES (@Type, 0, 'Error', LEFT(@ErrorMessage, 500));
    END CATCH

END;