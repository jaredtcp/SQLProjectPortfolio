SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE Location like'%Singapore%'
and continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Population

SELECT Location, Date, population, total_cases, (total_cases/population)*100 as PopulaitonInfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like'%Malaysia%'
and continent is not null
ORDER BY 1,2

-- Looking at Countries with highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like'%Malaysia%'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY 4 DESC

-- Showing Countries with the Highest Death Count per Population

SELECT Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like'%Malaysia%'
WHERE continent is not null
GROUP BY Location
ORDER BY 2 DESC

-- Breakdown by Continenet

-- Showing continent with the highest death count per population

SELECT Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like'%Malaysia%'
WHERE continent is null
GROUP BY Location
ORDER BY 2 DESC



-- Breakdown Globally

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like'%Malaysia%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by da.Location ORDER by da.Location, da.date) AS Vaccinations_Cumulation
--(Vaccinations_Cumulation/da.population)*100
FROM PortfolioProject..CovidDeaths da
JOIN PortfolioProject..CovidVaccinations vac
	ON da.location = vac.location
	AND da.date = vac.date
WHERE da.Continent is not Null
ORDER BY 2,3

--CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations,Vaccination_Cumulation)
AS
(SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by da.Location ORDER by da.Location, da.date) AS Vaccinations_Cumulation
--(Vaccinations_Cumulation/da.population)*100
FROM PortfolioProject..CovidDeaths da
JOIN PortfolioProject..CovidVaccinations vac
	ON da.location = vac.location
	AND da.date = vac.date
WHERE da.Continent is not Null
)
Select *, (Vaccination_Cumulation/Population)*100
From PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Vaccinations_Cumulation numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by da.Location ORDER by da.Location, da.date) AS Vaccinations_Cumulation
--(Vaccinations_Cumulation/da.population)*100
FROM PortfolioProject..CovidDeaths da
JOIN PortfolioProject..CovidVaccinations vac
	ON da.location = vac.location
	AND da.date = vac.date
--WHERE da.Continent is not Null
--ORDER BY 2,3

Select *, (Vaccinations_Cumulation/Population)*100
From #PercentPopulationVaccinated


-- Create View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by da.Location ORDER by da.Location, da.date) AS Vaccinations_Cumulation
--(Vaccinations_Cumulation/da.population)*100
FROM PortfolioProject..CovidDeaths da
JOIN PortfolioProject..CovidVaccinations vac
	ON da.location = vac.location
	AND da.date = vac.date
WHERE da.Continent is not Null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated