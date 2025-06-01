import jwt from 'jsonwebtoken';
import { registerUser, authenticateUser } from '../models/users.js';
import bcrypt from 'bcrypt';
import { pool } from '../models/db.js';
// Llibreria per a les variables d'entorn
import dotenv from 'dotenv';

// Aquesta és la forma correcta d'accedir a les claus secretes
dotenv.config();
const SECRET_KEY = process.env.SECRET_KEY;

// Registre d'usuari
export const register = async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).send({ error: 'Nom d\'usuari i contrasenya requerits' });
  }
  const newUser = await registerUser(username, password);
  res.status(201).send(newUser);
};

// Login d'usuari
export const login = async (req, res) => {
  console.log("Recibido login para:", req.body);
  const { username, password } = req.body;
  if (!username || !password) {
    console.log("Error: faltan credenciales");
    return res.status(400).send({ error: 'Nom d\'usuari i contrasenya requerits' });
  }

  try {
    console.log("Intentando autenticar:", username);
    const user = await authenticateUser(username, password);
    console.log("Resultado autenticación:", user ? "Exitoso" : "Fallido");
    
    if (!user) {
      return res.status(401).send({ error: 'Usuario o contraseña incorrectos' });
    }

    const token = jwt.sign({ 
      username: user.username,
      id: user.id 
    }, SECRET_KEY, { expiresIn: '1h' });
    
    res.send({ token, id: user.id });
  } catch (err) {
    console.error("Error en login:", err);
    res.status(500).send({ error: 'Error de servidor' });
  }
};

export const getProfile = async (req, res) => {
  try {
      // Aquí puedes obtener más datos del usuario si los necesitas
      res.json({
          username: req.user.username,
          message: `Benvingut, ${req.user.username}!`
      });
  } catch (err) {
      res.status(500).send({ error: 'Error al obtener el perfil' });
  }
};

// Actualizar datos de usuario
export const updatePerfil = async (req, res) => {
  const { nombre, contraseña } = req.body;
  const userId = req.user.id;

  if (!nombre && !contraseña) {
    return res.status(400).json({ error: 'Nada que actualizar' });
  }

  if (!nombre && !contraseña) {
    return res.status(400).json({ error: 'Nada que actualizar' });
  }

  const updates = [];
  const values = [];

  if (nombre) {
    updates.push('nombre = ?');
    values.push(nombre);
  }

  if (contraseña) {
    const hashedPassword = await bcrypt.hash(contraseña, 10);
    updates.push('contraseña = ?');
    values.push(hashedPassword);
  }

  values.push(userId);

  try {
    await pool.query(
      `UPDATE usuarios SET ${updates.join(', ')} WHERE id = ?`,
      values
    );
    res.status(200).json({ message: 'Perfil actualizado correctamente' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al actualizar perfil' });
  }
};
