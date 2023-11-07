create table caballosCarreras
(
	codigoCaballo  integer,
  	peso numeric(6,2),
  	nacionalidad  varchar(30),
  	
  	constraint pk_caballosCarreras  primary key(codigoCaballo)
);
create table instalacionesCuadras
(
	codigoCuadra integer,
	aforo integer,
	tam integer,
	tipo varchar(100),
	constraint pk_instalacionesCuadras primary key(codigoCuadra)
);
create table pistasEntrenamiento
(
	codigoCuadra integer,
	superficie varchar(15),
	longitud integer,
	constraint pk_pistas primary key(codigoCuadra),
	constraint superficieOk check (lower(superficie) in ('hierba', 'arena batida', 'tierra'))
);
create table propietarios 
(
	dni varchar(10),
	nombre varchar(15),
	apellido1 varchar(15),
	apellido2 varchar(15),
	cuotaMensual numeric(6,2),
	constraint pk_propietarios primary key(dni),
	constraint dniPropietarioOK check(lower(dni)~('[0-9]{8}[a-z]{1}$') or lower(dni)~('[k,l,m,x,y,z]{1}[0-9]{7}[a-z]{1}$'))
);
create table caballos 
(
	codigoCaballo integer,
	dniPropietario  varchar(10),
	nombre varchar(30),
	fechaNac date,
	raza varchar(30),
	constraint pk_caballos primary key(codigoCaballo),
	constraint fk_propietarios foreign key(dniPropietario) references propietarios(dni)
);
create table carrerasProfesionales
(
	codigoCarrera integer,
	fechaHora  timestamp unique ,
	importePremio numeric(7,2),
	limiteApuesta numeric(5,2),
	fechaNacMin date,
	fechaNacMax date,
	constraint pk_carrerasProf primary key(codigoCarrera),
	constraint ck_carrerasProf unique(fechaHora),
	constraint fechaOK check(to_char(fechaHora, 'MM') in ('11', '12', '01', '02') or (to_char(fechaHora, 'MM') = '10' and to_char(fechaHora, 'DD')>= '20') or ( to_char(fechaHora, 'MM') = '03' and to_char(fechaHora, 'DD')<= '02')), 
	constraint horaOK check(to_number(to_char(fechaHora, 'HH24'), '99') >= 09 and to_number(to_char(fechaHora, 'HH24'), '99') <= 14),
	constraint diaOk check (lower(to_char(fechaHora, 'DAY')) like '%domingo%' or lower(to_char(fechaHora, 'DAY')) like '%sunday%')
);
create table jockeys 
(
	dni varchar(10),
	nombre varchar(30),
	peso numeric(4,2),
	altura numeric(3,2),
	telefono varchar(9),
	constraint pk_jockeys primary key(dni),
	constraint dniJockeyOk check(lower(dni)~('[0-9]{8}[a-z]{1}$') or lower(dni)~('[k,l,m,x,y,z]{1}[0-9]{7}[a-z]{1}$'))
);
create table apuestas
(
	dniCliente varchar(10),
	codigoCarrera integer, 
	codigoCaballo integer,
	importeApostado numeric(6,2),
	tantoAUno numeric(5,2),
	constraint pk_apuestas primary key(dniCliente, codigoCarrera, codigoCaballo),
	constraint maxApuestaOK check((importeApostado) < 9000.00),
	constraint importeApuestaOk check (importeApostado is not null),
	constraint tantoOk check (tantoAUno is not null)
);
create table cuadrante
(
	codigoCaballo integer,
	codigoCuadra integer,
	fechaHora timestamp,
	constraint pk_cuadrante primary key(codigoCaballo, codigoCuadra),
	constraint fk_instalacionesCuadras foreign key(codigoCuadra) references instalacionesCuadras(codigoCuadra),
	constraint notLunesOk check( lower(to_char(fechaHora, 'DAY')) not like '%lunes%' or lower(to_char(fechaHora, 'DAY')) not like '%monday%')
);	
create table participaciones 
(
	codigoCarrera integer,
	codigoCaballo integer,
	dniJockey varchar(10),
	dorsal integer,
	posicionFinal integer,
	constraint pk_participaciones primary key(codigoCarrera, codigoCaballo),
	constraint fk_jockey foreign key(dniJockey) references jockeys(dni)
);
create table clientes 
(
	dni varchar(10),
	nombre varchar(30),
	apellido1 varchar(30),
	apellido2 varchar(30),
	direccion varchar(60),
	localidad varchar(30),
	provincia varchar(15),
	telefono varchar(9),
	constraint pk_clientes primary key(dni),
	constraint dniClienteOk check(lower(dni)~('[0-9]{8}[a-z]{1}$') or lower(dni)~('[k,l,m,x,y,z]{1}[0-9]{7}[a-z]{1}$')),
	constraint localidadOK check(localidad = initcap(localidad))
);
insert into pistasEntrenamiento
values (1, 'hierba', 3000);
insert into pistasEntrenamiento
values (2, 'arena batida', 1886);
insert into pistasEntrenamiento
values (3, 'tierra', 1609);
insert into pistasEntrenamiento
values (4, 'hierba', 1400);
insert into propietarios
values ('21913124n', 'Horacio','Arreguy', 'Fazzio', 250);
insert into propietarios
values ('Z7782152S', 'Robert', 'Chase', ' ',300);
insert into propietarios
values ('83069279H', 'Lucas', 'Martínez', 'Muñoz', 200.70);
insert into propietarios
values ('X58056225B', 'Gustavo', 'Scarpello',' ', 100);
insert into instalacionesCuadras
values(1, 1000, 72232, 'galope');
insert into instalacionesCuadras
values(2, 500, 32935, 'galope');
insert into instalacionesCuadras
values(3, 600, 34816, 'trote');
insert into instalacionesCuadras
values(4, 740, 56619, 'obstaculos steeple chase');
insert into instalacionesCuadras
values(5, 90, 30500, 'boxes');
insert into instalacionesCuadras
values(6, 5, 4000, 'centro veterinario');
insert into instalacionesCuadras
values(7, 10, 3000, 'duchas de caballos');
insert into instalacionesCuadras
values(8, 7, 500, 'almacen grano');
insert into caballosCarreras
values (1, 1490.5 ,'Americana');
insert into caballosCarreras
values (2, 1500, 'Española');
insert into caballosCarreras
values (3, 1440,'Árabe');
insert into caballosCarreras
values (4, 1600, 'Española');
insert into caballosCarreras
values (5, 1560.6, 'Británica');
insert into caballosCarreras
values (6, 1450,'Árabe');
insert into caballosCarreras
values (7, 1550, 'Española');
insert into caballosCarreras
values (8, 1500, 'Americana');
insert into caballosCarreras
values (9, 1490, 'Española');
insert into caballosCarreras
values (10, 1570.9, 'Árabe');
insert into clientes
values ('28841115N', 'Maria', 'Romero', 'Angulo', 'Calle París, 18, 1D', 'Dos Hermanas', 'Sevilla', '606088324');
insert into clientes
values ('Z4128090D', 'John', 'Smith', ' ' , 'Avenida de La paz, 71', 'Sevilla', 'Sevilla','954125995');
insert into clientes
values ('41500351W', 'Jose Luis', 'Torres', 'Andrades', 'Calle Turin, 7', 'Dos Hermanas', 'Sevilla','955126745');
insert into clientes
values ('X5339679E', 'Desa', 'Connif',' ', 'Calle Fernan Caballero, 47', 'Huevar Del Aljarafe', 'Sevilla','955341267');
insert into clientes
values ('18498310P', 'Mayumi', 'Ozaki',' ' , 'Calle Argentina', 'Las Rozas De Madrid', 'Madrid','917573498');
insert into clientes
values ('02411561B', 'Paco', 'Jover', 'Cobos', 'Calle Real, 12', 'Cordoba', 'Córdoba','678123467');
 
