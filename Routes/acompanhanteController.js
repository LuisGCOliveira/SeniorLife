import express from 'express';
import { cadastrar } from '../Controller/acompanhanteController.js';

const router = express.Router();

router.post('/Cadastro', cadastrar);

export default router;