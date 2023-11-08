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
