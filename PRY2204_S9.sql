DROP TABLE TRABAJADOR_CLUB_FUTBOL CASCADE CONSTRAINTS;
DROP TABLE TRABAJADOR_NACIONALIDAD CASCADE CONSTRAINTS;
DROP TABLE DOMINIO_IDIOMA CASCADE CONSTRAINTS;
DROP TABLE JUGADOR CASCADE CONSTRAINTS;
DROP TABLE PERSONAL_PLANTA CASCADE CONSTRAINTS;
DROP TABLE TRABAJADOR CASCADE CONSTRAINTS;
DROP TABLE COMUNA_RESIDENCIA CASCADE CONSTRAINTS;
DROP TABLE REGION CASCADE CONSTRAINTS;
DROP TABLE NACIONALIDAD CASCADE CONSTRAINTS;
DROP TABLE IDIOMA CASCADE CONSTRAINTS;
DROP TABLE ESTADO_CIVIL CASCADE CONSTRAINTS;
DROP TABLE ESCUELA_FORMACION CASCADE CONSTRAINTS;
DROP TABLE ASOCIACION CASCADE CONSTRAINTS;
DROP SEQUENCE seq_club_futbol;
DROP TABLE CLUB_FUTBOL CASCADE CONSTRAINTS;



--CREACIÓN DE TABLAS

CREATE TABLE REGION(
    id_region NUMBER(5) CONSTRAINT pk_region PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL
);

CREATE TABLE NACIONALIDAD(
    id_nacionalidad NUMBER(4) GENERATED ALWAYS AS IDENTITY (START WITH 210 INCREMENT BY 2) CONSTRAINT pk_nacionalidad PRIMARY KEY,
    nombre VARCHAR2(20) NOT NULL
);

CREATE TABLE IDIOMA(
    cod_idioma NUMBER(3) CONSTRAINT pk_idioma PRIMARY KEY,
    nombre_idioma VARCHAR2(20) NOT NULL
);

CREATE TABLE ESTADO_CIVIL(
    id_estado_civil VARCHAR2(2) CONSTRAINT pk_estado_civil PRIMARY KEY,
    descripcion VARCHAR2(25) NOT NULL
);

CREATE TABLE ESCUELA_FORMACION(
    id_escuela NUMBER(4) CONSTRAINT pk_escuela_formacion PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL,
    capacidad NUMBER(3) NOT NULL,
    fecha_fundacion DATE NOT NULL
);

CREATE TABLE ASOCIACION(
    cod_asociacion NUMBER(4) CONSTRAINT pk_asociacion PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL,
    --Restriccióm fecha_creacion mayor o igual a 31 de diciembre de 1980
    fecha_creacion DATE NOT NULL CONSTRAINT ck_fecha_creacion CHECK(fecha_creacion >= DATE '1980-12-31'),
    --Restriccióm de valores para tipo
    tipo CHAR(1) NOT NULL CONSTRAINT ck_tipo CHECK (tipo IN ('P','A'))
);


CREATE SEQUENCE seq_club_futbol START WITH 703 INCREMENT BY 4;

CREATE TABLE CLUB_FUTBOL(
    cod_club NUMBER(6) CONSTRAINT pk_club_futbol PRIMARY KEY,
    nombre_club VARCHAR2(50) CONSTRAINT nombre_club_un UNIQUE NOT NULL,
    patrimonio_clp NUMBER(15) NOT NULL,
    direccion VARCHAR2(50) NOT NULL,
    tipo_club VARCHAR2(15) NOT NULL CONSTRAINT ck_club_futbol_tipo CHECK (tipo_club IN ('Profesional', 'Amateur')) 
);


CREATE TABLE COMUNA_RESIDENCIA(
    id_comuna NUMBER(7) CONSTRAINT pk_comuna_residencia PRIMARY KEY,
    nombre VARCHAR2(30) NOT NULL,
    id_region NUMBER(5) NOT NULL,
    --Clave foránea id_region hace referencia a la columna id_region de la tabla REGION
    CONSTRAINT fk_comuna_residencia_region FOREIGN KEY (id_region) REFERENCES REGION(id_region)
);

