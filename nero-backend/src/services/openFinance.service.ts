import { supabase } from '../config/supabase';
import { pluggyService } from './pluggy.service';
import { aiCategorizationService } from './categorization.service';
import {
  BankConnection,
  BankAccount,
  SyncedTransaction,
  PluggyItem,
  PluggyAccount,
  PluggyTransaction,
} from '../models/pluggy.types';

class OpenFinanceService {
  /**
   * Create a Connect Token for the Pluggy widget
   */
  async createConnectToken(userId: string): Promise<{ accessToken: string }> {
    try {
      const result = await pluggyService.createConnectToken(userId);
      return result;
    } catch (error) {
      console.error('Error creating connect token:', error);
      throw new Error('Failed to create connect token');
    }
  }

  /**
   * Get all available banks/connectors
   */
  async getAvailableConnectors(filters?: {
    types?: string[];
    countries?: string[];
    name?: string;
  }) {
    try {
      const connectors = await pluggyService.getConnectors(filters);
      return connectors;
    } catch (error) {
      console.error('Error fetching connectors:', error);
      throw new Error('Failed to fetch available banks');
    }
  }

  /**
   * Save a new bank connection after user connects via Pluggy widget
   */
  async saveBankConnection(userId: string, itemId: string): Promise<BankConnection> {
    try {
      // Get item details from Pluggy
      const item = await pluggyService.getItem(itemId);

      // Check if connection already exists
      const { data: existing } = await supabase
        .from('bank_connections')
        .select('*')
        .eq('user_id', userId)
        .eq('pluggy_item_id', itemId)
        .single();

      if (existing) {
        // Update existing connection
        const { data, error } = await supabase
          .from('bank_connections')
          .update({
            status: item.status,
            last_sync_at: item.lastUpdatedAt,
            updated_at: new Date().toISOString(),
            error_message: item.error?.message || null,
          })
          .eq('id', existing.id)
          .select()
          .single();

        if (error) throw error;
        return data;
      }

      // Create new connection
      const { data, error } = await supabase
        .from('bank_connections')
        .insert({
          user_id: userId,
          pluggy_item_id: itemId,
          connector_id: item.connector.id,
          connector_name: item.connector.name,
          connector_image_url: item.connector.imageUrl,
          status: item.status,
          last_sync_at: item.lastUpdatedAt,
        })
        .select()
        .single();

      if (error) throw error;

      // Sync accounts and transactions
      await this.syncBankConnection(userId, data.id);

      return data;
    } catch (error) {
      console.error('Error saving bank connection:', error);
      throw new Error('Failed to save bank connection');
    }
  }

  /**
   * Get all bank connections for a user
   */
  async getUserBankConnections(userId: string): Promise<BankConnection[]> {
    try {
      const { data, error } = await supabase
        .from('bank_connections')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error fetching bank connections:', error);
      throw new Error('Failed to fetch bank connections');
    }
  }

  /**
   * Sync a bank connection - fetch accounts and transactions
   */
  async syncBankConnection(userId: string, connectionId: string): Promise<{
    accounts: number;
    transactions: number;
  }> {
    try {
      // Get connection details
      const { data: connection, error: connError } = await supabase
        .from('bank_connections')
        .select('*')
        .eq('id', connectionId)
        .eq('user_id', userId)
        .single();

      if (connError || !connection) {
        throw new Error('Bank connection not found');
      }

      // Trigger sync on Pluggy
      await pluggyService.syncItem(connection.pluggy_item_id);

      // Wait a bit for Pluggy to process
      await new Promise(resolve => setTimeout(resolve, 2000));

      // Fetch accounts from Pluggy
      const pluggyAccounts = await pluggyService.getAccounts(connection.pluggy_item_id);

      // Save accounts to database
      let accountsSaved = 0;
      for (const pluggyAccount of pluggyAccounts) {
        await this.saveBankAccount(connectionId, pluggyAccount);
        accountsSaved++;
      }

      // Fetch transactions from last 90 days
      const fromDate = new Date();
      fromDate.setDate(fromDate.getDate() - 90);

      const transactions = await pluggyService.getAllTransactionsForItem(
        connection.pluggy_item_id,
        {
          from: fromDate.toISOString().split('T')[0],
          to: new Date().toISOString().split('T')[0],
        }
      );

      // Save transactions
      let transactionsSaved = 0;
      for (const transaction of transactions) {
        await this.saveTransaction(userId, transaction);
        transactionsSaved++;
      }

      // Update connection sync time
      await supabase
        .from('bank_connections')
        .update({
          last_sync_at: new Date().toISOString(),
          status: 'UPDATED',
          updated_at: new Date().toISOString(),
        })
        .eq('id', connectionId);

      return {
        accounts: accountsSaved,
        transactions: transactionsSaved,
      };
    } catch (error) {
      console.error('Error syncing bank connection:', error);

      // Update connection with error
      await supabase
        .from('bank_connections')
        .update({
          status: 'LOGIN_ERROR',
          error_message: error instanceof Error ? error.message : 'Sync failed',
          updated_at: new Date().toISOString(),
        })
        .eq('id', connectionId);

      throw new Error('Failed to sync bank connection');
    }
  }

