import { Request, Response, NextFunction } from 'express';
import { config } from '../config/env';
import { supabase } from '../config/supabase';

/**
 * Middleware de autenticação por API Key
 */
export const apiKeyAuth = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const apiKey = req.headers['x-api-key'] as string;

  if (!apiKey) {
    return res.status(401).json({
      success: false,
      error: 'API Key é obrigatória. Use o header x-api-key',
    });
  }

  if (apiKey !== config.security.apiKey) {
    return res.status(403).json({
      success: false,
      error: 'API Key inválida',
    });
  }

  next();
};

/**
 * Middleware de autenticação do usuário (Supabase Token)
 */
export const authMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'Token de autenticação não fornecido',
      });
    }

    const token = authHeader.split(' ')[1];

    // Verificar o token com Supabase
    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      return res.status(401).json({
        success: false,
        error: 'Token inválido ou expirado',
      });
    }

    // Adicionar usuário ao request
    req.user = {
      id: user.id,
      email: user.email,
    };

    next();
  } catch (error) {
    console.error('Error in auth middleware:', error);
    return res.status(500).json({
      success: false,
      error: 'Erro ao verificar autenticação',
    });
  }
};

export default apiKeyAuth;
