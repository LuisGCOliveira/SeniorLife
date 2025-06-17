/**
 * @file Defines authentication middleware specifically for caregivers (acompanhantes).
 * This middleware verifies a JWT token, ensures the caregiver exists in the database,
 * is of the correct type ('acompanhante'), and that the token was issued before any
 * recent password changes.
 */

const jwt = require('jsonwebtoken');
const AppError = require('../../Utils/appError.js'); // Adjust path if AppError is located elsewhere
const acompanhanteModel = require('../../Model/acompanhanteModel.js'); // Adjust path to your model

/**
 * @async
 * @function autenticarAcompanhante
 * @description Middleware to authenticate a caregiver (acompanhante).
 * It performs the following checks:
 * 1. Retrieves the JWT from the Authorization header.
 * 2. Verifies the JWT using the secret key.
 * 3. Checks if the caregiver (user) identified by the token still exists in the database.
 * 4. Verifies that the user associated with the token is indeed a caregiver (type 'acompanhante').
 * 5. (Optional but Recommended) Checks if the caregiver changed their password after the token was issued.
 * If all checks pass, it attaches the caregiver's user object (from DB) to `req.acompanhante`
 * and calls `next()`. Otherwise, it calls `next()` with an appropriate `AppError`.
 *
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 * @param {function} next - The Express next middleware function.
 */
const autenticarAcompanhante = async (req, res, next) => {
  try {
    // 1. Get token and check if it's there
    let token;
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return next(new AppError('Token not provided. Please log in to get access.', 401));
    }

    // 2. Verify token
    let decoded;
    const jwtSecret = process.env.JWT_SECRET;

    if (!jwtSecret || jwtSecret.trim() === '') {
      console.error("FATAL ERROR: JWT_SECRET is not defined or is empty in environment variables.");
      return next(new AppError('Server configuration error. Please contact support.', 500));
    }

    try {
      decoded = jwt.verify(token, jwtSecret.trim());
    } catch (err) {
      // Handles errors from jwt.verify (e.g., token expired, signature invalid)
      return next(new AppError('Invalid or expired token. Please log in again.', 401));
    }

    // 3. Check if user (caregiver) still exists in the database
    //    The token payload should contain the caregiver's ID.
    //    Assuming the ID is in `decoded.id_acompanhante` or `decoded.id`.
    const caregiverId = decoded.id_acompanhante || decoded.id;
    if (!caregiverId) {
        return next(new AppError('Invalid token: Caregiver ID not found in token.', 401));
    }

    const currentCaregiver = await acompanhanteModel.buscarAcompanhantePorId(caregiverId);
    if (!currentCaregiver) {
      return next(new AppError('The caregiver belonging to this token no longer exists.', 401));
    }

    // 4. Check if the user type is 'acompanhante'
    //    This check ensures that the token belongs to a user with the caregiver role.
    //    It's recommended to include the user type/role in the JWT payload for efficiency.
    //    The field name in the payload for type is assumed to be 'tipo'.
    if (decoded.tipo && decoded.tipo !== 'acompanhante') {
      return next(new AppError('Access forbidden: Token does not belong to a caregiver.', 403));
    }
    // If neither the token nor the DB record provides a clear type, and this route is *only* for caregivers,
    // the fact that they were found in `acompanhanteModel` might be implicit, but explicit checks are better.


    // 5. Check if caregiver changed password after the token was issued
    //    This requires a `password_changed_at` (or similar) field in your `acompanhante` model/table
    //    and that `iat` (issued at timestamp) is part of your JWT payload (jsonwebtoken adds this by default).
    //    Adjust 'password_changed_at' to the actual field name in your `currentCaregiver` object.
    if (currentCaregiver.password_changed_at && decoded.iat) {
      const passwordChangedTimestamp = parseInt(new Date(currentCaregiver.password_changed_at).getTime() / 1000, 10);
      // If password was changed *after* the token was issued, invalidate the token.
      if (passwordChangedTimestamp > decoded.iat) {
        return next(new AppError('Caregiver recently changed password. Please log in again.', 401));
      }
    }

    // GRANT ACCESS TO PROTECTED ROUTE
    // Attach the full caregiver object (retrieved from DB) to the request object
    // for use in subsequent route handlers or middleware.
    req.acompanhante = currentCaregiver;

    next();
  } catch (err) {
    // For any other unexpected errors during the process, pass to the global error handler.
    return next(err);
  }
};

module.exports = {
  autenticarAcompanhante,
};