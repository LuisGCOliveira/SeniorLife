/**
 * @file Controller for handling caregiver (acompanhante) related operations.
 * This includes registration, login, and CRUD operations for caregivers.
 * All asynchronous operations are wrapped with `catchAsync` for centralized error handling.
 */

const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const {
  criarAcompanhante,
  listarAcompanhantes,
  editarAcompanhante,
  excluirAcompanhante,
  buscarAcompanhantePorEmail,
} = require('../Model/acompanhanteModel.js'); // Adjust path if necessary
const AppError = require('../Utils/appError.js');
const catchAsync = require('../Utils/catchAsync.js');

/**
 * @async
 * @function cadastrar
 * @description Registers a new caregiver (acompanhante).
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 * @param {function} next - Express next middleware function.
 */
exports.cadastrar = catchAsync(async (req, res, next) => {
  const { nome, email, senha } = req.body;

  if (!nome || !email || !senha) {
    return next(new AppError('Name, email, and password are required.', 400));
  }

  const senhaHash = await bcrypt.hash(senha, 10);
  const caregiverData = { nome, email, senha: senhaHash };

  const novoAcompanhante = await criarAcompanhante(caregiverData);
  // Model should throw an error for DB issues (e.g., unique constraint violation like PostgreSQL error code '23505').
  // catchAsync will handle these.
  if (!novoAcompanhante) {
     return next(new AppError('Failed to register caregiver. Model did not return data.', 500));
  }

  const { senha: _, ...acompanhanteSemSenha } = novoAcompanhante;

  res.status(201).json({
    status: 'success',
    message: 'Caregiver registered successfully!',
    data: {
      acompanhante: acompanhanteSemSenha,
    }
  });
});

/**
 * @async
 * @function login
 * @description Logs in an existing caregiver.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 * @param {function} next - Express next middleware function.
 */
exports.login = catchAsync(async (req, res, next) => {
  const { email, senha } = req.body;

  if (!email || !senha) {
    return next(new AppError('Email and password are required.', 400));
  }

  const acompanhante = await buscarAcompanhantePorEmail(email);

  if (!acompanhante || !(await bcrypt.compare(senha, acompanhante.senha))) {
    return next(new AppError('Invalid email or password.', 401));
  }

  const payload = {
    id: acompanhante.id, // SQL schema uses 'id' as the UUID primary key
    tipo: 'acompanhante',
  };

  const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '15d' });
  const { senha: _, ...acompanhanteInfo } = acompanhante;

  res.status(200).json({
    userId: acompanhante.id, // Include userId in response for client-side use
    userName: acompanhante.nome, // Include userName for client-side use
    userType: 'acompanhante', // Include userType for client-side use
    status: 'success',
    message: 'Login successful!',
    token: token,
    data: {
      acompanhante: acompanhanteInfo,
    }
  });
});

/**
 * @async
 * @function consultar
 * @description Retrieves a list of all caregivers.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 * @param {function} next - Express next middleware function.
 */
exports.consultar = catchAsync(async (req, res, next) => {
  const lista = await listarAcompanhantes();
  const caregiversWithoutPasswords = lista.map(cg => {
      const { senha, ...rest } = cg;
      return rest;
  });

  res.status(200).json({
    status: 'success',
    message: 'Caregivers retrieved successfully!',
    results: caregiversWithoutPasswords.length,
    data: {
      acompanhantes: caregiversWithoutPasswords,
    }
  });
});

/**
 * @async
 * @function editar
 * @description Updates an existing caregiver's profile information.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 * @param {function} next - Express next middleware function.
 */
exports.editar = catchAsync(async (req, res, next) => {
  const { id: caregiverIdToEdit } = req.params;
  const updateData = req.body;
  const authenticatedCaregiverId = req.acompanhante?.id; // From JWT (authAcompanhante middleware)

  if (!authenticatedCaregiverId || authenticatedCaregiverId !== caregiverIdToEdit) {
    return next(new AppError('Forbidden: You can only update your own profile.', 403));
  }

  delete updateData.id;
  delete updateData.email; // Email changes usually require verification

  if (updateData.senha) {
    if (updateData.senha.trim() === "") {
      delete updateData.senha;
    } else {
      updateData.senha = await bcrypt.hash(updateData.senha, 10);
    }
  }

  const atualizado = await editarAcompanhante(caregiverIdToEdit, updateData);

  if (!atualizado) {
    return next(new AppError('Caregiver not found or no changes made.', 404));
  }

  const { senha: _, ...updatedCaregiverWithoutPassword } = atualizado;

  res.status(200).json({
    status: 'success',
    message: 'Caregiver profile updated successfully!',
    data: {
      acompanhante: updatedCaregiverWithoutPassword,
    }
  });
});

/**
 * @async
 * @function excluir
 * @description Deletes a caregiver's profile.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 * @param {function} next - Express next middleware function.
 */
exports.excluir = catchAsync(async (req, res, next) => {
  const { id: caregiverIdToDelete } = req.params;
  const authenticatedCaregiverId = req.acompanhante?.id; // From JWT

  if (!authenticatedCaregiverId || authenticatedCaregiverId !== caregiverIdToDelete) {
    return next(new AppError('Forbidden: You can only delete your own profile.', 403));
  }

  const excluido = await excluirAcompanhante(caregiverIdToDelete);

  if (!excluido) { // Model should return truthy (e.g., rows affected > 0) or throw
    return next(new AppError('Caregiver not found or already deleted.', 404));
  }

  res.status(200).json({ // Or 204 with no content
    status: 'success',
    message: 'Caregiver profile deleted successfully!'
  });
});