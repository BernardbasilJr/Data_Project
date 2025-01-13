
--FIRSTLY, PREVIEWING THE TABLE TO QUERY

SELECT *
FROM Electric_vehicles_data

--CREATING A NEW COLUMN AND POPULATING THE ROWS BASED ON A CONDITIONS

ALTER TABLE Electric_vehicles_data
ADD Rapid_charge VARCHAR(255)

UPDATE Electric_vehicles_data
SET Rapid_charge = 'Rapid charge Ipossible'
WHERE [Electric Vehicle Type] = 'Battery Electric Vehicle (BEV)'

--OR WE COULD SIMPLY USE THE CASE STATEMENT IN THIS SITUATION

UPDATE Electric_vehicles_data
SET Rapid_charge = 
     CASE
WHEN [Electric Vehicle Type] = 'Battery Electric Vehicle (BEV)' THEN 'Rapid charge Possible'
     ELSE 'Rapid charge impossible'
END;


--CHECKING FOR DUPLICATE ROWS

SELECT Make, Model, [DOL Vehicle ID], [VIN (1-10)], COUNT(*)
FROM Electric_vehicles_data
GROUP BY Make, Model, [DOL Vehicle ID], [VIN (1-10)]
HAVING COUNT(*) > 1

	 --FROM THE QUERY WE KNOW THAT THERE ARE NO DUPLICATE ROWS.

	
	--SHOWING HOW MANY DIFFERENT 'MAKES' ARE REPRESENTED IN THE DATA

	 SELECT COUNT(DISTINCT Make)
	 FROM Electric_vehicles_data

	 SELECT COUNT([VIN (1-10)]) AS Total_Sample
	 FROM Electric_vehicles_data

	 SELECT COUNT(DISTINCT State) AS Num_Of_States
	 FROM Electric_vehicles_data
	
	 --SHOWING THE TOP 5 MOST COMMON 'BRANDS' IN TERMS OF FREQUENCY IN THE TABLE
	
	SELECT Make, COUNT(Make) AS Freq
	 FROM Electric_vehicles_data
	 GROUP BY Make
	 ORDER BY Freq DESC
	 
	
	--CHECKING FOR THE LOCATION WITH THE HIGHEST NUMBER OF ELECTRIC VEHICLES

	 SELECT State, COUNT(Make) AS NUM_OF_EV
	 FROM Electric_vehicles_data
	 GROUP BY State
	 ORDER BY NUM_OF_EV DESC

	 --CHECKING FOR THE COUNTIES AND CITIES WITH THE HIGHEST NUMBER OF ELECTRIC VEHICLES

	 SELECT County, City, State, COUNT(Make)  AS Num_of_EV
	 FROM Electric_vehicles_data
	 GROUP BY County, City, State
	 ORDER BY Num_of_EV DESC


	 --CHECKING FOR THE LOCATION WITH THE HIGHEST PERCENTAGE OF EV's WITH RAPID CHARGE CAPABILITIES
	
	WITH Percentage_RC_CTE AS 
	 (
	 SELECT County, City, State, COUNT(Rapid_charge) AS Num_of_rapidcharge_EV
	 FROM Electric_vehicles_data
	 WHERE Rapid_charge = 'Rapid charge Possible'
	 GROUP BY County, City, State
	 )
	     SELECT *, (Num_of_rapidcharge_EV * 100)/(SELECT SUM(Num_of_rapidcharge_EV)
		FROM Percentage_RC_CTE ) AS Percentage_RC
		FROM Percentage_RC_CTE
	ORDER BY Num_of_rapidcharge_EV DESC
		

      --CHECKING FOR THE CITY WITH THE MOST DIVERSE RANGE OF UNIQUE ELECTRIC VEHICLE MODELS


   SELECT City, State, COUNT(DISTINCT Model) AS Num_of_models
	FROM Electric_vehicles_data
	GROUP BY City, State
	ORDER BY Num_of_models DESC


	--LOOKING FOR THE THE MOST COMMON MODEL YEAR FOR EACH MAKE

	SELECT Make, [Model Year], COUNT(*) AS vehicle_count
	FROM Electric_vehicles_data
	  GROUP BY Make, [Model Year]
	  ORDER BY Make, vehicle_count DESC

	  --TO GET THE MOST COMMON MODEL YEAR FOR EACH MAKE

	  WITH Make_model_count AS 
	  (
	       SELECT Make, [Model Year], COUNT(*) AS vehicle_count
	FROM Electric_vehicles_data
	  GROUP BY Make, [Model Year]
	  )
	  SELECT *
	  FROM Make_model_count AS mmc
	  WHERE vehicle_count = (SELECT MAX(vehicle_count)
	           FROM Make_model_count AS MC
			   WHERE mmc.Make = MC.Make)
