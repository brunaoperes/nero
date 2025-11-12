import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';

/**
 * Middleware global de tratamento de erros
 */
export const errorHandler = (
  error: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error('Erro capturado:', error);

  // Erro de validação Zod
  if (error instanceof ZodError) {
    return res.status(400).json({
      success: false,
      error: 'Erro de validação',
      details: error.errors,
    });
  }

  // Erro padrão
  const statusCode = error.statusCode || 500;
  const message = error.message || 'Erro interno do servidor';

  return res.status(statusCode).json({
    success: false,
    error: message,
  });
};

export default errorHandler;
