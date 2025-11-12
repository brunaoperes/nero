import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import { config } from './config/env';
import aiRoutes from './routes/ai.routes';
import openFinanceRoutes from './routes/openFinance.routes';
import { apiKeyAuth } from './middlewares/auth.middleware';
import { errorHandler } from './middlewares/error.middleware';
import { initOpenFinanceSchedulers } from './schedulers/openFinanceSync.scheduler';

/**
 * Nero Backend - API de Inteligência Artificial
 * Serviços de categorização, recomendações e análise de comportamento
 */

const app: Application = express();

// ==========================================
// MIDDLEWARES
// ==========================================

// Segurança
app.use(helmet());

// CORS
app.use(
  cors({
    origin: config.nodeEnv === 'production' ? [] : '*', // Configurar origens permitidas em produção
    credentials: true,
  })
);

// Compressão
app.use(compression());

// Body parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logger
if (config.nodeEnv !== 'test') {
  app.use(morgan('combined'));
}

// ==========================================
// ROTAS PÚBLICAS
// ==========================================

// Health check (sem autenticação)
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Nero Backend is running',
    timestamp: new Date().toISOString(),
    environment: config.nodeEnv,
  });
});

// Rota raiz
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Nero Backend API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      ai: '/api/ai',
      openFinance: '/api/open-finance',
    },
    documentation: 'https://github.com/brunaoperes/gestor_pessoal_ia',
  });
});

// ==========================================
// ROTAS PROTEGIDAS (com API Key)
// ==========================================

// Aplicar autenticação por API Key em todas as rotas /api/*
app.use('/api', apiKeyAuth);

// Rotas de IA
app.use('/api/ai', aiRoutes);

// Rotas de Open Finance (Pluggy)
app.use('/api/open-finance', openFinanceRoutes);

// ==========================================
// ROTA 404
// ==========================================

app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: 'Rota não encontrada',
    path: req.originalUrl,
  });
});

// ==========================================
// TRATAMENTO DE ERROS
// ==========================================

app.use(errorHandler);

// ==========================================
// INICIALIZAÇÃO DO SERVIDOR
// ==========================================

const PORT = config.port;

app.listen(PORT, () => {
  console.log('╔════════════════════════════════════════╗');
  console.log('║     🤖 Nero Backend - IA Server       ║');
  console.log('╠════════════════════════════════════════╣');
  console.log(`║  Ambiente: ${config.nodeEnv.padEnd(28)} ║`);
  console.log(`║  Porta:    ${PORT.toString().padEnd(28)} ║`);
  console.log(`║  URL:      http://localhost:${PORT.toString().padEnd(17)} ║`);
  console.log('╠════════════════════════════════════════╣');
  console.log('║  Endpoints disponíveis:                ║');
  console.log('║  • GET  /health                        ║');
  console.log('║  • POST /api/ai/categorize-transaction ║');
  console.log('║  • POST /api/ai/categorize-batch       ║');
  console.log('║  • POST /api/ai/recommendations        ║');
  console.log('║  • GET  /api/open-finance/connectors   ║');
  console.log('║  • GET  /api/open-finance/connections  ║');
  console.log('╚════════════════════════════════════════╝');

  // Initialize Open Finance schedulers
  console.log('');
  initOpenFinanceSchedulers();
});

// Tratamento de erros não capturados
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

export default app;
