Select * 
From ProjectCovid..CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--From ProjectCovid..CovidVaccination
--order by 3 , 4

-- Select Data that we are going to be using

Select location, date,total_cases, new_cases,total_deaths , population 
From ProjectCovid..CovidDeaths
order by 1 , 2

-- Looking for total cases bs total deaths
-- Likelyhood that you could die if you had covid

Select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectCovid..CovidDeaths
Where location like '%states%'
order by 1 , 2

-- Looking at total cases vs population
-- shows the % of people who got covid

Select location, date,population,total_cases, (total_cases/population)*100 as AffectedPercentage
From ProjectCovid..CovidDeaths
--Where location like '%states%'
order by 1 , 2  


-- Highest infection rate
Select location,population,max(total_cases) as hieshestInfectionCount,
max((total_cases/population)*100) as MaxAffectedPercentage
From ProjectCovid..CovidDeaths
--Where location like '%states%'
group by Location , population
order by MaxAffectedPercentage desc

--showing countries with highest death count per population
Select location,  max(cast(total_deaths as int))  as Totaldeathcount
From ProjectCovid..CovidDeaths
--Where location like '%states%'
Where continent is not null
group by location
order by Totaldeathcount desc
 
 Select location,  max(cast(total_deaths as int))  as Totaldeathcount
From ProjectCovid..CovidDeaths
--Where location like '%states%'
Where continent is not null
group by location
order by Totaldeathcount desc


-- Showing continents with highest death count per population
Select date,sum(total_cases)  as total_cases, sum(cast(new_deaths as int)) as totaldeaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as deathPercentage
From ProjectCovid..CovidDeaths
where continent is not null
group by date
order by 1,2


--Total population vs vaccination

with Popvsvac (Continent , location , date , population ,new_vaccinations, rollingpeoplevaccinated)
as
(select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , 
dea.date) as rollingpeoplevaccinated-- we can use cast or convert 
from ProjectCovid..CovidDeaths as dea
join ProjectCovid..CovidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * , (rollingpeoplevaccinated/population)*100
from Popvsvac


-- Temp Table
Drop table if exists #PercentPopulationVaccinated
 Create table #PercentPopulationVaccinated
 (
 Continent nvarchar(225),
 Location nvarchar(225),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
rollingpeoplevaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,
dea.date) as rollingpeoplevaccinated-- we can use cast or convert 
from ProjectCovid..CovidDeaths as dea
join ProjectCovid..CovidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * , (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated



-- creating view to store data for later visualization
create view PercentPopulationVaccinated as 
select dea.continent , dea.location , dea.date , dea.population ,vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,
dea.date) as rollingpeoplevaccinated-- we can use cast or convert 
from ProjectCovid..CovidDeaths as dea
join ProjectCovid..CovidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated