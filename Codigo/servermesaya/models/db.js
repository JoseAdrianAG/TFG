import mysql from 'mysql2/promise';

// Configuración de la conexión a la base de datos
const pool = mysql.createPool({
    user: 'root',
    host: 'localhost',
    database: 'MesaYa',
    password: 'root',
    port: 3307,
    waitForConnections: true,
    connectionLimit: 10,     // Número máximo de conexiones en el pool
    queueLimit: 0
});

export { pool };