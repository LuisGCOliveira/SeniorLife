/**
 * @file Defines the main Mongoose model for a dependent's routine.
 */

const mongoose = require('mongoose');
const ActivitySchema = require('./activitySchema'); // Import the subdocument schema

/**
 * @description Schema for the main DependentRoutine document.
 * Links a dependent (from PostgreSQL) to their list of scheduled activities (in MongoDB).
 * @type {mongoose.Schema}
 */
const DependentRoutineSchema = new mongoose.Schema(
  {
    /**
     * The unique identifier (e.g., UUID) of the dependent from your PostgreSQL database.
     * This is the critical link between your two databases.
     */
    id_idoso: { // Dependent's ID
      type: String,
      required: [true, "Dependent ID (id_idoso) is required."],
      unique: true, // Ensures one routine document per dependent
      index: true,  // Optimizes queries by id_idoso
    },

    /**
     * @property {String} id_acompanhante
     * @description The unique identifier (e.g., UUID) of the primary caregiver (acompanhante)
     * from your PostgreSQL database who is responsible for this dependent's routine.
     * This field is CRUCIAL for sending failure alerts to the correct caregiver
     * via the schedulerService.
     * It's recommended to populate this when a routine is created or a primary caregiver is assigned.
     */
    id_acompanhante: { // Caregiver's ID
      type: String,
      required: [true, "Caregiver ID (id_acompanhante) is required for sending alerts."],
      index: true, // May be useful for querying routines by caregiver
    },

    /**
     * An array containing all scheduled activities for this dependent.
     * Each object in this array must conform to the ActivitySchema.
     */
    activity: {
      type: [ActivitySchema],
      default: []
    },

    /**
     * An array to store a log of significant actions related to the routine.
     * Useful for future auditing features.
     */
    log: {
      type: [Object], // Flexible Object type for logs
      default: []
    },
  },
  {
    timestamps: true, // Automatically adds createdAt and updatedAt to the main routine document
  }
);

/**
 * Compiles the DependentRoutineSchema into a Mongoose Model.
 * Mongoose will use the collection name 'dependentroutines'.
 */
module.exports = mongoose.model('DependentRoutine', DependentRoutineSchema);