import { openai, defaultChatConfig } from '../config/openai';
import {
  RecommendationRequest,
  RecommendationResponse,
  AIRecommendation,
  Task,
  Transaction,
} from '../models/types';
import { supabaseAdmin } from '../config/supabase';
import { v4 as uuidv4 } from 'uuid';

/**
 * Serviço de Recomendações Personalizadas usando GPT-4
 */
export class RecommendationsService {
  /**
   * Gera recomendações personalizadas para o usuário
   */
  async generateRecommendations(
    request: RecommendationRequest
  ): Promise<RecommendationResponse> {
    const { user_id, context } = request;

    // Buscar dados do usuário se não foram fornecidos
    const userContext = context || (await this.fetchUserContext(user_id));

    // Construir prompt com contexto
    const prompt = this.buildRecommendationPrompt(userContext);

    try {
      const completion = await openai.chat.completions.create({
        ...defaultChatConfig,
        messages: [
          {
            role: 'system',
            content: this.getSystemPrompt(),
          },
          {
            role: 'user',
            content: prompt,
          },
        ],
        max_tokens: 2000,
      });

      const response = completion.choices[0].message.content;
      if (!response) {
        throw new Error('GPT não retornou resposta');
      }

      const parsed = this.parseGPTResponse(response, user_id);

      // Salvar recomendações no banco
      await this.saveRecommendations(parsed.recommendations);

      return parsed;
    } catch (error) {
      console.error('Erro ao gerar recomendações:', error);
      throw new Error('Falha ao gerar recomendações');
    }
  }

  /**
   * Busca contexto do usuário no banco de dados
   */
  private async fetchUserContext(user_id: string) {
    const [tasksResult, transactionsResult] = await Promise.all([
      // Buscar tarefas dos últimos 30 dias
      supabaseAdmin
        .from('tasks')
        .select('*')
        .eq('user_id', user_id)
        .gte('created_at', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString())
        .order('created_at', { ascending: false })
        .limit(50),

      // Buscar transações dos últimos 30 dias
      supabaseAdmin
        .from('transactions')
        .select('*')
        .eq('user_id', user_id)
        .gte('date', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString())
        .order('date', { ascending: false })
        .limit(100),
    ]);

    return {
      tasks: (tasksResult.data as Task[]) || [],
      transactions: (transactionsResult.data as Transaction[]) || [],
    };
  }

  /**
   * Constrói o prompt para gerar recomendações
   */
  private buildRecommendationPrompt(context: {
    tasks?: Task[];
    transactions?: Transaction[];
  }): string {
    const tasksCount = context.tasks?.length || 0;
    const transactionsCount = context.transactions?.length || 0;

    // Estatísticas de tarefas
    const completedTasks = context.tasks?.filter((t) => t.is_completed).length || 0;
    const pendingTasks = tasksCount - completedTasks;
    const overdueTasks =
      context.tasks?.filter(
        (t) =>
          !t.is_completed &&
          t.due_date &&
          new Date(t.due_date) < new Date()
      ).length || 0;

    // Taxa de completude
    const completionRate = tasksCount > 0 ? (completedTasks / tasksCount) * 100 : 0;

    // Estatísticas financeiras
    const totalIncome =
      context.transactions
        ?.filter((t) => t.type === 'income')
        .reduce((sum, t) => sum + t.amount, 0) || 0;

    const totalExpense =
      context.transactions
        ?.filter((t) => t.type === 'expense')
        .reduce((sum, t) => sum + t.amount, 0) || 0;

    const balance = totalIncome - totalExpense;

    // Despesas por categoria
    const expensesByCategory: Record<string, number> = {};
    context.transactions
      ?.filter((t) => t.type === 'expense' && t.category)
      .forEach((t) => {
        expensesByCategory[t.category!] =
          (expensesByCategory[t.category!] || 0) + t.amount;
      });

    const topExpenseCategories = Object.entries(expensesByCategory)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 5)
      .map(([cat, amount]) => `${cat}: R$ ${amount.toFixed(2)}`);

    // Calcular tendências
    const weeklyExpenses = this.calculateWeeklyExpenses(context.transactions || []);
    const spendingTrend = this.calculateTrend(weeklyExpenses);

    // Padrões de comportamento
    const behaviorPatterns = this.analyzeBehaviorPatterns(context);

