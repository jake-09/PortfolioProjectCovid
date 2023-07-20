
-- Creating new table for Covid Deaths 

CREATE TABLE CovidDeaths
AS 
SELECT * 
FROM CovidData

-- Putting population Density up in the front for better overview

alter table CovidDeaths modify population_density double after date

-- Selecting Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidData
Order by 1, 2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in Denmark

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidData
WHERE location like '%Denmark%'
Order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, total_cases, total_deaths, (total_cases /population)*100 AS DeathPercentage
FROM CovidData
-- WHERE location like '%Denmark%'
Order by 1, 2

-- Looking at countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases /population))*100 AS PercentPopulationInfected
FROM CovidData
-- WHERE location like '%Denmark%'
GROUP BY Location, population 
Order by PercentPopulationInfected DESC


-- Showing the countries with Highest Death Count per Population 

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM CovidData
-- WHERE location like '%Denmark%'
WHERE iso_code NOT LIKE '%OWID%'
GROUP BY Location 
Order by TotalDeathCount DESC

-- Let's break things down by continent
SELECT continent , MAX(total_deaths) as TotalDeathCount
FROM CovidData
GROUP BY continent  
Order by TotalDeathCount DESC 



-- Global numbers 

SELECT SUM(new_cases) as total_cases , SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidData
-- WHERE location like '%Denmark%'
WHERE iso_code NOT LIKE '%OWID%'
-- GROUP BY date
Order by 1, 2


-- Looking at total population vs vaccinations 
SELECT location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location order by location, date) as RollingPeopleVaccinated

from CovidData cd 
WHERE location like '%Albania%'
order by 1,3 

-- Use CTE 

WITH PopvsVac (Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location order by location, date) as RollingPeopleVaccinated

from CovidData cd 
-- WHERE location like '%Albania%'
) 

SELECT *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
from PopvsVac


-- Create view to store data for later visualization 
CREATE View PercentPopulationVaccinated as 
SELECT location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location order by location, date) as RollingPeopleVaccinated

from CovidData cd 
WHERE iso_code NOT LIKE '%OWID%'



