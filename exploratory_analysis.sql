use CovidProject;

-- Exploratory Data Analysis 
SELECT * FROM Deaths;
SELECT * FROM Vaccinations;

--------------------------------------------------INVESTIGATE DEATHS AND CASES------------------------------------------------ 

-- GENERAL CASES AND DEATH ACROSS THE FOUR YEARS.

--Total Deaths and Cases
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, 
	   FORMAT((SUM(new_deaths)/SUM(new_cases))*100, 'N2') as FatalityRate 
FROM Deaths
WHERE continent is NOT NULL;
--  775 935 057 total cases and 7 060 988 total deaths between 2020/01/05 to 2024/08/14.

--Deaths and cases in each year.
SELECT YEAR(date) as 'Year', FORMAT(SUM(new_cases), 'N0') as TotalCases, FORMAT(SUM(new_deaths), 'N0') as TotalDeaths,
		FORMAT((SUM(new_deaths)/SUM(new_cases))*100, 'N2') as FatalityRate
FROM Deaths
WHERE continent is NOT NULL
GROUP BY YEAR(date)
ORDER BY YEAR(date);

----------------------------------------------------DEATH AND CASES BY REGION------------------------------------------------- 

SELECT location, FORMAT(MAX(population), 'N0') as Population, FORMAT(SUM(new_cases), 'N0') AS TotalCases,
	   FORMAT(SUM(new_deaths), 'N0') as TotalDeaths,
	   FORMAT((SUM(new_cases)/	MAX(population))*100, 'N2') as CasePercentage, --Percentage of ppoulation with covid.
	   FORMAT((SUM(new_deaths)/MAX(population))*100, 'N2') as DeathPercentage --Perctage of population dying from covid.
	
FROM Deaths
WHERE location in ('North America','Africa','Oceania','Europe','Asia','South America')
GROUP BY location
ORDER BY  SUM(new_cases)  DESC;

--Deep dive into africa.
SELECT continent, location, FORMAT(MAX(population), 'N0') as Population,
	   FORMAT(SUM(new_cases), 'N0') as TotalCases, FORMAT(SUM(new_deaths), 'N0') as TotalDeaths,
	   FORMAT((SUM(new_cases)/	MAX(population))*100, 'N2') as CasePercentage, --Percentage of ppoulation with covid.
	   FORMAT((SUM(new_deaths)/MAX(population))*100, 'N2') as DeathPercentage --Perctage of population dying from covid.
	
FROM Deaths
WHERE continent = 'Africa'
GROUP BY continent, location
ORDER BY  (SUM(new_cases)/	MAX(population))*100  DESC;
-- Investigate death rate, case rate for the leading and trailing countries. 

---------------------------------------------------------VACCINATIONS-------------------------------------------------

SELECT * FROM Vaccinations;

-- Investigate total vaccinations on a global scale. 
SELECT FORMAT(MAX(total_vaccinations), 'N0') TotalVaccinations, 
	   FORMAT(MAX(d.population), 'N0') as TotalPopulation,
	   FORMAT(MAX(people_vaccinated), 'N0') PeopleVaccinated,
	   FORMAT(MAX(people_fully_vaccinated), 'N0') FullyVaccinated,
	   FORMAT(MAX(people_vaccinated)/MAX(d.population), 'N2') VaccinatedPercentage,
	   FORMAT(MAX(people_fully_vaccinated)/MAX(d.population), 'N2') VaccinatedPercentage
FROM Vaccinations v
LEFT JOIN Deaths d
on v.location = d.location and v.date = d.date
WHERE v.location = 'World';

-- Compare in each year how many vacinnes were administred 
WITH cummulative AS (
	SELECT YEAR(d.date) [Year], MAX(total_vaccinations) as Cummulative_Vaccs,
		   FORMAT(MAX(people_vaccinated)/MAX(d.population), 'N2') PerVaccinated
	FROM Vaccinations v
	LEFT JOIN Deaths d
	on v.location = d.location and v.date = d.date
	WHERE v.location = 'World'
	GROUP BY YEAR(d.date) 
	)
SELECT Year, FORMAT(Cummulative_Vaccs, 'N0') AS Cummulative_Vaccinatios, PerVaccinated,
	  FORMAT(( (lead(Cummulative_Vaccs) OVER ( ORDER BY Year ) - Cummulative_Vaccs)/Cummulative_Vaccs)*100, 'N2') as PercentageIncrease
FROM cummulative

-- What was the impact of vaccines on a continent level, use joins to on population
SELECT  location, FORMAT(SUM(new_vaccinations), 'N0') as Vaccinations
FROM Vaccinations
WHERE location in ('North America','Africa','Oceania','Europe','Asia','South America')
GROUP BY location
ORDER BY SUM(new_vaccinations) DESC


-- Which country had the most vaccines and how did it impact the death and case rate
SELECT  location, FORMAT(SUM(new_vaccinations), 'N0') as Vaccinations
FROM Vaccinations
WHERE continent = 'Africa'
GROUP BY location
ORDER BY SUM(new_vaccinations) DESC




















