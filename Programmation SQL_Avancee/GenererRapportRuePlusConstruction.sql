CREATE PROC GenererRapportRuePlusConstruction
AS
BEGIN
    SELECT TOP 1 Highway, COUNT(*) AS WorkCount
    FROM Constructions
    GROUP BY Highway
    ORDER BY WorkCount DESC;
END;