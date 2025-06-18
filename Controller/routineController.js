/**
 * @file This file contains the controllers that handle HTTP requests for the routine API.
 * The controller's main job is to receive the request, call the appropriate service function,
 * delegate error handling, and then send back a response to the client.
 */

const routineServices = require('../Services/routineServices.js');
const AppError = require('../Utils/appError.js'); // Import AppError
const catchAsync = require('../Utils/catchAsync.js');

/**
 * @description Utility function to catch errors in async middleware/controllers.
 * @param {function} fn - The async function to be executed.
 * @returns {function} A new function that handles errors and passes them to next().
 */


/**
 * @description Controller to create a new activity for a dependent.
 * Errors are passed to the global error handler.
 * @async
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 * @param {function} next - The Express next middleware function.
 */
const createActivity = catchAsync(async (req, res, next) => {
  const { id_idoso } = req.params;
  const activityData = req.body;

  if (!id_idoso) {
    return next(new AppError("Dependent ID (id_idoso) is required in URL parameters.", 400));
  }
  if (!activityData || Object.keys(activityData).length === 0) {
    return next(new AppError("Activity data is required in the request body.", 400));
  }

  const newActivity = await routineServices.createActivity(id_idoso, activityData);

  res.status(201).json({
    status: 'success',
    data: {
      activity: newActivity
    }
  });
});

/**
 * @description Controller to get all activities for a dependent.
 * Errors are passed to the global error handler.
 * @async
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 * @param {function} next - The Express next middleware function.
 */
const getActivities = catchAsync(async (req, res, next) => {
  const { id_idoso } = req.params;
  const { type } = req.query; // <-- pega o filtro do query param

  if (!id_idoso) {
    return next(new AppError("Dependent ID (id_idoso) is required in URL parameters.", 400));
  }

  let activity = await routineServices.getActivitiesForDependent(id_idoso);

  // Se o filtro 'type' foi enviado, filtra as atividades
  if (type) {
    activity = activity.filter(act => act.type === type);
  }

  res.status(200).json({
    status: 'success',
    results: activity.length,
    data: {
      activity
    }
  });
});

/**
 * @description Controller to get a single activity by its ID.
 * Errors are passed to the global error handler.
 * @async
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 * @param {function} next - The Express next middleware function.
 */
const getActivityById = catchAsync(async (req, res, next) => {
  const { id_idoso, activityId } = req.params;
  if (!id_idoso || !activityId) {
    return next(new AppError("Dependent ID (id_idoso) and Activity ID (activityId) are required in URL parameters.", 400));
  }

  const activity = await routineServices.getActivityById(id_idoso, activityId);

  if (!activity) {
    return next(new AppError('No activity found with that ID for this dependent.', 404));
  }
  res.status(200).json({
    status: 'success',
    data: {
      activity
    }
  });
});

/**
 * @description Controller to update a specific activity.
 * Errors are passed to the global error handler.
 * @async
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 * @param {function} next - The Express next middleware function.
 */
const updateActivity = catchAsync(async (req, res, next) => {
  const { id_idoso, activityId } = req.params;
  const updateData = req.body;

  if (!id_idoso || !activityId) {
    return next(new AppError("Dependent ID (id_idoso) and Activity ID (activityId) are required in URL parameters.", 400));
  }
  if (!updateData || Object.keys(updateData).length === 0) {
    return next(new AppError("Update data is required in the request body.", 400));
  }

  const updatedActivity = await routineServices.updateActivity(id_idoso, activityId, updateData);

  if (!updatedActivity) {
    return next(new AppError('No activity found with that ID to update for this dependent.', 404));
  }
  res.status(200).json({
    status: 'success',
    data: {
      activity: updatedActivity
    }
  });
});

/**
 * @description Controller to delete a specific activity.
 * Errors are passed to the global error handler.
 * @async
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 * @param {function} next - The Express next middleware function.
 */
const deleteActivity = catchAsync(async (req, res, next) => {
  const { id_idoso, activityId } = req.params;
  if (!id_idoso || !activityId) {
    return next(new AppError("Dependent ID (id_idoso) and Activity ID (activityId) are required in URL parameters.", 400));
  }

  const success = await routineServices.deleteActivity(id_idoso, activityId);

  if (!success) {
    return next(new AppError('No activity found with that ID to delete for this dependent.', 404));
  }
  res.status(204).json({ // 204 No Content for successful deletion
    status: 'success',
    data: null
  });
});

/**
 * @description Controller to delete all activities for a specific dependent.
 * Errors are passed to the global error handler.
 * @async
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 * @param {function} next - The Express next middleware function.
 */
const deleteAllActivities = catchAsync(async (req, res, next) => {
  const { id_idoso } = req.params;
  if (!id_idoso) {
    return next(new AppError("Dependent ID (id_idoso) is required in URL parameters.", 400));
  }

  const success = await routineServices.deleteAllActivities(id_idoso);

  if (!success) {
    // This implies the routine for the dependent was not found, so no activities to delete.
    // Or it was found but already empty. The service returns true if matchedCount > 0.
    // A 404 might be too strong if the intent is "ensure no activities exist".
    // However, if the expectation is that a routine *must* exist to be cleared, 404 is okay.
    // For consistency, let's treat it as "resource to operate on not found".
    return next(new AppError('Routine for the dependent not found, or no activities to delete.', 404));
  }
  res.status(204).json({ // 204 No Content
    status: 'success',
    data: null
  });
});

module.exports = {
  createActivity,
  getActivities,
  getActivityById,
  updateActivity,
  deleteActivity,
  deleteAllActivities,
};