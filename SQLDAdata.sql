with mes_tratado as (
SELECT 
	date,
	instr(date,'/') as etapa_1,
	substr(date,1, instr(date,'/')) as etapa_2,
	substr(date,1, instr(date,'/')-1) as etapa_3,
	case 
		when cast(substr(date,1, instr(date,'/')-1) as integer) < 10 then "0" || date
		else date
	end as date_trat
FROM CovidVaccinations cv
), data_oficial as (
select
	date_trat,
	instr(date_trat,'/'), 
	substr(date_trat,4, instr(date_trat,'/')),
	CASE 
		when cast(substr(date_trat,4, instr(date_trat,'/')-1) as integer) < 10 then substr(date_trat,1, instr(date_trat,'/')) || "0" || substr(date_trat,4,8)
		else date_trat
	END as data
	
from mes_tratado
)
select data 
FROM data_oficial