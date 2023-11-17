--7. Muestra para cada carrera el caballo más joven que ha participado en la misma.
--HECHO POR JOSEMA.
select cp.codigoCarrera, c.codigoCaballo, c.nombre as NombreCaballo, c.fechaNac as FechaNacimiento 
from participaciones p, caballos c, carrerasProfesionales cp
where p.codigoCaballo = c.codigoCaballo and p.codigoCarrera = cp.codigoCarrera 
and c.fechaNac = (select MIN(c1.fechaNac) from participaciones p1, caballos c1 where p1.codigoCaballo = c1.codigoCaballo and p1.codigoCarrera = cp.codigoCarrera);

