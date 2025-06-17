/**
 * @file Defines the routes for dependent (idoso) registration and login.
 * These routes map HTTP requests to the appropriate controller functions for dependents.
 */

const express = require('express');

// Assuming the controller file is located at '../../Controller/dependenteController.js'
// relative to this routes file (Api/Routes/dependenteRoutes.js).
// Adjust the path if your folder structure is different.
const { cadastrar, login } = require('../../Controller/dependenteController.js');

// Assuming the middleware file is located at '../../Middleware/authAcompanhante.js'.
// Adjust the path if your folder structure is different.
const { autenticarAcompanhante } = require('../Middleware/authAcompanhante.js');

// Create a new router object to define a modular set of routes.
const router = express.Router();

/**
 * @route   POST /api/dependents/Cadastro
 * @desc    Register a new dependent (idoso). This route is protected and requires caregiver authentication.
 * @access  Private (Requires caregiver authentication via `autenticarAcompanhante` middleware)
 * @body    { "nome_completo": "string", "data_nascimento": "Date", "condicoes_medicas": "string", "contato_emergencia_nome": "string", "contato_emergencia_telefone": "string", "id_acompanhante": "string" }
 *          // Note: The actual fields will depend on your `dependenteController.cadastrar` function and `dependenteModel`.
 *          // `id_acompanhante` might be derived from the authenticated caregiver or passed in the body.
 */
router.post('/Cadastro', autenticarAcompanhante, cadastrar);

/**
 * @route   POST /api/dependents/Login
 * @desc    Login an existing dependent (idoso).
 * @access  Public
 * @body    { "cpf": "string", "senha": "string" } // Assuming login is via CPF and a password, adjust as needed.
 */
router.post('/Login', login);

// Export the router to be mounted by the main application.
module.exports = router;