SELECT *
FROM PortofolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortofolioProject..CovidVaccinations
--ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR CONTRY
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2


--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
SELECT location, date, population, total_cases, (total_Cases/population)*100 as PercentagePopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

--LOOKING AT COUNTRY WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) as HighestInfenctionCount, Max((total_Cases/population))*100 as PercentagePopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY 4 desc

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc



--LETS BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc




--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2



--LOOKING TOTAL POPULATION VS VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated