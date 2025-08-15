CREATE PROC RechercherEvenementsFiltres
    @Type NVARCHAR(50) = NULL,
    @Date DATETIME = NULL,
    @Région NVARCHAR(100) = NULL,
    @MotCle NVARCHAR(100) = NULL
AS
BEGIN
    SELECT * FROM Evenements
    WHERE (@Type IS NULL OR EventType = @Type)
      AND (@Date IS NULL OR CAST(StartDateUTC AS DATE) = CAST(@Date AS DATE))
      AND (@Région IS NULL OR Region LIKE '%' + @Région + '%')
      AND (@MotCle IS NULL OR Description LIKE '%' + @MotCle + '%');
END;