/**
 * @file Defines model functions for interacting with the 'dependente' (dependent/elderly) table
 * and the 'relacao_acompanhante_dependente' (caregiver-dependent relationship) table
 * in the PostgreSQL database. These functions use Knex.js for query building.
 */

// 1. Import the 'postgresConnection' instance from your configured instances file.
const { postgresConnection } = require('../Config/instaceConn.js'); // Adjust path if necessary

// 2. Get the Knex instance from the postgresConnection.
const db = postgresConnection.getConnection(); // 'db' is now your Knex instance.

// --- Dependent (idoso) Table Functions ---

/**
 * @async
 * @function criarDependente
 * @description Creates a new dependent in the 'dependente' table.
 * @param {object} dependentData - The dependent's data.
 * @param {string} dependentData.nome - The dependent's full name.
 * @param {string} dependentData.email - The dependent's email address (should be unique).
 * @param {string} dependentData.senha - The dependent's hashed password.
 * @param {string} [dependentData.data_nascimento] - Dependent's date of birth.
 * @param {string} [dependentData.condicoes_medicas] - Dependent's medical conditions.
 * @param {string} [dependentData.contato_emergencia_nome] - Emergency contact name.
 * @param {string} [dependentData.contato_emergencia_telefone] - Emergency contact phone.
 * @returns {Promise<object>} A promise that resolves to the newly created dependent object
 *                            (id, nome, email, criado_em, and other fields if returned).
 * @throws {Error} If there's an error during the database operation.
 */
const criarDependente = async (dependentData) => {
  try {
    // Destructure known fields, pass the rest if your table has more columns
    const { nome, email, senha, } = dependentData;
    const [newDependent] = await db('dependente')
      .insert({ nome, email, senha,  })
      .returning(['id', 'nome', 'email', 'criado_em']); // Add other fields you want returned
    return newDependent;
  } catch (err) {
    console.error("Error in criarDependente model:", err);
    throw err;
  }
};

/**
 * @async
 * @function listarDependentes
 * @description Retrieves all dependents from the 'dependente' table.
 * Note: This lists ALL dependents, consider if authorization is needed at service/controller level
 * or if a function like `listarDependentesPorAcompanhante` is more appropriate for most use cases.
 * @returns {Promise<Array<object>>} A promise that resolves to an array of dependent objects
 *                                   (id, nome, email, criado_em). Excludes passwords.
 * @throws {Error} If there's an error during the database operation.
 */
const listarDependentes = async () => {
  try {
    const dependents = await db('dependente').select('id', 'nome', 'email', 'criado_em');
    return dependents;
  } catch (err) {
    console.error("Error in listarDependentes model:", err);
    throw err;
  }
};

/**
 * @async
 * @function buscarDependentePorEmail
 * @description Finds a dependent by their email address.
 * @param {string} email - The email address of the dependent to find.
 * @returns {Promise<object|null>} A promise that resolves to the dependent object if found
 *                                 (including the hashed password), or null if not found.
 * @throws {Error} If there's an error during the database operation.
 */
const buscarDependentePorNome = async (nome) => {
  try {
    const dependent = await db('dependente').where({ nome }).first();
    return dependent || null;
  } catch (err) {
    console.error("Error in buscarDependentePorNome model:", err);
    throw err;
  }
};

/**
 * @async
 * @function buscarDependentePorId
 * @description Finds a dependent by their ID.
 * @param {string} id - The UUID of the dependent to find.
 * @returns {Promise<object|null>} A promise that resolves to the dependent object if found
 *                                 (excluding the password), or null if not found.
 * @throws {Error} If there's an error during the database operation.
 */
const buscarDependentePorId = async (id) => {
  try {
    const dependent = await db('dependente')
      .select('id', 'nome', 'email', 'criado_em') // Exclude password and other sensitive data
      .where({ id })
      .first();
    return dependent || null;
  } catch (err) {
    console.error("Error in buscarDependentePorId model:", err);
    throw err;
  }
};

/**
 * @async
 * @function editarDependente
 * @description Updates a dependent's information in the 'dependente' table by their ID.
 * @param {string} id - The UUID of the dependent to update.
 * @param {object} fieldsToUpdate - An object containing the fields to update.
 * @param {string} [fieldsToUpdate.nome] - The dependent's new full name.
 * @param {string} [fieldsToUpdate.email] - The dependent's new email address.
 * @param {string} [fieldsToUpdate.senha] - The dependent's new hashed password.
 * @returns {Promise<object|null>} A promise that resolves to the updated dependent object
 *                                 (id, nome, email, criado_em) if found and updated, or null if not found.
 * @throws {Error} If there's an error during the database operation.
 */
const editarDependente = async (id, fieldsToUpdate) => {
  try {
    const [updatedDependent] = await db('dependente')
      .where({ id })
      .update(fieldsToUpdate)
      .returning(['id', 'nome', 'email', 'criado_em']);
    return updatedDependent || null;
  } catch (err)
  {
    console.error("Error in editarDependente model:", err);
    throw err;
  }
};

