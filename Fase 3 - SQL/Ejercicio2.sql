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
