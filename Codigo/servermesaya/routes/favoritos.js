import express from 'express';
import { pool } from '../models/db.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';
const router = express.Router();

// Obtener todos los favoritos del usuario
router.get('/usuario/:usuario_id', authenticateToken, async (req, res) => {
  const { usuario_id } = req.params;
  try {
    const [favoritos] = await pool.query(
      'SELECT * FROM favoritos WHERE usuario_id = ?',
      [usuario_id]
    );
    res.status(200).json(favoritos);
  } catch (error) {
    console.error('Error al obtener los favoritos:', error);
    res.status(500).json({ error: 'Error al obtener los favoritos' });
  }
});

// Verificar si un restaurante es favorito
router.get('/es-favorito/:restaurante_id', authenticateToken, async (req, res) => {
  const usuario_id = req.user.id;
  const { restaurante_id } = req.params;

  try {
    const [rows] = await pool.query(
      'SELECT * FROM favoritos WHERE usuario_id = ? AND restaurante_id = ?',
      [usuario_id, restaurante_id]
    );

    if (rows.length > 0) {
      return res.sendStatus(200);
    } else {
      return res.sendStatus(404);
    }
  } catch (error) {
    console.error('Error al verificar favorito:', error);
    res.status(500).json({ error: 'Error al verificar favorito' });
  }
});

// Agregar favorito
router.post('/', authenticateToken, async (req, res) => {
  const usuario_id = req.user.id;
  const { restaurante_id } = req.body;
  const nombre_restaurante = req.body.nombre_restaurante;
  try {
    await pool.query(
      'INSERT INTO favoritos (usuario_id, restaurante_id, nombre_restaurante) VALUES (?, ?, ?)',
      [usuario_id, restaurante_id, nombre_restaurante]
    );
    res.status(201).json({ mensaje: 'Favorito guardado' });
  } catch (error) {
    console.error('Error al guardar favorito:', error);
    res.status(500).json({ mensaje: 'Error al guardar favorito' });
  }
});

// Eliminar favorito
router.delete('/', authenticateToken, async (req, res) => {
  const usuario_id = req.user.id;
  const { restaurante_id } = req.body;
  const nombre_restaurante = req.body.nombre_restaurante;
  try {
    await pool.query(
      'DELETE FROM favoritos WHERE usuario_id = ? AND restaurante_id = ? AND nombre_restaurante = ?',
      [usuario_id, restaurante_id, nombre_restaurante]
    );
    res.status(200).json({ mensaje: 'Favorito eliminado' });
  } catch (error) {
    console.error('Error al eliminar favorito:', error);
    res.status(500).json({ mensaje: 'Error al eliminar favorito' });
  }
});

export default router;
