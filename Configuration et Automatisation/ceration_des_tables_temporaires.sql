-- Exemple pour Evenements
CREATE TABLE Temp_Evenements (
    EventId NVARCHAR(50),
    Source NVARCHAR(100),
    Highway NVARCHAR(50),
    Direction NVARCHAR(50),
    Description NVARCHAR(MAX),
    StartDateUTC DATETIME,
    LastUpdatedUTC DATETIME,
    PlannedStartDateUTC DATETIME,
    PlannedEndDateUTC DATETIME,
    EventType NVARCHAR(50),
    Latitude FLOAT,
    Longitude FLOAT,
    Region NVARCHAR(100),
    Organization NVARCHAR(100)
);
-- Répéter pour constructions
--table temp_cameCREATE TABLE Temp_Constructions (
    WorkId NVARCHAR(100),
    Source NVARCHAR(100),
    Highway NVARCHAR(50),
    Direction NVARCHAR(50),
    Description NVARCHAR(MAX),
    StartDateUTC DATETIME,
    LastUpdatedUTC DATETIME,
    PlannedStartDateUTC DATETIME,
    PlannedEndDateUTC DATETIME,
    Status NVARCHAR(50),
    EventType NVARCHAR(50),
    IsActive BIT,
    DateRange NVARCHAR(200),
    Latitude FLOAT,
    Longitude FLOAT
);ras, 
--table temporaire_cameras
CREATE TABLE Temp_Cameras (
    CameraId NVARCHAR(100),
    Name NVARCHAR(255),
    Highway NVARCHAR(50),
    Direction NVARCHAR(50),
    Latitude FLOAT,
    Longitude FLOAT,
    IsActive BIT,
    LastUpdatedUTC DATETIME,
    UrlImage NVARCHAR(500),
    Description NVARCHAR(500)
);

--roadcondition
CREATE TABLE Temp_RoadCondition (
    RoadwayName NVARCHAR(255),
    WeatherCondition NVARCHAR(100),
    Visibility NVARCHAR(50),
    Temperature FLOAT,
    LastUpdatedUTC DATETIME,
    Region NVARCHAR(100),
    RoadNumber NVARCHAR(20),
    Geometry NVARCHAR(MAX),  -- Chaîne encodée (ex: polyline)
    Description NVARCHAR(MAX)
);