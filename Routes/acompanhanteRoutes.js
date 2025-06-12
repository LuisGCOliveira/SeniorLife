import express from 'express';
import { cadastrar, login } from '../Controller/acompanhanteController.js';

const router = express.Router();

// Rota para cadastrar um novo acompanhante
router.post('/Cadastro', cadastrar);
// Rota para login de um acompanhante
router.post('/Login', login);

export default router;