/**
 * @file Controller for handling dependent (idoso) related operations.
 * All asynchronous operations are wrapped with `catchAsync` for centralized error handling.
 */

const bcrypt = require('bcrypt');
const {
  criarDependente,
  listarDependentesPorAcompanhante,
  editarDependente,
  excluirDependente,
  criarRelacaoAcompanhanteDependente,
  buscarDependentePorNome,
  buscarDependentePorEmail
} = require('../Model/dependenteModel.js'); // Adjust path if necessary
const AppError = require('../Utils/appError.js');
const catchAsync = require('../Utils/catchAsync.js');
const jwt = require('jsonwebtoken');

/**
 * @async
 * @function cadastrar
 * @description Registers a new dependent and links them to the authenticated caregiver.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 * @param {function} next - Express next middleware function.
 */
exports.cadastrar = catchAsync(async (req, res, next) => {
  const {
    nome,
    email,
    senha,
    // ...other dependent fields
  } = req.body;

  const id_acompanhante = req.acompanhante?.id; // From authAcompanhante middleware

  if (!nome || !email || !senha) {
    return next(new AppError('Full name, email, and password for the dependent are required.', 400));
  }
  if (!id_acompanhante) {
    return next(new AppError('Caregiver authentication required.', 401)); // Should be caught by auth middleware
  }

  const senhaHash = await bcrypt.hash(senha, 10);
  const dependentData = { nome, email, senha: senhaHash /*, ...other fields */ };

  const novoDependente = await criarDependente(dependentData);
  if (!novoDependente || !novoDependente.id) {
    return next(new AppError('Failed to create dependent entry. Model did not return expected data.', 500));
  }

  await criarRelacaoAcompanhanteDependente(id_acompanhante, novoDependente.id);

  // Do not send password back
  const { senha: _, ...dependenteInfo } = novoDependente;

  res.status(201).json({
    status: 'success',
    message: 'Dependent registered and linked successfully!',
    data: {
      dependente: dependenteInfo,
    }
  });
});

exports.login = catchAsync(async (req, res, next) => {
  const { email, senha } = req.body;

  if (!email || !senha) {
    return next(new AppError('Name and password are required.', 400));
  }

  const dependente = await buscarDependentePorEmail(email);

  if (!dependente || !(await bcrypt.compare(senha, dependente.senha))) {
    return next(new AppError('Invalid name or password.', 401));
  }

  const payload = {
    id: dependente.id,
    tipo: 'dependente'
  };

   const token = jwt.sign(payload, process.env.JWT_SECRET);

  const { senha: _, ...dependenteInfo } = dependente;

  res.status(200).json({
    userId: dependente.id, // Include userId in response for client-side use
    userName: dependente.nome, // Include userName for client-side use
    userType: 'dependente', // Include userType for client-side use
    status: 'success',
    message: 'Login successful!',
    token,
    data: {
      dependente: dependenteInfo
    }
  });
});

/**
 * @async
 * @function consultar
 * @description Retrieves a list of dependents associated with the authenticated caregiver.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 * @param {function} next - Express next middleware function.
 */
exports.consultar = catchAsync(async (req, res, next) => {
  const id_acompanhante = req.acompanhante?.id;

  if (!id_acompanhante) {
    return next(new AppError('Caregiver authentication required.', 401));
  }

  const lista = await listarDependentesPorAcompanhante(id_acompanhante);

  res.status(200).json({
    status: 'success',
    message: 'Dependents retrieved successfully!',
    results: lista.length,
    data: {
      dependentes: lista,
    }
  });
});

/**
 * @async
 * @function editar
 * @description Updates an existing dependent's information.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 * @param {function} next - Express next middleware function.
 */
exports.editar = catchAsync(async (req, res, next) => {
  const { id: id_dependente } = req.params;
  const updateData = req.body;
  const id_acompanhante = req.acompanhante?.id; // From authAcompanhante middleware

  if (!id_acompanhante) {
      return next(new AppError('Caregiver authentication required.', 401));
  }
  // Authorization check (is this caregiver linked to this dependent?)
  // should be handled by permissionMiddleware.js if applied to the route.

  if (updateData.senha) {
    if (updateData.senha.trim() === "") {
        delete updateData.senha;
    } else {
        updateData.senha = await bcrypt.hash(updateData.senha, 10);
    }
  }
  delete updateData.id; // Prevent ID update

  const atualizado = await editarDependente(id_dependente, updateData);

  if (!atualizado) {
    return next(new AppError('Dependent not found or no changes made.', 404));
  }

  const { senha: _, ...dependenteInfo } = atualizado;

  res.status(200).json({
    status: 'success',
    message: 'Dependent updated successfully!',
    data: {
      dependente: dependenteInfo,
    }
  });
});

/**
 * @async
 * @function excluir
 * @description Deletes a dependent's record.
 * @param {object} req - Express request object.
 * @param {object} res - Express response object.
 * @param {function} next - Express next middleware function.
 */
exports.excluir = catchAsync(async (req, res, next) => {
  const { id: id_dependente } = req.params;
  const id_acompanhante = req.acompanhante?.id; // From authAcompanhante middleware

  if (!id_acompanhante) {
      return next(new AppError('Caregiver authentication required.', 401));
  }
  // Authorization check (is this caregiver linked to this dependent?)
  // should be handled by permissionMiddleware.js if applied to the route.

  const excluido = await excluirDependente(id_dependente);

  if (!excluido) { // Model should return truthy (e.g., rows affected > 0) or throw
    return next(new AppError('Dependent not found or already deleted.', 404));
  }

  res.status(200).json({ // Or 204 with no content
    status: 'success',
    message: 'Dependent deleted successfully!'
  });
});