    return `
Analise o comportamento financeiro e de produtividade do usuário e gere recomendações personalizadas e acionáveis.

**📊 CONTEXTO GERAL:**
Período analisado: Últimos 30 dias
Data atual: ${new Date().toLocaleDateString('pt-BR')}

**✅ PRODUTIVIDADE:**
- Total de Tarefas: ${tasksCount}
- Concluídas: ${completedTasks} (${completionRate.toFixed(1)}% de conclusão)
- Pendentes: ${pendingTasks}
- ⚠️ Atrasadas: ${overdueTasks}${overdueTasks > 0 ? ' 🚨' : ''}
${behaviorPatterns.taskPatterns}

**💰 FINANÇAS:**
- Receitas: R$ ${totalIncome.toFixed(2)}
- Despesas: R$ ${totalExpense.toFixed(2)}
- Saldo Final: R$ ${balance.toFixed(2)} ${balance < 0 ? '⚠️ NEGATIVO' : balance > 0 ? '✅' : ''}
- Tendência de gastos: ${spendingTrend}
${behaviorPatterns.financePatterns}

**🏆 Top 5 Categorias de Despesas:**
${topExpenseCategories.length > 0 ? topExpenseCategories.join('\n') : '• Nenhuma despesa registrada'}

**🎯 ANÁLISE DE PADRÕES:**
${behaviorPatterns.insights}

**📋 INSTRUÇÕES PARA RECOMENDAÇÕES:**

Gere de 3 a 5 recomendações **altamente personalizadas** baseadas nos dados acima:

1. **PRIORIZE EM ORDEM:**
   - Alertas críticos (saldo negativo, muitas tarefas atrasadas) → priority: "high"
   - Oportunidades de melhoria significativa → priority: "medium"
   - Dicas preventivas e otimizações → priority: "low"

2. **TIPOS DE RECOMENDAÇÃO:**
   - **task**: Relacionada a gestão de tarefas e produtividade
   - **financial**: Relacionada a finanças e controle de gastos
   - **productivity**: Relacionada a eficiência e hábitos
   - **alert**: Avisos urgentes que precisam atenção imediata

3. **QUALIDADE:**
   - Seja ESPECÍFICO com números e dados reais
   - Sugira AÇÕES concretas que o usuário pode tomar
   - Use linguagem clara, amigável e motivadora
   - Evite recomendações genéricas

4. **CONFIDENCE SCORE:**
   - Use 0.9-1.0 quando houver dados claros e evidentes
   - Use 0.7-0.9 para recomendações baseadas em padrões observados
   - Use 0.5-0.7 para sugestões preventivas sem evidência forte

**FORMATO DE RESPOSTA:**
Retorne APENAS um objeto JSON válido (sem markdown, sem \`\`\`):

{
  "recommendations": [
    {
      "type": "task|financial|productivity|alert",
      "title": "Título curto e direto (max 60 caracteres)",
      "description": "Descrição detalhada e acionável com números específicos se possível (max 250 caracteres)",
      "priority": "low|medium|high",
      "confidence": 0.85
    }
  ],
  "insights": [
    "Insight 1: Padrão específico observado nos dados",
    "Insight 2: Tendência ou comportamento identificado",
    "Insight 3: Observação relevante sobre o período"
  ]
}
`.trim();
  }

  /**
   * Calcula despesas semanais
   */
  private calculateWeeklyExpenses(transactions: Transaction[]): number[] {
    const weeks = [0, 0, 0, 0]; // últimas 4 semanas
    const now = new Date();

    transactions
      .filter((t) => t.type === 'expense' && t.date)
      .forEach((t) => {
        const transactionDate = new Date(t.date!);
        const diffDays = Math.floor(
          (now.getTime() - transactionDate.getTime()) / (1000 * 60 * 60 * 24)
        );

        if (diffDays < 7) weeks[0] += t.amount;
        else if (diffDays < 14) weeks[1] += t.amount;
        else if (diffDays < 21) weeks[2] += t.amount;
        else if (diffDays < 30) weeks[3] += t.amount;
      });

    return weeks;
  }

  /**
   * Calcula tendência de gastos
   */
  private calculateTrend(weeklyExpenses: number[]): string {
    if (weeklyExpenses.every((w) => w === 0)) return 'Sem dados suficientes';

    const lastWeek = weeklyExpenses[0];
    const previousWeek = weeklyExpenses[1];

    if (previousWeek === 0) return 'Sem comparação disponível';

    const change = ((lastWeek - previousWeek) / previousWeek) * 100;

    if (change > 20) return `📈 Crescimento de ${change.toFixed(1)}% vs semana anterior`;
    if (change < -20) return `📉 Redução de ${Math.abs(change).toFixed(1)}% vs semana anterior`;
    return `➡️ Estável (${change > 0 ? '+' : ''}${change.toFixed(1)}%)`;
  }

  /**
   * Analisa padrões de comportamento
   */
  private analyzeBehaviorPatterns(context: {
    tasks?: Task[];
    transactions?: Transaction[];
  }): { taskPatterns: string; financePatterns: string; insights: string } {
    const taskPatterns: string[] = [];
    const financePatterns: string[] = [];
    const insights: string[] = [];

    // Análise de tarefas
    if (context.tasks && context.tasks.length > 0) {
      const highPriorityTasks = context.tasks.filter((t) => t.priority === 'high').length;
      if (highPriorityTasks > 0) {
        taskPatterns.push(`• ${highPriorityTasks} tarefas de alta prioridade`);
      }

      const aiGeneratedTasks = context.tasks.filter((t) => t.origin === 'ai').length;
      if (aiGeneratedTasks > 0) {
        taskPatterns.push(`• ${aiGeneratedTasks} tarefas geradas por IA`);
      }
    }

    // Análise financeira
    if (context.transactions && context.transactions.length > 0) {
      const avgTransactionValue =
        context.transactions.reduce((sum, t) => sum + t.amount, 0) /
        context.transactions.length;
      financePatterns.push(
        `• Valor médio por transação: R$ ${avgTransactionValue.toFixed(2)}`
      );

      const categorizedPercent =
        (context.transactions.filter((t) => t.category).length /
          context.transactions.length) *
        100;
      financePatterns.push(
        `• ${categorizedPercent.toFixed(0)}% das transações categorizadas`
      );
    }

    // Insights gerais
    if (context.tasks && context.tasks.length > 5) {
      insights.push('• Usuário ativo na gestão de tarefas');
    }
    if (context.transactions && context.transactions.length > 10) {
      insights.push('• Histórico financeiro robusto para análise');
    }

    return {
      taskPatterns: taskPatterns.length > 0 ? taskPatterns.join('\n') : '• Sem dados detalhados',
      financePatterns:
        financePatterns.length > 0 ? financePatterns.join('\n') : '• Sem dados detalhados',
      insights: insights.length > 0 ? insights.join('\n') : '• Sem padrões significativos identificados ainda',
    };
  }

  /**
   * System prompt para o GPT
   */
  private getSystemPrompt(): string {
    return `Você é Nero, um assistente pessoal inteligente especializado em produtividade e finanças pessoais.
Seu objetivo é analisar o comportamento do usuário e gerar recomendações personalizadas, práticas e acionáveis.

Diretrizes:
- Seja proativo mas não alarmista
- Use linguagem clara e amigável
- Priorize ações que o usuário pode tomar imediatamente
- Base suas recomendações nos dados fornecidos
- Seja objetivo e retorne sempre JSON válido sem formatação markdown
- Confidence deve refletir o quão forte é a evidência para a recomendação`;
  }

  /**
   * Parse da resposta do GPT
   */
  private parseGPTResponse(
    response: string,
    user_id: string
  ): RecommendationResponse {
    try {
      const cleanResponse = response
        .replace(/```json\n?/g, '')
        .replace(/```\n?/g, '')
        .trim();

      const parsed = JSON.parse(cleanResponse);

      // Converter para formato do banco
      const recommendations: AIRecommendation[] = (
        parsed.recommendations || []
      ).map((rec: any) => ({
        id: uuidv4(),
        user_id,
        type: rec.type || 'productivity',
        title: rec.title || 'Recomendação',
        description: rec.description || '',
        priority: rec.priority || 'medium',
        confidence: Math.max(0, Math.min(1, rec.confidence || 0.5)),
        is_read: false,
        is_dismissed: false,
        created_at: new Date().toISOString(),
      }));

      return {
        recommendations,
        insights: parsed.insights || [],
      };
    } catch (error) {
      console.error('Erro ao parsear resposta do GPT:', error);
      console.error('Resposta recebida:', response);

      return {
        recommendations: [],
        insights: [],
      };
    }
  }

  /**
   * Salva recomendações no banco de dados
   */
  private async saveRecommendations(recommendations: AIRecommendation[]) {
    if (recommendations.length === 0) return;

    const { error } = await supabaseAdmin
      .from('ai_recommendations')
      .insert(recommendations);

    if (error) {
      console.error('Erro ao salvar recomendações:', error);
      throw new Error('Falha ao salvar recomendações');
    }
  }

  /**
   * Busca recomendações do usuário
   */
  async getUserRecommendations(
    userId: string,
    options?: {
      limit?: number;
      includeRead?: boolean;
      includeDismissed?: boolean;
      type?: 'task' | 'financial' | 'productivity' | 'alert';
    }
  ) {
    let query = supabaseAdmin
      .from('ai_recommendations')
      .select('*')
      .eq('user_id', userId)
      .order('score', { ascending: false })
      .order('created_at', { ascending: false });

    // Filtrar por lidas/não lidas
    if (options?.includeRead === false) {
      query = query.eq('is_read', false);
    }

    // Filtrar por dispensadas
    if (options?.includeDismissed === false) {
      query = query.eq('is_dismissed', false);
    }

    // Filtrar por tipo
    if (options?.type) {
      query = query.eq('type', options.type);
    }

    // Limitar resultados
    if (options?.limit) {
      query = query.limit(options.limit);
    }

    const { data, error } = await query;

    if (error) {
      console.error('Erro ao buscar recomendações:', error);
      throw new Error('Falha ao buscar recomendações');
    }

    return data as AIRecommendation[];
  }

  /**
   * Marca recomendação como lida
   */
  async markAsRead(recommendationId: string, userId: string) {
    const { error } = await supabaseAdmin
      .from('ai_recommendations')
      .update({ is_read: true })
      .eq('id', recommendationId)
      .eq('user_id', userId);

    if (error) {
      console.error('Erro ao marcar recomendação como lida:', error);
      throw new Error('Falha ao atualizar recomendação');
    }

    return true;
  }

  /**
   * Marca recomendação como dispensada
   */
  async dismissRecommendation(recommendationId: string, userId: string) {
    const { error } = await supabaseAdmin
      .from('ai_recommendations')
      .update({
        is_dismissed: true,
        action_taken: 'ignored',
        action_taken_at: new Date().toISOString(),
      })
      .eq('id', recommendationId)
      .eq('user_id', userId);

    if (error) {
      console.error('Erro ao dispensar recomendação:', error);
      throw new Error('Falha ao dispensar recomendação');
    }

    return true;
  }

  /**
   * Aceita uma recomendação
   */
  async acceptRecommendation(recommendationId: string, userId: string) {
    const { error } = await supabaseAdmin
      .from('ai_recommendations')
      .update({
        is_read: true,
        action_taken: 'accepted',
        action_taken_at: new Date().toISOString(),
      })
      .eq('id', recommendationId)
      .eq('user_id', userId);

    if (error) {
      console.error('Erro ao aceitar recomendação:', error);
      throw new Error('Falha ao aceitar recomendação');
    }

    return true;
  }

  /**
   * Marca recomendação como completada
   */
  async completeRecommendation(recommendationId: string, userId: string) {
    const { error } = await supabaseAdmin
      .from('ai_recommendations')
      .update({
        is_read: true,
        action_taken: 'completed',
        action_taken_at: new Date().toISOString(),
      })
      .eq('id', recommendationId)
      .eq('user_id', userId);

    if (error) {
      console.error('Erro ao completar recomendação:', error);
      throw new Error('Falha ao completar recomendação');
    }

    return true;
  }

  /**
   * Rejeita uma recomendação
   */
  async rejectRecommendation(recommendationId: string, userId: string) {
    const { error } = await supabaseAdmin
      .from('ai_recommendations')
      .update({
        is_read: true,
        action_taken: 'rejected',
        action_taken_at: new Date().toISOString(),
      })
      .eq('id', recommendationId)
      .eq('user_id', userId);

    if (error) {
      console.error('Erro ao rejeitar recomendação:', error);
      throw new Error('Falha ao rejeitar recomendação');
    }

    return true;
  }

  /**
   * Obtém estatísticas de recomendações
   */
  async getRecommendationStats(userId: string) {
    const { data, error } = await supabaseAdmin
      .from('ai_recommendations')
      .select('*')
      .eq('user_id', userId);

    if (error) {
      console.error('Erro ao buscar estatísticas:', error);
      throw new Error('Falha ao buscar estatísticas');
    }

    const recommendations = data as AIRecommendation[];

    return {
      total: recommendations.length,
      unread: recommendations.filter((r) => !r.is_read).length,
      dismissed: recommendations.filter((r) => r.is_dismissed).length,
      accepted: recommendations.filter((r) => r.action_taken === 'accepted').length,
      completed: recommendations.filter((r) => r.action_taken === 'completed').length,
      rejected: recommendations.filter((r) => r.action_taken === 'rejected').length,
      byType: {
        task: recommendations.filter((r) => r.type === 'task').length,
        financial: recommendations.filter((r) => r.type === 'financial').length,
        productivity: recommendations.filter((r) => r.type === 'productivity').length,
        alert: recommendations.filter((r) => r.type === 'alert').length,
      },
      byPriority: {
        high: recommendations.filter((r) => r.priority === 'high').length,
        medium: recommendations.filter((r) => r.priority === 'medium').length,
        low: recommendations.filter((r) => r.priority === 'low').length,
      },
    };
  }
}

export default new RecommendationsService();