CREATE TABLE TRABAJADOR(
    cod_trabajador NUMBER(9) CONSTRAINT pk_trabajador PRIMARY KEY,
    rut VARCHAR2(8) NOT NULL,
    digito_verificador CHAR(1) NOT NULL,
    nombres VARCHAR2(50) NOT NULL,
    apellidos VARCHAR2(50) NOT NULL,
    sueldo_base NUMBER(9) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(10) NOT NULL,
    telefono_movil VARCHAR2(13) NOT NULL,
    direccion VARCHAR2(50) NOT NULL,
    id_comuna NUMBER(7) NOT NULL,
    id_estado_civil VARCHAR2(2) NOT NULL,
    --Clave foránea id_comuna hace referencia a la columna id_comuna de la tabla COMUNA_RESIDENCIA
    CONSTRAINT fk_trabajador_comuna_residencia FOREIGN KEY(id_comuna) REFERENCES COMUNA_RESIDENCIA(id_comuna),
    --Clave foránea id_estado_civil hace referencia a la columna id_estado_civil de la tabla ESTADO_CIVIL
    CONSTRAINT fk_trabajador_estado_civil FOREIGN KEY(id_estado_civil) REFERENCES ESTADO_CIVIL(id_estado_civil)
);

CREATE TABLE PERSONAL_PLANTA(
    cod_trabajador NUMBER(9) CONSTRAINT pk_personal_planta PRIMARY KEY,
    cant_horas_trabajadas NUMBER(2),
    valor_horas_extras NUMBER(5),
    --Clave foránea cod_trabajador hace referencia a la columna cod_trabajador de la tabla TRABAJADOR
    CONSTRAINT fk_personal_planta_trabajador FOREIGN KEY(cod_trabajador) REFERENCES TRABAJADOR(cod_trabajador)
);

CREATE TABLE JUGADOR(
    cod_trabajador NUMBER(9) CONSTRAINT pk_jugador PRIMARY KEY,
    posicion_campo VARCHAR2(30) NOT NULL,
    monto_acumulado_premios NUMBER(9) NOT NULL,
    cod_asociacion NUMBER(4) NOT NULL,
    anio_fin_amateurismo NUMBER(4),
    id_escuela NUMBER(4),
    --Clave foránea cod_trabajador hace referencia a la columna cod_trabajador de la tabla TRABAJADOR
    CONSTRAINT fk_jugador_trabajador FOREIGN KEY(cod_trabajador) REFERENCES TRABAJADOR(cod_trabajador),
    --Clave foránea cod_asociacion hace referencia a la columna cod_asociacion de la tabla ASOCIACION
    CONSTRAINT fk_jugador_asociacion FOREIGN KEY(cod_asociacion) REFERENCES ASOCIACION(cod_asociacion),
     --Clave foránea id_escuela hace referencia a la columna id_escuela de la tabla ESCUELA_FORMACION
    CONSTRAINT fk_jugador_escuela_formacion FOREIGN KEY(id_escuela) REFERENCES ESCUELA_FORMACION(id_escuela)
);


CREATE TABLE DOMINIO_IDIOMA(
    nivel_dominio VARCHAR2(15) NOT NULL,
    cod_trabajador NUMBER(9) NOT NULL,
    cod_idioma NUMBER(3) NOT NULL,
    --Clave primaria compuesta por cod_trabajador y cod_idioma
    CONSTRAINT pk_dominio_idioma PRIMARY KEY(cod_trabajador, cod_idioma),
    --Clave foránea cod_trabajador hace referencia a la columna cod_trabajador de la tabla JUGADOR
    CONSTRAINT fk_dominio_idioma_jugador FOREIGN KEY(cod_trabajador) REFERENCES JUGADOR(cod_trabajador),
    --Clave foránea cod_idioma hace referencia a la columna cod_idioma de la tabla IDIOMA
    CONSTRAINT fk_dominio_idioma_idioma FOREIGN KEY(cod_idioma) REFERENCES IDIOMA(cod_idioma)
);

