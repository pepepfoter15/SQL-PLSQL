--8.- Realiza los módulos de programación necesarios para evitar que un propietario apueste por un caballo que no sea de su propiedad si en esa misma carrera corre algún caballo suyo
--AUTOR: MARIO Y GONZALO.

--En este ejercicio, primero crearemos un procedimeinto para comprobar que el cliente es propietario y buscandolo en la tabla de propietarios.
CREATE OR REPLACE PROCEDURE comprobar_propietario(p_dnicliente apuestas.dnicliente%TYPE, p_control_propietario OUT BOOLEAN)
IS
  v_propietario NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_propietario
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
  comprobar_propietario(:NEW.dnicliente,v_control_propietario);
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
--Primero, añado un cliente que sea propietario que pueda apostar y sea a su vez cliente y propietario.
INSERT INTO clientes VALUES ('53942599N', 'Mario', 'Zayas', 'Garcia', 'Calle Real, 12', 'Sevilla', 'Sevilla','678123467');

--Insertamos una apuesta de un cliente normal que no sea propietario y comprobamos que será necesario (consulta) tener presente cuáles son los caballos que pertenecen al propietario anteriormente añadido como cliente.
INSERT INTO apuestas VALUES ('28841115N',1 ,2 ,300 ,3.10);

--Para las comprobaciones que vienen a continuación será necesario tener presente cuáles son los caballos que pertenecen al propietario anteriormente añadido como cliente.
SELECT *
FROM caballos
WHERE dnipropietario = '53942599N';

--Inserto una apuesta de un propietario en una carrera en la que no corren caballos suyos. Ejemplo carrera 1.
SELECT codigocaballo
FROM participaciones
WHERE codigocarrera = 1;

--Como no hay ningún caballo suyo, le dejará apostar tanto en uno suyo como en uno ajeno.
INSERT INTO apuestas VALUES ('21913124n',1 ,1 ,300 ,3.10);
INSERT INTO apuestas VALUES ('21913124n',1 ,10 ,300 ,3.10);

--Ahora inserto una apuesta de un propietario en una carrera en la corre algún caballo suyo. Ejemplo carrera 3.
SELECT codigocaballo
FROM participaciones
WHERE codigocarrera = 3;

--Comprobación del trigger
INSERT INTO apuestas values ('21913124n',3 ,9 ,300 ,3.10);

INSERT INTO apuestas values ('21913124n',3 ,10 ,300 ,3.10);
INSERT INTO apuestas values ('21913124n',3 ,10 ,300 ,3.10);
