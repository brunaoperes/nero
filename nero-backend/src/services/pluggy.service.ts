import axios, { AxiosInstance, AxiosError } from 'axios';
import { pluggyConfig } from '../config/pluggy';
import {
  PluggyAuthResponse,
  PluggyConnector,
  PluggyItem,
  PluggyAccount,
  PluggyTransaction,
  PluggyCreateItemParams,
  PluggyUpdateItemParams,
} from '../models/pluggy.types';

class PluggyService {
  private apiClient: AxiosInstance;
  private apiKey: string | null = null;
  private apiKeyExpiration: number | null = null;

  constructor() {
    this.apiClient = axios.create({
      baseURL: `${pluggyConfig.baseUrl}`,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Add request interceptor to ensure authentication
    this.apiClient.interceptors.request.use(
      async (config) => {
        await this.ensureAuthenticated();
        if (this.apiKey) {
          config.headers['X-API-KEY'] = this.apiKey;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Add response interceptor for error handling
    this.apiClient.interceptors.response.use(
      (response) => response,
      async (error: AxiosError) => {
        if (error.response?.status === 401) {
          // Token expired, retry authentication
          this.apiKey = null;
          this.apiKeyExpiration = null;
          await this.ensureAuthenticated();

          // Retry the original request
          if (error.config) {
            return this.apiClient.request(error.config);
          }
        }
        return Promise.reject(this.handleError(error));
      }
    );
  }

  /**
   * Ensure we have a valid API key
   */
  private async ensureAuthenticated(): Promise<void> {
    const now = Date.now();

    // If we have a valid API key that hasn't expired, use it
    if (this.apiKey && this.apiKeyExpiration && now < this.apiKeyExpiration) {
      return;
    }

    // Otherwise, authenticate
    await this.authenticate();
  }

  /**
   * Authenticate with Pluggy API and get API key
   */
  private async authenticate(): Promise<void> {
    try {
      console.log('🔵 [PLUGGY] Authenticating...');
      console.log('🔵 [PLUGGY] Client ID:', pluggyConfig.clientId);

      const response = await axios.post<PluggyAuthResponse>(
        `${pluggyConfig.baseUrl}/auth`,
        {
          clientId: pluggyConfig.clientId,
          clientSecret: pluggyConfig.clientSecret,
        }
      );

      this.apiKey = response.data.apiKey;
      // API key is valid for 24 hours, refresh after 23 hours
      this.apiKeyExpiration = Date.now() + (23 * 60 * 60 * 1000);

      console.log('🟢 [PLUGGY] Authentication successful');
      console.log('🟢 [PLUGGY] API Key preview:', this.apiKey.substring(0, 30) + '...');
    } catch (error) {
      console.error('🔴 [PLUGGY] Failed to authenticate:', error);
      throw new Error('Failed to authenticate with Pluggy API');
    }
  }

  /**
   * Get all available connectors (banks)
   */
  async getConnectors(params?: {
    types?: string[];
    countries?: string[];
    name?: string;
  }): Promise<PluggyConnector[]> {
    try {
      const response = await this.apiClient.get<{ results: PluggyConnector[] }>('/connectors', {
        params,
      });
      return response.data.results;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Get a specific connector by ID
   */
  async getConnector(connectorId: number): Promise<PluggyConnector> {
    try {
      const response = await this.apiClient.get<PluggyConnector>(`/connectors/${connectorId}`);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Create a new item (bank connection)
   */
  async createItem(params: PluggyCreateItemParams): Promise<PluggyItem> {
    try {
      const response = await this.apiClient.post<PluggyItem>('/items', params);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Get item by ID
   */
  async getItem(itemId: string): Promise<PluggyItem> {
    try {
      const response = await this.apiClient.get<PluggyItem>(`/items/${itemId}`);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Update item credentials
   */
  async updateItem(itemId: string, params: PluggyUpdateItemParams): Promise<PluggyItem> {
    try {
      const response = await this.apiClient.patch<PluggyItem>(`/items/${itemId}`, params);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Delete an item
   */
  async deleteItem(itemId: string): Promise<void> {
    try {
      await this.apiClient.delete(`/items/${itemId}`);
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Get all accounts for an item
   */
  async getAccounts(itemId: string): Promise<PluggyAccount[]> {
    try {
      const response = await this.apiClient.get<{ results: PluggyAccount[] }>('/accounts', {
        params: { itemId },
      });
      return response.data.results;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Get a specific account by ID
   */
  async getAccount(accountId: string): Promise<PluggyAccount> {
    try {
      const response = await this.apiClient.get<PluggyAccount>(`/accounts/${accountId}`);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Get transactions for an account
   */
  async getTransactions(
    accountId: string,
    params?: {
      from?: string; // YYYY-MM-DD
      to?: string; // YYYY-MM-DD
      pageSize?: number;
      page?: number;
    }
  ): Promise<{ results: PluggyTransaction[]; total: number; totalPages: number }> {
    try {
      const response = await this.apiClient.get<{
        results: PluggyTransaction[];
        total: number;
        totalPages: number;
      }>(`/transactions`, {
        params: {
          accountId,
          ...params,
        },
      });
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Get all transactions for all accounts in an item
   */
  async getAllTransactionsForItem(
    itemId: string,
    params?: {
      from?: string;
      to?: string;
    }
  ): Promise<PluggyTransaction[]> {
    try {
      // First get all accounts
      const accounts = await this.getAccounts(itemId);

      // Then get transactions for each account
      const transactionPromises = accounts.map(account =>
        this.getTransactions(account.id, params)
      );

      const transactionResults = await Promise.all(transactionPromises);

      // Flatten and combine all transactions
      return transactionResults.flatMap(result => result.results);
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Trigger manual sync for an item
   */
  async syncItem(itemId: string): Promise<PluggyItem> {
    try {
      // PATCH to update the item triggers a sync
      const response = await this.apiClient.patch<PluggyItem>(`/items/${itemId}`, {});
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Create a Connect Token for frontend widget
   */
  async createConnectToken(clientUserId?: string): Promise<{ accessToken: string }> {
    try {
      console.log('🔵 [PLUGGY] Creating Connect Token...');
      console.log('🔵 [PLUGGY] Client User ID:', clientUserId);

      // itemOptions as recommended by Pluggy docs
      const payload: any = {};

      if (clientUserId) {
        payload.clientUserId = clientUserId;
      }

      // Add itemOptions to avoid some validation issues
      payload.itemOptions = {
        avoidDuplicates: true,
      };

      console.log('🔵 [PLUGGY] Payload:', JSON.stringify(payload, null, 2));

      const response = await this.apiClient.post<{ accessToken: string }>('/connect_token', payload);

      console.log('🟢 [PLUGGY] Connect Token created successfully');
      console.log('🟢 [PLUGGY] Access Token preview:', response.data.accessToken.substring(0, 30) + '...');
      console.log('🟢 [PLUGGY] Access Token length:', response.data.accessToken.length);

      return response.data;
    } catch (error) {
      console.error('🔴 [PLUGGY] Failed to create Connect Token:', error);
      throw this.handleError(error);
    }
  }

  /**
   * Handle errors from Pluggy API
   */
  private handleError(error: any): Error {
    if (axios.isAxiosError(error)) {
      const axiosError = error as AxiosError<any>;

      if (axiosError.response) {
        const status = axiosError.response.status;
        const data = axiosError.response.data;

        switch (status) {
          case 400:
            return new Error(`Bad Request: ${data.message || 'Invalid parameters'}`);
          case 401:
            return new Error('Unauthorized: Invalid API credentials');
          case 404:
            return new Error('Not Found: Resource does not exist');
          case 429:
            return new Error('Too Many Requests: Rate limit exceeded');
          case 500:
            return new Error('Internal Server Error: Pluggy API is experiencing issues');
          default:
            return new Error(`Pluggy API Error (${status}): ${data.message || 'Unknown error'}`);
        }
      } else if (axiosError.request) {
        return new Error('Network Error: Could not reach Pluggy API');
      }
    }

    return error instanceof Error ? error : new Error('Unknown error occurred');
  }
}

export const pluggyService = new PluggyService();
