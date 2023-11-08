--1. El jockey de menor estatura va a participar en la última carrera de la temporada con el caballo que más veces utilizó las instalaciones del hipódromo en el año 2014. Su dorsal será el 23 y todavía no sabemos en que posición acabará. Inserta el registro correspondiente.
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



--2. El caballo más joven del propietario que ha ganado más carreras entre todos sus caballos ha engordado siete kilos. Registra el cambio en la base de datos.
--Creamos una vista que nos nmuestre con ayuda de joins, el dni y el codigo de caballo del más joven que haya ganado mas carreras.

CREATE VIEW VistaPropietarioCaballo AS
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

--3. Muestra el importe total de las apuestas de cada uno de los caballos que participaron en la primera carrera de la temporada 2014.
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


--5. Muestra los propietarios de caballos que hayan ocupado todas y cada una de las tres posiciones del podio en las diferentes carreras en las que hayan participado.
SELECT
    pr.dni,
    pr.nombre AS NombrePropietario
FROM
    propietarios pr
WHERE
    (
        SELECT COUNT(DISTINCT pa.posicionFinal)
        FROM participaciones pa
        JOIN caballos c ON pa.codigoCaballo = c.codigoCaballo
        WHERE c.dniPropietario = pr.dni
        AND pa.posicionFinal IN (1, 2, 3)
    ) = 3;

--6. Muestra el número de abandonos de cada uno de los caballos, incluyendo aquéllos que no hayan sufrido ningún abandono.
--Muestra los caballos abandonados haciendo referencia a que si no tienen codigo de carrera, están sin dueño.
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
SELECT
  cp.codigoCarrera,
  c.codigoCaballo,
  c.nombre AS NombreCaballo,
  c.fechaNac AS FechaNacimiento
FROM
  participaciones p
  JOIN caballos c ON p.codigoCaballo = c.codigoCaballo
  JOIN carrerasProfesionales cp ON p.codigoCarrera = cp.codigoCarrera
WHERE
  c.fechaNac = (
    SELECT MIN(c1.fechaNac)
    FROM participaciones p1
    JOIN caballos c1 ON p1.codigoCaballo = c1.codigoCaballo
    WHERE p1.codigoCarrera = cp.codigoCarrera
  );


--8. Muestra el último caballo que ganó una carrera de cada uno de los propietarios.
SELECT
    p.dni,
    p.nombre AS NombrePropietario,
    MAX(cp.fechaHora) AS UltimaCarreraGanada,
    c.codigoCaballo AS UltimoCaballoGanador
FROM
    propietarios p
JOIN caballos c ON p.dni = c.dniPropietario
JOIN participaciones pa ON c.codigoCaballo = pa.codigoCaballo
JOIN carrerasProfesionales cp ON pa.codigoCarrera = cp.codigoCarrera
WHERE
    pa.posicionFinal = 1
GROUP BY
    p.dni, p.nombre, c.codigoCaballo;


--9. Muestra los propietarios que nunca han tenido uno de sus caballos en el podio.
SELECT
    p.dni,
    p.nombre AS NombrePropietario
FROM
    propietarios p
WHERE
    p.dni NOT IN (
        SELECT DISTINCT c.dniPropietario
        FROM
            caballos c
        JOIN participaciones pa ON c.codigoCaballo = pa.codigoCaballo
        WHERE
            pa.posicionFinal IN (1, 2, 3)
    );

--Prueba de que  el propietario tenga un caballo no metido en el podio es insertando otro nuevo ya que todos han estado previamente en el podio.
insert into propietarios
values ('X77056225B', 'Pepe', 'Gutierrez', ' ',150);

insert into caballos
values (11,'X77056225B', 'Dagoberto', '9-10-2010','Purasangre español' );

insert into participaciones
values(1, 11, 'Y6857984L', 24, 7);

--10.Crea una vista en la que aparezca la carrera que ha hecho ganar más dinero a cada uno de los clientes, junto con el importe de los beneficios obtenidos.
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
