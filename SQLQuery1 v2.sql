--SELECT * 
--FROM CovidDeaths
--Where continent is not null
--ORDER BY 3,4 

SELECT location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null
order by 1,2


--Displays Likelihood of dying if you get covid in Afghanistan specifically as a percentage
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%Afghanistan%' and continent is not null
order by DeathPercentage desc

--Displays total cases in Afghanistan as a percentage
SELECT location, date, total_cases, total_deaths,population, (total_cases/population)*100 as TotalCasesPop
From CovidDeaths
Where location like '%Afghanistan%' and continent is not null  
order by 1,2

--Displays countries with highest infection rates
SELECT location, Max(total_cases) as HighestInfectionCount,population, Max(total_cases/population)*100 as Percentpopulationinfected
From CovidDeaths
Where continent is not null
Group by location,population
Order by Percentpopulationinfected desc

--Displays Country with Highest Death Count
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Displays Continent with Highest Death Count
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers of cases and deaths by date
Select date,
SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast (new_deaths as int))/ SUM(New_Cases)*100 as Deathpercentage
from CovidDeaths
where continent is not null
Group by date
order by 1,2

--Global Numbers total
Select
SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast (new_deaths as int))/ SUM(New_Cases)*100 as Deathpercentage
from CovidDeaths
where continent is not null
order by 1,2


--Joining Covid Deaths Table and Vaccinations Table on date and location
--And Looking at Total Number of Global Vaccinations
Select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,CovidDeaths.new_vaccinations
From CovidDeaths
Join CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
order by 2,3

--Looking at Total Number of Global Vaccinations (per country) (rolling count)
Select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,CovidDeaths.new_vaccinations,
SUM(CONVERT(int,CovidDeaths.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location, CovidDeaths.Date)
as RollingCountVaccinated

From CovidDeaths
Join CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
order by 2,3

--Using a CTE to see percent of Population vaccinated (by country)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingCountVaccinated)
as

(
Select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,CovidDeaths.new_vaccinations,
SUM(CONVERT(int,CovidDeaths.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location, CovidDeaths.Date)
as RollingCountVaccinated

From CovidDeaths
Join CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
)
Select *, (RollingCountVaccinated/Population)*100
as PercentCountryVaccinated
From PopvsVac


--Creating a View For Visualation 
Create View PercentCountryVaccinated as 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingCountVaccinated)
as

(
Select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,CovidDeaths.new_vaccinations,
SUM(CONVERT(int,CovidDeaths.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location, CovidDeaths.Date)
as RollingCountVaccinated

From CovidDeaths
Join CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
)
Select *, (RollingCountVaccinated/Population)*100
as PercentCountryVaccinated
From PopvsVac