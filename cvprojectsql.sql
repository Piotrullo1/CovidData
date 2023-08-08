Select *
from cvproject..CovidDeaths
WHERE continent is not NULL
order by 3,4

Select *
from cvproject..CovidVaccination
order by 3,4

--Select Data that we are going to be using


Select [location], [date], total_cases, new_cases, total_deaths, population
from cvproject..CovidDeaths
order by 1,2

-- how to delete data where rows is 0 or is ''
DELETE FROM cvproject..CovidDeaths
WHERE (ISNULL(total_cases, '') = '' OR total_cases = '0')
AND (ISNULL(total_deaths, '') = '' OR total_deaths = '0');

-- looking at Total Cases vs Total Deaths
--shows likely hood of dying if you contract in your country
SELECT [location], [date], total_cases, total_deaths,
       CAST(total_deaths AS float) / CAST(total_cases AS float) * 100 AS death_percentage
FROM cvproject..CovidDeaths
WHERE [location] LIKE '%states%' 
ORDER BY 1,2

--looking at Total Cases vs Population
--shows what precentage of population got Covid
Select location, date, population, total_cases, 
        CAST(total_cases AS float) / CAST(population AS float) * 100 AS death_percentage
from cvproject..CovidDeaths
--WHERE [location] LIKE '%Poland%' 
order by 1,2

--Looking at Countries with highest infection rate compared to Population
Select location,  population, MAX(total_cases) as highestinfectionCount, 
        CAST(MAX(total_cases) AS float) / CAST(population AS float) * 100 AS PrecentagePopulationInfected
from cvproject..CovidDeaths
--WHERE [location] LIKE '%Poland%' 
group by location,  population
order by PrecentagePopulationInfected DESC


--showing Countries with how many people die during covid
Select location,  MAX(CAST(total_deaths as float)) as Totaldeaths
from cvproject..CovidDeaths
--WHERE [location] LIKE '%Poland%' 
WHERE continent is not NULL
group by location
order by Totaldeaths DESC

--Let's break things down by continent
--showing continents with highest death count 
Select continent, MAX(CAST(total_deaths as float)) as Totaldeaths
from cvproject..CovidDeaths 
WHERE continent is NOT NULL
group by continent
order by Totaldeaths DESC


--global numbers for continents
--SELECT location, date, total_cases, total_deaths,
       --CASE
        --   WHEN total_cases = '0' THEN 0
      --     WHEN TRY_CAST(total_cases AS float) IS NOT NULL AND TRY_CAST(total_deaths AS float) IS NOT NULL THEN CAST(total_deaths AS float) / NULLIF(CAST(total_cases AS float), 0) * 100
      --     ELSE NULL  -- or 0, depending on your preference
      -- END AS death_percentage
--FROM cvproject..CovidDeaths
--WHERE continent IS NOT NULL
--ORDER BY location, date;


--Global numbers
SELECT date,
       SUM(CAST(new_cases AS float)) AS total_new_cases,
       SUM(CAST(new_deaths AS float)) AS total_new_deaths,
       CAST(SUM(CAST(new_deaths AS float)) AS float) / NULLIF(SUM(CAST(new_cases AS float)), 0) * 100 AS death_percentage
FROM cvproject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;



--selecting both tables with same location and date 
-- looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations as float)) OVER (partition by dea.location ORDER by dea.location, dea.date) as People_gettin_vac
from cvproject..CovidDeaths dea
join cvproject..CovidVaccination vacc
    ON dea.location = vacc.location
    and dea.date = vacc.date
WHERE dea.continent IS NOT NULL
order by 2,3



--Use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, People_gettin_vac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations as float)) OVER (partition by dea.location ORDER by dea.location, dea.date) as People_gettin_vac
from cvproject..CovidDeaths dea
join cvproject..CovidVaccination vacc
    ON dea.location = vacc.location
    and dea.date = vacc.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
select *, (CAST(People_gettin_vac as float)/CAST(population as float))*100 as VacPrecentage
from PopvsVac


--temp table
Drop TABLE if EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
Date DATETIME,
population float,
new_vaccinations float,
People_gettin_vac float,
)

INSERT into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations as float)) OVER (partition by dea.location ORDER by dea.location, dea.date) as People_gettin_vac
from cvproject..CovidDeaths dea
join cvproject..CovidVaccination vacc
    ON dea.location = vacc.location
    and dea.date = vacc.date
WHERE dea.continent IS NOT NULL
order by 2,3

select *, (CAST(People_gettin_vac as float)/CAST(population as float))*100 as VacPrecentage
from #PercentPopulationVaccinated;



--Creating view to store data for later visual
CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vacc.new_vaccinations,
    SUM(CAST(vacc.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS People_getting_vac
FROM
    cvproject..CovidDeaths dea
JOIN
    cvproject..CovidVaccination vacc
    ON dea.location = vacc.location
    AND dea.date = vacc.date
WHERE
    dea.continent IS NOT NULL;


SELECT * from NewPercentPopulationVaccinated

