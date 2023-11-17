--1. Realiza una función que reciba como parámetros un código de carrera y un código de caballo y devuelva el importe total que tendrá que pagar el hipódromo a los apostantes suponiendo que dicha carrera sea ganada por el caballo recibido como parámetro. Se deben contemplar las siguientes excepciones: Carrera inexistente, Caballo inexistente, Caballo no participante en esa carrera. 
--AUTOR:
create or replace function importe (
    p_codigocarrera apuestas.codigocarrera%type,
    p_codigocaballo apuestas.codigocaballo%type) 
	return number is
    v_total number;
begin

    select importeApostado * tantoAUno into v_total
    from apuestas
    where codigocarrera = p_codigocarrera and codigocaballo = p_codigocaballo;

    RETURN v_total;
end;
/

CREATE OR REPLACE PROCEDURE comprobarcarrera (
    p_codigocarrera apuestas.codigocarrera%type,
    p_codigocaballo apuestas.codigocaballo%type) 
	is
    v_carrera number;
begin
    select count (*) INTO v_carrera
    from apuestas
    where codigocarrera = p_codigocarrera;
    if v_carrera = 0 then
        raise_application_error(-20112, 'No existe la carrera');
    end if;
end;
/
	
CREATE OR REPLACE PROCEDURE comprobarcaballo (
    p_codigocarrera apuestas.codigocarrera%type,
    p_codigocaballo apuestas.codigocaballo%type) 
	is
    v_caballo number;
begin
    select count (*) INTO v_caballo
    from apuestas
    where codigocaballo = p_codigocaballo;
    if v_caballo = 0 then
        raise_application_error(-20110, 'No se ha encontrado el caballo');
    end if;
end;
/

CREATE OR REPLACE PROCEDURE comprobarexiste (
    p_codigocarrera apuestas.codigocarrera%type,
    p_codigocaballo apuestas.codigocaballo%type) 
	is
    v_caballocarrera number;
begin
    select count (*) INTO v_caballocarrera
    from participaciones
    where codigocarrera = p_codigocarrera AND codigocaballo = p_codigocaballo;
    if v_caballocarrera = 0 then
        raise_application_error(-20103, 'No participa ese caballo en esa carrera');
    end if;
end;
/

CREATE OR REPLACE PROCEDURE Mostrar_Total (
    p_codigocarrera apuestas.codigocarrera%type,
    p_codigocaballo apuestas.codigocaballo%type)
IS
    importe_total number;
BEGIN
    comprobarcarrera(p_codigocarrera, p_codigocaballo);
    comprobarcaballo(p_codigocarrera, p_codigocaballo);
    comprobarexiste(p_codigocarrera, p_codigocaballo);
    importe_total := importe(p_codigocarrera, p_codigocaballo);

    dbms_output.put_line('Hay que pagar al ganador un total de ' || importe_total || ' euros');
END;
/

Funcionamiento del procedimiento:

exec comprobarcarrera('1','2');
exec comprobarcarrera('0','2');
exec comprobarcaballo('1','2');
exec comprobarcaballo('2','0');
exec comprobarexiste('2','2');
exec comprobarexiste('12','7');
exec Mostrar_Total('12','7');
