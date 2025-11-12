import { Router } from 'express';
import aiController from '../controllers/ai.controller';

const router = Router();

// Health check
router.get('/health', aiController.healthCheck.bind(aiController));

// Categorização de transações
router.post(
  '/categorize-transaction',
  aiController.categorizeTransaction.bind(aiController)
);

// Categorização em lote
router.post(
  '/categorize-batch',
  aiController.categorizeBatch.bind(aiController)
);

// ==========================================
// RECOMENDAÇÕES DE IA
// ==========================================

// Gerar recomendações personalizadas
router.post(
  '/recommendations',
  aiController.generateRecommendations.bind(aiController)
);

// Buscar recomendações do usuário
router.get(
  '/recommendations/:userId',
  aiController.getUserRecommendations.bind(aiController)
);

// Estatísticas de recomendações
router.get(
  '/recommendations/:userId/stats',
  aiController.getRecommendationStats.bind(aiController)
);

// Marcar como lida
router.patch(
  '/recommendations/:id/read',
  aiController.markRecommendationAsRead.bind(aiController)
);

// Dispensar recomendação
router.patch(
  '/recommendations/:id/dismiss',
  aiController.dismissRecommendation.bind(aiController)
);

// Aceitar recomendação
router.patch(
  '/recommendations/:id/accept',
  aiController.acceptRecommendation.bind(aiController)
);

// Completar recomendação
router.patch(
  '/recommendations/:id/complete',
  aiController.completeRecommendation.bind(aiController)
);

// Rejeitar recomendação
router.patch(
  '/recommendations/:id/reject',
  aiController.rejectRecommendation.bind(aiController)
);

export default router;
