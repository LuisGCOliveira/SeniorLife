/**
 * @file Utility function to wrap asynchronous route handlers.
 * This function catches errors from async functions and passes them to the next error-handling middleware.
 */

/**
 * @description Wraps an asynchronous route handler to catch any errors
 * and pass them to the global error handling middleware.
 * @param {function} fn - The asynchronous route handler function (e.g., an async controller function).
 * @returns {function} A new function that, when executed, will call the original function
 *                     and catch any rejected promises, passing the error to `next()`.
 */
const catchAsync = fn => {
  return (req, res, next) => {
    fn(req, res, next).catch(next); // Catches promise rejections and passes the error to Express's error handler
  };
};

module.exports = catchAsync;