#Creo la base de datos y las tablas que la componen
DROP DATABASE IF EXISTS ArteVida_Cultural; #Para refrescar la DB

CREATE DATABASE ArteVida_Cultural;
USE ArteVida_Cultural;

CREATE table Ubicacion (
	Id_lugar char(4),
    Direccion varchar(120),
    Nombre_U varchar(40),
    Caracteristicas varchar(150),
    Alquiler numeric(9,2) unsigned not null, #Positivo mayor que 0 
    Aforo int unsigned not null, #Entero mayor que 0
    Ciu_puebl BIT, #Ciudad = 1, Pueblo = 0
    PRIMARY KEY(Id_lugar)
);

CREATE table Actividades (
	Id_actividad char(4),
    Tipo varchar(40),
    Coste numeric(11,2) default 0,
    Nombre_A varchar(60),
    PRIMARY KEY(Id_actividad)
);

CREATE table Artista (
	Id_artista char(4),
    Nombre varchar(40),
    Biografia varchar(150),
    PRIMARY KEY(Id_artista)
);

CREATE table Asistentes ( 
	Id_asistente char(4),
    Nombre_C varchar(40),
    Mail varchar(40),
    PRIMARY KEY(Id_asistente)
);
/*
Se pueden añadir entradas sin añadir el nuevo asistente a Vienen aunque esté restringido por el modelo, no se puede controlar desde aquí
sino más bien requiere que la app que tome los datos obligue a los asistentes a elegir un evento al que asistan.
*/

CREATE table Telefonos (
	Id_asistente char(4),
    Num_Telef varchar(20),
    FOREIGN KEY(Id_asistente) REFERENCES Asistentes(Id_asistente) ON DELETE cascade,
    PRIMARY KEY(Id_asistente, Num_telef)
);

CREATE table Eventos (
	NombreE varchar(40),
    Precio numeric(5,2) unsigned not null,
    Descripcion varchar(150),
    Fecha date not null,
    Hora time not null,
    Id_actividad char(4), #foreign key
    Id_lugar char(4), #foreign key
    PRIMARY KEY(NombreE),
    FOREIGN KEY(Id_actividad) REFERENCES Actividades(Id_actividad) ON DELETE cascade,
    FOREIGN KEY(Id_lugar) REFERENCES Ubicacion(Id_lugar) ON DELETE cascade
);

CREATE table Vienen (
	NombreE varchar(40),
    Id_asistente char(4),
    Valoracion int unsigned,
    CHECK (Valoracion <= 5), #Va de 0 a 5
    PRIMARY KEY(NombreE,Id_asistente),
    FOREIGN KEY(NombreE) REFERENCES Eventos(NombreE) ON DELETE cascade,
    FOREIGN KEY(Id_asistente) REFERENCES Asistentes(Id_asistente) ON DELETE cascade
);

CREATE table Participa (
	Id_actividad char(4),
    Id_artista char(4),
    Cache_Art numeric(10,2),
    PRIMARY KEY(Id_actividad,Id_artista),
    FOREIGN KEY(Id_actividad) REFERENCES Actividades(Id_actividad) ON DELETE cascade,
    FOREIGN KEY(Id_artista) REFERENCES Artista(Id_artista) ON DELETE cascade
);

#Lista de los disparadores (TRIGGER) para los aspectos que no se pueden modelar en los diseños anteriores.

#Cálculo de Coste como la suma de caché.
DROP TRIGGER IF EXISTS CalculoDeCoste;
CREATE TRIGGER CalculoDeCoste
AFTER INSERT ON Participa
FOR EACH ROW
UPDATE Actividades
SET Coste = Coste + NEW.Cache_Art
WHERE Id_actividad = NEW.Id_actividad; #OJO la NEW hace referencia a la tabla participa mientras que el otro refiere a actividades

#Aqui se debe contar el número de asistentes que vienen a un mismo evento y comparar el aforo del lugar asociado al evento y si lo supera error.

