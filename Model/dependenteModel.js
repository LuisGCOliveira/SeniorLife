import { PostgresDB } from './conn.js';

/**
 * Cria um novo dependente no banco de dados.
 * Recebe um objeto com nome, email e senha (já criptografada).
 * Retorna o dependente criado.
 */
export async function criarDependente({ nome, email, senha }) {
  try {
    const [dependente] = await db('dependente')
      .insert({ nome, email, senha })
      .returning(['id', 'nome', 'email', 'criado_em']);
    return dependente;
  } catch (err) {
    throw err;
  }
}

/**
 * Lista todos os dependentes cadastrados.
 * Retorna um array de dependentes.
 */
export async function listarDependentes() {
  try {
    return await db('dependente').select('id', 'nome', 'email', 'criado_em');
  } catch (err) {
    throw err;
  }
}

/**
 * Busca um dependente pelo email.
 * Retorna o dependente encontrado ou null.
 */
export async function buscarDependentePorEmail(email) {
  try {
    return await db('dependente').where({ email }).first();
  } catch (err) {
    throw err;
  }
}

/**
 * Edita um dependente pelo ID.
 * Recebe o ID e os novos dados (nome, email, senha).
 * Retorna o dependente atualizado.
 */
export async function editarDependente(id, { nome, email, senha }) {
  try {
    const [dependente] = await db('dependente')
      .where({ id })
      .update({ nome, email, senha })
      .returning(['id', 'nome', 'email', 'criado_em']);
    return dependente;
  } catch (err) {
    throw err;
  }
}

/**
 * Exclui um dependente pelo ID.
 * Retorna true se excluiu, false se não encontrou.
 */
export async function excluirDependente(id) {
  try {
    const deletados = await db('dependente').where({ id }).del();
    return deletados > 0;
  } catch (err) {
    throw err;
  }
}

/**
 * Busca um dependente pelo email.
 * Retorna o dependente encontrado ou null.
 */
export async function buscarDependentePorEmail(email) {
  try {
    // Busca o primeiro dependente com o email informado
    const dependente = await db('dependente').where({ email }).first();
    return dependente;
  } catch (err) {
    throw err;
  }
}