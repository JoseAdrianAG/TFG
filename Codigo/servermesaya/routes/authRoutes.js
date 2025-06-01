import express from 'express';
import { register, login, updatePerfil } from '../controllers/authController.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';

// Creem el router
const router = express.Router();

// Configurem les rutes d'autenticació
router.post('/register', register);
router.post('/login', login);
router.put('/update', authenticateToken, updatePerfil)

// Creem unaruta protegida d'exemple
// Abans de passar al middleware que gestiona aqueta petició (el res.send), 
// ha de passar pel middleware autMiddleware o obtindre el token d'autenticació.
router.get('/protected', authenticateToken, (req, res) => {
  res.send({ message: `Benvingut, ${req.user.username}!` });
});

export default router;