delimiter // #Mirar lo de las fechas diferentes
CREATE TRIGGER AforoMaximo
AFTER INSERT ON Vienen
FOR EACH ROW
BEGIN 
	DECLARE id char(4);
	IF (SELECT Aforo - 1 < 0
    FROM Ubicacion U INNER JOIN Eventos E ON U.Id_lugar = E.Id_lugar
    WHERE E.NombreE = NEW.NombreE) #Aqui me ahorro el join con Vienen
		THEN SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Se ha superado el aforo';
	ELSE #Actualiza el aforo
		SELECT Id_lugar into id
        FROM Eventos
		WHERE NombreE = NEW.NombreE; #Aqui tambien me ahorro join con Vienen
		UPDATE Ubicacion SET Aforo = Aforo - 1 WHERE Id_lugar = id; #Uso esta notación para simplificar
	END IF;
END;//
delimiter ;

#Introduzco datos para la base de datos al usar el sistema operativo Ubuntu haré uso de los comandos de mysql para insertar datos.
#NOTA: Estoy insertando en Bulk los datos iniciales y me he asegurado de que estuvieran bien pero insertar datos a posteriori
#debe separar los values en inserts mas pequeños pues hay un trigger que causa rollback.

INSERT INTO Ubicacion(Id_lugar, Direccion, Nombre_U, Caracteristicas, Alquiler, Aforo, Ciu_puebl) 
VALUES 
('U001', 'Calle Mayor 10', 'Galería ArteUno', 'Sala amplia con buena iluminación', 1500.00, 100, 1),
('U002', 'Av. del Arte 45', 'Museo Moderno', 'Espacios abiertos y exposiciones', 3000.00, 250, 1),
('U003', 'Plazuela del Pueblo 3', 'Centro Cultural', 'Ideal para pequeños conciertos', 800.00, 50, 0),
('U004', 'Calle del Carmen 27', 'Sala Múltiple', 'Espacio multifuncional', 1200.00, 75, 1),
('U005', 'Camino Rural 12', 'Finca Cultura', 'Espacio al aire libre', 600.00, 200, 0),
('U006', 'Paseo de la Libertad 8', 'Teatro Central', 'Teatro con acústica excelente', 5000.00, 500, 1),
('U007', 'Calle Luna 9', 'Espacio Libre', 'Lugar de ensayo para obras pequeñas', 900.00, 60, 1),
('U008', 'Camino Viejo 22', 'Jardín Botánico', 'Ideal para eventos al aire libre', 1100.00, 150, 0),
('U009', 'Plaza del Mercado 5', 'Foro Abierto', 'Espacio abierto con buena acústica', 2000.00, 300, 0),
('U010', 'Avenida del Sol 20', 'Auditorio Sol', 'Sala de conferencias profesional', 3500.00, 400, 1);

INSERT INTO Actividades(Id_actividad, Tipo, Coste, Nombre_A) 
VALUES 
('A001', 'Concierto de Música Clásica', 0.00, 'Concierto de Beethoven y Mozart'),
('A002', 'Concierto de Pop', 0.00, 'Festival de Música Pop Moderna'),
('A003', 'Concierto de Jazz', 0.00, 'Concierto de Jazz en Vivo'),
('A004', 'Obra de Teatro', 0.00, 'Obra de Teatro Experimental'),
('A005', 'Exposición de Arte', 0.00, 'Exposición de Escultura Moderna'),
('A006', 'Concierto de Rock and Roll', 0.00, 'Concierto de Rock Clásico'),
('A007', 'Conferencia', 0.00, 'Conferencia sobre Literatura Contemporánea'),
('A008', 'Concierto de Blues', 0.00, 'Festival de Blues y Soul'),
('A009', 'Concierto de Reggaetón', 0.00, 'Concierto Urbano de Reggaetón'),
('A010', 'Concierto de Country', 0.00, 'Festival de Música Country');

INSERT INTO Artista(Id_artista, Nombre, Biografia) 
VALUES 
('ART1', 'Carlos Martínez', 'Pintor contemporáneo con exposiciones globales'),
('ART2', 'Laura Gómez', 'Escultora especializada en mármol y piedra'),
('ART3', 'Ana Rodríguez', 'Coreógrafa y bailarina de danza moderna'),
('ART4', 'Juan Pérez', 'Músico de jazz con 20 años de trayectoria'),
('ART5', 'Silvia Blanco', 'Actriz y directora de teatro experimental'),
('ART6', 'José Herrera', 'Fotógrafo urbano con varias publicaciones'),
('ART7', 'María Morales', 'Poeta y escritora de ensayos'),
('ART8', 'Andrés Fernández', 'Cineasta con enfoque en cine clásico'),
('ART9', 'Alejandro López', 'Artista de performance con presentaciones globales'),
('BRT1', 'Valentina Ríos', 'Músico indie con tres álbumes lanzados');

INSERT INTO Asistentes(Id_asistente, Nombre_C, Mail) 
VALUES 
('AS01', 'Juan García', 'juan.garcia@gmail.com'),
('AS02', 'María López', 'maria.lopez@hotmail.com'),
('AS03', 'Pedro Sánchez', 'pedro.sanchez@hotmail.com'),
('AS04', 'Ana Torres', 'ana.torres@gmail.com'),
('AS05', 'Luis Fernández', 'luis.fernandez@yahoo.com'),
('AS06', 'Carmen Martínez', 'carmen.martinez@banco.com'),
('AS07', 'Pablo Castillo', 'pablo.castillo@consultora.com'),
('AS08', 'Laura Gutiérrez', 'laura.gutierrez@construcciones.com'),
('AS09', 'Sergio Morales', 'sergio.morales@bing.com'),
('AS10', 'Elena Jiménez', 'elena.jimenez@facebook.com');

INSERT INTO Telefonos(Id_asistente, Num_Telef) 
VALUES 
('AS01', '+34 600123456'),
('AS02', '+34 600987654'),
('AS03', '+34 601234567'),
('AS04', '+34 609876543'),
('AS05', '+34 602345678'),
('AS06', '+34 608765432'),
('AS07', '+34 603456789'),
('AS08', '+34 607654321'),
('AS09', '+34 604567890'),
('AS10', '+34 606543210');

INSERT INTO Eventos(NombreE, Precio, Descripcion, Fecha, Hora, Id_actividad, Id_lugar) 
VALUES 
('Concierto Beethoven y Mozart', 15.00, 'Concierto de música clásica de Beethoven y Mozart', '2024-11-01', '18:00', 'A001', 'U001'),
('Festival de Pop', 20.00, 'Festival con los mejores artistas de música pop', '2024-11-05', '20:00', 'A002', 'U006'),
('Concierto de Jazz en Vivo', 25.00, 'Concierto en vivo de los mejores músicos de jazz', '2024-11-12', '21:00', 'A003', 'U009'),
('Exposición de Escultura Moderna', 10.00, 'Exposición de escultores contemporáneos', '2024-11-18', '19:00', 'A005', 'U010'),
('Obra Experimental', 18.00, 'Obra de teatro experimental con actores locales', '2024-11-20', '09:00', 'A004', 'U002'),
('Concierto de Rock Clásico', 12.00, 'Concierto de las mejores bandas de rock and roll', '2024-11-22', '20:30', 'A006', 'U004'),
('Conferencia sobre Literatura', 5.00, 'Conferencia sobre literatura contemporánea', '2024-11-25', '17:00', 'A007', 'U003'),
('Festival de Blues y Soul', 15.00, 'Concierto de blues y soul con artistas locales', '2024-11-28', '22:00', 'A008', 'U005'),
('Concierto de Reggaetón', 8.00, 'Concierto de reggaetón urbano', '2024-11-30', '10:00', 'A009', 'U007'),
('Festival de Música Country', 12.00, 'Festival con los mejores artistas de música country', '2024-12-02', '16:00', 'A010', 'U008');

INSERT INTO Vienen(NombreE, Id_asistente, Valoracion) 
VALUES 
('Concierto Beethoven y Mozart', 'AS01', 0),
('Concierto Beethoven y Mozart', 'AS02', 3),
('Concierto Beethoven y Mozart', 'AS06', 2),
('Festival de Pop', 'AS02', 5),
('Festival de Pop', 'AS08', 4),
('Concierto de Jazz en Vivo', 'AS03', 3),
('Exposición de Escultura Moderna', 'AS04', 5),
('Obra Experimental', 'AS05', 4),
('Concierto de Rock Clásico', 'AS06', 3),
('Conferencia sobre Literatura', 'AS07', 5),
('Festival de Blues y Soul', 'AS08', 4),
('Concierto de Reggaetón', 'AS09', 3),
('Festival de Música Country', 'AS10', 4);

INSERT INTO Participa(Id_actividad, Id_artista, Cache_Art) 
VALUES 
('A001', 'ART4', 1000.00),  
('A001', 'ART2', 1200.00),  
('A002', 'BRT1', 800.00),  
('A002', 'ART5', 600.00),   
('A003', 'ART4', 1500.00),  
('A003', 'ART9', 1000.00),  
('A004', 'ART5', 1200.00),  
('A005', 'ART1', 1300.00),  
('A005', 'ART7', 500.00),   
('A006', 'ART4', 700.00),  
('A006', 'ART3', 850.00),  
('A007', 'ART7', 400.00),   
('A007', 'ART9', 600.00),  
('A008', 'ART9', 900.00),  
('A008', 'ART4', 1100.00), 
('A009', 'ART6', 500.00),   
('A009', 'BRT1', 700.00),
('A010', 'BRT1', 2000.00), 
('A010', 'ART3', 1300.00);

#10 Queries. 

#Buscar la actividad y su coste asociado
SELECT Nombre_A, Coste
FROM Actividades;

#Obtener el coste total de los eventos
SELECT NombreE, Coste + Alquiler as total
FROM Eventos E INNER JOIN Actividades A ON E.Id_actividad = A.Id_actividad INNER JOIN Ubicacion U ON E.Id_lugar = U.Id_lugar;

#Calcular el beneficio total obtenido en cada evento
SELECT E.NombreE, E.Precio * (SELECT COUNT(V.Id_asistente) FROM Vienen V WHERE V.NombreE = E.NombreE) AS Beneficio
FROM Eventos E;

#Obtener la valoración media de cada evento
SELECT NombreE, AVG(Valoracion)
FROM Vienen
GROUP BY NombreE;

#Qué valoración obtuvieron las actividades con el TOP 5 artistas más caros
SELECT P.Id_actividad, Cache_Art, Valoracion
FROM Participa P INNER JOIN Eventos E ON P.Id_actividad = E.Id_actividad INNER JOIN Vienen V ON E.NombreE = V.NombreE
ORDER BY Cache_Art DESC
LIMIT 5;

#¿Cuales de todos los eventos fueron conciertos?
SELECT NombreE
FROM Eventos
WHERE NombreE LIKE '%Concierto%';

#¿Cuál es la hora del evento que tuvo más asistentes?
CREATE VIEW Asistencia AS #Creo una tabla virtual que tiene las horas de los eventos, la cantidad de asistentes y nombres
SELECT E.NombreE, Hora,COUNT(Id_asistente) AS Num 
FROM Eventos E INNER JOIN Vienen V ON V.NombreE = E.NombreE 
GROUP BY E.NombreE;

SELECT * 
FROM Asistencia
WHERE Num = (SELECT MAX(Num) FROM Asistencia); #Me quedo con la fila con más asistentes

#¿Cuál es la actividad con más artistas?

SELECT Nombre_A, COUNT(Id_artista) AS Num_art
FROM Actividades A INNER JOIN Participa P ON A.Id_actividad = P.Id_actividad
GROUP BY A.Id_actividad
ORDER BY Num_art DESC
LIMIT 1;

#¿Cuáles eventos han sido valorados menos que el promedio?
CREATE VIEW ValoracionEventos AS 
SELECT NombreE, AVG(Valoracion) AS rating
FROM Vienen
GROUP BY NombreE;

SELECT NombreE, rating
FROM ValoracionEventos
WHERE rating < (SELECT AVG(rating) FROM ValoracionEventos);

#¿Cuáles asistentes usaron un correo de empresa?

SELECT Nombre_C, Mail
FROM Asistentes
WHERE Mail NOT LIKE '%@gmail%' AND Mail NOT LIKE '%@hotmail%' AND Mail NOT LIKE '%@yahoo%' AND Mail NOT LIKE '%@bing%';

