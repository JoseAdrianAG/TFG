import jwt from 'jsonwebtoken';
import { registerUser, authenticateUser } from '../models/users.js';

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
      return res.status(401).send({ error: 'Credencials incorrectes' });
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