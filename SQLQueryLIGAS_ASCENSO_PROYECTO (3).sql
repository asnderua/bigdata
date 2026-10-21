--BASE DE DATOS--

/*Plataforma de Inteligencia Deportiva basada en Business
Intelligence y Big Data para la Toma de Decisiones en Ligas de
Fútbol de Ascenso del Perú*/

--GRUPO 04


--BASE DE DATOS:
CREATE DATABASE LigasdeAscenso;
GO

USE LigasdeAscenso;
GO

-- CREAMOS LAS TABLAS:

CREATE TABLE Competicion(
IDcompeticion INT IDENTITY(1,1) PRIMARY KEY,
NombreCompeticion VARCHAR(50) NOT NULL,
Organizador VARCHAR(50) NOT NULL,
Nivelcompeticion VARCHAR(50) NOT NULL

);


CREATE TABLE Ubicacion(
IDubicacion INT IDENTITY(1,1) PRIMARY KEY,
Departamento VARCHAR(50) NOT NULL, 
Provincia VARCHAR(50) NOT NULL,
Distrito VARCHAR(50) NOT NULL,
Region VARCHAR(50) NOT NULL

);


CREATE TABLE temporada(
IDtemporada INT IDENTITY(1,1) PRIMARY KEY,
Anio INT NOT NULL,
FechaInicio DATE NOT NULL,
FechaFinal DATE NOT NULL

);


CREATE TABLE Etapas(
IDetapa INT IDENTITY(1,1) PRIMARY KEY,
IDcompeticion INT NOT NULL REFERENCES Competicion (IDcompeticion),
nombreEtapa VARCHAR(50) NOT NULL,
nivelEtapa INT NOT NULL,
FactorPrecio DECIMAL(4,2) NOT NULL

);

ALTER TABLE Etapas                    --El precio no puede ser negativo p
ADD CONSTRAINT CK_Etapa_Negativo
CHECK (FactorPrecio >= 0)



CREATE TABLE TipoEntrada(
IDtipoEntrada INT IDENTITY(1,1) PRIMARY KEY,
nombreTE VARCHAR(50) NOT NULL,
PrecioBase DECIMAL (4,2) NOT NULL

);

ALTER TABLE TipoEntrada               --El precio de las entradas tampoco pude ser negativo 
ADD CONSTRAINT CK_Entradas_Negativo
CHECK (PrecioBase >= 0)




CREATE TABLE Estadio(
IDestadio INT IDENTITY(1,1) PRIMARY KEY,
NombreEstadio VARCHAR(100) NOT NULL,
IDubicacion INT NOT NULL REFERENCES Ubicacion(IDubicacion),
Categoria VARCHAR(50) NOT NULL,
MaxAforo INT NOT NULL

);

ALTER TABLE Estadio                   --El aforo maximo no puedes ser 0 o negativo ps wbn
ADD CONSTRAINT CK_Aforo_Negativo
CHECK (MaxAforo > 0)




CREATE TABLE Club(
IDclub INT IDENTITY(1,1) PRIMARY KEY,
NombreClub VARCHAR (100) NOT NULL,
IDubicacion INT NOT NULL REFERENCES Ubicacion(IDubicacion),
IDcompeticion INT NOT NULL REFERENCES Competicion (IDcompeticion),
AnioFundacion INT NULL

);

ALTER TABLE Club                                                         --No va a existir un club antes de 1863 si en ese año todavia ni se inventaba el futbol ps mano XDDD
ADD CONSTRAINT AnioFundacion                                             --No puede existir un club fundado en el futuro tampoco p
CHECK (AnioFundacion IS NULL OR AnioFundacion BETWEEN 1863 AND 2026)



CREATE TABLE Arbitro(
IDarbitro INT IDENTITY(1,1) PRIMARY KEY,
CodigoArbitro VARCHAR (50) NOT NULL,
CategoriaArbitro VARCHAR(50) NOT NULL

);



