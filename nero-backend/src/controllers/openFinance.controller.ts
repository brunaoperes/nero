import { Request, Response } from 'express';
import { openFinanceService } from '../services/openFinance.service';
import { z } from 'zod';

// Validation schemas
const createConnectionSchema = z.object({
  itemId: z.string().min(1, 'Item ID is required'),
});

const syncConnectionSchema = z.object({
  connectionId: z.string().uuid('Invalid connection ID'),
});

const connectorFiltersSchema = z.object({
  types: z.array(z.string()).optional(),
  countries: z.array(z.string()).optional(),
  name: z.string().optional(),
});

export class OpenFinanceController {
  /**
   * GET /api/open-finance/connect-token
   * Create a Pluggy Connect Token for the widget
   */
  async createConnectToken(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      console.log('🟢 [BACKEND] Creating connect token for user:', userId);

      if (!userId) {
        console.log('🔴 [BACKEND] User not authenticated');
        return res.status(401).json({ error: 'User not authenticated' });
      }

      const result = await openFinanceService.createConnectToken(userId);
      console.log('🟢 [BACKEND] Connect token created successfully');
      console.log('🟢 [BACKEND] Token length:', result.accessToken.length);
      console.log('🟢 [BACKEND] Token preview:', result.accessToken.substring(0, 30) + '...');

      res.json({
        success: true,
        data: result,
      });
    } catch (error) {
      console.error('🔴 [BACKEND] Error creating connect token:', error);
      res.status(500).json({
        error: 'Failed to create connect token',
        message: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  /**
   * GET /api/open-finance/connectors
   * Get available bank connectors
   */
  async getConnectors(req: Request, res: Response) {
    try {
      const filters = connectorFiltersSchema.parse(req.query);
      const connectors = await openFinanceService.getAvailableConnectors(filters);

      res.json({
        success: true,
        data: connectors,
        total: connectors.length,
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          error: 'Validation error',
          details: error.errors,
        });
      }

      console.error('Error fetching connectors:', error);
      res.status(500).json({
        error: 'Failed to fetch connectors',
        message: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  /**
   * POST /api/open-finance/connections
   * Save a new bank connection after user connects via widget
   */
  async createConnection(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) {
        return res.status(401).json({ error: 'User not authenticated' });
      }

      const { itemId } = createConnectionSchema.parse(req.body);

      const connection = await openFinanceService.saveBankConnection(userId, itemId);

      res.status(201).json({
        success: true,
        data: connection,
        message: 'Bank connection created successfully',
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          error: 'Validation error',
          details: error.errors,
        });
      }

      console.error('Error creating connection:', error);
      res.status(500).json({
        error: 'Failed to create connection',
        message: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  /**
   * GET /api/open-finance/connections
   * Get all bank connections for the user
   */
  async getConnections(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) {
        return res.status(401).json({ error: 'User not authenticated' });
      }

      const connections = await openFinanceService.getUserBankConnections(userId);

      res.json({
        success: true,
        data: connections,
        total: connections.length,
      });
    } catch (error) {
      console.error('Error fetching connections:', error);
      res.status(500).json({
        error: 'Failed to fetch connections',
        message: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  /**
   * POST /api/open-finance/connections/:connectionId/sync
   * Manually sync a bank connection
   */
  async syncConnection(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) {
        return res.status(401).json({ error: 'User not authenticated' });
      }

      const { connectionId } = req.params;

      const result = await openFinanceService.syncBankConnection(userId, connectionId);

      res.json({
        success: true,
        data: result,
        message: `Synced ${result.accounts} accounts and ${result.transactions} transactions`,
      });
    } catch (error) {
      console.error('Error syncing connection:', error);
      res.status(500).json({
        error: 'Failed to sync connection',
        message: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  /**
   * DELETE /api/open-finance/connections/:connectionId
   * Delete a bank connection
   */
  async deleteConnection(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) {
        return res.status(401).json({ error: 'User not authenticated' });
      }

      const { connectionId } = req.params;

      await openFinanceService.deleteBankConnection(userId, connectionId);

      res.json({
        success: true,
        message: 'Bank connection deleted successfully',
      });
    } catch (error) {
      console.error('Error deleting connection:', error);
      res.status(500).json({
        error: 'Failed to delete connection',
        message: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  /**
   * GET /api/open-finance/accounts
   * Get all bank accounts for the user
   */
  async getAccounts(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) {
        return res.status(401).json({ error: 'User not authenticated' });
      }

      const accounts = await openFinanceService.getUserBankAccounts(userId);

      res.json({
        success: true,
        data: accounts,
        total: accounts.length,
      });
    } catch (error) {
      console.error('Error fetching accounts:', error);
      res.status(500).json({
        error: 'Failed to fetch accounts',
        message: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }
}

export const openFinanceController = new OpenFinanceController();
