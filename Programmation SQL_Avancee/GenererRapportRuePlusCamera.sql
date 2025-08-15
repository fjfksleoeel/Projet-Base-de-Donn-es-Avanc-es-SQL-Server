CREATE PROC GenererRapportRuePlusCamera
AS
BEGIN
    SELECT TOP 1 Highway, COUNT(*) AS CameraCount
    FROM Cameras
    GROUP BY Highway
    ORDER BY CameraCount DESC;
END;