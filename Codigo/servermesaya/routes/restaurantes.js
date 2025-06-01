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

//Obtener horarios de un restaurante
router.get('/:id/horarios', async (req, res) => {
  const restauranteId = parseInt(req.params.id);
  const { fecha } = req.query;

  try {
    const datos = await fs.readFile('./assets/restaurantes.json', 'utf-8');
    const restaurantes = JSON.parse(datos);
    const restaurante = restaurantes.find(r => r.id === restauranteId);

    if (!restaurante || !restaurante.horario) {
      return res.status(404).json({ error: 'Restaurante o horario no encontrado' });
    }

    const diaSemana = new Date(fecha).toLocaleDateString('es-ES', { weekday: 'long' }).toLowerCase();
    const horarioDia = restaurante.horario[diaSemana];

    if (!horarioDia || horarioDia === 'CERRADO') {
      return res.json(['CERRADO']);
    }

    const horasDisponibles = [];

    const generarHoras = (apertura, cierre) => {
      let horaActual = new Date(`1970-01-01T${apertura}:00`);
      const fin = new Date(`1970-01-01T${cierre}:00`);
      while (horaActual < fin) {
        const horaStr = horaActual.toTimeString().slice(0, 5);
        horasDisponibles.push(horaStr);
        horaActual.setMinutes(horaActual.getMinutes() + 30);
      }
    };

    if (Array.isArray(horarioDia)) {
      for (const franja of horarioDia) {
        generarHoras(franja.apertura, franja.cierre);
      }
    } else if (horarioDia.apertura && horarioDia.cierre) {
      generarHoras(horarioDia.apertura, horarioDia.cierre);
    }

    res.json(horasDisponibles);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});


export default router;