CREATE TABLE Partido(
IDpartido INT IDENTITY(1,1) PRIMARY KEY,
IDtemporada INT NOT NULL REFERENCES temporada(IDtemporada),
IDetapa INT NOT NULL REFERENCES Etapas(IDetapa),
IDestadio INT NOT NULL REFERENCES Estadio(IDestadio),
IDequipoLocal INT NOT NULL REFERENCES Club(IDclub),
IDequipoVisitante INT NOT NULL REFERENCES Club(IDclub),
IDArbitro INT NOT NULL REFERENCES Arbitro(IDarbitro),
FechaHora DATETIME2(0) NOT NULL,
Jornada INT NULL,
GolesLocal INT NULL,
GolesVisita INT NULL,
EstadoPartido VARCHAR(20) NOT NULL

);

ALTER TABLE Partido                        --No se puede enfrentar un equipo asi mismo ps mano xd
ADD CONSTRAINT CK_Partido_MismoEquipo
CHECK (IDequipoLocal <> IDequipoVisitante);

ALTER TABLE Partido                         --No puede haber goles negativos
ADD CONSTRAINT CK_Partido_GolesNegativos
CHECK (
    (GolesLocal IS NULL OR GolesLocal >= 0)
    AND
    (GolesVisita IS NULL OR GolesVisita >= 0)
)

ALTER TABLE PARTIDO                              --La jorndada tiene que ser mayor que 0 p
ADD CONSTRAINT CK_Partido_Jornada CHECK (Jornada IS NULL OR Jornada > 0)

ALTER TABLE PARTIDO                                     --Solamente estas frases son validas                                     
ADD CONSTRAINT CK_Partido_Estado CHECK (
    EstadoPartido IN ('Programado', 'En juego', 'Finalizado', 'Suspendido', 'Cancelado'))







CREATE TABLE Boleto(
IDboleto INT IDENTITY (1,1) PRIMARY KEY,
IDpartido INT NOT NULL REFERENCES Partido(IDpartido),
IDtipoEntrada INT NOT NULL REFERENCES TipoEntrada(IDtipoEntrada),
FechaVenta DATETIME2(0),
CanalVenta VARCHAR(50) NOT NULL,
MetodoPago VARCHAR(50) NOT NULL,
EstadoPago VARCHAR(50) NOT NULL,
PrecioPagado DECIMAL(10,2) NULL

);

ALTER TABLE Boleto                                     --No pudes comprar un boleto con plata negativas ps
ADD CONSTRAINT CK_Boleto_Negativo
CHECK (PrecioPagado IS NULL OR PrecioPagado >= 0);

ALTER TABLE Boleto                                                --Solamente estas frases son validas
ADD CONSTRAINT CK_Boleto_EstadoPago CHECK (
EstadoPago IN ('Pendiente', 'Pagado', 'Anulado', 'Reembolsado'))






CREATE TABLE AsistenciaPartido(
IDpartido            INT NOT NULL PRIMARY KEY REFERENCES Partido(IDpartido),
AsistenciaRegistrada INT NULL,
AforoEstadio INT NULL

);

ALTER TABLE AsistenciaPartido                                            --La asistencia tiene que tener coherencia con los otros valores
ADD CONSTRAINT CK_Asistencia_Valores CHECK (
    (AsistenciaRegistrada IS NULL OR AsistenciaRegistrada >= 0) AND
    (AforoEstadio IS NULL OR AforoEstadio >= 0) AND
    (AsistenciaRegistrada IS NULL OR AforoEstadio IS NULL OR
     AsistenciaRegistrada <= AforoEstadio)
)





CREATE TABLE RendimientoEquipoPartido(
IDpartido    INT NOT NULL REFERENCES Partido(IDpartido),
IDclub     INT NOT NULL REFERENCES Club(IDclub),
Condicion    VARCHAR(10) NOT NULL,   
Goles        INT NULL,
Tiros        INT NULL,
TirosAlArco  INT NULL,
PosesionPct  INT NULL,
Faltas       INT NULL,
Amarillas    INT NULL,
Rojas        INT NULL,
Corners      INT NULL,
PRIMARY KEY (IDpartido, IDclub)


);