insert into caballos
values (1,'21913124n', 'Wad Vison', '11-11-2011','Quarter Horse' );
insert into caballos
values (2,'Z7782152S', 'Dagoberto', '10-10-2010','Purasangre español' );
insert into caballos
values (3,'83069279H', 'Atreus', '24-12-2011','Shagya Árabe' );
insert into caballos
values (4,'X58056225B', 'Mayo', '15-03-2010','Purasangre español' );
insert into caballos
values (5,'21913124n', 'Argos', '04-04-2012','Purasangre inglés' );
insert into caballos
values (6,'Z7782152S', 'Daniela', '06-06-2011','Shagya Árabe' );
insert into caballos
values (7,'83069279H', 'Kayak', '14-02-2010','Purasangre español' );
insert into caballos
values (8,'X58056225B', 'Charming Star', '23-09-2011','Quarter Horse' );
insert into caballos
values (9,'21913124n', 'Perdigon', '24-06-2012','Purasangre español' );
insert into caballos
values (10,'Z7782152S', 'Innuendo', '31-01-2011','Darley Arabian' );
insert into jockeys
values('00015258D', 'B.Fayos', 58.5, 1.60, '600031480');
insert into jockeys
values('55466243H', 'R.Ramos', 58.0, 1.65, '605309531');
insert into jockeys
values('09849927Q', 'R.Sousa', 57.0, 1.63, '606088322');
insert into jockeys
values('X6785562X' ,'M.Gomes', 56.5, 1.66, '670894325');
insert into jockeys
values('Y6857984L', 'N. de Julian', 58.0, 1.65, '652978612');
insert into jockeys
values('35647376K' ,'C.A.Loaiza', 55.0, 1.69, '607239176');
insert into jockeys
values('X6951336T' ,'D.Ferreira', 58.0, 1.68, '658902365');
insert into jockeys
values('85108890N' ,'J.Gelabert', 55.5, 1.58, '623459158');
insert into carrerasProfesionales 
values (1, '08-01-2017 09:30',  8750, 650, '01-01-2010', '31-12-2012');
insert into carrerasProfesionales 
values (2, '08-01-2017 10:00',  11156, 800, '01-01-2010', '31-12-2012' );
insert into carrerasProfesionales 
values (3, '15-01-2017 11:00',  6125, 450, '01-01-2010', '31-12-2012');
insert into carrerasProfesionales 
values (4, '15-01-2017 12:00',  7857, 520, '01-01-2010', '31-12-2012');
insert into carrerasProfesionales 
values (5, '22-01-2017 13:00',  7000, 470, '01-06-2009', '31-12-2012');
insert into carrerasProfesionales 
values (6, '22-01-2017 14:00',  6125, 450, '01-06-2009', '31-12-2012');
insert into carrerasProfesionales 
values (7, '06-11-2016 11:00',  8750, 650, '01-06-2009', '31-12-2012');
insert into carrerasProfesionales 
values (8, '06-11-2016 12:00',  11167, 800, '01-06-2009', '31-12-2012');
insert into carrerasProfesionales 
values (9, '06-11-2016 13:00', 7000, 470, '01-01-2010', '01-06-2013');
insert into carrerasProfesionales 
values (10, '13-11-2016 10:00', 8750, 650, '01-01-2010', '01-06-2013');
insert into carrerasProfesionales 
values (11, '13-11-2016 10:30', 7000, 470, '01-01-2010', '01-06-2013');
insert into carrerasProfesionales 
values (12, '13-11-2016 12:00', 6125, 450, '01-01-2010', '01-06-2013');
insert into apuestas
values ('28441115n',12 ,2 ,300 ,3.10);
insert into apuestas
values ('41500351W',2 ,4 ,700 ,5.10);
insert into apuestas
values ('18498310P', 7, 5 ,20 ,1.8 );
insert into apuestas
values ('X5339679E',5 , 2, 450,1.6);
insert into apuestas
values ('Z4128090D', 6,1 ,400 ,10.30);
insert into apuestas
values ('41500351W', 12,7 ,345 ,103.02 );
insert into apuestas
values ('28441115n', 4, 4,50 ,0.00 );
insert into apuestas
values ('28441115n', 8,8 ,600 ,6.9);
insert into apuestas
values ('18498310P', 9, 3, 100, 11.4 );
insert into apuestas
values ('Z4128090D', 10, 9, 90, 25.2 );
insert into apuestas
values ('41500351W', 11, 1, 235.55,9.7 );
insert into apuestas
values ('X5339679E', 3, 4,123.6 ,15.7 );
insert into apuestas
values ('28441115n', 11, 10, 334, 8.7 );
insert into apuestas
values ('02411561B', 2, 3, 730,16.7  );
insert into apuestas
values ('18498310P', 11, 10, 400, 6.4 );
insert into apuestas
values ('02411561B', 1,5 ,250 ,3.4  );
insert into apuestas
values ('X5339679E', 1, 6,280 ,6.8  );
insert into apuestas
values ('02411561B', 5,7 ,290 ,21.7  );
insert into apuestas
values ('41500351W', 3, 1, 125, 27.2 );
insert into apuestas
values ('02411561B', 12, 8, 275, 43.5 );
insert into apuestas
values ('Z4128090D', 8,9 ,650 ,3.5  );
insert into cuadrante
values(1,1, ('16-02-2017 16:00'));
insert into cuadrante
values(2,2,  ('16-02-2017 17:00'));
insert into cuadrante
values(3,3,  ('16-02-2017 16:00'));
insert into cuadrante
values(4,4,  ('16-02-2017 17:00'));
insert into cuadrante
values(5,5,  ('16-02-2017 19:00'));
insert into cuadrante
values(6,6,  ('16-02-2017 12:00'));
insert into cuadrante
values(7,7,  ('21-02-2017 18:00'));
insert into cuadrante
values(8,8,  ('14-02-2017 15:00'));
insert into cuadrante
values(9,8,  ('17-01-2017 16:00'));
insert into cuadrante
values(10,7,  ('16-02-2017 17:00'));
insert into cuadrante
values(1,6,  ('17-01-2017 16:00'));
insert into cuadrante
values(2,5,  ('17-01-2017 17:00'));
insert into cuadrante
values(2,4,  ('16-02-2017 19:00'));
insert into cuadrante
values(3,2,  ('16-02-2017 12:00'));
insert into cuadrante
values(4,2,  ('21-02-2017 18:00'));
insert into cuadrante
values(4,3,  ('14-02-2017 15:00'));
insert into cuadrante
values(5,7,  ('07-02-2017 19:00'));
insert into cuadrante
values(6,1,  ('16-02-2017 12:00'));
insert into cuadrante
values(8,4,  ('25-02-2017 18:00'));
insert into cuadrante
values(9,7,  ('14-02-2017 15:00'));
insert into participaciones
values(1, 2, 'Y6857984L', 1, 1);
insert into participaciones
values(1, 4, '85108890N', 3, 4);
insert into participaciones
values(1, 6, '00015258D', 5, 7);
insert into participaciones
values(2, 8, '09849927Q', 5, 4);
insert into participaciones
values(2, 3, 'X6785562X', 6, 3);
insert into participaciones
values(3, 7, 'X6785562X', 8, 7);
insert into participaciones
values(3, 5, '55466243H', 7, 6);
insert into participaciones
values(3, 2, 'Y6857984L', 9, 5);
insert into participaciones
values(3, 8, '09849927Q', 2, 2);
insert into participaciones
values(4, 9, '35647376K', 5, 2);
insert into participaciones
values(4, 2, 'Y6857984L', 3, 8);
insert into participaciones
values(4, 5, '55466243H', 4, 1);
insert into participaciones
values(5, 7, 'X6951336T', 3, 4);
insert into participaciones
values(5, 3, 'X6785562X', 1, 1);
insert into participaciones
values(6, 9, '35647376K', 5, 2);
insert into participaciones
values(6, 6, '00015258D', 3, 5);
insert into participaciones
values(6, 4, '85108890N', 1, 7);
insert into participaciones
values(7, 1, '00015258D', 2, 1);
insert into participaciones
values(7, 2, 'Y6857984L', 4, 2);
insert into participaciones
values(8, 10, '09849927Q', 7, 4);
insert into participaciones
values(8, 1, '00015258D', 6, 3);
insert into participaciones
values(9, 1, '00015258D', 1, 5);
insert into participaciones
values(9, 5, '55466243H', 5, 7);
insert into participaciones
values(9, 2, 'Y6857984L', 6, 6);
insert into participaciones
values(10, 3, 'X6785562X', 2, 2);
insert into participaciones
values(10, 10, '09849927Q', 3, 4);
insert into participaciones
values(11, 10, '09849927Q', 7, 6);
insert into participaciones
values(11, 4, '85108890N', 5, 1);
insert into participaciones
values(12, 7, 'X6785562X', 1, 2);
insert into participaciones
values(12, 8, '09849927Q', 2, 5);