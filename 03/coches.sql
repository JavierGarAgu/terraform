USE coches;

CREATE TABLE coches (
    id INT IDENTITY(1,1) PRIMARY KEY,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    anio INT NOT NULL
);

INSERT INTO coches (marca, modelo, anio) VALUES
    ('Toyota', 'Corolla', 2022),
    ('Honda', 'Civic', 2021),
    ('Ford', 'Focus', 2023),
    ('Chevrolet', 'Cruze', 2020);