CREATE TABLE TRABAJADOR_NACIONALIDAD(
    id_nacionalidad NUMBER(4) NOT NULL,
    cod_trabajador NUMBER(9) NOT NULL,
    --Clave primaria compuesta por id_nacionalidad y cod_trabajador
    CONSTRAINT pk_trabajador_nacionalidad PRIMARY KEY(id_nacionalidad, cod_trabajador),
    --Clave foránea id_nacionalidad hace referencia a la columna id_nacionalidad de la tabla NACIONALIDAD
    CONSTRAINT fk_trabajador_nacionalidad_nacionalidad FOREIGN KEY(id_nacionalidad) REFERENCES NACIONALIDAD(id_nacionalidad),
    --Clave foránea cod_trabajador hace referencia a la columna cod_trabajador de la tabla TRABAJADOR
    CONSTRAINT fk_trabajador_nacionalidad_trabajador FOREIGN KEY(cod_trabajador) REFERENCES TRABAJADOR(cod_trabajador)
);

CREATE TABLE TRABAJADOR_CLUB_FUTBOL(
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CONSTRAINT ck_trabajador_club_fechas CHECK (fecha_fin >= fecha_inicio), 
    cod_club NUMBER(6) NOT NULL,
    cod_trabajador NUMBER(9) NOT NULL,
    --Clave primaria compuesta por fecha_inicio, cod_club y cod_trabajador
    CONSTRAINT pk_trabajador_club_futbol PRIMARY KEY(fecha_inicio, cod_club, cod_trabajador),
     --Clave foránea cod_club hace referencia a la columna cod_club de la tabla CLUB_FUTBOL
    CONSTRAINT fk_trabajador_club_futbol_club_futbol FOREIGN KEY(cod_club) REFERENCES CLUB_FUTBOL(cod_club),
    --Clave foránea cod_trabajador hace referencia a la columna cod_trabajador de la tabla TRABAJADOR
    CONSTRAINT fk_trabajador_club_futbol_trabajador FOREIGN KEY(cod_trabajador) REFERENCES TRABAJADOR(cod_trabajador)
);



--INSERCIÓN DE DATOS

INSERT INTO REGION(id_region, nombre) VALUES (1, 'ARICA Y PARINACOTA Y TARAPACA');
INSERT INTO REGION(id_region, nombre) VALUES (2, 'ANTOFAGASTA');
INSERT INTO REGION(id_region, nombre) VALUES (3, 'ATACAMA Y COQUIMBO');
INSERT INTO REGION(id_region, nombre) VALUES (5, 'VALPARAISO');
INSERT INTO REGION(id_region, nombre) VALUES (8, 'BIO-BIO');
INSERT INTO REGION(id_region, nombre) VALUES (13, 'METROPOLITANA');
INSERT INTO REGION(id_region, nombre) VALUES (16, 'ÑUBLE');


INSERT INTO COMUNA_RESIDENCIA(id_comuna, id_region, nombre) VALUES (101, 13, 'Santiago');
INSERT INTO COMUNA_RESIDENCIA(id_comuna, id_region, nombre) VALUES (102, 5, 'Valparaíso');
INSERT INTO COMUNA_RESIDENCIA(id_comuna, id_region, nombre) VALUES (103, 8, 'Concepción');
INSERT INTO COMUNA_RESIDENCIA(id_comuna, id_region, nombre) VALUES (104, 2, 'Antofagasta');
INSERT INTO COMUNA_RESIDENCIA(id_comuna, id_region, nombre) VALUES (105, 16, 'Chillán');


