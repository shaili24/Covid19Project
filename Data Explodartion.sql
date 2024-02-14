SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `portfolioproject-414220.CovidProject.CovidDeaths` 
WHERE Continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total_cases vs total_death 

SELECT location, date, total_cases, total_deaths,
(total_deaths/total_cases)* 100 as deathPercantage
FROM `portfolioproject-414220.CovidProject.CovidDeaths` 
WHERE location like '%States%' AND Continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total_cases vs populations
-- Show what percentage people get covid

SELECT location, date, total_cases, population,
((total_cases/population)*100) as covidcases
FROM `portfolioproject-414220.CovidProject.CovidDeaths` 
WHERE location like '%States%' AND Continent IS NOT NULL
ORDER BY 1,2;

-- Looking at countries with highest infection rate against population

SELECT location, Max(total_cases) as HighestInfection, population,
MAX((total_cases/population)*100) as PercentagePopulationInfected
FROM `portfolioproject-414220.CovidProject.CovidDeaths` 
WHERE Continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC; 

-- Looking at countries with highest deathcount per population
SELECT location, Max(total_deaths) as HighestDeathCount, 
FROM `portfolioproject-414220.CovidProject.CovidDeaths` 
WHERE Continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC; 

-- Let's break it down with continents

-- Looking at continents with highest deathcount per population
SELECT continent, Max(total_deaths) as HighestDeathCount, 
FROM `portfolioproject-414220.CovidProject.CovidDeaths` 
WHERE Continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

-- Global numbers 

SELECT date, sum(new_cases) AS totalNewCases, sum(new_deaths) AS totalNewDeaths, 
sum(new_deaths)/sum(new_cases)*100 AS DeathPercentage
FROM `portfolioproject-414220.CovidProject.CovidDeaths` 
WHERE continent is not null
group by date
ORDER BY 1,2 ;

SELECT sum(new_cases) AS totalNewCases, sum(new_deaths) AS totalNewDeaths, 
sum(new_deaths)/sum(new_cases)*100 AS DeathPercentage
FROM `portfolioproject-414220.CovidProject.CovidDeaths` 
WHERE continent is not null
ORDER BY 1,2;

--Toatl Population vs Total vaccines and vaccine percentage for locations

SELECT cd.location, sum(cd.population) AS population, sum(cv.total_vaccinations) As Total_vaccination, 
sum(cv.total_vaccinations)/sum(cd.population)*100 AS VaccinationPercentage
FROM 
`portfolioproject-414220.CovidProject.CovidDeaths` cd
JOIN
`portfolioproject-414220.CovidProject.CovidVaccines` cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null
GROUP BY cd.location ;

-- Population vs New vaccines Per day 


SELECT cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
as RollingPeopleVaccination
FROM 
`portfolioproject-414220.CovidProject.CovidDeaths` cd
JOIN
`portfolioproject-414220.CovidProject.CovidVaccines` cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null
order by 2,3; 

-- USE CTE

WITH PopVSVac AS 
(
SELECT cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
as RollingPeopleVaccination
FROM 
`portfolioproject-414220.CovidProject.CovidDeaths` cd
JOIN
`portfolioproject-414220.CovidProject.CovidVaccines` cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null
--order by 2,3 
)

SElECt *, (RollingPeoplevaccination/ population)*100 FROM PopVSVac;

-- Creating View to store data for later 


create View `portfolioproject-414220.CovidProject.PercentPopulationVaccinated` as

SELECT cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
as RollingPeopleVaccination
FROM 
`portfolioproject-414220.CovidProject.CovidDeaths` cd
JOIN
`portfolioproject-414220.CovidProject.CovidVaccines` cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null;


SELECT * FROM `portfolioproject-414220.CovidProject.PercentPopulationVaccinated`;
