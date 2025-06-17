/**
 * @file Initializes and exports pre-configured instances of database connections.
 * This file uses the MongoDB and PostgresDB classes from './conn.js'
 * and environment variables to create ready-to-use connection objects.
 */

// Load environment variables from a .env file into process.env
require('dotenv').config();

// 1. Import the database connection classes from conn.js
const { MongoDB, PostgresDB } = require('./conn.js'); // <<< IMPORTANTE: Importa as classes

// --- MongoDB Configuration and Instance ---

// Retrieve the MongoDB connection URI from environment variables.
const mongoURI = process.env.MONGODB_URI;
if (!mongoURI) {
  console.warn('MONGODB_URI environment variable is not set. MongoDB connection might fail.');
  // Consider throwing an error or exiting if MONGODB_URI is critical and must be set
  // process.exit(1);
}
// 2. Create a new INSTANCE of the MongoDB connection manager.
const mongoConnection = new MongoDB(mongoURI);

// --- PostgreSQL Configuration and Instance ---

// Construct the PostgreSQL connection configuration object from environment variables.
const postgresConfig = {
  host: process.env.PG_HOST,
  user: process.env.PG_USER,
  password: process.env.PG_PASSWORD,
  database: process.env.PG_DATABASE,
  // Use the PG_PORT from environment variables, or default to 5432 if not set.
  port: parseInt(process.env.PG_PORT, 10) || 5432, // Ensure port is an integer
};

// Basic check for essential PostgreSQL environment variables
if (!postgresConfig.host || !postgresConfig.user || !postgresConfig.database) {
  console.warn('One or more essential PostgreSQL environment variables (PG_HOST, PG_USER, PG_DATABASE) are not set. PostgreSQL connection might fail.');
  // Consider throwing an error or exiting if these are critical
  // process.exit(1);
}

// 3. Create a new INSTANCE of the PostgreSQL connection manager.
const postgresConnection = new PostgresDB(postgresConfig);

// 4. Export the ready-to-use database connection INSTANCES.
// These instances can be imported elsewhere in the application to interact with the databases.
module.exports = {
  mongoConnection,
  postgresConnection,
};