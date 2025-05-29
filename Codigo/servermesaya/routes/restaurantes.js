import express from 'express';
import { authenticateToken } from '../middlewares/authMiddleware.js';
import fs from 'fs/promises';
const router = express.Router();

//Obtener todos los restaurantes
router.get('/', async (req, res) => {
  try {
    const datos = await fs.readFile('./assets/restaurantes.json', 'utf-8');
    const restaurantes = JSON.parse(datos);

    res.status(200).json(restaurantes);
  } catch (error) {
    console.error('Error al leer el archivo de restaurantes:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

//Obtener restaurante por ID
router.get('/:id', authenticateToken, async (req, res) => {
  const id = parseInt(req.params.id);

  try {
    const datos = await fs.readFile('./assets/restaurantes.json', 'utf-8');
    const restaurantes = JSON.parse(datos);

    const restaurante = restaurantes.find(r => r.id === id);

    if (restaurante) {
      res.status(200).json(restaurante);
    } else {
      res.status(404).json({ error: 'Restaurante no encontrado' });
    }
  } catch (error) {
    console.error('Error al leer el archivo de restaurantes:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

export default router;