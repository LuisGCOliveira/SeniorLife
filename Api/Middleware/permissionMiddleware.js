/**
 * @file Middleware to verify a caregiver's permission over a specific dependent.
 * It queries the 'relacao_acompanhante_dependente' table to validate the link.
 */

const { postgresConnection } = require('../../Config/instaceConn.js'); // Or '../Config/conn.js'
const AppError = require('../../Utils/appError.js'); // Import AppError

const knex = postgresConnection.getConnection();

/**
 * @description Middleware to check if the authenticated caregiver has permission
 * to access or modify data for a specific dependent.
 * Errors are passed to the global error handler.
 * @async
 * @function checkCaregiverPermission
 * @param {object} req - The Express request object. Expected to have:
 *                       `req.acompanhante.id` (from JWT, populated by authentication middleware).
 *                       `req.params.id_idoso` (from the URL route parameter, representing the dependent's ID).
 * @param {object} res - The Express response object.
 * @param {function} next - The next middleware function in the Express stack.
 */
const checkCaregiverPermission = async (req, res, next) => {
  try {
    const caregiverId = req.acompanhante?.id;
    const { id_idoso: dependentId } = req.params;

    if (!caregiverId || !dependentId) {
      // Pass an operational error to the global error handler.
      return next(new AppError('Caregiver ID or Dependent ID not provided for permission check.', 400));
    }

    const relationship = await knex('relacao_acompanhante_dependente')
      .where({
        id_acompanhante: caregiverId,
        id_dependente: dependentId,
      })
      .first();

    if (!relationship) {
      // Pass an operational error (forbidden access) to the global error handler.
      return next(new AppError('Access Forbidden. You do not have permission to manage this dependent.', 403));
    }

    // If the relationship exists, allow the request to proceed.
    next();
  } catch (error) {
    // Log the error for server-side debugging.
    console.error('Error during caregiver permission check:', error);
    // Pass the unexpected error to the global error handler.
    // The global error handler will decide how to respond (e.g., generic 500 error in production).
    return next(error);
  }
};

module.exports = { checkCaregiverPermission };