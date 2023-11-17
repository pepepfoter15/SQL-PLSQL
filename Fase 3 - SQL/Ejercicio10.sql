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
