/**
 * @file Defines a global error handling middleware for the Express application.
 * This middleware catches errors passed via `next(err)` and sends a standardized
 * JSON response to the client. It differentiates between development and production
 * environments to provide appropriate error details.
 */

const AppError = require('../../Utils/appError.js'); // Assuming AppError is in a Utils directory

/**
 * @function sendErrorDev
 * @description Sends detailed error information in the development environment.
 * Includes the error object, message, and stack trace.
 * @param {Error|AppError} err - The error object.
 * @param {object} res - The Express response object.
 */
const sendErrorDev = (err, res) => {
  res.status(err.statusCode).json({
    status: err.status,
    error: err, // Send the full error object in development
    message: err.message,
    stack: err.stack, // Include the stack trace for debugging
  });
};

/**
 * @function sendErrorProd
 * @description Sends generalized error information in the production environment.
 * For operational errors (trusted errors, instances of AppError), it sends the error message.
 * For programming or unknown errors, it sends a generic message to avoid leaking sensitive details.
 * @param {Error|AppError} err - The error object.
 * @param {object} res - The Express response object.
 */
const sendErrorProd = (err, res) => {
  // A) Operational, trusted error: send message to client
  if (err.isOperational) {
    res.status(err.statusCode).json({
      status: err.status,
      message: err.message,
    });
  // B) Programming or other unknown error: don't leak error details
  } else {
    // 1. Log the error to the console (or a logging service) for the developers.
    // This is crucial for debugging production issues.
    console.error('PRODUCTION ERROR 💥:', err);

    // 2. Send a generic message to the client.
    res.status(500).json({
      status: 'error',
      message: 'Something went very wrong! Please try again later.',
    });
  }
};

/**
 * @function handleErrors
 * @description Global error handling middleware.
 * It normalizes the error object by ensuring `statusCode` and `status` are set.
 * Then, it delegates to either `sendErrorDev` or `sendErrorProd` based on the
 * `NODE_ENV` environment variable.
 * @param {Error|AppError} err - The error object passed from previous middleware or route handlers.
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 * @param {function} next - The Express next middleware function (rarely used in global error handlers).
 */
const handleErrors = (err, req, res, next) => {
  // Set default statusCode and status if not already present on the error object.
  // This handles errors that might not be instances of AppError.
  err.statusCode = err.statusCode || 500; // Default to 500 Internal Server Error
  err.status = err.status || 'error';     // Default status to 'error'

  // Differentiate error handling based on the environment.
  if (process.env.NODE_ENV === 'development') {
    sendErrorDev(err, res);
  } else if (process.env.NODE_ENV === 'production') {
    // In production, you might want to handle specific error types differently
    // (e.g., Mongoose validation errors, JWT errors) before sending the response.
    // For simplicity, this example directly calls sendErrorProd.
    // You could create a shallow copy of the error if you plan to modify it
    // for specific production error handling without affecting the original 'err' object.
    // let error = { ...err, message: err.message, name: err.name };
    // if (error.name === 'CastError') error = handleCastErrorDB(error);
    // if (error.name === 'ValidationError') error = handleValidationErrorDB(error);
    // etc.

    sendErrorProd(err, res);
  } else {
    // Fallback for environments other than 'development' or 'production'
    // (though typically NODE_ENV is one of these two or 'test').
    // Behaves like production by default to be safe.
    console.error('UNKNOWN ENV ERROR 💥:', err);
    res.status(500).json({
      status: 'error',
      message: 'An unexpected error occurred.',
    });
  }
};

// Export the global error handling middleware.
module.exports = handleErrors;