ORDER BY  mmc.vehicle_count DESC

--COUNT FOR HOW MANY DISTINCT MODELS ARE AVAILABLE IN EACH MODEL YEAR

SELECT Make, [Model Year], COUNT(DISTINCT Model) AS Model_count
FROM Electric_vehicles_data
GROUP BY Make, [Model Year]
ORDER BY Make, Model_count 


--THE STATE WITH THE FASTEST GROWING ADOPTION OF ELECTRIC VEHICLES BASED ON MODEL YEAR

SELECT State,[Model Year], COUNT(*) AS vehicles_per_yr
  FROM Electric_vehicles_data
    GROUP BY State, [Model Year]
	ORDER BY vehicles_per_yr DESC 

	--Calculating the year over year growth by state
WITH Vehicle_growth AS 
(
      SELECT State, 
	  [Model Year], 
	  COUNT(*) AS vehicles_count,
	  LAG(COUNT(*)) OVER (PARTITION BY State
	      ORDER BY [Model Year]) AS Prev_yr_count
	  FROM Electric_vehicles_data
	GROUP BY State, [Model Year]
	),     
	 State_growth_trend AS
	(
	    SELECT State,
		[Model Year],
		vehicles_count,
		Prev_yr_count,
		AVG(vehicles_count - COALESCE(Prev_yr_count,0)) AS Avg_growth,
		     (vehicles_count - Prev_yr_count)*100/Prev_yr_count
		 AS Growth_Percentage
		FROM Vehicle_growth
		GROUP BY State, [Model Year], vehicles_count, Prev_yr_count
		 )
		   SELECT *
		   FROM State_growth_trend
		   
		   GROUP BY State, [Model Year], vehicles_count, Prev_yr_count, Avg_growth, Growth_Percentage;

		   WITH Growth AS
		   (SELECT City, Year, SUM([Waterborne Disease Cases]) AS Total
		   FROM waterborne_disease_dataset
		   GROUP BY City, Year
		   ),
		   City_disease_growth_trend AS
	      (SELECT City, Year, Total,
		  LAG(Total) OVER
		   (ORDER BY Year) AS Prev_yr_count
		FROM Growth
		   )
		   SELECT City, Year, Total, Prev_yr_count,
		      CASE WHEN Prev_yr_count IS NOT NULL THEN ROUND(((Total - Prev_yr_count)*100)/Prev_yr_count,2)
			     ELSE NULL
			END AS Percentage_change
			  FROM City_disease_growth_trend
		   ORDER BY City

		   CREATE VIEW Total_Num_of_Makes AS
		   SELECT COUNT(DISTINCT Make) as Total_makes
	 FROM Electric_vehicles_data
	
	CREATE VIEW Top_5_Brands AS
	SELECT Make, COUNT(Make) AS Freq
	 FROM Electric_vehicles_data
	 GROUP BY Make
	 

	 Create VIEW Location_Freq AS
	 SELECT County, City, State, COUNT(Make)  AS Num_of_EV
	 FROM Electric_vehicles_data
	 GROUP BY County, City, State
	 
	 CREATE VIEW Year_percentage_growth3 AS
	 WITH Vehicle_growth AS 
(
      SELECT State, 
	  [Model Year], 
	  COUNT(*) AS vehicles_count,
	  LAG(COUNT(*)) OVER (PARTITION BY State
	      ORDER BY [Model Year]) AS Prev_yr_count
	  FROM Electric_vehicles_data
	GROUP BY State, [Model Year]
	),     
	 State_growth_trend AS
	(
	    SELECT State,
		[Model Year],
		vehicles_count,
		Prev_yr_count,
		AVG(vehicles_count - COALESCE(Prev_yr_count,0)) AS Avg_growth,
		     (vehicles_count - Prev_yr_count)*100/Prev_yr_count
		 AS Growth_Percentage
		FROM Vehicle_growth
		GROUP BY State, [Model Year], vehicles_count, Prev_yr_count
		 )
		   SELECT *
		   FROM State_growth_trend
		   WHERE Growth_Percentage >= 300
		   GROUP BY State, [Model Year], vehicles_count, Prev_yr_count, Avg_growth, Growth_Percentage
		   
		   
		   
		   SELECT State, Avg_growth
		   FROM Year_percentage_growth3

		   CREATE VIEW Cities_Vehicles_freq AS
		   SELECT City, State, COUNT(DISTINCT Model) AS Num_of_models
	FROM Electric_vehicles_data
	GROUP BY City, State
	
	SELECT *
	FROM Cities_Vehicles_freq
	ORDER BY Num_of_models DESC