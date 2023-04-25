Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Pulling out data for use
Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Comparing Total Cases to Total Deaths
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From PortfolioProject..CovidDeaths
--Where location like 'United States'
where continent is not null
order by 1,2

--Comparing Total Cases to Population
Select Location, Date, total_cases, population, (total_cases/population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
--Where location like 'United States'
where continent is not null
order by 1,2

--Comparing Highest Infection Rates to Population
Select Location, population, Max(total_cases) as max_infection_count, Max((total_cases/population))*100 as InfectionRate
From PortfolioProject..CovidDeaths
--Where location like 'United States'
where continent is not null
Group by Location, population
order by InfectionRate desc

--Making a note to check every query before this one for correct math and value (int VS. chr)

--Countries organized by highest Death Toll 
Select Location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
--Where location like 'United States'
where continent is not null
Group by Location
order by total_death_count desc


--slight detour to get rid of the seperation by class
Delete From PortfolioProject..CovidDeaths
Where location in('High income', 'Upper middle income', 'Lower middle income', 'Low income')

Delete From PortfolioProject..CovidVaccinations
Where location in('High income', 'Upper middle income', 'Lower middle income', 'Low income')



--Grouped by continent with highest death counts
Select continent, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
--Where location like 'United States'
where continent is not null
Group by continent
order by total_death_count desc

---THE CORRECT WAY TO DO IT... COME BACK TO THIS
--Select location, MAX(cast(total_deaths as int)) as total_death_count
--From PortfolioProject..CovidDeaths
--Where location like 'United States'
--where continent is null
--Group by location
--order by total_death_count desc


--GLOBAL NUMBERS
Select Date, Sum(new_cases) as total_global_cases, Sum(cast(new_deaths as int)) as total_global_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathRate
From PortfolioProject..CovidDeaths
--Where location like 'United States'
where continent is not null
Group by Date
order by 1,2

--By removing the date you get the overall numbers
Select Sum(new_cases) as total_global_cases, Sum(cast(new_deaths as int)) as total_global_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathRate
From PortfolioProject..CovidDeaths
--Where location like 'United States'
where continent is not null
order by 1,2


--Joining the vaccinations spreadsheet with deaths
---and comparing Vaccinations to Total Population
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as rolling_count
--CAST can be replaced by CONVERT(int,...)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3




--CTE (must have the same # of columns as what you put in there)

With VacRate (continent, Location, Date, population, new_vaccinations, rolling_count)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as rolling_count
--CAST can be replaced by CONVERT(int,...)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 (can't be in the CTE)
)
Select *, (rolling_count/population)*100
From VacRate
-- if I wanted to look at the most current vaccinated % of population I would need to remove date




--Temp Table
Drop Table if exists #PercentVac --use to make changes
Create Table #PercentVac
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rolling_count numeric
)
Insert into #PercentVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as rolling_count
--CAST can be replaced by CONVERT(int,...)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 (can't be in the Temp Table)

Select *, (rolling_count/population)*100
From #PercentVac
order by 2,3



--Creating view (visualization) for later
Use PortfolioProject
GO
Create View PercentVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as rolling_count
--CAST can be replaced by CONVERT(int,...)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 (can't be in the Temp Table)



Select *
From PercentVac