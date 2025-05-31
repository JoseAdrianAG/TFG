import express from 'express';
import { pool } from '../models/db.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';
const router = express.Router();

// Verificar disponibilidad antes de crear reserva
router.get('/disponibilidad', authenticateToken, async (req, res) => {
  const { restaurante_id, fecha, hora } = req.query;
  
  try {
    // Verificar si ya existe una reserva para ese restaurante en esa fecha y hora
    const [reservas] = await pool.query(
      `SELECT * FROM reservas 
       WHERE restaurante_id = ? AND fecha = ? AND hora = ?`,
      [restaurante_id, fecha, hora]
    );

    // Si no hay reservas, está disponible
    if (reservas.length === 0) {
      return res.json({ disponible: true });
    }

    // Si hay reservas, no está disponible
    return res.json({ 
      disponible: false,
      mensaje: 'Ya existe una reserva para este restaurante en la fecha y hora seleccionadas'
    });
    
  } catch (error) {
    console.error('Error al verificar disponibilidad:', error);
    res.status(500).json({ error: 'Error al verificar disponibilidad' });
  }
});

// Obtener reservas del usuario
router.get('/', authenticateToken, async (req, res) => {
  const usuarioId = req.user.id;

  try {
    const [reservas] = await pool.query(
      'SELECT * FROM reservas WHERE usuario_id = ?',
      [usuarioId]
    );

    res.status(200).json(reservas);
  } catch (error) {
    console.error('Error al obtener las reservas:', error);
    res.status(500).json({ error: 'Error al obtener las reservas' });
  }
});

// Eliminar reserva
router.delete('/:id', authenticateToken, async (req, res) => {
  const reservaId = req.params.id;
  const usuarioId = req.user.id;

  try {
    // Verificar que la reserva pertenece al usuario
    const [verificacion] = await pool.query(
      'SELECT * FROM reservas WHERE id = ? AND usuario_id = ?',
      [reservaId, usuarioId]
    );

    if (verificacion.length === 0) {
      return res.status(404).json({ mensaje: 'Reserva no encontrada o no autorizada' });
    }

    const [result] = await pool.query(
      'DELETE FROM reservas WHERE id = ?',
      [reservaId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ mensaje: 'Reserva no encontrada' });
    }

    res.status(200).json({ mensaje: 'Reserva eliminada correctamente' });
  } catch (error) {
    console.error('Error al eliminar la reserva:', error);
    res.status(500).json({ mensaje: 'Error al eliminar la reserva' });
  }
});

// Crear nueva reserva con verificación de disponibilidad
router.post('/', authenticateToken, async (req, res) => {
  const usuarioId = req.user.id;
  const { restaurante_id, nombre_restaurante, fecha, hora, personas } = req.body;

  try {
    // Primero verificamos disponibilidad
    const [reservasExistentes] = await pool.query(
      `SELECT * FROM reservas 
       WHERE restaurante_id = ? AND fecha = ? AND hora = ?`,
      [restaurante_id, fecha, hora]
    );

    if (reservasExistentes.length > 0) {
      return res.status(400).json({ 
        mensaje: 'Ya existe una reserva para este restaurante en la fecha y hora seleccionadas' 
      });
    }

    // Si está disponible, creamos la reserva
    const [result] = await pool.query(
      `INSERT INTO reservas 
       (usuario_id, restaurante_id, nombre_restaurante, fecha, hora, personas)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [usuarioId, restaurante_id, nombre_restaurante, fecha, hora, personas]
    );

    res.status(201).json({ 
      mensaje: 'Reserva creada correctamente',
      id: result.insertId 
    });
  } catch (error) {
    console.error('Error al crear la reserva:', error);
    res.status(500).json({ mensaje: 'Error al crear la reserva' });
  }
});

export default router;