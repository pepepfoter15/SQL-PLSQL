--3. Realiza un trigger que controle que solo participan en una carrera caballos en el rango de edades permitido. Si es necesario, cambia el modelo de datos. 
--AUTOR: GONZALO Y MARIO.
CREATE OR REPLACE PROCEDURE obtener_fechanac_caballo(p_codigocaballo participaciones.codigocaballo%TYPE, p_fechanac OUT DATE)
IS
BEGIN
  SELECT fechanac
  INTO p_fechanac
  FROM caballos
  WHERE codigocaballo = p_codigocaballo;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20002, 'El caballo con código ' || p_codigocaballo || ' no existe');
END;
/

CREATE OR REPLACE PROCEDURE obtener_fechanac_carreras(p_codigocarrera participaciones.codigocarrera%TYPE, p_fechanacmin OUT DATE, p_fechanacmac OUT DATE)
IS
BEGIN
  SELECT fechanacmin, fechanacmac
  INTO p_fechanacmin, p_fechanacmac
  FROM carrerasprofesionales
  WHERE codigocarrera = p_codigocarrera;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20002, 'La carrera con código ' || p_codigocarrera || ' no existe');
END;
/

CREATE OR REPLACE TRIGGER monitorizar_participaciones
  BEFORE INSERT OR UPDATE ON participaciones
  FOR EACH ROW
DECLARE
  v_fechanac_caballo caballos.fechanac%TYPE;
  v_fechanacmin_carreras DATE;
  v_fechanacmac_carreras DATE;
BEGIN
  obtener_fechanac_caballo(:NEW.codigocaballo, v_fechanac_caballo);
  obtener_fechanac_carreras(:NEW.codigocarrera, v_fechanacmin_carreras, v_fechanacmac_carreras);

  IF v_fechanac_caballo <= v_fechanacmac_carreras AND v_fechanac_caballo >= v_fechanacmin_carreras THEN
    NULL; 
  ELSE
    RAISE_APPLICATION_ERROR(-20001, 'El caballo con codigo ' || :NEW.codigocaballo || ' no esta en el rango de edades permitido para la carrera ' || :NEW.codigocarrera);
  END IF;
END;
/


INSERT INTO caballos values (11,'21913124n', 'gonzalo', to_date('11-11-2015', 'DD-MM-YYYY'), 'gonzalo' );

INSERT INTO participaciones values(1, 11, 'Y6857984L', 1, 1);
