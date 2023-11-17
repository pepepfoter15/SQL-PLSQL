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
