--4. Añade una columna email en la tabla Clientes y rellénala con datos consistentes. Realiza un trigger que cuando se actualice la tabla Participaciones para introducir los resultados de la carrera envíe un correo electrónico a todos los apostantes del caballo ganador informándoles del importe apostado y el beneficio obtenido. 
--AUTOR: GONZALO Y MARIO 
  
ALTER TABLE clientes ADD email varchar2(50);


UPDATE clientes SET email = 'josema@correo.com' WHERE dni = '28841115N';
UPDATE clientes SET email = 'pepe@correo.com' WHERE dni = 'Z4128090D';
UPDATE clientes SET email = 'gonzalo@correo.com' WHERE dni = '41500351W';
UPDATE clientes SET email = 'wikypedio@gmail.com' WHERE dni = 'X5339679E';


@$ORACLE_HOME/rdbms/admin/utlmail.sql

@$ORACLE_HOME/rdbms/admin/prvtmail.plb

ALTER SYSTEM SET smtp_out_server='localhost' SCOPE=BOTH;

grant execute on utl_tcp to MARIO;
        grant execute on utl_smtp to MARIO;
        grant execute on utl_http to MARIO;


    BEGIN
       DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
       acl => '/sys/acls/utl_http.xml',
       description => 'Allowing SMTP Connection',
       principal => 'MARIO',
       is_grant => TRUE,
       privilege => 'connect',
       start_date => SYSTIMESTAMP,
       end_date => NULL);

     COMMIT;
     END;
   /

    BEGIN
     DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
     acl => '/sys/acls/utl_http.xml',
     principal => 'MARIO',
     is_grant => true,
     privilege => 'resolve');
    COMMIT;
   END;
  /

     BEGIN
       DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL (
        acl => '/sys/acls/utl_http.xml',
        host => '*');
       COMMIT;
      END;
     /

BEGIN
    dbms_network_acl_admin.create_acl(
        acl => 'aclcorreo.xml',
        description => 'Enviar correos',
        principal => 'MARIO',
        is_grant => true,
        privilege => 'connect',
        start_date => systimestamp,
        end_date => NULL
    );
    COMMIT;
END;
/

BEGIN
    dbms_network_acl_admin.assign_acl (
        acl => 'aclcorreo.xml',
        host => '*',
        lower_port => NULL,
        upper_port => NULL
    );
    COMMIT;
END;
/

grant execute on UTL_MAIL to MARIO;

BEGIN
    utl_mail.send (
        sender => 'pcg.200204@gmail.com',
        recipients => 'pcg.200204@gmail.com',
        subject => 'Prueba',
        message => 'Esto es un mensaje de prueba.'
    );
END;
/

CREATE OR REPLACE TRIGGER enviar_correo_clientes
AFTER INSERT OR UPDATE ON participaciones
FOR EACH ROW
DECLARE
    CURSOR c_clientes IS
        SELECT dni, nombre, apellido1, email
        FROM clientes
        WHERE dni in (select dniCliente from apuestas where codigoCaballo=:NEW.codigoCaballo AND codigoCarrera = :NEW.codigoCarrera);

    v_importeApostado apuestas.importeApostado%TYPE;
    v_tantoauno apuestas.tantoAUno%TYPE;
    v_beneficios NUMBER;

BEGIN

    IF :NEW.posicionFinal = 1 THEN
        FOR cliente IN c_clientes LOOP

            SELECT importeApostado,tantoAUno
            INTO v_importeApostado,v_tantoAUno
            FROM apuestas
            WHERE codigoCaballo=:NEW.codigoCaballo AND dniCliente=cliente.dni;

            v_beneficios := (v_tantoAUno/100) * v_importeApostado;

            UTL_MAIL.SEND(
                sender => 'pcg.200204@gmail.com',
                recipients => cliente.email,
                subject => 'Resultados de la carrera',
                message => 'Para ' || cliente.nombre || ' ' || cliente.apellido1||',' ||CHR(10)|| ', su caballo ha ganado la carrera'||CHR(10)||CHR(10)||'Usted a aportado el siguiente dinero: ' || v_importeApostado || CHR(10)||'Y el beneficio obtenido es de: ' || v_beneficios || CHR(10)||CHR(10)|| 'Gracias por confiar en nosotros' ||CHR(10)||CHR(10)||'Atentamente,'||CHR(10)||'El equipo del hipodromo.',
                mime_type => 'text/plain; charset=us-ascii'
            );
        END LOOP;
    END IF;
END enviar_correo_clientes;
/


insert into clientes values ('49034862N', 'Gonzalo', 'Zayas', 'Garcia', 'Flipper', 'Dos Hermanas', 'Sevilla', '628836858', 'pcg.200204@gmail.com');

insert into carrerasProfesionales  values (13, to_date('11-12-2022 12:00' , 'DD-MM-YYYY HH24:MI'), 6125, 450, '01-01-2020', '01-06-2020');


insert into apuestas values ('49034862N',13 ,3 ,300 ,50.15);

insert into participaciones values(13, 3, 'Y6857984L', 1, 1);