ALTER TABLE RendimientoEquipoPartido              --Tiene que haber coherencia con los otros datos p, 
ADD CONSTRAINT CK_Rendimiento_Valores             --no puedes poner que hay 8 tiros al arco y solo 5 tiros toales ps no seas wbn xd
CHECK (
    (Tiros IS NULL OR Tiros >= 0)
    AND (TirosAlArco IS NULL OR TirosAlArco >= 0)
    AND (Tiros IS NULL OR TirosAlArco IS NULL
         OR TirosAlArco <= Tiros)
    AND (PosesionPct IS NULL OR
         PosesionPct BETWEEN 0 AND 100)
    AND (Faltas IS NULL OR Faltas >= 0)
    AND (Amarillas IS NULL OR Amarillas >= 0)
    AND (Rojas IS NULL OR Rojas >= 0)
    AND (Corners IS NULL OR Corners >= 0)
    AND (Goles IS NULL OR Goles >= 0)
);





--INSERTAMOS DATOS:

INSERT INTO Competicion (NombreCompeticion, Organizador, Nivelcompeticion) VALUES
('Liga 2',    'Federación Peruana de Fútbol', 'Profesional'),  
('Copa Perú', 'Federación Peruana de Fútbol', 'Amateur');  


INSERT INTO Ubicacion (Departamento, Provincia, Distrito, Region) VALUES
('Lima', 'Lima', 'Ate', 'Costa'),
('Lima', 'Lima', 'La Victoria', 'Costa'),
('Lima', 'Lima', 'San Juan de Lurigancho', 'Costa'),
('Callao', 'Callao', 'Callao', 'Costa'),
('Arequipa', 'Arequipa', 'Cayma', 'Sierra'),
('Cusco', 'Cusco', 'Cusco', 'Sierra'),
('La Libertad', 'Trujillo', 'Trujillo', 'Costa'),
('Lambayeque', 'Chiclayo', 'Chiclayo', 'Costa'),
('Piura', 'Piura', 'Piura', 'Costa'),
('Piura', 'Sullana', 'Sullana', 'Costa'),
('Junín', 'Huancayo', 'Huancayo', 'Sierra'),
('Ica', 'Ica', 'Ica', 'Costa'),
('Ayacucho', 'Huamanga', 'Ayacucho', 'Sierra'),
('Loreto', 'Maynas', 'Iquitos', 'Selva'),
('Ucayali', 'Coronel Portillo', 'Callería', 'Selva'),
('San Martín', 'San Martín', 'Tarapoto', 'Selva'),
('Tacna', 'Tacna', 'Tacna', 'Costa'),
('Puno', 'San Román', 'Juliaca', 'Sierra'),
('Puno', 'Puno', 'Puno', 'Sierra'),
('Áncash', 'Santa', 'Chimbote', 'Costa'),
('Cajamarca', 'Cajamarca', 'Cajamarca', 'Sierra'),
('Huánuco', 'Huánuco', 'Huánuco', 'Sierra'),
('Moquegua', 'Mariscal Nieto', 'Moquegua', 'Costa'),
('Tumbes', 'Tumbes', 'Tumbes', 'Costa'),
('Madre de Dios', 'Tambopata', 'Tambopata', 'Selva'),
('Apurímac', 'Abancay', 'Abancay', 'Sierra'),
('Pasco', 'Pasco', 'Chaupimarca', 'Sierra'),
('Huancavelica', 'Huancavelica', 'Huancavelica', 'Sierra'),
('Amazonas', 'Chachapoyas', 'Chachapoyas', 'Sierra'),
('Áncash', 'Huaraz', 'Huaraz', 'Sierra');



INSERT INTO temporada(Anio, FechaInicio, FechaFinal) VALUES
(2022, '2022-02-01', '2022-11-30'),
(2023, '2023-02-01', '2023-11-30'),
(2024, '2024-02-01', '2024-11-30'),
(2025, '2025-02-01', '2025-11-30'),
(2026, '2026-02-01', '2026-11-30');



