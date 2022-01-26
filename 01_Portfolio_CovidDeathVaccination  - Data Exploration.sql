

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Dta that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- It shows the lilelihood (chances) of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DearthPercentage
From PortfolioProject..CovidDeaths
Where location like '%United%'
order by 1,2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population ghot  Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Kingdom%'
order by 1,2

-- Looking at Countries with the Highest Infection Rate compared to Popuplation 

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Kingdom%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected Desc

-- Showing Countris with Highest Death Count per Population 

Select Location,MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Kingdom%'
Group by Location
order by TotalDeathCount Desc   -- Query has an issue with total_deaths and needs to be coverted into integer(int)

Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Kingdom%'
Where continent is not null
Group by Location
order by TotalDeathCount Desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing continents with the highest death count per population 

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Kingdom%'
Where continent is not null
Group by continent
order by TotalDeathCount Desc  -- It is not calculation properly (US is the total for North America) which ia wrong

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Kingdom%'
Where continent is null
Group by location
order by TotalDeathCount Desc   -- 1st option 

-- GLOBAL NUMBERS 

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DearthPercentage
From PortfolioProject..CovidDeaths
--Where location like '%United%'
Where continent is not null
Group by date
order by 1,2   -- Query will give you totals by date

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DearthPercentage
From PortfolioProject..CovidDeaths
--Where location like '%United%'
Where continent is not null
--Group by date
order by 1,2   --This Query will give you all Totals


-- Looking at Total population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3


-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 
From PopvsVac

--TEMP TABLE 

Drop Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated	
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
		and dea.date =vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data fopr visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
		and dea.date =vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated

-- -- Queries used for Tableau Project 

-- 1

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DearthPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Kingdom%'
Where continent is not null
--Group by date
order by 1,2

-- Just a doible check off the data provided 
-- numbers are extremely close so we will keep them - The Second includes "International" Location 

--Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DearthPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%Kingdom%'
--Where location = 'World'
----Group by date
--order by 1,2

-- 2

-- We took these out as they are not included in the above queries and I want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Kingdom%'
Where continent is null
and location not in ('World', 'European Union', 'International', 'Upper middle income','High income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc 


-- 3

Select location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Kingdom%'
--Where continent is null
Group by location, population
order by PercentPopulationInfected Desc 

-- 4

Select location, Population, date, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Kingdom%'
--Where continent is null
Group by location, population, date
order by PercentPopulationInfected Desc 

