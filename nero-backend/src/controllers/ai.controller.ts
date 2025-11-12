import { Request, Response } from 'express';
import categorizationService from '../services/categorization.service';
import recommendationsService from '../services/recommendations.service';
import { ApiResponse } from '../models/types';

/**
 * Controlador para endpoints de IA
 */
export class AIController {
  /**
   * POST /api/ai/categorize-transaction
   * Categoriza uma transação usando GPT-4
   */
  async categorizeTransaction(req: Request, res: Response) {
    try {
      const { description, amount, type, user_id } = req.body;

      // Validação
      if (!description || !amount || !type || !user_id) {
        return res.status(400).json({
          success: false,
          error: 'Campos obrigatórios: description, amount, type, user_id',
        } as ApiResponse);
      }

      if (type !== 'income' && type !== 'expense') {
        return res.status(400).json({
          success: false,
          error: 'type deve ser "income" ou "expense"',
        } as ApiResponse);
      }

      const result = await categorizationService.categorizeTransaction({
        description,
        amount: parseFloat(amount),
        type,
        user_id,
      });

      return res.json({
        success: true,
        data: result,
      } as ApiResponse);
    } catch (error: any) {
      console.error('Erro em categorizeTransaction:', error);
      return res.status(500).json({
        success: false,
        error: error.message || 'Erro ao categorizar transação',
      } as ApiResponse);
    }
  }

  /**
   * POST /api/ai/categorize-batch
   * Categoriza múltiplas transações em lote
   */
  async categorizeBatch(req: Request, res: Response) {
    try {
      const { transactions } = req.body;

      if (!Array.isArray(transactions) || transactions.length === 0) {
        return res.status(400).json({
          success: false,
          error: 'transactions deve ser um array não vazio',
        } as ApiResponse);
      }

      const results = await categorizationService.categorizeBatch(transactions);

      return res.json({
        success: true,
        data: results,
      } as ApiResponse);
    } catch (error: any) {
      console.error('Erro em categorizeBatch:', error);
      return res.status(500).json({
        success: false,
        error: error.message || 'Erro ao categorizar transações em lote',
      } as ApiResponse);
    }
  }

  /**
   * POST /api/ai/recommendations
   * Gera recomendações personalizadas
   */
  async generateRecommendations(req: Request, res: Response) {
    try {
      const { user_id, context } = req.body;

      if (!user_id) {
        return res.status(400).json({
          success: false,
          error: 'user_id é obrigatório',
        } as ApiResponse);
      }

      const result = await recommendationsService.generateRecommendations({
        user_id,
        context,
      });

      return res.json({
        success: true,
        data: result,
      } as ApiResponse);
    } catch (error: any) {
      console.error('Erro em generateRecommendations:', error);
      return res.status(500).json({
        success: false,
        error: error.message || 'Erro ao gerar recomendações',
      } as ApiResponse);
    }
  }

  /**
   * GET /api/ai/health
   * Health check
   */
  async healthCheck(req: Request, res: Response) {
    return res.json({
      success: true,
      data: {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        services: {
          openai: 'connected',
          supabase: 'connected',
        },
      },
    } as ApiResponse);
  }

  /**
   * GET /api/ai/recommendations/:userId
   * Busca recomendações do usuário
   */
  async getUserRecommendations(req: Request, res: Response) {
    try {
      const { userId } = req.params;
      const { limit, includeRead, includeDismissed, type } = req.query;

      if (!userId) {
        return res.status(400).json({
          success: false,
          error: 'userId é obrigatório',
        } as ApiResponse);
      }

      const recommendations = await recommendationsService.getUserRecommendations(
        userId,
        {
          limit: limit ? parseInt(limit as string) : undefined,
          includeRead: includeRead === 'true',
          includeDismissed: includeDismissed === 'true',
          type: type as any,
        }
      );

      return res.json({
        success: true,
        data: recommendations,
      } as ApiResponse);
    } catch (error: any) {
      console.error('Erro em getUserRecommendations:', error);
      return res.status(500).json({
        success: false,
        error: error.message || 'Erro ao buscar recomendações',
      } as ApiResponse);
    }
  }