INSERT INTO Etapas(IDcompeticion, nombreEtapa, nivelEtapa, FactorPrecio) VALUES
(2, 'Etapa Distrital',     1, 0.70),
(2, 'Etapa Provincial',    2, 0.85),
(2, 'Etapa Departamental', 3, 1.00),
(2, 'Etapa Nacional',      4, 1.30),
(1, 'Fase Regular',        1, 1.50),
(1, 'Play-off',            2, 2.00);



INSERT INTO TipoEntrada(nombreTE, PrecioBase)VALUES
('Tribuna Norte',     20.00), --precio de las populares xd
('Tribuna Sur',       20.00),  --si lees esto zbinher kbro
('Tribuna Oriente',   35.00),
('Tribuna Occidente', 50.00); 

--0
INSERT INTO Estadio (NombreEstadio, IDubicacion, Categoria, MaxAforo) VALUES

('Estadio Andrés Bedoya Díaz',                1, 'MEDIANO', 7000), -- Ate 
('Estadio Alejandro Villanueva',                    2, 'GRANDE',   33938), -- La Victoria
('Estadio Municipal José Carlos Mariátegui',        3, 'PEQUEÑO',  2000), -- San Juan de Lurigancho
('Estadio Facundo Ramírez Aguilar',          4, 'PEQUEÑO',   2000), -- Callao

('Estadio Municipal de La Tomilla',          5, 'MEDIANO',  5000), -- Cayma / Arequipa
('Estadio Inca Garcilaso de la Vega',       6, 'GRANDE',  42000), -- Cusco
('Estadio Municipal de Florencia de Mora',   7, 'PEQUEÑO',   4000), -- Trujillo
('Estadio César Flores Marigorda',           8, 'MEDIANO',   7000), -- Lambayeque/Chiclayo
('Estadio Municipal de La Unión',            9, 'MEDIANO',   5000), -- Piura
('Estadio Campeones del 36',                 10, 'GRANDE', 12000), -- Sullana
('Estadio Mariscal Castilla de El Tambo',    11, 'MEADIANO',   5000), -- Huancayo
('Estadio José Picasso Peratta', 12, 'MEDIANO',  8000), -- Ica
('Estadio Eloy Molina Robles',               13, 'MEDIANO',  7500), -- Huanta / Ayacucho
('Estadio Max Augustín',                     14, 'GRANDE',  24576), -- Iquitos
('Estadio Aliardo Soria Pérez',              15, 'GRANDE', 25848), -- Pucallpa
('Estadio Carlos Vidaurre García',           16, 'MEDIANO', 7000), -- Tarapoto
('Estadio Joel Gutiérrez',                   17, 'GRANDE',  21000), -- Tacna
('Estadio Guillermo Briceño Rosamedina',      18, 'GRANDE',  18030), -- Juliaca
('Estadio Carolino de Puno',                 19, 'PEQUEÑO',  1020), -- Puno
('Estadio Centenario Manuel Rivera Sánchez ', 20, 'GRANDE',  32000), --Chimbote
('Estadio Héroes de San Ramón',          21, 'GRANDE',   10495), -- Cajamarca
('Estadio Olimpico de Amarilis',        22, 'GRANDE',   11000), -- Huánuco
('Estadio Mariscal Nieto',                   23, 'PEQUEÑO',  3000), -- Ilo / Moquegua
('Estadio Mariscal Cáceres',                 24, 'GRANDE', 12000), -- Tumbes
('Estadio IPD de Puerto Maldonado',          25, 'PEQUEÑO',  2000), -- Puerto Maldonado
('Estadio Monumental de Condebamba',         26, 'GRANDE', 12000), -- Abancay
('Estadio Daniel Alcides Carrión',           27, 'GRANDE', 12000), -- Cerro de Pasco
('Estadio IPD de Huancavelica',              28, 'MEDIANO',  8500), -- Huancavelica
('Estadio Kuélap',                           29, 'PEQUEÑO',  1000), -- Chachapoyas
('Estadio Rosas Pampa', 30, 'GRANDE',  18000);--Huaraz

INSERT INTO Club (NombreClub, IDubicacion, IDcompeticion, AnioFundacion) VALUES

