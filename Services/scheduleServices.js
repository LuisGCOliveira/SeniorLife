/**
 * @file Manages scheduled tasks using node-cron.
 * This service is responsible for checking for due activities (e.g., alarms, notifications)
 * and emitting Socket.IO events to relevant users.
 */

const cron = require('node-cron');
const DependentRoutine = require('../Model/dependentRoutine'); // Adjust path if necessary
const { io } = require('../../index.js'); // Adjust path if the 'io' instance is exported differently

/**
 * @object schedulerService
 * @description Service object for managing scheduled tasks.
 */
const schedulerService = {
  /**
   * @method run
   * @description Initializes and starts the cron job scheduler.
   * The scheduler runs every minute to check for various task states:
   * 1. Immediate alarms for activities due now.
   * 2. Pre-notifications for activities due in ~15 minutes.
   * 3. Failure alerts for activities that were due ~30 minutes ago and are still pending.
   */
  run: () => {
    // Schedule a task to run every minute ('* * * * *').
    cron.schedule('* * * * *', async () => {
      try {
        const currentTime = new Date();
        console.log(`\n--- Scheduler running: ${currentTime.toLocaleString()} ---`);

        // --- 1. LOGIC FOR IMMEDIATE ALARMS (AT ACTIVITY SCHEDULED TIME) ---
        const oneMinuteAgo = new Date(currentTime.getTime() - 60000); // Window: last minute up to now
        const routinesForImmediateAlarm = await DependentRoutine.find({
          'activity.schedule': { $gte: oneMinuteAgo, $lte: currentTime },
          'activity.status': 'pendente',
          'activity.immediate_alarm_sent': { $ne: true } // Only if immediate alarm hasn't been sent
        }).select('id_idoso activity');

        for (const routine of routinesForImmediateAlarm) {
          if (!routine.id_idoso) {
            console.warn(`[IMMEDIATE ALARM] Dependent ID (id_idoso) missing for routine ${routine._id}. Skipping.`);
            continue;
          }
          for (const activity of routine.activity) {
            const activityScheduleTime = new Date(activity.schedule);
            if (
              activityScheduleTime <= currentTime &&
              activityScheduleTime > oneMinuteAgo &&
              activity.status === 'pendente' &&
              !activity.immediate_alarm_sent // Double-check flag
            ) {
              if (io) {
                io.to(routine.id_idoso.toString()).emit('alarm', {
                  title: 'Activity Alarm!',
                  message: `It's time for: ${activity.titulo}`, // Using 'titulo'
                  activity: activity,
                  type: 'immediate_alarm'
                });
                console.log(`[IMMEDIATE ALARM] Sent to dependent ${routine.id_idoso} -> Activity: ${activity.titulo}`);
                // Mark that the immediate alarm has been sent
                await DependentRoutine.updateOne(
                  { _id: routine._id, "activity._id": activity._id },
                  { $set: { "activity.$.immediate_alarm_sent": true } }
                );
              }
            }
          }
        }
        console.log(`Checked ${routinesForImmediateAlarm.length} routines for immediate alarms.`);

        // --- 2. LOGIC FOR PRE-NOTIFICATIONS (APPROX. 15 MINUTES BEFORE) ---
        // Window: activities scheduled between 14 and 15 minutes from now
        const fifteenMinutesAheadStart = new Date(currentTime.getTime() + (14 * 60000));
        const fifteenMinutesAheadEnd = new Date(currentTime.getTime() + (15 * 60000));

        const routinesForPreNotification = await DependentRoutine.find({
          'activity.schedule': { $gte: fifteenMinutesAheadStart, $lte: fifteenMinutesAheadEnd },
          'activity.status': 'pendente',
          'activity.pre_notification_sent': { $ne: true } // Only if pre-notification hasn't been sent
        }).select('id_idoso activity');

        for (const routine of routinesForPreNotification) {
          if (!routine.id_idoso) {
            console.warn(`[PRE-NOTIFICATION] Dependent ID (id_idoso) missing for routine ${routine._id}. Skipping.`);
            continue;
          }
          for (const activity of routine.activity) {
            const activityScheduleTime = new Date(activity.schedule);
            if (
              activityScheduleTime >= fifteenMinutesAheadStart &&
              activityScheduleTime <= fifteenMinutesAheadEnd &&
              activity.status === 'pendente' &&
              !activity.pre_notification_sent // Double-check flag
            ) {
              if (io) {
                io.to(routine.id_idoso.toString()).emit('pre_notification', {
                  title: 'Activity Reminder',
                  message: `Reminder: ${activity.titulo} in approximately 15 minutes.`, // Using 'titulo'
                  activity: activity,
                  type: 'pre_activity_notification'
                });
                console.log(`[PRE-NOTIFICATION 15min] Sent to dependent ${routine.id_idoso} -> Activity: ${activity.titulo}`);
                // Mark that the pre-notification has been sent
                await DependentRoutine.updateOne(
                  { _id: routine._id, "activity._id": activity._id },
                  { $set: { "activity.$.pre_notification_sent": true } }
                );
              }
            }
          }
        }
        console.log(`Checked ${routinesForPreNotification.length} routines for pre-notifications.`);


        // --- 3. LOGIC FOR FAILURE ALERTS (APPROX. 30 MINUTES AFTER IF STILL PENDING) ---
        // Window: activities scheduled between 31 and 30 minutes ago
        const thirtyMinutesAgoStart = new Date(currentTime.getTime() - (31 * 60000));
        const thirtyMinutesAgoEnd = new Date(currentTime.getTime() - (30 * 60000));

        const routinesForFailureAlert = await DependentRoutine.find({
          'activity.schedule': { $gte: thirtyMinutesAgoStart, $lte: thirtyMinutesAgoEnd },
          'activity.status': 'pendente', // Activity is still pending after 30 minutes
          'activity.failure_alert_sent': { $ne: true } // Only if failure alert hasn't been sent
        }).select('id_idoso id_acompanhante activity'); // Ensure id_acompanhante is selected

        for (const routine of routinesForFailureAlert) {
          if (!routine.id_acompanhante) {
            console.warn(`[FAILURE ALERT] Caregiver ID (id_acompanhante) not found for routine of dependent ${routine.id_idoso}. Alert not sent for activity: ${routine.activity.find(a => a.schedule >= thirtyMinutesAgoStart && a.schedule <= thirtyMinutesAgoEnd)?.titulo}`);
            continue;
          }
          for (const activity of routine.activity) {
            const activityScheduleTime = new Date(activity.schedule);
            if (
              activityScheduleTime >= thirtyMinutesAgoStart &&
              activityScheduleTime <= thirtyMinutesAgoEnd &&
              activity.status === 'pendente' &&
              !activity.failure_alert_sent // Double-check flag
            ) {
              if (io) {
                io.to(routine.id_acompanhante.toString()).emit('failure_alert', {
                  title: 'Alert: Activity Not Completed!',
                  message: `The activity "${activity.titulo}" for dependent (ID: ${routine.id_idoso || 'N/A'}) scheduled for ${activityScheduleTime.toLocaleTimeString()} appears to be uncompleted.`, // Using 'titulo'
                  activity: activity,
                  dependentId: routine.id_idoso,
                  type: 'activity_failure_alert'
                });
                console.log(`[FAILURE ALERT 30min] Sent to caregiver ${routine.id_acompanhante} (Dependent: ${routine.id_idoso}) -> Activity: ${activity.titulo}`);
                // Mark that the failure alert has been sent
                await DependentRoutine.updateOne(
                  { _id: routine._id, "activity._id": activity._id },
                  { $set: { "activity.$.failure_alert_sent": true } }
                );
              }
            }
          }
        }
        console.log(`Checked ${routinesForFailureAlert.length} routines for failure alerts.`);

      } catch (error) {
        // CRITICAL: Always include error handling in scheduled tasks.
        // Otherwise, an unhandled promise rejection or error can crash the cron job or the app.
        console.error('CRITICAL ERROR in scheduler job:', error);
        // Consider adding more sophisticated error reporting here (e.g., Sentry, a logging service).
      }
    });

    console.log('Scheduler service started. Cron job is configured to run every minute.');
  }
};

module.exports = schedulerService;