import express from 'express';
import { cadastrar, login } from '../Controller/dependenteController';
import { autenticarAcompanhante } from '../Middleware/authAcompanhante.js';


const router = express.Router();


// Rota para cadastrar um novo dependente
router.post('/Cadastro', autenticarAcompanhante, cadastrar);
// Rota para login de um dependente 
router.post('/Login', login);