--COPA PERU:
('Club Deportivo LAIVE', 1, 2, 2024), -- Ate 
('Club Mariscal Sucre de Deportes',  2, 2, 1925),-- La Victoria
('Club Defensor Lubricantes de Bayovar', 3, 2, 1996),-- San Juan de Lurigancho
('Club Deportivo Cultural Hacienda San Agustin', 4, 2, 1952),-- Callao

('Sportivo Huracan', 5, 2, 1927), -- Cayma / Arequipa
('Equipo de futbol UNSAAC', 6, 2, 1903),-- Cusco
('Alfonso Ugarte de Chiclin', 7, 2, 1946), -- Trujillo
('Club Cultural Deportivo Jose Balta', 8, 2, 1960),-- Lambayeque/Chiclayo
('Acedimia Shekina FC', 9, 2, 2010), -- Piura
('Chanel Futbol Club', 10, 2, 1957),-- Sullana
('AFAR Shalom', 11, 2, 2017),-- Huancayo
('Club Sport Marino de Comatrana', 12, 2, 1923),-- Ica
('Sport Matozoide FC', 13, 2, 2022),-- Ayacucho
('Club Deportivo UNAP', 14, 2, 1961),-- Iquitos
('CS Deportivo Bancos', 15, 2, 1954), -- Pucallpa
('Shuta Boys', 16, 2, 2018),-- Tarapoto
('Club Defensor UNTAC', 17, 2, 1971),-- Tacna
('Club Deportivo Credicoop San Roman', 18, 2, 2000),-- Juliaca
('Central Galeno FBC', 19, 2, 2016),-- Puno
('Club Juventud La Union', 20, 2, 1982),--Chimbote
('Deportivo Ingenieria Maximo Nivel', 21, 2, 2014),-- Cajamarca
('CSD Miguel Grau UDH', 22, 2, 2014),-- Huánuco
('Club Deportivo Enersur', 23, 2, 2003),-- Ilo / Moquegua
('Club Defensor las Mercedes', 24, 2, 1981), -- Tumbes
('Deportivo Maldonado', 25, 2, 1935),-- Puerto Maldonado
('Club Miguel Grau de Deportes de Abancay', 26, 2, 1954),-- Abancay
('Club Sport Sausa', 27, 2, 1963),-- Cerro de Pasco
('Diablos Rojos', 28, 2, 1968),-- Huancavelica
('Deportivo Sachapuyos', 29, 2, 1952),-- Chachapoyas
('Sport Ancash', 30, 2, 1935),-- Huaraz

--EQUIPOS DE LIGA 2:
('Academia Deportiva Cantolao', 4, 1, 1981),-- Callao
('Carlos A Mannucci',      7, 1, 1959), -- Trujillo
('Universidad Cesar Vallejo',      7, 1, 1996), -- Trujillo
('Pirata FC',         8, 1, 2015),-- Lambayeque/Chiclayo
('Sport Huancayo B',     11, 1, 1962),-- Huancayo
('Club Social Santos FC',              12, 1, 1976),-- Ica
('Ayacucho FC',    13, 1, 2008),--Ayacucho
('Comerciantes FC',      14, 1, 2017),-- Iquitos
('Estudiantil CNI',      14, 1, 1996),-- Iquitos
('Union Comercio',     16, 1, 2002),-- Tarapoto
('Bentin Tacna Heroica',        17, 1, 2014),-- Tacna
('Deportivo Binacional',         18, 1, 2010),-- Juliaca
('Alianza Universidad',         22, 1, 1939),-- Huánuco
('Union Minas', 27, 1, 1974);-- Cerro de Pasco



INSERT INTO Arbitro(CodigoArbitro, CategoriaArbitro) VALUES
('ARB-001', 'Nacional'),
('ARB-002', 'Nacional'),
('ARB-003', 'Nacional'),
('ARB-004', 'Regional'),
('ARB-005', 'Regional'),
('ARB-006', 'Regional'),
('ARB-007', 'Regional'),
('ARB-008', 'Departamental'),
('ARB-009', 'Departamental'),
('ARB-010', 'Departamental');





