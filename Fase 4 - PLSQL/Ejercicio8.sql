--8.- Realiza los módulos de programación necesarios para evitar que un propietario apueste por un caballo que no sea de su propiedad si en esa misma carrera corre algún caballo suyo
--AUTOR: PEPE

--En este ejercicio, primero crearemos un procedimeinto para comprobar que el cliente es propietario y buscandolo en la tabla de propietarios.
CREATE OR REPLACE PROCEDURE comprobar_propietario(p_dnicliente apuestas.dnicliente%TYPE, p_control_propietario OUT BOOLEAN)
IS
  v_propietario NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_propietario_si_no
  FROM propietarios
  WHERE dni = p_dnicliente;

  IF v_propietario = 1 THEN
    p_control_propietario := TRUE;
  ELSE
    p_control_propietario := FALSE;
  END IF;
END comprobar_propietario;
/

--Seguido a esto, tenemos que comprobar si el caballo es propiedad de un propietario o no. Lo haremos con el siguiente procediemiento.
CREATE OR REPLACE PROCEDURE comprobar_caballo_propiertario(p_codigocaballo participaciones.codigocaballo%TYPE, p_dnicliente apuestas.dnicliente%TYPE, p_control_caballo_suyo OUT BOOLEAN)
IS
  v_caballo_prop NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_caballo_prop
  FROM caballos
  WHERE dnipropietario = p_dnicliente AND codigocaballo = p_codigocaballo;

  IF v_caballo_prop = 1 THEN
    p_control_caballo_suyo := TRUE;
  ELSE
    p_control_caballo_suyo := FALSE;
  END IF;
END comprobar_caballo_propiertario;
/

--Posteriormente, tendremos que hacer un procedimiento comprueba si alguno de los caballos de una carrera específica es propiedad del propietario que intenta apostar.
CREATE OR REPLACE PROCEDURE comprobar_apuestas_prop(p_codigocarrera apuestas.codigocarrera%TYPE, p_dnicliente apuestas.dnicliente%TYPE, p_control_carrera OUT BOOLEAN)
IS
  CURSOR c_caballos IS
    SELECT codigocaballo
    FROM participaciones
    WHERE codigocarrera = p_codigocarrera;
  v_control BOOLEAN;
  v_cont NUMBER := 0;
BEGIN
  FOR i IN c_caballos LOOP
    comprobar_caballo_propiertario(i.codigocaballo,p_dnicliente,v_control);
    IF v_control = TRUE THEN
      v_cont := v_cont + 1;
    END IF;
  END LOOP;
  IF v_cont > 0 THEN
    p_control_carrera := TRUE;
  ELSE
    p_control_carrera := FALSE;
  END IF;
END comprobar_apuestas_prop;
/

--Por último, creamos un triiger para controlar las apuestas.
CREATE OR REPLACE TRIGGER controlar_apuestas
  BEFORE INSERT OR UPDATE ON apuestas
  FOR EACH ROW
DECLARE
  v_control_propietario BOOLEAN;
  v_control_carrera BOOLEAN;
  v_control_caballo BOOLEAN;
BEGIN
  comprobar_apuestas_prop(:NEW.dnicliente,v_control_propietario);
  IF v_control_propietario = TRUE THEN
    comprobar_apuestas_prop(:NEW.codigocarrera,:NEW.dnicliente,v_control_carrera);
    IF v_control_carrera = TRUE THEN
      comprobar_caballo_propiertario(:NEW.codigocaballo,:NEW.dnicliente,v_control_caballo);
      IF v_control_caballo = FALSE THEN
        RAISE_APPLICATION_ERROR(-20001,'El propietario con DNI ' || :NEW.dnicliente || ' no puede apostar por el caballo con codigo ' || :NEW.codigocaballo || ' porque no es suyo');
      END IF;
    END IF;
  END IF;
END;
/


--Pruebas de funcionamiento