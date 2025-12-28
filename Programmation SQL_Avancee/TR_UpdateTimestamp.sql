-- First batch: Add the column
ALTER TABLE Evenements ADD DateModification DATETIME DEFAULT NULL;
GO

-- Second batch: Create the trigger
CREATE TRIGGER TR_UpdateTimestamp
ON Evenements
AFTER UPDATE
AS
BEGIN
    UPDATE e
    SET DateModification = GETUTCDATE()
    FROM Evenements e
    INNER JOIN inserted i ON e.EventId = i.EventId;
END;
GO