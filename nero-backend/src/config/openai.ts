import OpenAI from 'openai';
import { config } from './env';

// Inicializar cliente OpenAI
export const openai = new OpenAI({
  apiKey: config.openai.apiKey,
});

// Configurações padrão para chamadas
export const defaultChatConfig = {
  model: config.openai.model as 'gpt-4-turbo-preview',
  temperature: 0.7,
  max_tokens: 1000,
};

export default openai;
