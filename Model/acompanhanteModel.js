import { PostgresDB } from './conn.js'

/**
 * Função do model responsável por criar um novo acompanhante no banco de dados.
 * Recebe um objeto com nome, email e senha.
 * Retorna o acompanhante criado (id, nome, email, criado_em).
 */
export async function criarAcompanhante({ nome, email, senha }) {
  try {
    // Executa a query de inserção usando Knex
    const [acompanhante] = await db('acompanhante')
      .insert({ nome, email, senha }) // Insere os dados recebidos
      .returning(['id', 'nome', 'email', 'criado_em']); // Retorna os campos desejados
    return acompanhante; // Retorna o acompanhante criado
  } catch (err) {
    // Se ocorrer erro, lança para ser tratado no controller
    throw err;
  }
}

/**
 * Função do model para consultar todos os acompanhantes no banco de dados.
 * Retorna um array de acompanhantes.
 */
export async function listarAcompanhantes() {
  try {
    // Busca todos os registros da tabela 'acompanhante'
    const acompanhantes = await db('acompanhante').select('id', 'nome', 'email', 'criado_em');
    return acompanhantes;
  } catch (err) {
    throw err;
  }
}

/**
 * Função do model para atualizar um acompanhante pelo ID.
 * Recebe o ID do acompanhante e os campos a serem atualizados.
 * Retorna o acompanhante atualizado.
 */
export async function editarAcompanhante(id, { nome, email, senha }) {
  try {
    // Atualiza os campos informados onde o id for igual ao passado
    const [acompanhante] = await db('acompanhante')
      .where({ id })
      .update({ nome, email, senha })
      .returning(['id', 'nome', 'email', 'criado_em']);
    return acompanhante;
  } catch (err) {
    throw err;
  }
}

// ...existing code...

/**
 * Função do model para excluir um acompanhante pelo ID.
 * Retorna true se excluiu, false se não encontrou.
 */
export async function excluirAcompanhante(id) {
  try {
    const deletados = await db('acompanhante').where({ id }).del();
    return deletados > 0; // true se excluiu, false se não encontrou
  } catch (err) {
    throw err;
  }
}

/**
 * Função do model para buscar um acompanhante pelo email.
 * Retorna o acompanhante encontrado ou null.
 */
export async function buscarAcompanhantePorEmail(email) {
  try {
    const acompanhante = await db('acompanhante').where({ email }).first();
    return acompanhante;
  } catch (err) {
    throw err;
  }
}