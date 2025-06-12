import jwt from 'jsonwebtoken';

/**
 * Middleware para permitir acesso apenas para acompanhantes autenticados.
 */
export function autenticarAcompanhante(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ erro: 'Token não fornecido.' });
  }

  const [, token] = authHeader.split(' ');

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'seuSegredoJWT');
    if (decoded.tipo !== 'acompanhante') {
      return res.status(403).json({ erro: 'Acesso permitido apenas para acompanhantes.' });
    }
    req.acompanhante = decoded; // Disponibiliza os dados do acompanhante na req
    next();
  } catch (err) {
    return res.status(401).json({ erro: 'Token inválido ou expirado.' });
  }
}