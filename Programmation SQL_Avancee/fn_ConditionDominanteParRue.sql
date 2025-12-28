CREATE FUNCTION fn_ConditionDominanteParRue (@RoadwayName NVARCHAR(255))
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @Condition NVARCHAR(50);
    SELECT TOP 1 @Condition = WeatherCondition
    FROM RoadCondition
    WHERE RoadwayName = @RoadwayName
    GROUP BY WeatherCondition
    ORDER BY COUNT(*) DESC;
    RETURN @Condition;
END;