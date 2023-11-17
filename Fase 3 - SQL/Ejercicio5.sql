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