-- FALTAN TABLAS partido, Boleto, AsistenciaPartido , rendimiento partido

INSERT INTO Partido
(IDtemporada, IDetapa, IDestadio,IDequipoLocal, IDequipoVisitante, IDArbitro,
 FechaHora, Jornada, GolesLocal, GolesVisita, EstadoPartido)
VALUES
(5, 5, 1, 1, 2, 1, '2026-03-15 15:00:00', 1, 2, 1, 'Finalizado'),
(5, 5, 2, 3, 4, 2, '2026-03-16 16:00:00', 1, 0, 0, 'Finalizado'),
(5, 5, 5, 5, 6, 3, '2026-03-22 15:30:00', 2, 1, 2, 'Finalizado'),
(5, 5, 7, 7, 8, 4, '2026-10-10 15:00:00', 3, NULL, NULL, 'Programado'),
(5, 1, 1,  1,  2, 1, '2026-04-05 15:00:00', 1, 2, 0, 'Finalizado'),
(5, 1, 2,  3,  4, 2, '2026-04-05 16:00:00', 1, 1, 1, 'Finalizado'),
(5, 1, 5,  5,  6, 3, '2026-04-12 15:00:00', 2, 0, 2, 'Finalizado'),
(5, 1, 6,  7,  8, 4, '2026-04-12 16:00:00', NULL, NULL, NULL, 'Programado'),
(5, 2, 7,  9, 10, 5, '2026-05-03 15:00:00', 3, 2, 2, 'Finalizado'),
(5, 2, 8, 11, 12, 6, '2026-05-03 16:00:00', 3, 1, 0, 'Finalizado'),
(5, 2, 9, 13, 14, 7, '2026-05-10 15:00:00', 4, 0, 1, 'Finalizado'),
(5, 2, 10,15, 16, 8, '2026-05-10 16:00:00', 4, 2, 3, 'Finalizado'),
(5, 3, 11,17, 18, 9, '2026-06-07 15:00:00', 5, 1, 1, 'Finalizado'),
(5, 3, 12,19, 20,10, '2026-06-07 16:00:00', 5, NULL, NULL, 'Programado');


INSERT INTO Boleto
(IDpartido, IDtipoEntrada, FechaVenta,
 CanalVenta, MetodoPago, EstadoPago, PrecioPagado)
VALUES
(5, 1, '2026-04-01 10:00:00', 'Online', 'Yape', 'Pagado', 20.00),
(5, 2, '2026-04-02 11:00:00', 'Taquilla', 'Efectivo', 'Pagado', 20.00),
(6, 3, '2026-04-02 12:00:00', 'Online', 'Tarjeta', 'Pagado', 35.00),
(6, 4, '2026-04-03 13:00:00', 'Taquilla', 'Efectivo', 'Pagado', 50.00),
(7, 1, '2026-04-09 09:00:00', 'Online', 'Yape', 'Pagado', 20.00),
(7, 3, '2026-04-10 10:00:00', 'Online', 'Tarjeta', 'Pagado', 35.00),
(8, 2, '2026-04-10 11:00:00', 'Taquilla', 'Efectivo', 'Pagado', 20.00),
(8, 4, '2026-04-11 12:00:00', 'Online', 'Tarjeta', 'Pagado', 50.00),
(9, 1, '2026-04-29 10:00:00', 'Online', 'Yape', 'Pagado', 20.00),
(9, 2, '2026-04-30 11:00:00', 'Taquilla', 'Efectivo', 'Pagado', 20.00),
(10, 3, '2026-04-30 12:00:00', 'Online', 'Tarjeta', 'Pendiente', 35.00),
(10, 4, '2026-05-01 13:00:00', 'Taquilla', 'Efectivo', 'Pagado', 50.00),
(11, 1, '2026-05-06 10:00:00', 'Online', 'Yape', 'Pagado', 20.00),
(11, 3, '2026-05-07 11:00:00', 'Taquilla', 'Efectivo', 'Pendiente', 35.00),
(12, 2, '2026-05-06 12:00:00', 'Online', 'Tarjeta', 'Pagado', 20.00),
(12, 4, '2026-05-08 13:00:00', 'Taquilla', 'Efectivo', 'Pagado', 50.00),
(13, 1, '2026-06-03 10:00:00', 'Online', 'Yape', 'Pagado', 20.00),
(13, 3, '2026-06-04 11:00:00', 'Taquilla', 'Efectivo', 'Pagado', 35.00),
(14, 2, '2026-06-04 12:00:00', 'Online', 'Yape', 'Pendiente', 20.00),
(14, 4, '2026-06-05 13:00:00', 'Taquilla', 'Efectivo', 'Pendiente', 50.00);


