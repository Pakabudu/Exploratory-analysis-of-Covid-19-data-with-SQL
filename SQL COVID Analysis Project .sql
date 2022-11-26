SELECT * 
From [Portfolio Project] ..CovidDeaths
Where continent is not null 
order by 3,4

--SELECT * 
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

Select location, date, total_cases,new_cases,total_deaths, population
From [Portfolio Project] ..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project] ..CovidDeaths
order by 1,2

--For the US alone 
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project] ..CovidDeaths
Where location like '%states%'
And  continent is not null 
order by 1,2

--Looking at the Total Cases Vs Population 
-- Shows what percentage of population got Covid

Select location, date, population total_cases,(total_cases/population)*100 as CasesPercentage
From [Portfolio Project] ..CovidDeaths
Where location like '%states%'
And continent is not null 
order by 1,2

Select location, date, population total_cases,(total_cases/population)*100 as PercentagePopulationInfected
From [Portfolio Project] ..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at Countries with Higest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From [Portfolio Project] ..CovidDeaths
--Where location like '%states%'
Group by location, population
order by 1,2

--Order by PercentagePopulationInfected

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From [Portfolio Project] ..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentagePopulationInfected desc

--Showing Countries with highest death count per population

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project] ..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by location
Order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project] ..CovidDeaths
--Where location like '%states%'
Where continent is null 
Group by location
Order by TotalDeathCount desc



--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT


Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project] ..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
Order by TotalDeathCount desc


--Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



