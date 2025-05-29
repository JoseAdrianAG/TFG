DROP DATABASE IF EXISTS MesaYa;
CREATE DATABASE MesaYa;
USE MesaYa;

-- Tabla de usuarios
CREATE TABLE usuarios (
  id BIGINT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  contraseña VARCHAR(100) NOT NULL,
  fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de reservas
CREATE TABLE reservas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id BIGINT NOT NULL,
  restaurante_id INT NOT NULL,
  nombre_restaurante VARCHAR(255),
  fecha DATE,
  hora TIME,
  personas INT,
  fecha_reserva TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de restaurantes favoritos
CREATE TABLE favoritos (
  usuario_id BIGINT NOT NULL,
  restaurante_id INT NOT NULL,
  nombre_restaurante VARCHAR(255),
  PRIMARY KEY (usuario_id, restaurante_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
