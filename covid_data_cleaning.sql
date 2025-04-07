use CovidProject;

-- PHASE1: Data Cleaning and inspection 

-----------------------------------------------------Deaths Table Cleaning------------------------------------------------------- 
SELECT * FROM Deaths;

EXEC sp_help 'Deaths'; -- Check the data types of our olumns 

ALTER TABLE Deaths
ALTER COLUMN population float;
------------------------------------------------------------NULL VALUES ----------------------------------------------------------
-- Check for null values if they exist
SELECT *                           
FROM Deaths
WHERE new_cases is null                 
or total_cases is null
or total_deaths is null
or new_deaths is null
or total_cases_per_million is null
or new_cases_per_million is null
or total_deaths_per_million is null
or new_deaths_per_million is null;

BEGIN TRANSACTION
DELETE FROM Deaths  --Delete rows where there is no informtion related to covid deaths at all as they are not useful. 
WHERE new_cases is null                 
AND total_cases is null
AND total_deaths is null
AND new_deaths is null
AND total_cases_per_million is null
AND new_cases_per_million is null
AND total_deaths_per_million is null
AND new_deaths_per_million is null;
COMMIT;

-- Replace the null values with zero. We will assume that for the null values this data was not reccorded 
-- for the purpose of this analysis we will assume these values to be 0. 
BEGIN TRANSACTION
UPDATE Deaths
SET new_cases = COALESCE(new_cases, 0),
	total_cases = COALESCE(total_cases, 0),
	total_deaths = COALESCE(total_deaths, 0),
	new_deaths = COALESCE(new_deaths, 0),
	total_cases_per_million = COALESCE(total_cases_per_million,0),
	new_cases_per_million  = COALESCE(new_cases_per_million, 0),
	total_deaths_per_million = COALESCE(total_deaths_per_million, 0),
	new_deaths_per_million = COALESCE(new_deaths_per_million, 0);
COMMIT;
 
 --For data verification 
--SELECT SUM(new_cases) as cases, SUM(total_deaths) deaths, SUM(total_cases_per_million) c_m
--from Deaths

-------------------------------------------Data Duplicates----------------------------------------------------------------------------

-- using row number over all the columns in our data will allow us to find rows that exactly the same hence duplicates. 
SELECT *
FROM (
	SELECT *, 
	ROW_NUMBER () OVER (PARTITION BY iso_code, continent, location, date, population, total_cases, new_cases, total_deaths, 
						new_deaths, total_cases_per_million, new_cases_per_million, total_deaths_per_million, new_deaths_per_million
						ORDER BY date) as duplicates
	FROM Deaths
	 ) as dup
WHERE duplicates > 1 -- There are no row outputs, therefore there no duplicates. 


------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------Vaccinations Table Cleaning------------------------------------------------------------------------ 
SELECT * FROM Vaccinations ORDER BY DATE ;

-- Check and change data types 
EXEC sp_help 'Vaccinations'; 

ALTER TABLE Vaccinations
ALTER COLUMN total_vaccinations float;

ALTER TABLE Vaccinations
ALTER COLUMN people_vaccinated float;

ALTER TABLE Vaccinations
ALTER COLUMN people_fully_vaccinated float;

ALTER TABLE Vaccinations
ALTER COLUMN new_vaccinations float;

/*SELECT *
FROM Vaccinations
WHERE total_vaccinations is null
or people_vaccinated is null
or people_fully_vaccinated is null
or new_vaccinations is null;*/

-------------------------------------------Data Duplicates----------------------------------------------------------------------------
--Find the duplicates
SELECT *
FROM (
	SELECT *, 
	ROW_NUMBER () OVER (PARTITION BY iso_code, continent, location, date, total_vaccinations, 
						people_vaccinated, people_fully_vaccinated, new_vaccinations
						ORDER BY date) as duplicates
	FROM Vaccinations
	 ) as vac_dup
WHERE duplicates > 1 ;/* There are about 1159 duplicates in our data. We will therefore delete these as they do not  
						provide any aditional important information. */

-- Deleting the duplicates
BEGIN TRANSACTION;
WITH dups_table AS (
    SELECT *, 
		   ROW_NUMBER () OVER (PARTITION BY iso_code, continent, location, date, total_vaccinations, 
											people_vaccinated, people_fully_vaccinated, new_vaccinations
											ORDER BY date) as duplicates
    FROM Vaccinations
)
DELETE FROM dups_table WHERE duplicates > 1
COMMIT;
------NULL VALUES-------------------------------------------------------------------
/* There are to many null values for the vaccinations table as this is daily data. We will continue our 
   analysis is and take a note of it. */