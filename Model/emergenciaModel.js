const db = require('../Config/conn.js');

exports.criarEmergencia = async (dados) => {
  return await db('emergencia').insert(dados).returning('*');
};

exports.buscarEmergenciaPorDependente = async (dependente_id) => {
  return await db('emergencia').where({ dependente_id }).first();
};

exports.atualizarEmergencia = async (dependente_id, dados) => {
  return await db('emergencia').where({ dependente_id }).update(dados).returning('*');
};

exports.buscarEmergenciaPorDependente = async (dependente_id) => {
  return await db('emergencia').where({ dependente_id }).first();
};