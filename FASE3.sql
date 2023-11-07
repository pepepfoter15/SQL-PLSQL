--1. El jockey de menor estatura va a participar en la última carrera de la temporada con el caballo que más veces utilizó las instalaciones del hipódromo en el año 2014. Su dorsal será el 23 y todavía no sabemos en que posición acabará. Inserta el registro correspondiente.



--2. El caballo más joven del propietario que ha ganado más carreras entre todos sus caballos ha engordado siete kilos. Registra el cambio en la base de datos.
--Primero buscamos el dni del propietario con esta select.
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
    COUNT(DISTINCT cp.codigoCarrera) = (SELECT MAX(cantidadCarreras) FROM (SELECT dniPropietario, COUNT(DISTINCT cp.codigoCarrera) AS cantidadCarreras FROM caballos c JOIN participaciones pa ON c.codigoCaballo = pa.codigoCaballo JOIN carrerasProfesionales cp ON pa.codigoCarrera = cp.codigoCarrera WHERE pa.posicionFinal = 1 GROUP BY dniPropietario));

--Segundo, buscamos con el dni que hemos filtrado anteriormente con la otra consulta.
SELECT
    c.codigoCaballo,
    c.fechaNac
FROM
    caballos c
WHERE
    c.dniPropietario = '21913124n'
AND ROWNUM = 1
ORDER BY
    c.fechaNac;

--Modificación del contenido del peso del caballo :)
UPDATE caballosCarreras
SET peso = peso + 7
WHERE codigoCaballo = '1';

--3. Muestra el importe total de las apuestas de cada uno de los caballos que participaron en la primera carrera de la temporada 2014.

--4. Muestra los datos del cliente que ha ganado más dinero con las apuestas en los tres últimos meses.


--5. Muestra los propietarios de caballos que hayan ocupado todas y cada una de las tres posiciones del podio en las diferentes carreras en las que hayan participado.

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

--8. Muestra el último caballo que ganó una carrera de cada uno de los propietarios.

--9. Muestra los propietarios que nunca han tenido uno de sus caballos en el podio.

--10.Crea una vista en la que aparezca la carrera que ha hecho ganar más dinero a cada uno de los clientes, junto con el importe de los beneficios obtenidos.