INSERT INTO ASOCIACION(cod_asociacion, nombre, fecha_creacion, tipo) VALUES(25, 'Asociación de Fútbol de Santiago', '15-05-2001', 'P');
INSERT INTO ASOCIACION(cod_asociacion, nombre, fecha_creacion, tipo) VALUES(26, 'Asociación Nacional de Fútbol Amateur', '10-03-1998', 'A');
INSERT INTO ASOCIACION(cod_asociacion, nombre, fecha_creacion, tipo) VALUES(27, 'Asociación de Fútbol de Valparaíso', '21-07-1987', 'P');
INSERT INTO ASOCIACION(cod_asociacion, nombre, fecha_creacion, tipo) VALUES(28, 'Asociación de Fútbol de Concepción', '30-11-1995', 'A');
INSERT INTO ASOCIACION(cod_asociacion, nombre, fecha_creacion, tipo) VALUES(29, 'Asociación de Fútbol de Antofagasta', '25-06-2003', 'P');
INSERT INTO ASOCIACION(cod_asociacion, nombre, fecha_creacion, tipo) VALUES(30, 'Asociación de Fútbol de Temuco', '12-01-2010', 'A');
INSERT INTO ASOCIACION(cod_asociacion, nombre, fecha_creacion, tipo) VALUES(31, 'Asociación de Fútbol de Rancagua', '08-09-1999', 'P');
INSERT INTO ASOCIACION(cod_asociacion, nombre, fecha_creacion, tipo) VALUES(32, 'Asociación de Fútbol de Puerto Montt', '20-04-2005', 'A');
INSERT INTO ASOCIACION(cod_asociacion, nombre, fecha_creacion, tipo) VALUES(33, 'Asociación de Fútbol de La Serena', '14-08-2012', 'P');
INSERT INTO ASOCIACION(cod_asociacion, nombre, fecha_creacion, tipo) VALUES(34, 'Asociación de Fútbol de Chillán', '01-01-2018', 'A');


INSERT INTO NACIONALIDAD(nombre) VALUES ('Chilena');
INSERT INTO NACIONALIDAD(nombre) VALUES ('Argentina');
INSERT INTO NACIONALIDAD(nombre) VALUES ('Peruana');
INSERT INTO NACIONALIDAD(nombre) VALUES ('Boliviana');
INSERT INTO NACIONALIDAD(nombre) VALUES ('Brasileña');


INSERT INTO CLUB_FUTBOL(cod_club, nombre_club, patrimonio_clp, direccion, tipo_club) VALUES(seq_club_futbol.nextval, 'Colo-Colo', 500000000, 'Av. Marathon 5300', 'Profesional');
INSERT INTO CLUB_FUTBOL(cod_club, nombre_club, patrimonio_clp, direccion, tipo_club) VALUES(seq_club_futbol.nextval, 'Universidad de Chile', 450000000, 'Av. El Parrón 0931', 'Profesional');
INSERT INTO CLUB_FUTBOL(cod_club, nombre_club, patrimonio_clp, direccion, tipo_club) VALUES(seq_club_futbol.nextval, 'Deportes Antofagasta', 180000000, 'Avenida Angamos 01606', 'Profesional');
INSERT INTO CLUB_FUTBOL(cod_club, nombre_club, patrimonio_clp, direccion, tipo_club) VALUES(seq_club_futbol.nextval, 'Huachipato', 220000000, 'Avenida Desiderio García 909', 'Profesional');
INSERT INTO CLUB_FUTBOL(cod_club, nombre_club, patrimonio_clp, direccion, tipo_club) VALUES(seq_club_futbol.nextval, 'Ñublense', 170000000, 'Pedro Aguirre Cerda 1003', 'Profesional');



--RECUPERACIÓN DE DATOS

SELECT
    'ID' || ': ' || cod_asociacion || ' * ' || nombre AS ASOCIACION,
    TO_CHAR(fecha_creacion, 'DD-MM-YYYY') AS CREADA, --Convierte fecha_creacion a formato DD-MM-YYYY
    tipo AS TIPO
FROM ASOCIACION
WHERE tipo = 'P' AND fecha_creacion  >= DATE '2001-01-01'
ORDER BY fecha_creacion DESC;


SELECT
    cod_club AS CLUB,
    nombre_club AS "NOMBRE CLUB",
    patrimonio_clp AS "PATRIMONIO EN PESOS",
    ROUND(patrimonio_clp / 955, 2) AS "PATRIMONIO EN DÓLARES"
FROM CLUB_FUTBOL
WHERE LOWER(nombre_club) LIKE '%a%' AND patrimonio_clp > 200000000 AND tipo_club = 'Profesional'
ORDER BY cod_club DESC;


