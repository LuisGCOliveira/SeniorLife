/**
 * @file Defines validation middleware using express-validator.
 * This includes rules for creating and updating activities, and validating URL parameters.
 */

const { body, param, validationResult } = require('express-validator');
const AppError = require('../../../Utils/appError.js'); // Import AppError

/**
 * @description A helper middleware to check for validation errors.
 * If errors exist, it creates an AppError and passes it to the global error handler.
 * Otherwise, it calls next() to continue to the next middleware or route handler.
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 * @param {function} next - The next middleware function.
 */
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    // If there are validation errors, create an AppError.
    // We can concatenate messages or just use the first one.
    // For a more detailed error, you could pass errors.array() as a property of AppError
    // if AppError is designed to handle an additional 'details' or 'errors' field.
    const errorMessages = errors.array().map(err => err.msg).join('. ');
    return next(new AppError(`Validation failed: ${errorMessages}`, 400));
  }
  // If no errors, proceed to the next middleware or route handler.
  next();
};

// --- VALIDATION RULE SETS ---

/**
 * @description Validation rules for creating a new activity.
 * Includes checks for title, type, schedule, and an optional description.
 */
const validateCreateActivity = [
  body('title')
    .trim() // Remove leading/trailing whitespace.
    .notEmpty().withMessage('Title is required.'), // Must not be empty.
  body('type')
    .isIn(['atividade fisica', 'alimentação', 'medicação']) // Must be one of these values.
    .withMessage("Type must be 'physical activity', 'feeding', or 'medication'."),
  body('schedule')
    .isISO8601().withMessage('Schedule must be in ISO 8601 date format (UTC standard).') // Must be a valid ISO 8601 date string.
    .toDate(), // Convert the valid date string to a JavaScript Date object.
  body('description')
    .optional() // This field is optional.
    .trim(), // If present, trim whitespace.
  // At the end of the validation chain, include the error handler.
  handleValidationErrors,
];

/**
 * @description Validation rules for updating an existing activity.
 * Most fields are optional for updates; validation applies if they are present.
 */
const validateUpdateActivity = [
  // For updates, most fields are optional.
  // We only validate them if they exist in the request body.
  body('title')
    .optional() // Title is optional for updates.
    .trim()
    .notEmpty().withMessage('Title cannot be empty if provided.'), // If provided, it cannot be empty.
  body('type')
    .optional()
    .isIn(['atividade fisica', 'alimentação', 'medicação'])
    .withMessage('Invalid activity type.'),
  body('schedule')
    .optional()
    .isISO8601().withMessage('Schedule must be in ISO 8601 date format if provided.')
    .toDate(),
  body('status')
    .optional()
    .isIn(['pending', 'completed', 'not_completed']) // Assuming these are your status values.
    .withMessage("Status must be 'pending', 'completed', or 'not_completed' if provided."),
  body('description') // Added optional description validation for updates as well
    .optional()
    .trim(),
  handleValidationErrors,
];

/**
 * @description Validation rules for URL parameters.
 * Example: Validating 'id_idoso' (dependent ID) and 'activityId'.
 */
const validateParams = [
    // Example: Validate if 'id_idoso' is a non-empty string.
    // For UUIDs, you could add .isUUID().withMessage('Dependent ID must be a valid UUID.')
    param('id_idoso')
      .notEmpty().withMessage('Dependent ID in the URL is required.'),
    // Example: Validate 'activityId' if it's present in the URL.
    param('activityId')
      .optional() // This parameter itself might be optional in some routes.
      .notEmpty().withMessage('Activity ID in the URL cannot be empty if present.'),
      // For UUIDs: .isUUID().withMessage('Activity ID must be a valid UUID if present.')
    handleValidationErrors
];


// Export the validation middleware arrays to be used in route definitions.
module.exports = {
  validateCreateActivity,
  validateUpdateActivity,
  validateParams,
  // handleValidationErrors // No longer need to export this separately if only used internally
};