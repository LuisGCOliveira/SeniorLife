/**
 * @file Defines the schema for a single activity subdocument.
 * @see {@link dependentRoutine.js} for the parent schema.
 */

const mongoose = require('mongoose');

/**
 * @description Schema for a single activity within a dependent's routine.
 * This schema is not a standalone model but is intended to be embedded
 * as a subdocument within the DependentRoutine document.
 * @type {mongoose.Schema}
 */
const ActivitySchema = new mongoose.Schema(
  {
    /**
     * The title of the activity, e.g., "Morning Walk" or "Lunch".
     * This field is required and will have leading/trailing whitespace removed.
     */
    titulo: { // Changed from 'title' to 'titulo' to match your previous validator example
      type: String,
      required: [true, 'Activity title (titulo) is required.'],
      trim: true,
    },

    /**
     * Differentiates activities (e.g., physical activity, meal, medication).
     * Acts as a "tag" or "label".
     */
    tipo: { // Changed from 'type' to 'tipo'
      type: String,
      required: true,
      enum: {
        values: ['atividade fisica', 'alimentacao', 'medicacao'],
        message: '{VALUE} is not a supported activity type (tipo).',
      },
    },

    /**
     * A more detailed description of the activity. This field is optional.
     */
    description: {
      type: String,
      trim: true,
    },

    /**
     * The specific date and time the activity is scheduled for.
     */
    schedule: {
      type: Date,
      required: true,
    },

    /**
     * The current state of the activity. Defaults to 'pendente'.
     */
    status: {
      type: String,
      required: true,
      enum: ['pendente', 'concluido', 'nao_cumprido'],
      default: 'pendente',
    },

    /**
     * Flexible field for data unique to a specific activity type.
     * Example for 'medicacao': { dosage: '50mg', drug_name: 'Aspirin' }
     */
    specific_data: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },

    /**
     * Timestamp of when the activity was marked as 'concluido'.
     */
    completion_date: {
      type: Date,
    },

    // --- NEW FIELDS FOR SCHEDULER NOTIFICATIONS/ALERTS ---
    /**
     * @property {Boolean} pre_notification_sent
     * @description Flag indicating if the pre-activity notification (e.g., 15 minutes before) has been sent.
     * @default false
     */
    pre_notification_sent: {
      type: Boolean,
      default: false,
    },

    /**
     * @property {Boolean} immediate_alarm_sent
     * @description Flag indicating if the immediate alarm (at the scheduled time) has been sent.
     * @default false
     */
    immediate_alarm_sent: {
      type: Boolean,
      default: false,
    },

    /**
     * @property {Boolean} failure_alert_sent
     * @description Flag indicating if the failure alert (e.g., 30 minutes after if still pending)
     * has been sent to the caregiver.
     * @default false
     */
    failure_alert_sent: {
      type: Boolean,
      default: false,
    },
    // --- END OF NEW FIELDS ---
  },
  {
    timestamps: true, // Automatically adds createdAt and updatedAt
    _id: true,        // Ensures each activity subdocument gets its own _id
  }
);

module.exports = ActivitySchema;