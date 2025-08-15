-- Table: Evenements
CREATE TABLE Evenements (
    EventId NVARCHAR(50) PRIMARY KEY,
    Source NVARCHAR(100) NOT NULL,
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
    Organization NVARCHAR(100),
    CONSTRAINT CHK_EventType CHECK (EventType IN ('roadwork', 'closures', 'accident', 'construction', 'maintenance'))
);

-- Table: Constructions
CREATE TABLE Constructions (
    WorkId INT IDENTITY(1,1) PRIMARY KEY,
    EventId NVARCHAR(50) NOT NULL,
    Highway NVARCHAR(50),
    Direction NVARCHAR(50),
    Description NVARCHAR(MAX),
    PlannedStartDateUTC DATETIME,
    PlannedEndDateUTC DATETIME,
    Status NVARCHAR(50) DEFAULT 'Active',
    CONSTRAINT FK_Constr_EventId FOREIGN KEY (EventId) REFERENCES Evenements(EventId)
);

-- Table: Cameras
CREATE TABLE Cameras (
    CameraId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255),
    Highway NVARCHAR(50),
    Direction NVARCHAR(50),
    Latitude FLOAT,
    Longitude FLOAT,
    IsActive BIT DEFAULT 1,
    LastUpdated DATETIME DEFAULT GETUTCDATE()
);

-- Table: RoadCondition
CREATE TABLE RoadCondition (
    ConditionId INT IDENTITY(1,1) PRIMARY KEY,
    Highway NVARCHAR(50),
    Region NVARCHAR(100),
    RoadwayName NVARCHAR(255),
    WeatherCondition NVARCHAR(50),
    Visibility NVARCHAR(50),
    Temperature FLOAT,
    LastUpdatedUTC DATETIME DEFAULT GETUTCDATE(),
    ReportSource NVARCHAR(100)
);

-- Table: LogsExecution
CREATE TABLE LogsExecution (
    LogId INT IDENTITY(1,1) PRIMARY KEY,
    ExecutionTime DATETIME DEFAULT GETUTCDATE(),
    DataType NVARCHAR(50) NOT NULL,
    RecordCount INT,
    Status NVARCHAR(20) NOT NULL, -- 'Success', 'Error'
    ErrorMessage NVARCHAR(500) NULL
);

-- Table: HistoriqueEvenements
CREATE TABLE HistoriqueEvenements (
    ArchiveId INT IDENTITY(1,1) PRIMARY KEY,
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
    Organization NVARCHAR(100),
    ArchivedDate DATETIME DEFAULT GETUTCDATE()
);

-- Table: Statistiques
CREATE TABLE Statistiques (
    StatId INT IDENTITY(1,1) PRIMARY KEY,
    TotalActiveEvents INT,
    AvgEventsPerDay DECIMAL(10,2),
    AvgEventDurationHours DECIMAL(10,2),
    TotalCameras INT,
    AvgActiveConstructionsPerDay DECIMAL(10,2),
    LastUpdated DATETIME DEFAULT GETUTCDATE()
);