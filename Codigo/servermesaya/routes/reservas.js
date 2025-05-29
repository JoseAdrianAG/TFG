import express from 'express';
import { pool } from '../models/db.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';
const router = express.Router();

//Peticion GET, conseguir una reserva por id
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

//Peticion DELETE, eliminar una reserva por id
router.delete('/:id', async (req, res) => {
  const reservaId = req.params.id;

  try {
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


//Peticion POST, guardar una reserva
router.post('/', authenticateToken, async (req, res) => {
  const { usuario_id, restaurante_id, nombre_restaurante, fecha, hora, personas } = req.body;

  try {
    await pool.query(
      `INSERT INTO reservas (usuario_id, restaurante_id, nombre_restaurante, fecha, hora, personas)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [usuario_id, restaurante_id, nombre_restaurante, fecha, hora, personas]
    );

    res.status(200).json({ mensaje: 'Reserva guardada correctamente' });
  } catch (error) {
    console.error('Error al guardar la reserva:', error);
    res.status(500).json({ mensaje: 'Error al guardar la reserva' });
  }
});

export default router;
