CREATE PROC GenererRapportConditionParRegion
AS
BEGIN
    SELECT Region, WeatherCondition, COUNT(*) AS freq,
           ROW_NUMBER() OVER (PARTITION BY Region ORDER BY COUNT(*) DESC) AS rn
    INTO #TempFreq
    FROM RoadCondition
    GROUP BY Region, WeatherCondition;

    SELECT Region, WeatherCondition AS MostFrequentCondition
    FROM #TempFreq
    WHERE rn = 1;
END;