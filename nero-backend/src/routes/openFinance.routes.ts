import { Router } from 'express';
import { openFinanceController } from '../controllers/openFinance.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = Router();

// All routes require authentication
router.use(authMiddleware);

/**
 * @route   GET /api/open-finance/connect-token
 * @desc    Create a Pluggy Connect Token for widget
 * @access  Private
 */
router.get('/connect-token', (req, res) =>
  openFinanceController.createConnectToken(req, res)
);

/**
 * @route   GET /api/open-finance/connectors
 * @desc    Get available bank connectors
 * @access  Private
 */
router.get('/connectors', (req, res) =>
  openFinanceController.getConnectors(req, res)
);

/**
 * @route   POST /api/open-finance/connections
 * @desc    Create a new bank connection
 * @access  Private
 */
router.post('/connections', (req, res) =>
  openFinanceController.createConnection(req, res)
);

/**
 * @route   GET /api/open-finance/connections
 * @desc    Get all bank connections for user
 * @access  Private
 */
router.get('/connections', (req, res) =>
  openFinanceController.getConnections(req, res)
);

/**
 * @route   POST /api/open-finance/connections/:connectionId/sync
 * @desc    Manually sync a bank connection
 * @access  Private
 */
router.post('/connections/:connectionId/sync', (req, res) =>
  openFinanceController.syncConnection(req, res)
);

/**
 * @route   DELETE /api/open-finance/connections/:connectionId
 * @desc    Delete a bank connection
 * @access  Private
 */
router.delete('/connections/:connectionId', (req, res) =>
  openFinanceController.deleteConnection(req, res)
);

/**
 * @route   GET /api/open-finance/accounts
 * @desc    Get all bank accounts for user
 * @access  Private
 */
router.get('/accounts', (req, res) =>
  openFinanceController.getAccounts(req, res)
);

export default router;
