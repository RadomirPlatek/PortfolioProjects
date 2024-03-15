  SELECT *
  FROM [PortfolioProject].[dbo].[Covidvaccinations]
  where continent is not null
  order by 3,4

  SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  order by 1,2


  -- Looking at Total Cases vs Total Deaths
  -- shows likelihood of dying if you contract covid in your country
 SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where location like '%states'
  order by 1,2

  --looking at total cases vs population
 SELECT location, date, population, total_cases, (total_cases/population)*100 as covidpercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where location like '%states%'
  order by 1,2

--looking at countries with highest infection rate vs population
 SELECT location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectionRatePerPop
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  Group by Location, population 
  order by InfectionRatePerPop desc

  --Looking at countries with Highest death Count per population
  SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is not null
  Group by Location 
  order by TotalDeathCount desc

--Broken down by continent

  --Highest death count per population by Continent
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is not null
  Group by continent
  order by TotalDeathCount desc

  --Global numbers
  SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is not null
  Group by Date
  order by 1,2

--looking at total population vs vaccination
  --using CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingpeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, sum(cast(vax.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] Dea
join PortfolioProject..CovidVaccinations Vax
	on dea.location=vax.location
	and dea.date=vax.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingpeopleVaccinated/population)*100
from PopvsVac
	
--Using TEMP TABLE

Drop table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
Insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, sum(cast(vax.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] Dea
join PortfolioProject..CovidVaccinations Vax
	on dea.location=vax.location
	and dea.date=vax.date
where dea.continent is not null
--order by 2,3

select *, (RollingpeopleVaccinated/population)*100 as PercentPopulationVaccinated
from #percentpopulationvaccinated

--Creating View to store data for viz
Use PortfolioProject
GO
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, sum(cast(vax.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] Dea
join PortfolioProject..CovidVaccinations Vax
	on dea.location=vax.location
	and dea.date=vax.date
where dea.continent is not null