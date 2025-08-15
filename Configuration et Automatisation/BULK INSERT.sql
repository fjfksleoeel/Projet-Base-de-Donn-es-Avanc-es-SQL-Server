USE Ontario511;
GO

-- ====================================================
-- 1. BULK INSERT : EVENEMENTS
-- ====================================================
DELETE FROM Temp_Evenements;

BULK INSERT Temp_Evenements
FROM 'C:\Ontario511_Data\evenements_ontario_511.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    CODEPAGE = '65001',        -- UTF-8
    KEEPNULLS,
    TABLOCK
);
PRINT '✅ Données evenements_ontario_511.csv chargées dans Temp_Evenements';


-- ====================================================
-- 2. BULK INSERT : CONSTRUCTIONS
-- ====================================================
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
PRINT '✅ Données constructions_ontario_511.csv chargées dans Temp_Constructions';


-- ====================================================
-- 3. BULK INSERT : CAMERAS
-- ====================================================
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
PRINT '✅ Données cameras_ontario_511.csv chargées dans Temp_Cameras';


-- ====================================================
-- 4. BULK INSERT : ROADCONDITION
-- ====================================================
DELETE FROM Temp_RoadCondition;

BULK INSERT Temp_RoadCondition
FROM 'C:\Ontario511_Data\roadconditions_ontario_511.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',   -- \n (parfois nécessaire pour les fichiers mal formatés)
    FIRSTROW = 1,             -- Pas d’en-tête propre ou données corrompues
    CODEPAGE = '65001',
    KEEPNULLS,
    TABLOCK,
    ERRORFILE = 'C:\Ontario511_Data\Errors_RoadCondition'
);
PRINT '✅ Données roadconditions_ontario_511.csv chargées dans Temp_RoadCondition';