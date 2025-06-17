/**
 * @file Manages database connections for MongoDB and PostgreSQL.
 * This module exports classes that encapsulate the connection logic for each database.
 */

const mongoose = require('mongoose');
const knex = require('knex');

/**
 * @class MongoDB
 * @description Handles the connection to a MongoDB database using Mongoose.
 */
class MongoDB {
  /**
   * Creates an instance of MongoDB.
   * @param {string} uri - The MongoDB connection URI.
   */
  constructor(uri) {
    this.uri = uri;
    this.connection = null; // Stores the active Mongoose connection object.
  }

  /**
   * Establishes a connection to the MongoDB database.
   * If a connection already exists, it returns the existing connection.
   * Exits the process if the connection fails.
   * @async
   * @returns {Promise<mongoose.Connection>} A promise that resolves to the Mongoose connection object.
   */
  async connect() {
    // If a connection already exists, return it to prevent multiple connections.
    if (this.connection) {
      return this.connection;
    }

    try {
      // Attempt to connect to MongoDB using the provided URI.
      this.connection = await mongoose.connect(this.uri);
      console.log('Successfully connected to MongoDB!'); // Success message.
      return this.connection;
    } catch (err) {
      // Log the error and exit the application if the connection fails.
      // This is a critical failure, so exiting might be appropriate.
      console.error('Error connecting to MongoDB:', err.message);
      process.exit(1); // Exit with a failure code.
    }
  }
}

/**
 * @class PostgresDB
 * @description Handles the connection to a PostgreSQL database using Knex.js.
 */
class PostgresDB {
  /**
   * Creates an instance of PostgresDB and initializes the Knex connection pool.
   * @param {object} config - The Knex connection configuration object for PostgreSQL.
   *                          (e.g., { host, user, password, database, port })
   */
  constructor(config) {
    this.config = config;
    // The Knex instance manages a connection pool, which is great for performance.
    this.knex = knex({
      client: 'pg', // Specifies the PostgreSQL client.
      connection: this.config, // Passes the connection configuration.
    });
    console.log('PostgreSQL connection pool configured.'); // Confirmation message.
  }

  /**
   * Returns the initialized Knex instance.
   * This instance can be used by services to make database queries.
   * @returns {knex.Knex} The Knex instance.
   */
  getConnection() {
    return this.knex;
  }
}

// Export both classes so they can be instantiated and used elsewhere in the application.
module.exports = { MongoDB, PostgresDB };