INSERT INTO AsistenciaPartido
(IDpartido, AsistenciaRegistrada, AforoEstadio)       --Si ves que la asistencia salta de 3 a 5 o de 7 a 8, es poruqe esos partidos todavia no se juegan
VALUES
(1, 4500, 7000),
(2, 1800, 3000),
(3, 3200, 5000),
(5, 3200, 7000),
(6, 4500, 6000),
(7, 1800, 5000),
(9, 3900, 4000),
(10, 5200, 7000),
(11, 2400, 5000),
(12, 6100, 12000),
(13, 4800, 5000);


INSERT INTO RendimientoEquipoPartido                  --Si ves que los partidos saltan de 3 a 5 o de 7 a 8, es poruqe esos partidos todavia no se juegan
(IDpartido, IDclub, Condicion, Goles,                 
 Tiros, TirosAlArco, PosesionPct,
 Faltas, Amarillas, Rojas, Corners)
VALUES
-- Partido 1
(1, 1, 'Local', 2, 12, 6, 55, 14, 2, 0, 5),
(1, 2, 'Visitante', 1, 8, 3, 45, 17, 3, 0, 3),

-- Partido 2
(2, 3, 'Local', 0, 7, 2, 48, 15, 1, 0, 4),
(2, 4, 'Visitante', 0, 9, 4, 52, 12, 2, 0, 6),

-- Partido 3
(3, 5, 'Local', 1, 10, 4, 51, 13, 2, 0, 7),
(3, 6, 'Visitante', 2, 11, 5, 49, 16, 3, 1, 4),

-- Partido 5
(5, 1, 'Local', 2, 14, 6, 58, 12, 2, 0, 7),
(5, 2, 'Visitante', 0, 7, 2, 42, 16, 3, 0, 3),

-- Partido 6
(6, 3, 'Local', 1, 9, 3, 51, 14, 1, 0, 4),
(6, 4, 'Visitante', 1, 11, 4, 49, 13, 2, 0, 5),

-- Partido 7
(7, 5, 'Local', 0, 8, 2, 46, 15, 2, 0, 3),
(7, 6, 'Visitante', 2, 13, 7, 54, 11, 1, 0, 6),

-- Partido 9
(9, 9, 'Local', 2, 12, 5, 53, 14, 2, 0, 5),
(9, 10, 'Visitante', 2, 10, 4, 47, 16, 3, 0, 4),

-- Partido 10
(10, 11, 'Local', 1, 11, 5, 56, 12, 1, 0, 6),
(10, 12, 'Visitante', 0, 6, 2, 44, 17, 2, 0, 2),

-- Partido 11
(11, 13, 'Local', 0, 7, 2, 48, 13, 2, 0, 3),
(11, 14, 'Visitante', 1, 12, 5, 52, 15, 1, 0, 7),

-- Partido 12
(12, 15, 'Local', 2, 14, 6, 45, 17, 3, 0, 4),
(12, 16, 'Visitante', 3, 15, 7, 55, 12, 2, 0, 6),

-- Partido 13
(13, 17, 'Local', 1, 10, 4, 50, 14, 2, 0, 5),
(13, 18, 'Visitante', 1, 9, 3, 50, 15, 3, 0, 4);

select idTemporada from temporada
select idEtapa from Etapas
select IDestadio from Estadio
select IDclub from Club
select IDarbitro from Arbitro
select IDpartido from Partido

SELECT * FROM RendimientoEquipoPartido


