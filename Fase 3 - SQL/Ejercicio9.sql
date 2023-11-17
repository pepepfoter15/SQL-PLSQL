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