/**
 * @async
 * @function excluirDependente
 * @description Deletes a dependent from the 'dependente' table by their ID.
 * If `ON DELETE CASCADE` is set for `id_dependente` in `relacao_acompanhante_dependente`,
 * the corresponding relationship entries will also be deleted.
 * @param {string} id - The UUID of the dependent to delete.
 * @returns {Promise<boolean>} A promise that resolves to true if the dependent was deleted,
 *                             false if no dependent with that ID was found.
 * @throws {Error} If there's an error during the database operation.
 */
const excluirDependente = async (id) => {
  try {
    const deletedRowsCount = await db('dependente').where({ id }).del();
    return deletedRowsCount > 0;
  } catch (err) {
    console.error("Error in excluirDependente model:", err);
    throw err;
  }
};


// --- Caregiver-Dependent Relationship (relacao_acompanhante_dependente) Table Functions ---

/**
 * @async
 * @function criarRelacaoAcompanhanteDependente
 * @description Creates a link between a caregiver and a dependent in the 'relacao_acompanhante_dependente' table.
 * @param {string} id_acompanhante - The UUID of the caregiver.
 * @param {string} id_dependente - The UUID of the dependent.
 * @returns {Promise<object>} A promise that resolves to the newly created relationship object.
 * @throws {Error} If there's an error during the database operation (e.g., duplicate entry, foreign key violation).
 */
const criarRelacaoAcompanhanteDependente = async (id_acompanhante, id_dependente) => {
  try {
    const [newRelationship] = await db('relacao_acompanhante_dependente')
      .insert({ id_acompanhante, id_dependente })
      .returning(['id_acompanhante', 'id_dependente']); // Or '*' if you want all columns from this table
    return newRelationship;
  } catch (err) {
    console.error("Error in criarRelacaoAcompanhanteDependente model:", err);
    // Handle specific errors like duplicate entry if primary key is (id_acompanhante, id_dependente)
    if (err.code === '23505') { // PostgreSQL unique violation
        throw new Error('This caregiver is already linked to this dependent.');
    }
    throw err;
  }
};

/**
 * @async
 * @function listarDependentesPorAcompanhante
 * @description Retrieves all dependents linked to a specific caregiver.
 * @param {string} id_acompanhante - The UUID of the caregiver.
 * @returns {Promise<Array<object>>} A promise that resolves to an array of dependent objects
 *                                   (id, nome, email, criado_em of the dependent).
 * @throws {Error} If there's an error during the database operation.
 */
const listarDependentesPorAcompanhante = async (id_acompanhante) => {
  try {
    const dependents = await db('dependente')
      .join('relacao_acompanhante_dependente', 'dependente.id', '=', 'relacao_acompanhante_dependente.id_dependente')
      .where('relacao_acompanhante_dependente.id_acompanhante', id_acompanhante)
      .select('dependente.id', 'dependente.nome', 'dependente.email', 'dependente.criado_em'); // Select fields from 'dependente'
    return dependents;
  } catch (err) {
    console.error("Error in listarDependentesPorAcompanhante model:", err);
    throw err;
  }
};

/**
 * @async
 * @function verificarRelacaoAcompanhanteDependente
 * @description Checks if a specific caregiver is linked to a specific dependent.
 * Useful for authorization middleware.
 * @param {string} id_acompanhante - The UUID of the caregiver.
 * @param {string} id_dependente - The UUID of the dependent.
 * @returns {Promise<boolean>} A promise that resolves to true if the link exists, false otherwise.
 * @throws {Error} If there's an error during the database operation.
 */
const verificarRelacaoAcompanhanteDependente = async (id_acompanhante, id_dependente) => {
  try {
    const relationship = await db('relacao_acompanhante_dependente')
      .where({
        id_acompanhante: id_acompanhante,
        id_dependente: id_dependente,
      })
      .first(); // Check if any row matches
    return !!relationship; // Convert the result (object or undefined) to a boolean
  } catch (err) {
    console.error("Error in verificarRelacaoAcompanhanteDependente model:", err);
    throw err;
  }
};

/**
 * Busca um dependente pelo email.
 * @param {string} email
 * @returns {Promise<object|null>}
 */
const buscarDependentePorEmail = async (email) => {
  try {
    const dependente = await db('dependente').where({ email }).first();
    return dependente || null;
  } catch (err) {
    console.error('Erro ao buscar dependente por email:', err);
    throw err;
  }
};

module.exports = {
  criarDependente,
  listarDependentes,
  buscarDependentePorId,
  editarDependente,
  excluirDependente,
  criarRelacaoAcompanhanteDependente,
  listarDependentesPorAcompanhante,
  verificarRelacaoAcompanhanteDependente,
  buscarDependentePorNome,
  buscarDependentePorEmail,
};