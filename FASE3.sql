


--2. El caballo más joven del propietario que ha ganado más carreras entre todos sus caballos ha engordado siete kilos. Registra el cambio en la base de datos.
--HECHO POR PEPE.
--Creamos una vista que nos nmuestre con ayuda de joins, el dni y el codigo de caballo del más joven que haya ganado mas carreras.

CREATE OR REPLACE VIEW VistaPropietarioCaballo AS
SELECT
    c.dniPropietario AS DNIPropietario,
    c.codigoCaballo AS CodigoCaballo
FROM
    caballos c
WHERE
    c.dniPropietario = (
        SELECT
            c.dniPropietario
        FROM
            caballos c
        JOIN participaciones pa ON c.codigoCaballo = pa.codigoCaballo
        JOIN carrerasProfesionales cp ON pa.codigoCarrera = cp.codigoCarrera
        WHERE
            pa.posicionFinal = 1
        GROUP BY
            c.dniPropietario
        HAVING
            COUNT(DISTINCT cp.codigoCarrera) = (SELECT MAX(cantidadCarreras) FROM (SELECT dniPropietario, COUNT(DISTINCT cp.codigoCarrera) AS cantidadCarreras FROM caballos c JOIN participaciones pa ON c.codigoCaballo = pa.codigoCaballo JOIN carrerasProfesionales cp ON pa.codigoCarrera = cp.codigoCarrera WHERE pa.posicionFinal = 1 GROUP BY dniPropietario))
    ) AND ROWNUM = 1;


--Modificación del contenido del peso del caballo :)
UPDATE caballosCarreras
SET peso = peso + 7
WHERE codigoCaballo IN (SELECT CodigoCaballo FROM VistaPropietarioCaballo);

SELECT *
FROM caballosCarreras WHERE codigoCaballo = '1';


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


--5. Muestra los propietarios de caballos que hayan ocupado todas y cada una de las tres posiciones del podio en las diferentes carreras en las que hayan participado.
--HECHO POR PEPE.
SELECT
    pr.dni,
    pr.nombre AS NombrePropietario
FROM
    propietarios pr
WHERE
    (
        SELECT COUNT(DISTINCT pa.posicionFinal)
        FROM participaciones pa, caballos c
        WHERE pa.codigoCaballo = c.codigoCaballo
        AND c.dniPropietario = pr.dni
        AND pa.posicionFinal IN (1, 2, 3)
    ) = 3;


--6. Muestra el número de abandonos de cada uno de los caballos, incluyendo aquéllos que no hayan sufrido ningún abandono.
--Muestra los caballos abandonados haciendo referencia a que si no tienen codigo de carrera, están sin dueño.
--HECHO POR MARIO Y CON AYUDA DE PEPE.
SELECT
    c.codigoCaballo,
    c.nombre AS NombreCaballo,
    COUNT(p.codigoCarrera) AS NumeroAbandonos
FROM
    caballos c
LEFT JOIN participaciones p ON c.codigoCaballo = p.codigoCaballo AND p.posicionFinal = -1
GROUP BY
    c.codigoCaballo, c.nombre
ORDER BY
    c.codigoCaballo;


--7. Muestra para cada carrera el caballo más joven que ha participado en la misma.
--HECHO POR JOSEMA.
select cp.codigoCarrera, c.codigoCaballo, c.nombre as NombreCaballo, c.fechaNac as FechaNacimiento 
from participaciones p, caballos c, carrerasProfesionales cp
where p.codigoCaballo = c.codigoCaballo and p.codigoCarrera = cp.codigoCarrera 
and c.fechaNac = (select MIN(c1.fechaNac) from participaciones p1, caballos c1 where p1.codigoCaballo = c1.codigoCaballo and p1.codigoCarrera = cp.codigoCarrera);


--8. Muestra el último caballo que ganó una carrera de cada uno de los propietarios.
--HECHO POR PEPE.
SELECT
    p.dni,
    p.nombre AS NombrePropietario,
    (SELECT MAX(cp.fechaHora)
     FROM carrerasProfesionales cp, participaciones pa
     WHERE pa.codigoCarrera = cp.codigoCarrera
       AND pa.posicionFinal = 1
       AND pa.codigoCaballo = c.codigoCaballo) AS UltimaCarreraGanada,
    c.codigoCaballo AS UltimoCaballoGanador
FROM
    propietarios p, caballos c, participaciones pa
WHERE
    p.dni = c.dniPropietario
    AND c.codigoCaballo = pa.codigoCaballo
    AND pa.posicionFinal = 1
GROUP BY
    p.dni, p.nombre, c.codigoCaballo;


--9. Muestra los propietarios que nunca han tenido uno de sus caballos en el podio.
--HECHO POR MARIO Y CON AYUDA PEPE.
SELECT
    p.dni,
    p.nombre AS NombrePropietario
FROM
    propietarios p
WHERE
    p.dni NOT IN (
        SELECT DISTINCT c.dniPropietario
        FROM
            caballos c, participaciones pa
        WHERE
            c.codigoCaballo = pa.codigoCaballo
            AND pa.posicionFinal IN (1, 2, 3)
    );


--Prueba de que  el propietario tenga un caballo no metido en el podio es insertando otro nuevo ya que todos han estado previamente en el podio.
insert into propietarios
values ('X77056225B', 'Pepe', 'Gutierrez', ' ',150);

insert into caballos
values (11,'X77056225B', 'Dagoberto', '9-10-2010','Purasangre español' );

insert into participaciones
values(1, 11, 'Y6857984L', 24, 7);


--10.Crea una vista en la que aparezca la carrera que ha hecho ganar más dinero a cada uno de los clientes, junto con el importe de los beneficios obtenidos.
--HECHO POR GONZALO
CREATE VIEW vista_ganancias_clientes AS
SELECT c.dni AS cliente_dni, c.nombre AS cliente_nombre, c.apellido1 AS cliente_apellido1, c.apellido2 AS cliente_apellido2,
       a.dniCliente, a.codigoCarrera,
       cp.fechaHora AS fecha_carrera,
       SUM(a.importeApostado * a.tantoAUno) AS ganancias
FROM clientes c
JOIN apuestas a ON c.dni = a.dniCliente
JOIN carrerasProfesionales cp ON a.codigoCarrera = cp.codigoCarrera
GROUP BY c.dni, c.nombre, c.apellido1, c.apellido2, a.dniCliente, a.codigoCarrera, cp.fechaHora
HAVING SUM(a.importeApostado * a.tantoAUno) = (
  SELECT MAX(SUM(a2.importeApostado * a2.tantoAUno))
  FROM apuestas a2
  JOIN carrerasProfesionales cp2 ON a2.codigoCarrera = cp2.codigoCarrera
  WHERE a2.dniCliente = a.dniCliente
  GROUP BY a2.dniCliente, a2.codigoCarrera
)
ORDER BY c.dni, ganancias DESC;

SELECT * FROM vista_ganancias_clientes;
