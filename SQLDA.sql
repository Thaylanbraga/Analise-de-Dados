/* 2-Faça uma tabela com uma coluna de total de casos 
e outra com total de mortes por país*/
SELECT 
	DISTINCT location,
	SUM(new_cases) as casos,
	SUM(new_deaths) as mortes
FROM CovidDeaths cd 
WHERE iso_code not LIKE 'OWID%' and continent not like ''
GROUP BY 1

/*3-Mostre a probabilidade de morrer se contrair covid em cada país
 * */
SELECT 
	DISTINCT location,
	SUM(new_cases) as casos,
	SUM(new_deaths) as mortes,
	round((SUM(new_deaths)/SUM(new_cases))*100,2) as probabilidade_morte
FROM CovidDeaths cd 
WHERE iso_code not LIKE 'OWID%' and continent not like ''
GROUP BY 1

/*4-Faça uma tabela com uma coluna de total de casos  e outra com 
 * total população por país
 * */
SELECT 
	DISTINCT location,
	SUM(new_cases) as casos,
	SUM(new_deaths) as mortes,
	population 
FROM CovidDeaths cd 
WHERE iso_code not LIKE 'OWID%' and continent not like ''
GROUP BY 1

/*5-Mostre a probabilidade de se infectar com Covid por país
 * */

SELECT 
	DISTINCT location,
	SUM(new_cases) as casos,
	SUM(new_deaths) as mortes,
	population,
	--NA LINHA ABAIXO FAZEMOS O CALCULA DE PROBABILIDADE DE MORRER
	--CASO VENHA A CONTRAIR A DOENÇA
	round((SUM(new_deaths)/SUM(new_cases))*100,2) as probabilidade_morte,
	--NA LINHA ABAIXO FAZEMOS O CALCULA DE PROBABILIDADE DE CONTRAIR
	--A DOENÇA, A CADA 1000 PESSOAS
	round (1000*SUM(new_cases) / population,2) as contrair_covid_a_cada_1000pessoas,
	--NA LINHA ABAIXO FAZEMOS O CALCULA DE PROBABILIDADE DE MORRER
	--CASO VENHA A CONTRAIR A DOENÇA, A CADA 1000 PESSOAS
	round (1000*SUM(new_deaths) / sum(new_cases),2) as morte_a_cada_1000_pessoas_infect
FROM CovidDeaths cd 
WHERE iso_code not LIKE 'OWID%' and continent not like ''
GROUP BY 1

/*
  6-Quais são os países com maior taxa de infecção?
 */
SELECT 
	DISTINCT location,
	SUM(new_cases) as casos,
	SUM(new_deaths) as mortes,
	population,
	--NA LINHA ABAIXO FAZEMOS O CALCULA DE PROBABILIDADE DE MORRER
	--CASO VENHA A CONTRAIR A DOENÇA
	round((SUM(new_deaths)/SUM(new_cases))*100,2) as probabilidade_morte,
	--NA LINHA ABAIXO FAZEMOS O CALCULA DE PROBABILIDADE DE CONTRAIR
	--A DOENÇA, A CADA 1000 PESSOAS
	round (1000*SUM(new_cases) / population,2) as contrair_covid_a_cada_1000pessoas,
	--NA LINHA ABAIXO FAZEMOS O CALCULA DE PROBABILIDADE DE MORRER
	--CASO VENHA A CONTRAIR A DOENÇA, A CADA 1000 PESSOAS
	round (1000*SUM(new_deaths) / sum(new_cases),2) as morte_a_cada_1000_pessoas_infect
FROM CovidDeaths cd 
WHERE iso_code not LIKE 'OWID%' and continent not like ''
GROUP BY 1
ORDER BY 6 DESC 

/*
 * 7-Quais são os países com maior taxa de morte?
 * */

SELECT 
	DISTINCT location,
	SUM(new_cases) as casos,
	SUM(new_deaths) as mortes,
	population,
	--NA LINHA ABAIXO FAZEMOS O CALCULA DE PROBABILIDADE DE MORRER
	--CASO VENHA A CONTRAIR A DOENÇA
	round((SUM(new_deaths)/SUM(new_cases))*100,2) as probabilidade_morte,
	--NA LINHA ABAIXO FAZEMOS O CALCULA DE PROBABILIDADE DE CONTRAIR
	--A DOENÇA, A CADA 1000 PESSOAS
	round (1000*SUM(new_cases) / population,2) as contrair_covid_a_cada_1000pessoas,
	--NA LINHA ABAIXO FAZEMOS O CALCULA DE PROBABILIDADE DE MORRER
	--CASO VENHA A CONTRAIR A DOENÇA, A CADA 1000 PESSOAS
	round (1000*SUM(new_deaths) / sum(new_cases),2) as morte_a_cada_1000_pessoas_infect
FROM CovidDeaths cd 
WHERE iso_code not LIKE 'OWID%' and continent not like ''
GROUP BY 1
ORDER BY 5 DESC 

/*
 * 8-Mostre os continentes com a maior taxa de morte
 * */

SELECT 
	DISTINCT continent,
	SUM(new_cases) as casos,
	SUM(new_deaths) as mortes,
	population,
	--NA LINHA ABAIXO FAZEMOS O CALCULA DE PROBABILIDADE DE MORRER
	--CASO VENHA A CONTRAIR A DOENÇA
	round((SUM(new_deaths)/SUM(new_cases))*100,2) as probabilidade_morte,
	--NA LINHA ABAIXO FAZEMOS O CALCULA DE PROBABILIDADE DE CONTRAIR
	--A DOENÇA, A CADA 1000 PESSOAS
	round (1000*SUM(new_cases) / population,2) as contrair_covid_a_cada_1000pessoas,
	--NA LINHA ABAIXO FAZEMOS O CALCULA DE PROBABILIDADE DE MORRER
	--CASO VENHA A CONTRAIR A DOENÇA, A CADA 1000 PESSOAS
	round (1000*SUM(new_deaths) / sum(new_cases),2) as morte_a_cada_1000_pessoas_infect
FROM CovidDeaths cd 
WHERE iso_code NOT LIKE 'OWID%' and continent not like ''
GROUP BY 1
ORDER BY 3 DESC 

/*9-População Total vs Vacinações: mostre a porcentagem da população que  
 *recebeu pelo menos uma vacina contra a Covid
 * */

/*10-Importante mostrar acumulado de vacina por data e localização
 * */



with mes_tratado as (
SELECT 
	cv.location,
	cd.population,
	cv.people_vaccinated,
	cv.total_vaccinations,
	case 
		when cast(substr(cv.date,1, instr(cv.date,'/')-1) as integer) < 10 then "0" || cv.date
		else cv.date
	end as date_trat
FROM CovidVaccinations cv
left join CovidDeaths cd
	on cv.iso_code = cd.iso_code
WHERE cv.iso_code not LIKE 'OWID%' AND cd.iso_code 
not LIKE 'OWID%'
), data_oficial as (
select
	location,
	CASE 
		when cast(substr(date_trat,4, instr(date_trat,'/')-1) as integer) < 10 then substr(date_trat,1, instr(date_trat,'/')) || "0" || substr(date_trat,4,8)
		else date_trat
	END as data,
	population,
	people_vaccinated,
	total_vaccinations	
from mes_tratado
)
select  DISTINCT  *,
	round(MAX(cast(people_vaccinated as real)) / MAX(population) * 100,2 ) as '%_de pessoas_vacinadas'
FROM data_oficial
GROUP BY 1,2,4,5
ORDER BY 2 ASC 



/*11-Crie uma view para armazenar dados para visualizações posteriores
 * */