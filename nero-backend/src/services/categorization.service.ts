import { openai, defaultChatConfig } from '../config/openai';
import {
  TransactionCategorizationRequest,
  TransactionCategorizationResponse,
} from '../models/types';

/**
 * Serviço de Categorização Automática de Transações usando GPT-4
 */
export class CategorizationService {
  // Categorias disponíveis
  private readonly EXPENSE_CATEGORIES = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Saúde',
    'Educação',
    'Lazer',
    'Vestuário',
    'Outros',
  ];

  private readonly INCOME_CATEGORIES = [
    'Salário',
    'Freelance',
    'Investimentos',
    'Vendas',
    'Outros',
  ];

  /**
   * Categoriza uma transação usando GPT-4
   */
  async categorizeTransaction(
    request: TransactionCategorizationRequest
  ): Promise<TransactionCategorizationResponse> {
    const categories =
      request.type === 'expense'
        ? this.EXPENSE_CATEGORIES
        : this.INCOME_CATEGORIES;

    const prompt = this.buildCategorizationPrompt(request, categories);

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
        temperature: 0.3, // Mais determinístico para categorização
      });

      const response = completion.choices[0].message.content;
      if (!response) {
        throw new Error('GPT não retornou resposta');
      }

      return this.parseGPTResponse(response);
    } catch (error) {
      console.error('Erro ao categorizar transação:', error);
      throw new Error('Falha na categorização automática');
    }
  }

  /**
   * Categoriza múltiplas transações em lote
   */
  async categorizeBatch(
    requests: TransactionCategorizationRequest[]
  ): Promise<TransactionCategorizationResponse[]> {
    const promises = requests.map((req) => this.categorizeTransaction(req));
    return Promise.all(promises);
  }

  /**
   * Constrói o prompt para categorização
   */
  private buildCategorizationPrompt(
    request: TransactionCategorizationRequest,
    categories: string[]
  ): string {
    return `
Analise a seguinte transação e categorize-a:

**Tipo:** ${request.type === 'income' ? 'Receita' : 'Despesa'}
**Valor:** R$ ${request.amount.toFixed(2)}
**Descrição:** ${request.description || 'Sem descrição'}

**Categorias disponíveis:**
${categories.map((cat, index) => `${index + 1}. ${cat}`).join('\n')}

Retorne APENAS um objeto JSON no seguinte formato (sem markdown):
{
  "category": "nome_da_categoria",
  "confidence": 0.95,
  "reasoning": "breve explicação da escolha"
}

Critérios:
- confidence deve ser entre 0 e 1
- category deve ser EXATAMENTE uma das categorias listadas
- reasoning deve ter no máximo 100 caracteres
`.trim();
  }

  /**
   * System prompt para o GPT
   */
  private getSystemPrompt(): string {
    return `Você é um assistente especializado em categorização financeira.
Sua tarefa é analisar transações e atribuir a categoria mais apropriada com alta precisão.
Seja objetivo e retorne sempre JSON válido sem formatação markdown.
Use seu conhecimento sobre padrões de gastos brasileiros para melhorar a precisão.`;
  }

  /**
   * Parse da resposta do GPT
   */
  private parseGPTResponse(response: string): TransactionCategorizationResponse {
    try {
      // Remover possíveis markdown code blocks
      const cleanResponse = response
        .replace(/```json\n?/g, '')
        .replace(/```\n?/g, '')
        .trim();

      const parsed = JSON.parse(cleanResponse);

      // Validar estrutura
      if (!parsed.category || typeof parsed.confidence !== 'number') {
        throw new Error('Resposta inválida do GPT');
      }

      // Garantir que confidence está entre 0 e 1
      parsed.confidence = Math.max(0, Math.min(1, parsed.confidence));

      return {
        category: parsed.category,
        confidence: parsed.confidence,
        reasoning: parsed.reasoning || 'Categorizado automaticamente',
      };
    } catch (error) {
      console.error('Erro ao parsear resposta do GPT:', error);
      console.error('Resposta recebida:', response);

      // Fallback para categoria "Outros" com baixa confiança
      return {
        category: 'Outros',
        confidence: 0.3,
        reasoning: 'Categorização automática falhou, usando categoria padrão',
      };
    }
  }
}

export default new CategorizationService();
