/**
 * @file Defines the routes for managing dependent routines and their activities.
 * These routes map HTTP requests to the appropriate controller functions,
 * including authentication, authorization, and validation middlewares.
 */

const express = require('express');
const routineController = require('../../Controller/routineController.js');

// Import authentication and permission middlewares
const { autenticarAcompanhante } = require('../Middleware/authAcompanhante.js');
const { checkCaregiverPermission } = require('../Middleware/permissionMiddleware.js');

// Import validation middlewares
const {
  validateCreateActivity,
  validateUpdateActivity,
  validateParams
} = require('./Validators/validatorMiddleware.js'); // Adjust path if necessary

const router = express.Router();

// --- ROUTE DEFINITIONS ---

/**
 * @route   POST /api/rotinas/:id_idoso/activity
 * @desc    Create a new activity for a specific dependent
 * @access  Private (Requires caregiver authentication, permission, and valid input)
 */
router.post(
  '/rotinas/:id_idoso/activity',
  autenticarAcompanhante,     // 1. Authenticate
  checkCaregiverPermission,   // 2. Authorize
  validateParams,             // 3. Validate URL parameters (e.g., id_idoso)
  validateCreateActivity,     // 4. Validate request body for creating an activity
  routineController.createActivity // 5. Controller
);

/**
 * @route   GET /api/rotinas/:id_idoso/activity
 * @desc    Get all activities for a specific dependent
 * @access  Private (Requires caregiver authentication, permission, and valid params)
 */
router.get(
  '/rotinas/:id_idoso/activity',
  autenticarAcompanhante,
  checkCaregiverPermission,
  validateParams,             // Validate URL parameters
  routineController.getActivities
);

/**
 * @route   DELETE /api/rotinas/:id_idoso/activity
 * @desc    Delete all activities for a specific dependent
 * @access  Private (Requires caregiver authentication, permission, and valid params - destructive action)
 */
router.delete(
  '/rotinas/:id_idoso/activity',
  autenticarAcompanhante,
  checkCaregiverPermission,
  validateParams,             // Validate URL parameters
  routineController.deleteAllActivities
);

/**
 * @route   GET /api/rotinas/:id_idoso/activity/:activityId
 * @desc    Get a single specific activity by its ID for a dependent
 * @access  Private (Requires caregiver authentication, permission, and valid params)
 */
router.get(
  '/rotinas/:id_idoso/activity/:activityId',
  autenticarAcompanhante,
  checkCaregiverPermission,
  validateParams,             // Validate URL parameters (id_idoso and activityId)
  routineController.getActivityById
);

/**
 * @route   PUT /api/rotinas/:id_idoso/activity/:activityId
 * @desc    Update a specific activity for a dependent
 * @access  Private (Requires caregiver authentication, permission, and valid input)
 */
router.put(
  '/rotinas/:id_idoso/activity/:activityId',
  autenticarAcompanhante,
  checkCaregiverPermission,
  validateParams,             // Validate URL parameters
  validateUpdateActivity,     // Validate request body for updating an activity
  routineController.updateActivity
);

/**
 * @route   DELETE /api/rotinas/:id_idoso/activity/:activityId
 * @desc    Delete a specific activity for a dependent
 * @access  Private (Requires caregiver authentication, permission, and valid params)
 */
router.delete(
  '/rotinas/:id_idoso/activity/:activityId',
  autenticarAcompanhante,
  checkCaregiverPermission,
  validateParams,             // Validate URL parameters
  routineController.deleteActivity
);


module.exports = router;