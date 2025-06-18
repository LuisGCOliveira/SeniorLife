/**
 * @file This file contains the core business logic for managing dependent routines and their activities.
 * It acts as an intermediary between the controllers (API layer) and the models (database layer),
 * and also handles real-time event emissions via Socket.IO for certain actions.
 */

// 1. Import the main Mongoose model to interact with the database.
const DependentRoutine = require('../Model/dependentRoutine.js');
const mongoose = require('mongoose'); // Mongoose is required to work with ObjectIDs.

// 2. Import the Socket.IO instance for real-time updates.
// Ensure 'io' is correctly exported from your main app file (e.g., index.js).
const { io } = require('../index.js'); // Adjust path if your io instance is exported differently

/**
 * @description Adds a new activity to a dependent's routine. If the dependent
 * does not have a routine document yet, one will be created automatically (upsert).
 * Also logs the creation of the activity and emits a real-time event.
 * @async
 * @param {string} id_idoso - The unique identifier of the dependent.
 * @param {object} activityData - The data for the new activity.
 * @returns {Promise<object>} A promise that resolves to the newly created activity subdocument.
 * @throws {Error} If there's an issue with database operation.
 */
exports.createActivity = async (id_idoso, activityData) => {
  const newActivityId = new mongoose.Types.ObjectId();
  const activityWithId = { ...activityData, _id: newActivityId };

  const logEntry = {
    action: 'activity_created',
    activityId: newActivityId.toString(),
    activityTitle: activityData.titulo || 'N/A',
    timestamp: new Date(),
  };

  const routine = await DependentRoutine.findOneAndUpdate(
    { id_idoso: id_idoso },
    {
      $push: {
        activity: activityWithId,
        log: logEntry,
      },
    },
    { new: true, upsert: true, runValidators: true }
  );

  const createdActivity = routine.activity.find(act => act._id.equals(newActivityId));

  // Emit a real-time event for activity creation
  if (io && id_idoso && createdActivity) {
    io.to(id_idoso.toString()).emit('activity_created_realtime', createdActivity);
    console.log(`[Socket.IO] Emitted 'activity_created_realtime' to room ${id_idoso} for activity ${createdActivity.titulo}`);
  }

  return createdActivity;
};

/**
 * @description Fetches all activities for a specific dependent.
 * @async
 * @param {string} id_idoso - The unique identifier of the dependent.
 * @returns {Promise<Array<object>>} A promise that resolves to an array of the dependent's activity subdocuments.
 * @throws {Error} If there's an issue with database operation.
 */
exports.getActivitiesForDependent = async (id_idoso) => {
  const routine = await DependentRoutine.findOne({ id_idoso: id_idoso }).lean(); // .lean() for plain JS objects
  return routine ? routine.activity : [];
};

/**
 * @description Fetches a single activity by its ID for a specific dependent.
 * @async
 * @param {string} id_idoso - The unique identifier of the dependent.
 * @param {string} activityId - The unique `_id` of the activity subdocument to find.
 * @returns {Promise<object|null>} A promise that resolves to the specific activity subdocument.
 * @throws {Error} If there's an issue with database operation.
 */
exports.getActivityById = async (id_idoso, activityId) => {
  const routine = await DependentRoutine.findOne(
    { id_idoso: id_idoso },
    // Projection to return only the matched activity subdocument
    { activity: { $elemMatch: { _id: new mongoose.Types.ObjectId(activityId) } } }
  ).lean(); // .lean() for plain JS objects

  if (!routine || !routine.activity || routine.activity.length === 0) {
    return null;
  }
  return routine.activity[0];
};

/**
 * @description Updates any field of a specific activity within a dependent's routine.
 * Also logs the update action and emits a real-time event for the update.
 * @async
 * @param {string} id_idoso - The unique identifier of the dependent.
 * @param {string} activityId - The unique `_id` of the activity subdocument to update.
 * @param {object} updateData - An object containing the fields to update.
 * @returns {Promise<object|null>} A promise that resolves to the updated activity subdocument.
 * @throws {Error} If there's an issue with database operation.
 */
