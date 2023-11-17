1. Realiza una función que reciba como parámetros un código de carrera y un código de caballo y devuelva el importe total que tendrá que pagar el hipódromo a los apostantes suponiendo que dicha carrera sea ganada por el caballo recibido como parámetro. Se deben contemplar las siguientes excepciones: Carrera inexistente, Caballo inexistente, Caballo no participante en esa carrera. 

CREATE OR REPLACE FUNCTION importetotal (
    p_codcarrera apuestas.codigocarrera%type,
    p_codcaballo apuestas.codigocaballo%type
) RETURN NUMBER IS
    v_mult NUMBER;
BEGIN
    comprobarvacias(p_codcarrera, p_codcaballo);

    SELECT importeapostado * tantoauno INTO v_mult
    FROM apuestas
    WHERE codigocarrera = p_codcarrera AND codigocaballo = p_codcaballo;

    dbms_output.put_line('Hay que pagar al ganador un total de ' || v_mult || ' euros');
    
    RETURN v_mult;
END;
/

CREATE OR REPLACE PROCEDURE comprobarvacias (
    p_codcarrera apuestas.codigocarrera%type,
    p_codcaballo apuestas.codigocaballo%type
) IS
    v_carrera        NUMBER;
    v_caballo        NUMBER;
    v_caballocarrera NUMBER;
BEGIN
    SELECT COUNT (*) INTO v_carrera
    FROM apuestas
    WHERE codigocarrera = p_codcarrera;

    IF v_carrera = 0 THEN
        raise_application_error(-20112, 'No existe la carrera');
    END IF;

    SELECT COUNT (*) INTO v_caballo
    FROM apuestas
    WHERE codigocaballo = p_codcaballo;

    IF v_caballo = 0 THEN
        raise_application_error(-20110, 'No se ha encontrado el caballo');
    END IF;

    SELECT COUNT (*) INTO v_caballocarrera
    FROM participaciones
    WHERE codigocarrera = p_codcarrera AND codigocaballo = p_codcaballo;
    
    IF v_caballocarrera = 0 THEN
        raise_application_error(-20103, 'No existen caballos en esas carreras');
    END IF;
dbms_output.put_line('Comprobado que están vacias');
END;
/

Funcionamiento de la función: 

DECLARE
    v_resultado NUMBER;
BEGIN
    v_resultado := importetotal('1', '2');
    dbms_output.put_line('El importe total es: ' || v_resultado || ' euros');
END;
/

Funcionamiento del procedimiento:

EXEC comprobarvacias('0', '2');
EXEC comprobarvacias('2', '0');
EXEC comprobarvacias('2', '3');
EXEC comprobarvacias('2', '7');

3. Realiza un trigger que controle que solo participan en una carrera caballos en el rango de edades permitido. Si es necesario, cambia el modelo de datos. 

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


5. Añade una columna a la tabla Propietarios llamada ImporteTotalPremios. Rellénala con un procedimiento o una sentencia SQL considerando los premios que han conseguido los caballos de cada uno de ellos por sus victorias en las carreras. Haz un trigger que la mantenga actualizada cada vez que se realice cualquier cambio en la tabla Participaciones que afecte a este total. 

CREATE OR REPLACE PROCEDURE importe_total IS
    CURSOR c_propietarios IS
        SELECT nombre
        FROM propietarios
        WHERE dni IN (
                SELECT dnipropietario
                FROM caballos
                WHERE codigocaballo IN (
                        SELECT codigocaballo
                        FROM participaciones
                        WHERE posicionfinal=1
                    )
            );
    v_importe NUMBER;
BEGIN
    FOR i IN c_propietarios LOOP

        SELECT SUM(importepremio) INTO v_importe
        FROM carrerasprofesionales
        WHERE codigocarrera IN (
                SELECT codigocarrera
                FROM participaciones
                WHERE posicionfinal=1 AND codigocaballo IN (
                        SELECT codigocaballo
                        FROM caballos
                        WHERE dnipropietario IN (
                                SELECT dni
                                FROM propietarios
                                WHERE nombre=i.nombre
                            )
                    )
            );

        UPDATE propietarios
        SET
            importetotalpremios=v_importe
        WHERE
            nombre=i.nombre;
            
    END LOOP;
END importe_total;
/
 
CREATE OR REPLACE TRIGGER nueva_carrera
    BEFORE INSERT OR UPDATE ON participaciones
BEGIN
    importe_total;
END;
/
