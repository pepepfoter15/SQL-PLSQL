--5. Añade una columna a la tabla Propietarios llamada ImporteTotalPremios. Rellénala con un procedimiento o una sentencia SQL considerando los premios que han conseguido los caballos de cada uno de ellos por sus victorias en las carreras. Haz un trigger que la mantenga actualizada cada vez que se realice cualquier cambio en la tabla Participaciones que afecte a este total. 
--AUTOR: GONZALO
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
