--1. Realiza una función que reciba como parámetros un código de carrera y un código de caballo y devuelva el importe total que tendrá que pagar el hipódromo a los apostantes suponiendo que dicha carrera sea ganada por el caballo recibido como parámetro. Se deben contemplar las siguientes excepciones: Carrera inexistente, Caballo inexistente, Caballo no participante en esa carrera. 
--AUTOR:

CREATE OR REPLACE FUNCTION importe (
    p_codigocarrera apuestas.codigocarrera%type,
    p_codigocaballo apuestas.codigocaballo%type) 
    returnS numeric as
$$
declare
    v_total numeric;
begin
    select importeApostado * tantoAUno into v_total
    from apuestas
    where codigocarrera = p_codigocarrera and codigocaballo = p_codigocaballo;

    return v_total;
end;
$$ language plpgsql;



CREATE OR REPLACE PROCEDURE comprobarcarrera (
    p_codigocarrera apuestas.codigocarrera%type,
    p_codigocaballo apuestas.codigocaballo%type) 
AS
$$
declare
    v_carrera integer;
begin
    select count(*) into v_carrera
    from apuestas
    where codigocarrera = p_codigocarrera;

    if v_carrera = 0 then
        raise exception 'No existe la carrera';
    end if;
end;
$$ language plpgsql;


CREATE OR REPLACE PROCEDURE comprobarcaballo (
    p_codigocarrera apuestas.codigocarrera%type,
    p_codigocaballo apuestas.codigocaballo%type) 
AS
$$
declare
    v_caballo integer;
begin
    select count(*) into v_caballo
    from apuestas
    where codigocaballo = p_codigocaballo;

    if v_caballo = 0 then
        raise exception 'No se ha encontrado el caballo';
    end if;
end;
$$ language plpgsql;


CREATE OR REPLACE PROCEDURE comprobarexiste (
    p_codigocarrera apuestas.codigocarrera%type,
    p_codigocaballo apuestas.codigocaballo%type) 
AS
$$
declare
    v_caballocarrera integer;
begin
    select count(*) into v_caballocarrera
    from participaciones
    where codigocarrera = p_codigocarrera and codigocaballo = p_codigocaballo;

    if v_caballocarrera = 0 then
        raise exception 'No participa ese caballo en esa carrera';
    end if;
end;
$$ language plpgsql;


CREATE OR REPLACE PROCEDURE Mostrar_Total (
    p_codigocarrera apuestas.codigocarrera%type,
    p_codigocaballo apuestas.codigocaballo%type)
AS
$$
declare
    importe_total numeric;
begin
    CALL comprobarcarrera(p_codigocarrera, p_codigocaballo);
    CALL comprobarcaballo(p_codigocarrera, p_codigocaballo);
    CALL comprobarexiste(p_codigocarrera, p_codigocaballo);
    
    importe_total := importe(p_codigocarrera, p_codigocaballo);

    raise notice 'Hay que pagar al ganador un total de % euros', importe_total;
end;
$$ language plpgsql;



Comprobar que existen

CALL comprobarcarrera('1','2');
CALL comprobarcarrera('0','2');
CALL comprobarcaballo('1','2');
CALL comprobarcaballo('2','0');
CALL comprobarexiste('2','2');
CALL comprobarexiste('12','7');
CALL Mostrar_Total('12','7');
