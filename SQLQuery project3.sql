SELECT *
FROM waterborne_disease_dataset

SELECT City, ROUND(AVG([Waterborne Disease Cases]),2) AS Avg_Waterborne_disease_cases
FROM waterborne_disease_dataset
GROUP BY City
ORDER BY Avg_Waterborne_disease_cases DESC

--NUMBER OF CITIES IN THE DATASET

SELECT COUNT(DISTINCT City)
FROM waterborne_disease_dataset

SELECT DISTINCT Year
FROM waterborne_disease_dataset
ORDER BY Year 

--USING THE PIVOT OPERATOR TO AGGREGATE DATA TO KNOW NUMBER OF WATERBORNE DISEASE CASES ACROSS VARIOUS YEARS AND CITIES

SELECT City, ROUND([2019], 2) AS [2019] ,ROUND([2020], 2) AS [2020], ROUND([2021], 2) AS [2021],ROUND([2022], 2) AS [2022], ROUND([2023], 2) AS [2023], ROUND([2024],2) AS [2024]
  FROM (SELECT City, Year, [Waterborne Disease Cases] 
       FROM waterborne_disease_dataset
	   GROUP BY City, Year, [Waterborne Disease Cases] ) as Source_table
	 PIVOT(AVG([Waterborne Disease Cases]) FOR Year IN([2019],[2020],[2021],[2022],[2023],[2024])) AS PivotTable

	 --HOW HAS THE AQI TRENDED OVER THE YEARS IN CITIES WITH GREEN COVERAGE PERCENTAGE OVER 40%
	 SELECT City,ROUND( [2019],2) AS [AQI_IN_2019] , ROUND([2020],2) AS [AQI_IN_2020], ROUND([2021],2) AS [AQI_IN_2021], ROUND([2022],2)AS [AQI_IN_2022],
	 ROUND([2023],2) AS [AQI_IN_2023], ROUND([2024],2) AS [AQI_IN_2024]
	FROM (SELECT City, Year, AQI
	                FROM waterborne_disease_dataset
					WHERE [Green Coverage (%)] > 40 
					    GROUP BY City, Year, AQI) AS Src_Table
	PIVOT(AVG(AQI) FOR Year IN ([2019], [2020],[2021], [2022], [2023], [2024])) AS PvT


	WITH Green_coverage AS
	(SELECT City,Year, AQI,
CASE WHEN [Green Coverage (%)] > 40 THEN 'High green coverage'
    WHEN [Green Coverage (%)] <= 30 THEN 'Low green coverage'
	ELSE 'Low green coverage'
		       END AS Green_coverage_category
       FROM waterborne_disease_dataset)
 SELECT City,Green_coverage_category ,Year, ROUND(AVG(AQI),2)
 AS Avg_AQI
   FROM Green_coverage
   WHERE Year >= '2019'
 GROUP BY Year, City, [Green_coverage_category]
	order by Year


	--IS THERE A RELATIONSHIP BETWEEN THE NUMBER OF VEHICLES, AQI AND RESPIRATORY DISEASE CASES ACROSS CITIES OVER A PERIOD OF TIME?

	SELECT Year, City, ROUND(AVG([Vehicles Count]),2) Vehicles_count, ROUND(AVG(AQI),2) Avg_AQI, ROUND(AVG([Respiratory Disease Cases]),2) Avg_Cases_count
	 FROM waterborne_disease_dataset
	 WHERE Year > '2018'
	 GROUP BY  Year, City;

	 WITH Vehicles_AQI AS 
	      (SELECT City, Year, [Respiratory Disease Cases],
	CASE WHEN [Vehicles Count] > (SELECT AVG([Vehicles Count]) FROM waterborne_disease_dataset ) THEN 'High_count'
	WHEN [Vehicles Count] <= (SELECT AVG([Vehicles Count]) FROM waterborne_disease_dataset ) THEN 'Low_count'
	END AS Vehicles_Count_Category
	     FROM waterborne_disease_dataset)

		 SELECT City, Year, ROUND(AVG([Respiratory Disease Cases]),2) AS Avg_Respiratory_diseases_cases, Vehicles_Count_Category
		 FROM Vehicles_AQI
		 WHERE Year >= '2019'
		 GROUP BY City, Year, Vehicles_Count_Category
	 

	 --HOW DOES THE NUMBER OF FACTORIES IN CITIES IMPACT AQI AND RESPIRATORY DISEASE COUNT?

	 SELECT City, ROUND(AVG(Factories),2) Avg_Factories_count, ROUND(AVG(AQI),2) Avg_AQI, ROUND(AVG([Respiratory Disease Cases]),2) Avg_Respiratory_disease_count
	 FROM waterborne_disease_dataset
	 GROUP BY 
	      City;

		  WITH Factory_Avg AS
(SELECT Factories, AQI, [Respiratory Disease Cases],
      CASE WHEN Factories > (SELECT Avg(Factories) FROM waterborne_disease_dataset) THEN 'High_Count'
		  WHEN Factories <= (SELECT Avg(Factories) FROM waterborne_disease_dataset) THEN 'Low_count'
 END AS Factory_count_category
            FROM waterborne_disease_dataset)
	SELECT
	    Factory_count_category,
      ROUND(AVG(AQI), 2) AS Avg_AQI,
		ROUND(AVG([Respiratory Disease Cases]), 2) AS Avg_Respiratory_disease_count
FROM Factory_Avg
     GROUP BY
	      Factory_count_category	
ORDER BY Factory_count_category


--CHECKING FOR THE YEAR OVER YEAR PERCENTAGE CHANGE OF NUMBER OF WATERBORNE DISEASE CASES IN DIFFERENT CITIES


WITH Growth AS
		   (SELECT City, Year, SUM([Waterborne Disease Cases]) AS Total_Waterborne_Disease_cases
		   FROM waterborne_disease_dataset
		   GROUP BY City, Year
		   ),
		   City_disease_growth_trend AS
	      (SELECT City, Year, Total_Waterborne_Disease_cases,
		  LAG(Total_Waterborne_Disease_cases) OVER
		   (ORDER BY Year) AS Prev_yr_count
		FROM Growth
		   )
		   SELECT City, Year, Total_Waterborne_Disease_cases, Prev_yr_count,
		      CASE WHEN Prev_yr_count IS NOT NULL THEN ROUND(((Total_Waterborne_Disease_cases - Prev_yr_count)*100)/Prev_yr_count,2)
			     ELSE NULL
			END AS Percentage_change
			  FROM City_disease_growth_trend
		   ORDER BY City