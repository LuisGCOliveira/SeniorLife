const express = require('express');
const controller = require('../../Controller/emergenciaController.js');
const router = express.Router();

router.post('/', controller.criarEmergencia);
router.get('/:dependente_id', controller.buscarEmergencia);
router.put('/:dependente_id', controller.atualizarEmergencia);
router.post('/emergency_alert', controller.emergencyAlert);
router.post('/cancel_alert', controller.cancelAlert);
router.get('/medical_info/:userId', controller.getMedicalInfo);
module.exports = router;