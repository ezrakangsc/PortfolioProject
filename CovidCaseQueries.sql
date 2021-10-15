SELECT * 
FROM `portfolioproject-326019.Tables.CovidDeaths`
-- have to add this because in the data, location and continents have some issues
WHERE continent IS NOT NULL
ORDER BY 3,4; 

-- Select data that we are going to be using 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `portfolioproject-326019.Tables.CovidDeaths`
ORDER BY 1, 2;

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `portfolioproject-326019.Tables.CovidDeaths`
WHERE location = 'United States'
ORDER BY 1, 2;

-- Looking at total cases vs population
-- shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM `portfolioproject-326019.Tables.CovidDeaths`
WHERE location = 'United States'
ORDER BY 1, 2;

-- looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS  HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM `portfolioproject-326019.Tables.CovidDeaths`
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- LET"S BREAK THINGS DOWN BY CONTINENT 
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM `portfolioproject-326019.Tables.CovidDeaths`
WHERE continent IS NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- showing countries with highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM `portfolioproject-326019.Tables.CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- global numbers
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage 
FROM `portfolioproject-326019.Tables.CovidDeaths`
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- looking at total population vs vaccinations
-- USE CTE - number of columns must be  same or it will give u an error
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingVaccinationPercentage
FROM PopVsVac
-- USE CTE
