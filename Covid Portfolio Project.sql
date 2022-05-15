SELECT * 
FROM [Portfolio Project]..CovidDeaths
WHERE continent is null
ORDER BY 3,4

--SELECT * 
--FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Chance of possibility of death from covid in Country

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
Order by 1,2


-- Total Cases vs Population
-- Percentage of population contracting Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as ContractedPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
Order by 1,2

-- Looking at Country with Highest Infection Rate compared to Population

SELECT Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as ContractedPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
Group by location, population
Order by ContractedPercentage desc

-- Countries with the highest mortality per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
Group by location
Order by TotalDeathCount desc

--Broken down by continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent is null
AND location not like '%income%'
Group by location
Order by TotalDeathCount desc

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
AND location not like '%income%'
Group by continent
Order by TotalDeathCount desc

-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total Population Vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinations
From [Portfolio Project]..CovidVaccinations vac
JOIN [Portfolio Project]..CovidDeaths dea
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
AND vac.new_vaccinations is not null
ORDER BY 2,3

--USE CTE

WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, people_vaccinated, TotalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, vac.people_vaccinated,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinations
From [Portfolio Project]..CovidVaccinations vac
JOIN [Portfolio Project]..CovidDeaths dea
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

--ORDER BY 2,3
)
SELECT *, (people_vaccinated/population)*100 as PercentVaccinated, (TotalVaccinations/population)*100 as PercentOfVaccinationsPerPopulation
FROM PopVsVac
ORDER BY 2,3

-- TEMP TABLE
DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
--People_Vaccinated numeric,
--TotalVaccinations numeric
)

Insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations --, vac.people_vaccinated,
--SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinations
From [Portfolio Project]..CovidVaccinations vac
JOIN [Portfolio Project]..CovidDeaths dea
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT * --(people_vaccinated/population)*100 as PercentVaccinated, (TotalVaccinations/population)*100 as PercentOfVaccinationsPerPopulation
From PercentPopulationVaccinated
--ORDER BY 2,3

--Creating View to store data for later visualizations

Create View ContinentDeathCount as
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
AND location not like '%income%'
Group by continent
--Order by TotalDeathCount desc