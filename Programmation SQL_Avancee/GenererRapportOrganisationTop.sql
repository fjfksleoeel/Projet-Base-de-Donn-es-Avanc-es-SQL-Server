CREATE PROC GenererRapportOrganisationTop
AS
BEGIN
    SELECT TOP 1 Organization, COUNT(*) AS EventCount
    FROM Evenements
    GROUP BY Organization
    ORDER BY EventCount DESC;
END;