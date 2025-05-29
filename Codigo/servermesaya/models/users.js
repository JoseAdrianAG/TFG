import bcrypt from 'bcryptjs';
import { pool } from './db.js';

export const registerUser = async (username, password) => {
    const hashedPassword = await bcrypt.hash(password, 10);

    // Usamos el nombre exacto del campo 'contraseña'
    const query = 'INSERT INTO usuarios (nombre, contraseña) VALUES (?, ?)';
    const values = [username, hashedPassword];

    try {
        const [result] = await pool.query(query, values);

        if (result.affectedRows === 1) {
            return { username };
        } else {
            throw new Error('No se pudo registrar el usuario');
        }
    } catch (err) {
        throw new Error('Error al registrar el usuario: ' + err.message);
    }
};

export const authenticateUser = async (usuario, contraseña) => {
    const query = 'SELECT id, nombre, contraseña FROM usuarios WHERE nombre = ?';
    const values = [usuario];

    try {
        const [rows] = await pool.query(query, values);
        
        // Si no se encuentra el usuario
        if (rows.length === 0) {
            return null;
        }

        const user = rows[0];
        
        // Asegurarnos de usar el campo correcto 'contraseña'
        const isPasswordValid = await bcrypt.compare(contraseña, user.contraseña);
        
        if (isPasswordValid) {
            return {
                id: user.id,
                username: user.nombre
            };
        } else {
            return null;
        }
    } catch (err) {
        console.error('Error completo:', err);
        throw new Error('Error al autenticar el usuario: ' + err.message);
    }
};

export const getUserProfile = async (userId) => {
    const query = 'SELECT id, nombre FROM usuarios WHERE id = ?';
    try {
        const [rows] = await pool.query(query, [userId]);
        if (rows.length === 0) return null;
        return {
            id: rows[0].id,
            username: rows[0].nombre
        };
    } catch (err) {
        throw new Error('Error al obtener el perfil: ' + err.message);
    }
};