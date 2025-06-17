/**
 * @file Manages Socket.IO connections, including JWT authentication and user room management.
 */

const jwt = require('jsonwebtoken');

/**
 * @function initializeSocket
 * @description Initializes Socket.IO with authentication middleware and connection handling.
 * @param {object} io - The Socket.IO server instance.
 */
function initializeSocket(io) {
  // Socket.IO authentication middleware.
  // This runs for every new connecting client before the 'connection' event is emitted.
  io.use((socket, next) => {
    // The client should send the JWT token in the 'auth' object during the handshake.
    // Example client-side: const socket = io({ auth: { token: "your_jwt_token" } });
    const token = socket.handshake.auth.token;

    if (!token) {
      // If no token is provided, reject the connection with an authentication error.
      return next(new Error('Authentication error: No token provided'));
    }

    // Verify the JWT token.
    jwt.verify(token, process.env.JWT_SECRET, (err, decodedUser) => {
      if (err) {
        // If token verification fails (e.g., invalid signature, expired),
        // reject the connection.
        return next(new Error('Authentication error: Invalid token'));
      }
      // If the token is valid, attach the decoded user information (payload)
      // to the socket object. This makes it available in subsequent event handlers.
      socket.user = decodedUser;
      // Proceed to establish the connection.
      next();
    });
  });

  // Event listener for new client connections.
  // This runs after the authentication middleware has successfully processed the connection.
  io.on('connection', (socket) => {
    // Log successful connection, using the user ID from the decoded token.
    console.log(`User connected via Socket: ${socket.user.id} (Socket ID: ${socket.id})`);

    // Have the user join a private room named after their own user ID.
    // This is a key pattern for sending direct/private messages or notifications
    // to a specific user, as you can then emit events to this room: io.to(socket.user.id).emit(...).
    socket.join(socket.user.id);

    // Event listener for client disconnection.
    socket.on('disconnect', () => {
      // Log user disconnection.
      console.log(`User disconnected: ${socket.user.id} (Socket ID: ${socket.id})`);
      // Additional cleanup or presence management could be done here,
      // e.g., removing the user from any other rooms or updating their status.
    });

    // You can add more custom event listeners here for this socket connection.
    // For example:
    // socket.on('chat message', (msg) => {
    //   // Handle chat message, potentially broadcasting to a room or another user
    //   console.log(`Message from ${socket.user.id}: ${msg}`);
    //   // Example: io.to(someRoomId).emit('chat message', { user: socket.user.id, message: msg });
    // });
  });
}

module.exports = initializeSocket;