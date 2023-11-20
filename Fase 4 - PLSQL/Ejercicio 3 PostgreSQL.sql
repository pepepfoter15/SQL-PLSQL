--3. Realiza un trigger que controle que solo participan en una carrera caballos en el rango de edades permitido. Si es necesario, cambia el modelo de datos. 
--AUTOR: GONZALO

CREATE OR REPLACE FUNCTION obtener_fechanac_caballo(p_codigocaballo participaciones.codigocaballo%TYPE, OUT p_fechanac DATE)
AS $$
BEGIN
  SELECT fechanac
  INTO p_fechanac
  FROM caballos
  WHERE codigocaballo = p_codigocaballo;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'El caballo con código % no existe', p_codigocaballo;
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION obtener_fechanac_carreras(p_codigocarrera participaciones.codigocarrera%TYPE)
RETURNS RECORD AS $$
DECLARE
  result_record RECORD;
BEGIN
  SELECT fechanacmin, fechanacmac
  INTO result_record.fechanacmin, result_record.fechanacmac
  FROM carrerasprofesionales
  WHERE codigocarrera = p_codigocarrera;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'La carrera con código % no existe', p_codigocarrera;
  END IF;

  RETURN result_record;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION monitorizar_participaciones_function()
RETURNS TRIGGER AS $$
DECLARE
  v_fechanac_caballo DATE;
  v_fechanacmin_carreras DATE;
  v_fechanacmac_carreras DATE;
BEGIN
  v_fechanac_caballo := obtener_fechanac_caballo(NEW.codigocaballo);
  SELECT fechanacmin, fechanacmac
  INTO v_fechanacmin_carreras, v_fechanacmac_carreras
  FROM obtener_fechanac_carreras(NEW.codigocarrera);

  IF v_fechanac_caballo <= v_fechanacmac_carreras AND v_fechanac_caballo >= v_fechanacmin_carreras THEN
    RETURN NEW;
  ELSE
    RAISE EXCEPTION 'El caballo con código % no está en el rango de edades permitido para la carrera %', NEW.codigocaballo, NEW.codigocarrera;
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER monitorizar_participaciones
BEFORE INSERT OR UPDATE ON participaciones
FOR EACH ROW
EXECUTE FUNCTION monitorizar_participaciones();


INSERT INTO caballos VALUES (11,'21913124n', 'gonzalo', '2015-11-11', 'gonzalo');

INSERT INTO participaciones (codigoparticipacion, codigocarrera, identificacion, codigocaballo, puesto)
VALUES (1, 11, 'Y6857984L', 1, 1);

INSERT INTO participaciones (codigoparticipacion, codigocarrera, identificacion, codigocaballo, puesto)
VALUES (1, 100, 'Y6857984L', 1, 1);

INSERT INTO participaciones (codigoparticipacion, codigocarrera, identificacion, codigocaballo, puesto)
VALUES (100, 11, 'Y6857984L', 1, 1);