  /**
   * Save or update a bank account
   */
  private async saveBankAccount(
    connectionId: string,
    pluggyAccount: PluggyAccount
  ): Promise<BankAccount> {
    try {
      // Check if account exists
      const { data: existing } = await supabase
        .from('bank_accounts')
        .select('*')
        .eq('pluggy_account_id', pluggyAccount.id)
        .single();

      if (existing) {
        // Update existing
        const { data, error } = await supabase
          .from('bank_accounts')
          .update({
            balance: pluggyAccount.balance,
            credit_limit: pluggyAccount.creditData?.creditLimit,
            updated_at: new Date().toISOString(),
          })
          .eq('id', existing.id)
          .select()
          .single();

        if (error) throw error;
        return data;
      }

      // Create new
      const { data, error } = await supabase
        .from('bank_accounts')
        .insert({
          connection_id: connectionId,
          pluggy_account_id: pluggyAccount.id,
          account_type: pluggyAccount.type,
          account_subtype: pluggyAccount.subtype,
          account_number: pluggyAccount.number,
          account_name: pluggyAccount.name,
          balance: pluggyAccount.balance,
          currency_code: pluggyAccount.currencyCode,
          credit_limit: pluggyAccount.creditData?.creditLimit,
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error saving bank account:', error);
      throw error;
    }
  }

  /**
   * Save a transaction and auto-categorize it
   */
  private async saveTransaction(
    userId: string,
    pluggyTransaction: PluggyTransaction
  ): Promise<void> {
    try {
      // Check if transaction already exists
      const { data: existing } = await supabase
        .from('synced_transactions')
        .select('id')
        .eq('pluggy_transaction_id', pluggyTransaction.id)
        .single();

      if (existing) {
        return; // Transaction already synced
      }

      // Get account_id from bank_accounts
      const { data: account } = await supabase
        .from('bank_accounts')
        .select('id, connection_id')
        .eq('pluggy_account_id', pluggyTransaction.accountId)
        .single();

      if (!account) {
        console.warn(`Account not found for transaction ${pluggyTransaction.id}`);
        return;
      }

      // Auto-categorize using AI
      let categoryId: string | undefined;
      let categorySuggestion: string | undefined;
      let categoryConfidence: number | undefined;

      try {
        const categorization = await aiCategorizationService.categorizeTransaction(
          userId,
          pluggyTransaction.description
        );

        if (categorization && categorization.confidence >= 0.6) {
          categoryId = categorization.categoryId;
          categorySuggestion = categorization.categoryName;
          categoryConfidence = categorization.confidence;
        }
      } catch (error) {
        console.error('Error auto-categorizing transaction:', error);
        // Continue without categorization
      }

      // Determine type (income or expense)
      const type = pluggyTransaction.type === 'CREDIT' ? 'income' : 'expense';

      // Save to synced_transactions table
      const { error: syncError } = await supabase.from('synced_transactions').insert({
        account_id: account.id,
        pluggy_transaction_id: pluggyTransaction.id,
        description: pluggyTransaction.description,
        amount: Math.abs(pluggyTransaction.amount),
        date: pluggyTransaction.date,
        type,
        category_id: categoryId,
        category_suggestion: categorySuggestion,
        category_confidence: categoryConfidence,
        status: pluggyTransaction.status.toLowerCase(),
        synced_at: new Date().toISOString(),
      });

      if (syncError) throw syncError;

      // Also save to main transactions table if categorized
      if (categoryId) {
        await supabase.from('transactions').insert({
          user_id: userId,
          description: pluggyTransaction.description,
          amount: Math.abs(pluggyTransaction.amount),
          type,
          category_id: categoryId,
          date: pluggyTransaction.date,
          origin: 'open_finance',
        });
      }
    } catch (error) {
      console.error('Error saving transaction:', error);
      // Don't throw - continue processing other transactions
    }
  }

  /**
   * Delete a bank connection
   */
  async deleteBankConnection(userId: string, connectionId: string): Promise<void> {
    try {
      const { data: connection } = await supabase
        .from('bank_connections')
        .select('pluggy_item_id')
        .eq('id', connectionId)
        .eq('user_id', userId)
        .single();

      if (!connection) {
        throw new Error('Bank connection not found');
      }

      // Delete from Pluggy
      await pluggyService.deleteItem(connection.pluggy_item_id);

      // Delete from database (cascade will handle accounts and transactions)
      const { error } = await supabase
        .from('bank_connections')
        .delete()
        .eq('id', connectionId);

      if (error) throw error;
    } catch (error) {
      console.error('Error deleting bank connection:', error);
      throw new Error('Failed to delete bank connection');
    }
  }

  /**
   * Get all accounts for a user
   */
  async getUserBankAccounts(userId: string): Promise<BankAccount[]> {
    try {
      const { data, error } = await supabase
        .from('bank_accounts')
        .select(`
          *,
          connection:bank_connections!inner(user_id)
        `)
        .eq('connection.user_id', userId);

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error fetching bank accounts:', error);
      throw new Error('Failed to fetch bank accounts');
    }
  }
}

export const openFinanceService = new OpenFinanceService();
