// Pluggy API Types

export interface PluggyAuthResponse {
  apiKey: string;
}

export interface PluggyConnector {
  id: number;
  name: string;
  institutionUrl: string;
  imageUrl: string;
  primaryColor: string;
  type: 'PERSONAL_BANK' | 'BUSINESS_BANK' | 'INVESTMENT';
  country: string;
  credentials: PluggyCredential[];
  hasMFA: boolean;
  health: {
    status: 'ONLINE' | 'OFFLINE' | 'UNSTABLE';
    stage: string | null;
  };
}

export interface PluggyCredential {
  label: string;
  name: string;
  type: 'text' | 'password' | 'number';
  placeholder?: string;
  validation?: string;
  validationMessage?: string;
  optional?: boolean;
}

export interface PluggyItem {
  id: string;
  connector: {
    id: number;
    name: string;
    institutionUrl: string;
    imageUrl: string;
    primaryColor: string;
  };
  createdAt: string;
  updatedAt: string;
  status: 'UPDATED' | 'UPDATING' | 'LOGIN_ERROR' | 'OUTDATED';
  executionStatus: 'SUCCESS' | 'ERROR' | 'PARTIAL_SUCCESS' | 'MERGING';
  lastUpdatedAt: string;
  webhookUrl?: string;
  error?: {
    code: string;
    message: string;
  };
  consecutiveFailedLoginAttempts: number;
  userAction?: string | null;
  clientUserId?: string;
}

export interface PluggyAccount {
  id: string;
  type: 'BANK' | 'CREDIT';
  subtype: 'CHECKING_ACCOUNT' | 'SAVINGS_ACCOUNT' | 'CREDIT_CARD';
  number: string;
  name: string;
  balance: number;
  currencyCode: string;
  itemId: string;
  creditData?: {
    level: string;
    brand: string;
    balanceCloseDate: string;
    balanceDueDate: string;
    availableCreditLimit: number;
    balanceForeignCurrency: number;
    minimumPayment: number;
    creditLimit: number;
  };
}

export interface PluggyTransaction {
  id: string;
  description: string;
  descriptionRaw: string | null;
  currencyCode: string;
  amount: number;
  date: string;
  category: string | null;
  categoryId: string | null;
  balance: number;
  accountId: string;
  providerCode: string | null;
  status: 'PENDING' | 'POSTED';
  type: 'DEBIT' | 'CREDIT';
  paymentData?: {
    payer?: string;
    payee?: string;
    paymentMethod?: string;
    referenceNumber?: string;
    reason?: string;
  };
  merchant?: {
    name: string;
    businessName: string;
    cnpj: string;
    cnae: string;
    category: string;
  };
}

export interface PluggyCreateItemParams {
  connectorId: number;
  credentials: Record<string, string>;
  webhookUrl?: string;
  clientUserId?: string;
}

export interface PluggyUpdateItemParams {
  credentials?: Record<string, string>;
  webhookUrl?: string;
}

export interface PluggyWebhook {
  event: 'item/created' | 'item/updated' | 'item/deleted' | 'item/error' | 'item/waiting_user_input';
  data: {
    itemId: string;
    error?: {
      code: string;
      message: string;
    };
  };
}

// Database models for storing Pluggy data
export interface BankConnection {
  id: string;
  user_id: string;
  pluggy_item_id: string;
  connector_id: number;
  connector_name: string;
  connector_image_url: string;
  status: 'UPDATED' | 'UPDATING' | 'LOGIN_ERROR' | 'OUTDATED';
  last_sync_at: string;
  created_at: string;
  updated_at: string;
  error_message?: string;
}

export interface BankAccount {
  id: string;
  connection_id: string;
  pluggy_account_id: string;
  account_type: 'BANK' | 'CREDIT';
  account_subtype: string;
  account_number: string;
  account_name: string;
  balance: number;
  currency_code: string;
  credit_limit?: number;
  created_at: string;
  updated_at: string;
}

export interface SyncedTransaction {
  id: string;
  account_id: string;
  pluggy_transaction_id: string;
  description: string;
  amount: number;
  date: string;
  type: 'income' | 'expense';
  category_id?: string;
  category_suggestion?: string;
  category_confidence?: number;
  status: 'pending' | 'posted';
  synced_at: string;
  created_at: string;
}
