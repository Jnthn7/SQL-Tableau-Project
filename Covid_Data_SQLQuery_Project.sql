
-- Opening the data for both excel files (covid deaths and covid vaccinations)
Select *
From [SQL-Tableau Project]..Covid_Data_Deaths
order by 3,4

Select *
From [SQL-Tableau Project]..Covid_Data_Vaccinations
order by 3,4


-- Lets pull the columns in the data we will be using for our dashboard
Select location, date, total_cases, new_cases, total_deaths, population
From [SQL-Tableau Project]..Covid_Data_Deaths
order by 1,2

---------------------------------------  QUERIES  ---------------------------------------

-- 1. Looking at Countries and their Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as FatalityRate
From [SQL-Tableau Project]..Covid_Data_Deaths
Where continent is not null --and location like '%states%'
order by 1,2


-- 2. Looking at Total Cases vs Total Population
Select location, date, population, total_cases, (total_cases/population)*100 as PopulationInfected
From [SQL-Tableau Project]..Covid_Data_Deaths
Where continent is not null --and location like '%states%'
order by 1,2


-- 3. Looking at Countries with Highest Infection Rate compared to Countries Total Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [SQL-Tableau Project]..Covid_Data_Deaths
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc

--Modified query from above for visualization on Tableau
Select location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [SQL-Tableau Project]..Covid_Data_Deaths
Where continent is not null
Group by location, population, date
order by PercentPopulationInfected desc


-- 4. Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalCountryDeathCount
From [SQL-Tableau Project]..Covid_Data_Deaths
Where continent is not null
Group by location
order by TotalCountryDeathCount desc


-- 5. Let's break things down by continent
-- Showing Continents with the Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalContinentDeathCount
From [SQL-Tableau Project]..Covid_Data_Deaths
Where continent is null and location not like '%world%' and location not like '%income%' and location not like '%international%' and location not like '%European%'
Group by location
order by TotalContinentDeathCount desc


-- 6. Worldwide Numbers when comparing Worldwide Cases vs Worldwide Deaths
Select SUM(new_cases) as WorldCases, SUM(cast(new_deaths as int)) as WorldDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as WorldFatalityRate
From [SQL-Tableau Project]..Covid_Data_Deaths
Where continent is not null --and location like '%states%'
order by 1,2


-- 7. Join Covid Deaths and Vaccinations Data for further analysis
Select *
From [SQL-Tableau Project]..Covid_Data_Deaths deaths
Join [SQL-Tableau Project]..Covid_Data_Vaccinations vaccinations
on deaths.location = vaccinations.location and deaths.date = vaccinations.date


-- 8. CTE Total Population vs Vaccinations using the Join from previous query
With PopulationvsVaccinated (continent, location, date, population, new_vaccinations, RollingCountVaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(CONVERT(bigint,vaccinations.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as RollingCountVaccinated
From [SQL-Tableau Project]..Covid_Data_Deaths deaths
Join [SQL-Tableau Project]..Covid_Data_Vaccinations vaccinations
on deaths.location = vaccinations.location and deaths.date = vaccinations.date
where deaths.continent is not null
)
Select *, ((RollingCountVaccinated/population)*100) as RollingPercentVaccinated
From PopulationvsVaccinated