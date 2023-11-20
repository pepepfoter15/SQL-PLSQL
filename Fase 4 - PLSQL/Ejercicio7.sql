--7 Realiza los módulos de programación necesarios para evitar que un mismo jockey corra más de tres carreras en el
--mismo día
--AUTOR: PEPE Y JOSEMA
create or replace trigger tres_carreras_jockey
    before insert or update on  participaciones
    for each row
declare
    v_num_carreras number;
begin
    select count(*) into v_num_carreras
    from participaciones p, carrerasprofesionales c
    where p.codigocarrera=c.codigocarrera
        and p.dnijockey = :new.dnijockey
        and to_char(c.fechahora, 'DD-MM-YYYY') = (
            select to_char(fechahora, 'DD-MM-YYYY')
            from carrerasprofesionales
            where codigocarrera = :new.codigocarrera
        );

    if v_num_carreras >= 3 then
        raise_application_error(-20001, 'El jockey ya ha corrido tres carreras ese día.');
    end if;
end;
/

--Prueba: 

insert into carrerasProfesionales 
values (17, to_date('13-11-2016 09:30' , 'DD-MM-YYYY HH24:MI'), 6125, 450, '01-01-2010', '01-06-2013');


insert into participaciones values(10, 2, 'Y6857984L', 2, 5);
insert into participaciones values(11, 2, 'Y6857984L', 7, 4);
insert into participaciones values(12, 2, 'Y6857984L', 1, 3);
insert into participaciones values(17, 2, 'Y6857984L', 1, 1);
