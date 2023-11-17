--4. Muestra los datos del cliente que ha ganado más dinero con las apuestas en los tres últimos meses.
--HECHO POR JOSEMA.
--He insertado datos nuevos actuales, como nuevas apuestas y nuevas carreras realizadas en los 3 ultimos meses.

--Carreras de los ultimos 3 meses.
create view ultimascarreras
as select * from carrerasprofesionales 
where fechahora >= sysdate - interval '3' month;

--caballos que han ganado una carrera de los ultimos 3 meses
create or replace view ganadores
as select p.codigocaballo, p.codigocarrera 
from participaciones p, ultimascarreras c 
where posicionfinal = 1 and c.codigocarrera=p.codigocarrera;

--apuestas ganadas, que mas dinero ha ganado en los ultimos 3 meses.:
create or replace view apuestasganadas
as select dnicliente, importeapostado * tantoAUno as ganancias from apuestas 
where (codigocarrera, codigocaballo) in (select codigocarrera, codigocaballo from ganadores)
order by ganancias DESC
fetch first 1 row only;

--Mostrar datos cliente:
select * from clientes 
where dni = (select dnicliente from apuestasganadas);