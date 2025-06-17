/**
 * @file Defines a custom error class `AppError` for handling operational errors.
 * This class extends the built-in `Error` class and adds properties like
 * `statusCode`, `status`, and `isOperational` to provide more context for error handling.
 */

/**
 * @class AppError
 * @extends Error
 * @description Custom error class for creating operational errors that can be handled gracefully.
 * Operational errors are predictable errors that can occur during the normal operation of the application
 * (e.g., user not found, invalid input), as opposed to programming errors (bugs).
 */
class AppError extends Error {
  /**
   * Creates an instance of AppError.
   * @param {string} message - The error message.
   * @param {number} statusCode - The HTTP status code associated with this error.
   */
  constructor(message, statusCode) {
    // Call the parent constructor (Error class) with the error message.
    super(message);

    /**
     * @property {number} statusCode - The HTTP status code for the error response.
     */
    this.statusCode = statusCode;

    /**
     * @property {string} status - A string indicating the type of error ('fail' for 4xx, 'error' for 5xx).
     * Determined based on the statusCode.
     */
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';

    /**
     * @property {boolean} isOperational - A flag to distinguish operational errors from programming errors.
     * Operational errors are expected and should be handled by sending a meaningful response to the client.
     * Programming errors are bugs and might require a more generic error response in production.
     * @default true
     */
    this.isOperational = true;

    // Capture the stack trace, excluding the constructor call from AppError itself,
    // to provide a cleaner stack trace pointing to where the error was instantiated.
    Error.captureStackTrace(this, this.constructor);
  }
}

// Export the AppError class to be used in other parts of the application.
module.exports = AppError;