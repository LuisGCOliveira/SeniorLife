const emergenciaModel = require('../Model/emergenciaModel.js');
const { io } = require('../../index.js');

exports.criarEmergencia = async (req, res, next) => {
  const { dependente_id, nome, idade, alergias, historico, contato_emergencia } = req.body;
  const emergencia = await emergenciaModel.criarEmergencia({ dependente_id, nome, idade, alergias, historico, contato_emergencia });
  res.status(201).json({ status: 'success', data: emergencia[0] });
};

exports.buscarEmergencia = async (req, res, next) => {
  const { dependente_id } = req.params;
  const emergencia = await emergenciaModel.buscarEmergenciaPorDependente(dependente_id);
  if (!emergencia) return res.status(404).json({ status: 'fail', message: 'Não encontrado' });
  res.json({ status: 'success', data: emergencia });
};

exports.atualizarEmergencia = async (req, res, next) => {
  const { dependente_id } = req.params;
  const dados = req.body;
  const emergencia = await emergenciaModel.atualizarEmergencia(dependente_id, dados);
  res.json({ status: 'success', data: emergencia[0] });
};

exports.emergencyAlert = async (req, res, next) => {
  const { acompanhanteId, timestamp } = req.body;

  io.to(acompanhanteId).emit('emergency', { acompanhanteId, timestamp });

  res.status(200).json({ status: 'success', message: 'Alerta de emergência enviado!' });
};

exports.cancelAlert = async (req, res, next) => {
  const { acompanhanteId } = req.body;

  // Notifica o acompanhante em tempo real (emit para a room do acompanhante)
  io.to(acompanhanteId).emit('emergency_cancel', { acompanhanteId });

  res.status(200).json({ status: 'success', message: 'Alerta de emergência cancelado!' });
};

exports.getMedicalInfo = async (req, res, next) => {
  const { userId } = req.params;
  const info = await emergenciaModel.buscarEmergenciaPorDependente(userId);

  if (!info) {
    return res.status(404).json({ status: 'fail', message: 'Informações médicas não encontradas.' });
  }

  res.status(200).json({
    name: info.nome,
    age: info.idade,
    allergies: info.alergias,
    history: info.historico,
    emergencyContact: info.contato_emergencia
  });
};