exports.updateActivity = async (id_idoso, activityId, updateData) => {
  const updatePayload = {};
  // Construct the $set payload for MongoDB, targeting fields within the subdocument
  for (const key in updateData) {
    updatePayload[`activity.$[elem].${key}`] = updateData[key];
  }

  // If status is being updated to 'concluido', set completion_date
  if (updateData.status === 'concluido') {
    updatePayload['activity.$[elem].completion_date'] = new Date();
  } else if (updateData.status !== undefined && updateData.status !== 'concluido') {
    // If status is being changed to something other than 'concluido', clear completion_date
    updatePayload['activity.$[elem].completion_date'] = null;
  }

  // --- Reset notification flags if status or schedule changes ---
  // If the status is reset to 'pendente', or schedule changes,
  // it might be logical to reset notification flags so they can be triggered again.
  if (updateData.status === 'pendente') {
    updatePayload['activity.$[elem].pre_notification_sent'] = false;
    updatePayload['activity.$[elem].immediate_alarm_sent'] = false;
    updatePayload['activity.$[elem].failure_alert_sent'] = false;
    console.log(`[Activity Update] Resetting notification flags for activity ${activityId} due to status change to 'pendente'.`);
  }
  // Add similar logic if 'schedule' is in updateData and you want to reset flags

  const result = await DependentRoutine.findOneAndUpdate(
    { id_idoso: id_idoso, 'activity._id': new mongoose.Types.ObjectId(activityId) },
    { $set: updatePayload },
    {
      arrayFilters: [{ 'elem._id': new mongoose.Types.ObjectId(activityId) }],
      new: true, // Return the modified document
      runValidators: true // Ensure schema validations are run
    }
  );

  if (!result) {
    return null; // Routine or activity not found
  }

  // Log the update action
  const logEntry = {
    action: 'activity_updated',
    activityId: activityId,
    updatedFields: Object.keys(updateData),
    timestamp: new Date(),
  };
  // This updateOne is separate to avoid issues with returning the subdocument from the first update
  await DependentRoutine.updateOne(
    { _id: result._id }, // Use the routine's _id for precision
    { $push: { log: logEntry } }
  );

  const updatedActivity = result.activity.find((act) => act._id.toString() === activityId);

  // ▼▼▼ SOCKET.IO EVENT EMISSION FOR REAL-TIME UPDATE ▼▼▼
  if (io && id_idoso && updatedActivity) {
    // Emit an event to the specific dependent's room
    io.to(id_idoso.toString()).emit('activity_updated_realtime', updatedActivity);
    console.log(`[Socket.IO] Emitted 'activity_updated_realtime' to room ${id_idoso} for activity ${updatedActivity.titulo}`);
  }
  // ▲▲▲ END OF SOCKET.IO EVENT EMISSION ▲▲▲

  return updatedActivity;
};

/**
 * @description Deletes an activity from a dependent's routine.
 * Also logs the deletion action and emits a real-time event.
 * @async
 * @param {string} id_idoso - The unique identifier of the dependent.
 * @param {string} activityId - The unique `_id` of the activity subdocument to delete.
 * @returns {Promise<boolean>} A promise that resolves to true if the deletion was successful.
 * @throws {Error} If there's an issue with database operation.
 */
exports.deleteActivity = async (id_idoso, activityId) => {
  const deleteResult = await DependentRoutine.updateOne(
    { id_idoso: id_idoso },
    { $pull: { activity: { _id: new mongoose.Types.ObjectId(activityId) } } }
  );

  if (deleteResult.modifiedCount > 0) {
    const logEntry = {
      action: 'activity_deleted',
      activityId: activityId,
      timestamp: new Date(),
    };
    await DependentRoutine.updateOne(
      { id_idoso: id_idoso },
      { $push: { log: logEntry } }
    );

    // Emit a real-time event for activity deletion
    if (io && id_idoso) {
      io.to(id_idoso.toString()).emit('activity_deleted_realtime', { activityId: activityId, dependentId: id_idoso });
      console.log(`[Socket.IO] Emitted 'activity_deleted_realtime' to room ${id_idoso} for activity ID ${activityId}`);
    }
    return true;
  }
  return false;
};

/**
 * @description Deletes ALL activities from a dependent's routine. This is a destructive action.
 * Also logs this action and emits a real-time event.
 * @async
 * @param {string} id_idoso - The unique identifier of the dependent whose activities will be cleared.
 * @returns {Promise<boolean>} A promise that resolves to true if a routine for the dependent was found.
 * @throws {Error} If there's an issue with database operation.
 */
exports.deleteAllActivities = async (id_idoso) => {
  const clearResult = await DependentRoutine.updateOne(
    { id_idoso: id_idoso },
    { $set: { activity: [] } } // Set the activity array to empty
  );

  if (clearResult.matchedCount > 0) { // Check if a document was matched
    const logEntry = {
      action: 'all_activities_deleted',
      dependentId: id_idoso,
      timestamp: new Date(),
    };
    await DependentRoutine.updateOne(
      { id_idoso: id_idoso },
      { $push: { log: logEntry } }
    );

    // Emit a real-time event for all activities deletion
    if (io && id_idoso) {
      io.to(id_idoso.toString()).emit('all_activities_deleted_realtime', { dependentId: id_idoso });
      console.log(`[Socket.IO] Emitted 'all_activities_deleted_realtime' to room ${id_idoso}`);
    }
    return true;
  }
  return false;
};