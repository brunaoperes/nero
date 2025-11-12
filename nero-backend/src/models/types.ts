// ==========================================
// TIPOS DE TRANSAÇÕES
// ==========================================

export interface Transaction {
  id: string;
  user_id: string;
  amount: number;
  type: 'income' | 'expense';
  category?: string;
  suggested_category?: string;
  category_confidence?: number;
  category_confirmed: boolean;
  description?: string;
  date?: string;
  company_id?: string;
  source?: string;
  external_id?: string;
  metadata?: Record<string, any>;
  created_at: string;
  updated_at: string;
}

export interface TransactionCategorizationRequest {
  description: string;
  amount: number;
  type: 'income' | 'expense';
  user_id: string;
}

export interface TransactionCategorizationResponse {
  category: string;
  confidence: number;
  reasoning: string;
}

// ==========================================
// TIPOS DE TAREFAS
// ==========================================

export interface Task {
  id: string;
  user_id: string;
  title: string;
  description?: string;
  is_completed: boolean;
  completed_at?: string;
  due_date?: string;
  priority?: 'low' | 'medium' | 'high';
  origin?: 'personal' | 'company' | 'ai' | 'recurring';
  company_id?: string;
  recurrence_type?: 'daily' | 'weekly' | 'monthly' | 'yearly';
  metadata?: Record<string, any>;
  created_at: string;
  updated_at: string;
}

// ==========================================
// TIPOS DE RECOMENDAÇÕES IA
// ==========================================

export interface AIRecommendation {
  id: string;
  user_id: string;
  type: 'task' | 'financial' | 'productivity' | 'alert';
  title: string;
  description: string;
  priority: 'low' | 'medium' | 'high';
  confidence: number;
  is_read: boolean;
  is_dismissed: boolean;
  action_taken?: string;
  metadata?: Record<string, any>;
  expires_at?: string;
  created_at: string;
}

export interface RecommendationRequest {
  user_id: string;
  context?: {
    tasks?: Task[];
    transactions?: Transaction[];
    recent_behavior?: UserBehavior[];
  };
}

export interface RecommendationResponse {
  recommendations: AIRecommendation[];
  insights: string[];
}

// ==========================================
// TIPOS DE COMPORTAMENTO
// ==========================================

export interface UserBehavior {
  id: string;
  user_id: string;
  action_type: string;
  action_data?: Record<string, any>;
  timestamp: string;
}

export interface BehaviorAnalysis {
  patterns: Pattern[];
  insights: string[];
  suggestions: string[];
}

export interface Pattern {
  type: string;
  frequency: number;
  description: string;
  confidence: number;
}

// ==========================================
// TIPOS DE RESPOSTA DA API
// ==========================================

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface ApiError {
  success: false;
  error: string;
  statusCode: number;
}
