Select*
from Portfolioproject..Coviddeaths
where continent is not null
order by 3,4

--Select*
--from Portforlioproject..Covidvaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolioproject..Coviddeaths 
where continent is not null
order by 1,2

--Looking at total cases vs Total deaths
--shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
From Portfolioproject..Coviddeaths
where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total cases vs population
--shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolioproject..Coviddeaths
--where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolioproject..Coviddeaths
--where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..Coviddeaths
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Break things down by continent

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..Coviddeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--showing continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..Coviddeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers

Select Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathsPercentage
From Portfolioproject..Coviddeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location
  , dea.date) as RollingPeopleVaccinated
  --, (RollingPeopleVaccinated/population)*100
from Portfolioproject..Coviddeaths dea
join Portfolioproject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location
  , dea.date) as RollingPeopleVaccinated
  --, (RollingPeopleVaccinated/population)*100
from Portfolioproject..Coviddeaths dea
join Portfolioproject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location
  , dea.date) as RollingPeopleVaccinated
  --, (RollingPeopleVaccinated/population)*100
from Portfolioproject..Coviddeaths dea
join Portfolioproject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualization

create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location
  , dea.date) as RollingPeopleVaccinated
  --, (RollingPeopleVaccinated/population)*100
from Portfolioproject..Coviddeaths dea
join Portfolioproject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated
