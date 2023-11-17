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