  /**
   * PATCH /api/ai/recommendations/:id/read
   * Marca recomendação como lida
   */
  async markRecommendationAsRead(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { user_id } = req.body;

      if (!id || !user_id) {
        return res.status(400).json({
          success: false,
          error: 'id e user_id são obrigatórios',
        } as ApiResponse);
      }

      await recommendationsService.markAsRead(id, user_id);

      return res.json({
        success: true,
        data: { message: 'Recomendação marcada como lida' },
      } as ApiResponse);
    } catch (error: any) {
      console.error('Erro em markRecommendationAsRead:', error);
      return res.status(500).json({
        success: false,
        error: error.message || 'Erro ao marcar como lida',
      } as ApiResponse);
    }
  }

  /**
   * PATCH /api/ai/recommendations/:id/dismiss
   * Dispensa uma recomendação
   */
  async dismissRecommendation(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { user_id } = req.body;

      if (!id || !user_id) {
        return res.status(400).json({
          success: false,
          error: 'id e user_id são obrigatórios',
        } as ApiResponse);
      }

      await recommendationsService.dismissRecommendation(id, user_id);

      return res.json({
        success: true,
        data: { message: 'Recomendação dispensada' },
      } as ApiResponse);
    } catch (error: any) {
      console.error('Erro em dismissRecommendation:', error);
      return res.status(500).json({
        success: false,
        error: error.message || 'Erro ao dispensar recomendação',
      } as ApiResponse);
    }
  }

  /**
   * PATCH /api/ai/recommendations/:id/accept
   * Aceita uma recomendação
   */
  async acceptRecommendation(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { user_id } = req.body;

      if (!id || !user_id) {
        return res.status(400).json({
          success: false,
          error: 'id e user_id são obrigatórios',
        } as ApiResponse);
      }

      await recommendationsService.acceptRecommendation(id, user_id);

      return res.json({
        success: true,
        data: { message: 'Recomendação aceita' },
      } as ApiResponse);
    } catch (error: any) {
      console.error('Erro em acceptRecommendation:', error);
      return res.status(500).json({
        success: false,
        error: error.message || 'Erro ao aceitar recomendação',
      } as ApiResponse);
    }
  }

  /**
   * PATCH /api/ai/recommendations/:id/complete
   * Marca recomendação como completada
   */
  async completeRecommendation(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { user_id } = req.body;

      if (!id || !user_id) {
        return res.status(400).json({
          success: false,
          error: 'id e user_id são obrigatórios',
        } as ApiResponse);
      }

      await recommendationsService.completeRecommendation(id, user_id);

      return res.json({
        success: true,
        data: { message: 'Recomendação completada' },
      } as ApiResponse);
    } catch (error: any) {
      console.error('Erro em completeRecommendation:', error);
      return res.status(500).json({
        success: false,
        error: error.message || 'Erro ao completar recomendação',
      } as ApiResponse);
    }
  }

  /**
   * PATCH /api/ai/recommendations/:id/reject
   * Rejeita uma recomendação
   */
  async rejectRecommendation(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { user_id } = req.body;

      if (!id || !user_id) {
        return res.status(400).json({
          success: false,
          error: 'id e user_id são obrigatórios',
        } as ApiResponse);
      }

      await recommendationsService.rejectRecommendation(id, user_id);

      return res.json({
        success: true,
        data: { message: 'Recomendação rejeitada' },
      } as ApiResponse);
    } catch (error: any) {
      console.error('Erro em rejectRecommendation:', error);
      return res.status(500).json({
        success: false,
        error: error.message || 'Erro ao rejeitar recomendação',
      } as ApiResponse);
    }
  }

  /**
   * GET /api/ai/recommendations/:userId/stats
   * Obtém estatísticas de recomendações
   */
  async getRecommendationStats(req: Request, res: Response) {
    try {
      const { userId } = req.params;

      if (!userId) {
        return res.status(400).json({
          success: false,
          error: 'userId é obrigatório',
        } as ApiResponse);
      }

      const stats = await recommendationsService.getRecommendationStats(userId);

      return res.json({
        success: true,
        data: stats,
      } as ApiResponse);
    } catch (error: any) {
      console.error('Erro em getRecommendationStats:', error);
      return res.status(500).json({
        success: false,
        error: error.message || 'Erro ao buscar estatísticas',
      } as ApiResponse);
    }
  }
}

export default new AIController();
