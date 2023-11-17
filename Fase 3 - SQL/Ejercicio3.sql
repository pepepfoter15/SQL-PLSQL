--3. Muestra el importe total de las apuestas de cada uno de los caballos que participaron en la primera carrera de la temporada 2014.
--HECHO POR JOSEMA.
--(Ya que no hay datos en 2014 he usado los datos que existian y he usado el año 2017 )
--Primera carrera
create or replace view primcarrera
as select * from carrerasprofesionales where extract(year from fechaHora) = 2017
order by fechaHora ASC
fetch first 1 row only;

--ver los caballos q participaron en esa carrera:
create or replace view participantes
as select codigocaballo from participaciones 
where codigoCarrera = (select codigocarrera from primcarrera);

--Importe apostado por caballo
select codigocaballo, sum(importeapostado) as Total_Apostado from apuestas 
where codigocaballo in (select codigocaballo from participantes) 
group by codigocaballo;
