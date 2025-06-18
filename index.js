/**
 * @file Main application file (entry point) for the SeniorLife backend server.
 * This file sets up the Express server, connects to databases,
 * configures middleware, mounts application routes, initializes Socket.IO,
 * and starts the scheduler service.
 */

// 1. Importing core packages
const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const bodyParser = require('body-parser');
const http = require('http'); // Required for Socket.IO
const { Server } = require("socket.io"); // Socket.IO Server class
const dotenv = require('dotenv'); // Import dotenv

// Load environment variables from .env file
dotenv.config(); // Isso deve vir antes de qualquer código que use process.env

// 2. Importing pre-configured database connection instances
const { mongoConnection, postgresConnection } = require('./Config/instaceConn.js');

// 3. Importing route handlers
const routineRouters = require('./Api/Routes/routineRouters.js');
const dependenteRoutes = require('./Api/Routes/dependenteRoutes.js');
const acompanhanteRoutes = require('./Api/Routes/acompanhanteRoutes.js');
const emergenciaRoutes = require('./Api/Routes/emergenciaRoutes.js');

// 4. Importing custom modules/services
const initializeSocketManager = require('./socketManager.js'); // Path to your socketManager
const schedulerService = require('./Services/scheduleServices.js'); // Path to your schedulerService
const AppError = require('./Utils/appError.js'); // Import AppError para o handler 404

// 5. Importing middleware by errors
const errorHandler = require('./Api/Middleware/errorMiddleware.js'); // Corrigido o nome da variável

// --- DATABASE CONNECTIONS ---
mongoConnection.connect();
const knexInstance = postgresConnection.getConnection();

// --- EXPRESS SERVER AND SOCKET.IO CONFIGURATION ---
const app = express();
const server = http.createServer(app); // Create HTTP server from Express app

// Initialize Socket.IO
const ioModule = require('./io'); 
const io = new Server(server, {
  cors: {
    origin: "*", // Adjust to your client's URL in production for security
    methods: ["GET", "POST"]
  }
});
ioModule.setIO(io);

// Initialize Socket.IO manager (authentication, rooms, etc.)
initializeSocketManager(io);

// Applying middleware to Express app
app.use(morgan('dev'));
app.use(cors()); // CORS for Express routes
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// --- MOUNTING APPLICATION ROUTES ---
app.use('/api', routineRouters);
app.use('/api/dependents', dependenteRoutes);
app.use('/api/caregivers', acompanhanteRoutes);
app.use('/api/emergency', emergenciaRoutes);


// --- DATABASE CONNECTION TEST (OPTIONAL) ---
// ... (seu teste de conexão com Knex) ...

// --- START SCHEDULER SERVICE ---
schedulerService.run();

// --- ERROR HANDLING MIDDLEWARES ---
// Handler para rotas não encontradas (404) - DEVE VIR ANTES DO errorHandler global
//app.all('*', (req, res, next) => {
  //next(new AppError());
//});

// REGISTRO DO MIDDLEWARE DE ERRO GLOBAL - DEVE SER O ÚLTIMO!
app.use(errorHandler);

// --- SERVER INITIALIZATION ---
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => { // Express app now listens through the HTTP server
  console.log(`Server is running on port ${PORT}`);
  console.log(`Socket.IO initialized and listening.`);
});

module.exports = { app, io };