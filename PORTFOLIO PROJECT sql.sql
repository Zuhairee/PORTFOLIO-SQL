--SELECT*
--FROM [Portfolio Project]..CovidVaccinations$
--ORDER BY 3,4

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2

-- TOTAL CASES VS TOTAL DEATHS
-- LIKELYHOOD OF DYING IN COUNTRY PICKED

SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths$
WHERE location LIKE 'Malaysia'
ORDER BY 1,2

--TOTAL CASES VS POPULATION


SELECT location,date, total_cases, population, (total_cases/population)*100 AS case_percentage
FROM CovidDeaths$
WHERE location LIKE '%Malaysia%'
ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM CovidDeaths$
GROUP BY population, location
ORDER BY percent_population_infected DESC


-- COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(cast(total_deaths AS int)) AS totaldeathsCount
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY totaldeathsCount DESC

-- BY CONTINENT

SELECT location, MAX(cast(total_deaths AS int)) AS totaldeathsCount
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY totaldeathsCount DESC


--GLOBAL NUMBERS


SELECT SUM(new_cases) totalcases, SUM(CAST(new_deaths AS INT)) totaldeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS deathpercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevacinnated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE

WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, rollingpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevacinnated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (rollingpeoplevaccinated/Population)* 100
FROM PopVsVac


--Temp Table

DROP TABLE IF exists percentpopulationvaccinated
CREATE TABLE percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
Rollingpeoplevaccinated numeric
)


INSERT INTO percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevacinnated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


SELECT *, (rollingpeoplevaccinated/Population)* 100
FROM percentpopulationvaccinated


-- Creating View to store data for later visualisations

CREATE VIEW percentpopulationvaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevacinnated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM percentpopulationvaccinated