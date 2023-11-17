--1. El jockey de menor estatura va a participar en la última carrera de la temporada con el caballo que más veces utilizó las instalaciones del hipódromo en el año 2014. Su dorsal será el 23 y todavía no sabemos en que posición acabará. Inserta el registro correspondiente.
--HECHO POR JOSEMA Y CON AYUDA DE PEPE.
--(Hemos usado en vez del año 2014, el año 2017 ya que teniamos todos los registros en ese año.)

--DNI Jockey mas pequeño:
select DNI from jockeys order by altura ASC
fetch first 1 row only;

--Caballos que mas veces a usado las instalaciones:
select c.nombre,cu.codigoCaballo, count(*) as Veces_uso from cuadrante cu, caballos c 
where c.codigocaballo=cu.codigocaballo and extract(year from cu.fechaHora) = 2017
group by cu.codigocaballo, c.nombre
order by Veces_uso DESC
fetch first 1 row only;

--Ver codigo de la ultima carrera del año:
select codigoCarrera from carrerasProfesionales order by fechahora DESC
fetch first 1 row only;

--Insertar los datos:
insert into participaciones
values(6, 2, '85108890N', 23, NULL);