--6.- Realiza los módulos de programación necesarios para evitar que un mismo propietario envíe dos caballos a una misma carrera.
--AUTOR: PEPE Y JOSEMA.

--Ya este es un problema alberga un problema de compilación entre tablas mutantes, tendremos que crear un paquete.
--Este tendrá tendrá los valores referentes al dni de la tabla caballos y el codigo de carrera de la tabla participantes.
CREATE OR REPLACE PACKAGE informacionpropietarios AS
    v_codcaballo NUMBER; 
    TYPE resgistrodni IS RECORD ( codigodni caballos.dnipropietario%type, codigocarrera participaciones.codigocarrera%type );
    TYPE tab_controldni IS TABLE OF resgistrodni INDEX BY BINARY_INTEGER;
    info    tab_controldni;
END informacionpropietarios;
/

--Con esto pasamos al trigger que rellene estos datos en la tabla que hemos creado en el paquete anterior.
--Estos datos se guardarán en memriora y no en la tabla particiopaciones y con ello no mutará.
CREATE OR REPLACE TRIGGER rellenarinformacionpropietarios
    BEFORE INSERT OR UPDATE ON participaciones
DECLARE
    CURSOR c_rellenar IS
        SELECT codigocarrera, dnipropietario
        FROM participaciones p, caballos c
        WHERE c.codigocaballo=p.codigocaballo;
    indice NUMBER := 0;
BEGIN
    FOR v_rellenar IN c_rellenar LOOP
        informacionpropietarios.info(indice).codigodni := v_rellenar.dnipropietario;
        informacionpropietarios.info(indice).codigocarrera := v_rellenar.codigocarrera;
        indice:=indice+1;
    END LOOP;
END rellenarinformacionpropietarios;
/

--Cuando ejecutemos este trigger, tendremos que ver si la carrera existe y para esto, 
--tendremos que hacer un bucle for para recorrer el paquete para ver las coincidencias con las nuevas inversiones y los datos en memoria.
-- Si el nuevo DNI coincide, nos mostrará un 1.

CREATE OR REPLACE FUNCTION existednicarrera (p_dni caballos.dnipropietario%type, p_carrera participaciones.codigocarrera%type) RETURN NUMBER IS
    v_existedni NUMBER:=0;
BEGIN
    FOR i IN informacionpropietarios.info.first .. informacionpropietarios.info.last LOOP
        IF informacionpropietarios.info(i).codigodni = p_dni AND informacionpropietarios.info(i).codigocarrera = p_carrera THEN
            v_existedni:=1;
        END IF;
    END LOOP;
    RETURN v_existedni;
END existednicarrera;
/

--Tras esta función, tendremos que controlar esta expeción que hemos hecho en la función. 
--Si coincide no deberá dejarnos hacer el insert
CREATE OR REPLACE TRIGGER excepcionescaballos
    BEFORE INSERT OR UPDATE ON participaciones
    FOR EACH ROW
DECLARE
    v_dnipropietario caballos.dnipropietario%type;
BEGIN
    SELECT dnipropietario INTO v_dnipropietario
    FROM caballos
    WHERE codigocaballo = :new.codigocaballo;
    
    IF existednicarrera(v_dnipropietario, :new.codigocarrera) = 1 THEN
        raise_application_error(-20003, 'No puedes meter más de un caballo por propietario');
    ELSE
        modifparticipaciones(v_dnipropietario, :new.codigocarrera);
    END IF;
END excepcionescaballos;
/

--Por último, modificamos las participaciones con las variables p_dni y p_carrera y se deberá modificar con los nuevos valores intoducidos, sino nos fallará.
CREATE OR REPLACE PROCEDURE modifparticipaciones (p_dni caballos.dnipropietario%type, p_carrera participaciones.codigocarrera%type) IS
    indice NUMBER;
BEGIN
    indice:=informacionpropietarios.info.last+1;
    informacionpropietarios.info(indice).codigodni:=p_dni;
    informacionpropietarios.info(indice).codigocarrera:=p_carrera;
END modifparticipaciones;
/

--Datos de pruebas

--Más de un caballo
INSERT INTO participaciones VALUES(90, 10, '49227273J', 3, 4);

--NO hay ningun dato encontrado
INSERT INTO participaciones VALUES(90, 11, '49227273J', 7, 6);
