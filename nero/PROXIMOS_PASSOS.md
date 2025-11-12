# ⚡ PRÓXIMOS PASSOS - Configure e Execute o Nero

Suas credenciais do Supabase já foram configuradas! ✅

## ✅ O Que Já Está Pronto

- ✅ Projeto Supabase criado (`nero-app`)
- ✅ Arquivo `.env` configurado com suas credenciais
- ✅ URL e Anon Key já inseridos

## 🎯 Próximos Passos (Siga na Ordem)

### 1️⃣ Criar o Banco de Dados no Supabase (5 minutos)

**IMPORTANTE**: O banco ainda está vazio. Você precisa criar as tabelas.

1. Abra o Supabase: https://supabase.com/dashboard/project/yyxrgfwezgffncxuhkvo

2. No menu lateral, clique em **SQL Editor**

3. Clique no botão **New query**

4. Abra o arquivo `SUPABASE_SCHEMA.sql` deste projeto (está na pasta raiz)

5. Copie **TODO** o conteúdo do arquivo (Ctrl+A, Ctrl+C)

6. Cole no SQL Editor do Supabase (Ctrl+V)

7. Clique em **Run** (ou pressione Ctrl+Enter)

8. Aguarde a execução (pode demorar alguns segundos)

9. **Resultado esperado**: Mensagem verde "Success. No rows returned"

### 2️⃣ Verificar se as Tabelas Foram Criadas (2 minutos)

1. No Supabase, clique em **Table Editor** no menu lateral

2. Você deve ver 8 tabelas:
   - ✅ users
   - ✅ companies
   - ✅ tasks
   - ✅ meetings
   - ✅ transactions
   - ✅ ai_recommendations
   - ✅ user_behavior
   - ✅ audit_logs

**Se não aparecer nenhuma tabela**: Volte ao passo 1 e execute o SQL novamente.

### 3️⃣ Executar o Setup do Flutter (5 minutos)

Abra o **PowerShell ou CMD** e execute:

```bash
cd C:\Users\awgco\gestor_pessoal_ia\nero
.\setup.bat
```

O script vai:
- ✅ Verificar se o Flutter está instalado
- ✅ Instalar as dependências do projeto
- ✅ Gerar o código necessário (Freezed, Riverpod)
- ✅ Verificar se há erros

**Se o Flutter não estiver instalado**:
- Baixe aqui: https://flutter.dev/docs/get-started/install/windows
- Siga o guia de instalação
- Depois execute o `setup.bat` novamente

### 4️⃣ Executar o Aplicativo (2 minutos)

Após o setup concluir, execute:

```bash
flutter run -d chrome
```

**O que vai acontecer:**
- O Chrome vai abrir automaticamente
- O app Nero vai carregar (pode demorar 2-5 min na primeira vez)
- Você verá a tela de login!

### 5️⃣ Testar o App (5 minutos)

No navegador que abriu:

1. **Criar conta**:
   - Clique em "Não tem conta? Cadastre-se"
   - Preencha: Nome, Email, Senha (mínimo 6 caracteres)
   - Clique em "Criar Conta"

2. **Confirmar email** (se ativado):
   - Verifique sua caixa de entrada
   - Clique no link de confirmação
   - Volte para o app e faça login

3. **Completar onboarding**:
   - Siga as 4 etapas
   - Configure seus horários
   - Informe se tem empresa
   - Ative/desative modo empreendedorismo
   - Clique em "Finalizar"

4. **Ver dashboard**:
   - Você deve ver o dashboard com:
     - Card de sugestão da IA
     - Widget de foco
     - Lista de tarefas
     - Resumo financeiro

**Se tudo funcionou: PARABÉNS! 🎉 Seu app está rodando!**

## 🐛 Se Algo Der Errado

### Erro: "Flutter command not found"
```bash
# Instale o Flutter
https://flutter.dev/docs/get-started/install/windows
```

### Erro: "pub get failed"
```bash
flutter clean
flutter pub get
```

### Erro ao gerar código
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erro: "relation does not exist"
→ Você esqueceu de executar o SQL no Supabase (volte ao passo 1)

### Erro: "Invalid token" ou "JWT expired"
→ Verifique se o `.env` tem as credenciais corretas (já está configurado)

### Mais problemas?
→ Abra o arquivo `TROUBLESHOOTING.md` e procure sua mensagem de erro

## 📚 Após Tudo Funcionar

Quando o app estiver rodando perfeitamente, leia:

1. **[NEXT_STEPS.md](NEXT_STEPS.md)** - Para ver o que implementar a seguir
2. **[ARCHITECTURE.md](ARCHITECTURE.md)** - Para entender a arquitetura
3. **[QUICK_START.md](QUICK_START.md)** - Para comandos úteis

## 🎯 Roadmap Sugerido (Após Setup)

### Semana 1-2: Módulo de Tarefas
- Listar todas as tarefas
- Criar, editar, deletar tarefas
- Filtros e busca
- Tarefas recorrentes

### Semana 3-4: Módulo de Empresas
- Gestão de empresas
- Dashboard por empresa
- Timeline de ações

### Semana 5-6: Módulo de Finanças
- Transações manuais
- Categorização
- Gráficos
- Relatórios

### Semana 7-8: Integração com IA
- Backend API
- ChatGPT integration
- Análise de comportamento
- Sugestões inteligentes

## 💡 Dicas

1. **Hot Reload**: Quando o app estiver rodando, salve arquivos (Ctrl+S) e veja mudanças instantâneas
2. **Debug**: Use `print()` para debugar ou coloque breakpoints no VS Code
3. **Logs**: Execute `flutter logs` em outro terminal para ver logs detalhados
4. **Limpar**: Se algo estranho acontecer, execute `flutter clean` e tente novamente

## 🎨 Personalização

Quer mudar cores ou textos?

- **Cores**: Edite `lib/core/config/app_colors.dart`
- **Textos**: Edite os arquivos em `lib/features/*/presentation/pages/`
- **Widgets**: Edite os arquivos em `lib/shared/widgets/`

Todas as mudanças aparecem instantaneamente com Hot Reload (pressione `r` no terminal)!

## 🆘 Precisa de Ajuda?

- **Discord**: [criar servidor]
- **GitHub Issues**: [criar repositório]
- **Email**: dev@nero.app

## ✅ Checklist Rápido

Marque conforme for completando:

- [ ] Executei o SQL no Supabase
- [ ] Verifiquei que as 8 tabelas foram criadas
- [ ] Executei `.\setup.bat` sem erros
- [ ] Executei `flutter run -d chrome`
- [ ] O app abriu no navegador
- [ ] Criei uma conta de teste
- [ ] Completei o onboarding
- [ ] Vi o dashboard funcionando
- [ ] Li o NEXT_STEPS.md

**Todos marcados?** Você está pronto para desenvolver! 🚀

---

**Suas Credenciais (já configuradas no .env)**:
- URL: https://yyxrgfwezgffncxuhkvo.supabase.co
- Senha do Banco: qkrCqPcgvpksyFqe (salve em local seguro!)

**Próximo arquivo para ler**: [NEXT_STEPS.md](NEXT_STEPS.md)
