/**
 * @file Defines model functions for interacting with the 'acompanhante' (caregiver) table
 * in the PostgreSQL database. These functions use Knex.js for query building.
 */

// 1. Import the 'postgresConnection' instance from your configured instances file.
//    This file (instaceConn.js) has already created and configured the PostgresDB class instance.
const { postgresConnection } = require('../Config/instaceConn.js'); // Adjust path if necessary

// 2. Get the Knex instance from the postgresConnection.
//    'db' is now your Knex instance, ready for use.
const db = postgresConnection.getConnection();

/**
 * @async
 * @function criarAcompanhante
 * @description Creates a new caregiver (acompanhante) in the database.
 * @param {object} caregiverData - The caregiver's data.
 * @param {string} caregiverData.nome - The caregiver's full name.
 * @param {string} caregiverData.email - The caregiver's email address (should be unique).
 * @param {string} caregiverData.senha - The caregiver's hashed password.
 * @returns {Promise<object>} A promise that resolves to the newly created caregiver object
 *                            (id, nome, email, criado_em).
 * @throws {Error} If there's an error during the database operation.
 */
const criarAcompanhante = async ({ nome, email, senha }) => {
  try {
    // Execute the insert query using Knex.
    const [newCaregiver] = await db('acompanhante') // Target the 'acompanhante' table.
      .insert({ nome, email, senha }) // Insert the provided data.
      .returning(['id', 'nome', 'email', 'criado_em']); // Return specified fields of the new record.
    return newCaregiver; // Return the created caregiver.
  } catch (err) {
    // Log the error for server-side debugging.
    console.error("Error in criarAcompanhante model:", err);
    // Re-throw the error to be handled by the controller.
    throw err;
  }
};

/**
 * @async
 * @function listarAcompanhantes
 * @description Retrieves all caregivers from the database.
 * @returns {Promise<Array<object>>} A promise that resolves to an array of caregiver objects.
 *                                   Each object contains (id, nome, email, criado_em).
 *                                   Does not return passwords.
 * @throws {Error} If there's an error during the database operation.
 */
const listarAcompanhantes = async () => {
  try {
    // Fetch all records from the 'acompanhante' table.
    // Select only non-sensitive fields.
    const caregivers = await db('acompanhante').select('id', 'nome', 'email', 'criado_em');
    return caregivers;
  } catch (err) {
    console.error("Error in listarAcompanhantes model:", err);
    throw err;
  }
};

/**
 * @async
 * @function editarAcompanhante
 * @description Updates a caregiver's information by their ID.
 * @param {string} id - The UUID of the caregiver to update.
 * @param {object} fieldsToUpdate - An object containing the fields to update.
 * @param {string} [fieldsToUpdate.nome] - The caregiver's new full name.
 * @param {string} [fieldsToUpdate.email] - The caregiver's new email address (handle uniqueness in controller/service).
 * @param {string} [fieldsToUpdate.senha] - The caregiver's new hashed password.
 * @returns {Promise<object|null>} A promise that resolves to the updated caregiver object
 *                                 (id, nome, email, criado_em) if found and updated, or null if not found.
 * @throws {Error} If there's an error during the database operation.
 */
const editarAcompanhante = async (id, fieldsToUpdate) => {
  try {
    // Update the specified fields where the ID matches.
    const [updatedCaregiver] = await db('acompanhante')
      .where({ id }) // Find the caregiver by ID.
      .update(fieldsToUpdate) // Apply the updates.
      .returning(['id', 'nome', 'email', 'criado_em']); // Return specified fields of the updated record.

    return updatedCaregiver || null; // Return the updated caregiver, or null if not found (update returned empty)
  } catch (err) {
    console.error("Error in editarAcompanhante model:", err);
    throw err;
  }
};

/**
 * @async
 * @function excluirAcompanhante
 * @description Deletes a caregiver by their ID.
 * @param {string} id - The UUID of the caregiver to delete.
 * @returns {Promise<boolean>} A promise that resolves to true if the caregiver was deleted (one row affected),
 *                             false if no caregiver with that ID was found (zero rows affected).
 * @throws {Error} If there's an error during the database operation.
 */
const excluirAcompanhante = async (id) => {
  try {
    // Execute the delete operation.
    const deletedRowsCount = await db('acompanhante').where({ id }).del();
    return deletedRowsCount > 0; // True if one or more rows were deleted, false otherwise.
  } catch (err) {
    console.error("Error in excluirAcompanhante model:", err);
    throw err;
  }
};

/**
 * @async
 * @function buscarAcompanhantePorEmail
 * @description Finds a caregiver by their email address.
 * This is typically used for login to retrieve the user and their hashed password.
 * @param {string} email - The email address of the caregiver to find.
 * @returns {Promise<object|null>} A promise that resolves to the caregiver object if found
 *                                 (including all fields, e.g., id, nome, email, senha, criado_em),
 *                                 or null if not found.
 * @throws {Error} If there's an error during the database operation.
 */
const buscarAcompanhantePorEmail = async (email) => {
  try {
    // Find the first caregiver matching the email.
    // It's important to select the password here for login verification in the controller.
    const caregiver = await db('acompanhante').where({ email }).first(); // .first() returns the object or undefined
    return caregiver || null; // Return the caregiver object or null if not found.
  } catch (err) {
    console.error("Error in buscarAcompanhantePorEmail model:", err);
    throw err;
  }
};

/**
 * @async
 * @function buscarAcompanhantePorId
 * @description Finds a caregiver by their ID.
 * @param {string} id - The UUID of the caregiver to find.
 * @returns {Promise<object|null>} A promise that resolves to the caregiver object if found
 *                                 (excluding the password), or null if not found.
 * @throws {Error} If there's an error during the database operation.
 */
const buscarAcompanhantePorId = async (id) => {
  try {
    // Find the first caregiver matching the ID, excluding sensitive information like password.
    const caregiver = await db('acompanhante')
      .select('id', 'nome', 'email', 'criado_em') // Explicitly select fields, excluding 'senha'.
      .where({ id })
      .first();
    return caregiver || null; // Return the caregiver object or null if not found.
  } catch (err) {
    console.error("Error in buscarAcompanhantePorId model:", err);
    throw err;
  }
};

module.exports = {
  criarAcompanhante,
  listarAcompanhantes,
  editarAcompanhante,
  excluirAcompanhante,
  buscarAcompanhantePorEmail,
  buscarAcompanhantePorId,
};