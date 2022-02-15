SELECT *
FROM dbo.CovidDeaths
order by 3,4

--SELECT *
--FROM dbo.covidVaccinations
--order by 3,4

-- Select data which ill be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths in NZ
-- Seeing the likelihood of contracting covid and dying in NZ

SELECT location, date, total_cases,total_deaths, (total_deaths / total_cases ) as DeathPercentage
FROM dbo.CovidDeaths
WHERE location LIKE '%zealand%'
AND continent is not null
order by 1,2

-- Showing the what proportion of NZ has contracted covid
-- Less than 1% of the population in NZ which has been confirmed has contracted covid

SELECT location, date, population, total_cases, (total_cases / population ) *100 as PercentOfPopulationInfected
FROM dbo.CovidDeaths
WHERE location LIKE '%zealand%'
order by 1,2

-- Looking at countries with Highest Infection Rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population ))*100 as PercentOfPopulationInfected
FROM dbo.CovidDeaths
--WHERE location LIKE '%zealand%'
group by location,population
order by PercentOfPopulationInfected desc

-- Showing Countries with Highest Death Count per population

SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not null
group by location
order by TotalDeathCount desc

-- Lets seperate by continent with highest number of death

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers

SELECT SUM(new_cases) as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
FROM dbo.CovidDeaths
-- WHERE location LIKE '%Zealand%'
WHERE continent is not null
--group by date
order by 1,2

----------------

SELECT date,SUM(new_cases) as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is not null
group by date
order by 1,2


/* Joining both our tables CovidDeaths and CovidVaccine
	
	Lets look at the total Population vs Vaccinations

*/


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN covidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- Using CTE

with PopvsVac ( Continent,Location,Date,Population,new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN covidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinations Numeric,
RollingPeopleVaccinated Numeric,
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN covidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--  Creating Views to store for visualisations

CREATE VIEW PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN covidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentagePopulationVaccinated