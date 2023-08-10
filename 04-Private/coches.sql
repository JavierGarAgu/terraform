USE coches;

-- Tabla para almacenar información de fabricantes de coches
CREATE TABLE Fabricantes (
    fabricante_id INT PRIMARY KEY,
    nombre VARCHAR(255)
);

-- Tabla para almacenar información de modelos de coches
CREATE TABLE Modelos (
    modelo_id INT PRIMARY KEY,
    nombre VARCHAR(255),
    fabricante_id INT,
    año INT,
    FOREIGN KEY (fabricante_id) REFERENCES Fabricantes(fabricante_id)
);

-- Tabla para almacenar información de propietarios de coches
CREATE TABLE Propietarios (
    propietario_id INT PRIMARY KEY,
    nombre VARCHAR(255),
    dirección VARCHAR(255),
    teléfono VARCHAR(20)
);

-- Tabla para relacionar coches con propietarios
CREATE TABLE Coches (
    coche_id INT PRIMARY KEY,
    modelo_id INT,
    propietario_id INT,
    año_compra INT,
    color VARCHAR(50),
    FOREIGN KEY (modelo_id) REFERENCES Modelos(modelo_id),
    FOREIGN KEY (propietario_id) REFERENCES Propietarios(propietario_id)
);

-- Insertar datos en la tabla Fabricantes
INSERT INTO Fabricantes (fabricante_id, nombre) VALUES
    (1, 'Toyota'),
    (2, 'Ford'),
    (3, 'Honda'),
    (4, 'Chevrolet');

-- Insertar datos en la tabla Modelos
INSERT INTO Modelos (modelo_id, nombre, fabricante_id, año) VALUES
    (1, 'Corolla', 1, 2022),
    (2, 'Camry', 1, 2021),
    (3, 'F-150', 2, 2022),
    (4, 'Civic', 3, 2021),
    (5, 'Accord', 3, 2022),
    (6, 'Silverado', 4, 2021);

-- Insertar datos en la tabla Propietarios
INSERT INTO Propietarios (propietario_id, nombre, dirección, teléfono) VALUES
    (1, 'Juan Pérez', 'Calle Principal 123', '555-1234'),
    (2, 'María López', 'Avenida Central 456', '555-5678'),
    (3, 'Pedro Rodríguez', 'Plaza Mayor 789', '555-9876');

-- Insertar datos en la tabla Coches
INSERT INTO Coches (coche_id, modelo_id, propietario_id, año_compra, color) VALUES
    (1, 1, 1, 2022, 'Azul'),
    (2, 3, 2, 2022, 'Rojo'),
    (3, 4, 3, 2021, 'Blanco'),
    (4, 2, 1, 2022, 'Gris'),
    (5, 5, 2, 2021, 'Negro');
