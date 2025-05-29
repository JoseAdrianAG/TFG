import express from 'express';
import https from 'https';
import fs from 'fs';
import dotenv from 'dotenv';
import jwt from 'jsonwebtoken';
import authRouter from './routes/authRoutes.js';
import reservas from './routes/reservas.js';
import favoritos from './routes/favoritos.js';
import restaurantes from './routes/restaurantes.js';


// Carregar els certificats i crea un JSON anomenat credentials
const privateKey = fs.readFileSync('./certs/server.key', 'utf8');
const certificate = fs.readFileSync('./certs/server.cert', 'utf8');
const credentials = { key: privateKey, cert: certificate };

// Definim app com a una aplicació Express
const app = express();

// Incorporem el middleware per gestionar sol·licituds JSON
app.use(express.json());

app.use('/auth', authRouter);

app.use('/reservas',reservas);

app.use('/favoritos',favoritos);

app.use('/restaurantes',restaurantes);

app.get('/', (req, res) => {
  res.send('Servidor conectado correctamente ✔️');
});



// Creem el servidor HTTPS amb les credencials i l'aplicació Express
const httpsServer = https.createServer(credentials, app);

// Escoltar al port 3000
httpsServer.listen(3000, () => {
  console.log('Servidor HTTPS en execució a https://localhost:3000');
});


dotenv.config();
const SECRET_KEY = process.env.SECRET_KEY;

export const authenticateToken = (req, res, next) => {
  // Busquem el camp Authorization en la capçalera
  const authHeader = req.header('Authorization');

  // obtenim el token (component 1)
  const token = authHeader && authHeader.split(' ')[1];

  // Si no hi ha token retornem error
  if (!token) {
    return res.status(401).send({ error: 'Token no proporcionat' });
  }

  // Verifiquem el token, i extraiem l'usuari
  try {
    const payload = jwt.verify(token, SECRET_KEY);
    req.user = payload;
    // Amb next, "botem" al pròxim middleware
    next();
  } catch (err) {
    res.status(403).send({ error: 'Token no vàlid' });
  }
};