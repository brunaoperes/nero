# 🖥️ Configurar Projeto no Outro Computador

## 📋 Pré-requisitos
- Git instalado
- Flutter instalado
- Conta GitHub configurada

---

## 🚀 Passo a Passo (Primeira Vez)

### 1. Abrir Terminal/PowerShell
```bash
cd C:\caminho\onde\quer\salvar
```

### 2. Clonar o Repositório
```bash
git clone https://github.com/brunaoperes/nero.git
```

Vai pedir autenticação:
- **Username**: brunaoperes
- **Password**: (use token ou login web)

### 3. Configurar Git Credential Manager (Recomendado)
```bash
cd nero
git config --global credential.helper manager
```

Na próxima vez que fizer `git pull` ou `git push`, vai abrir uma janela de login.
Depois disso, não precisa mais autenticar!

### 4. Instalar Dependências Flutter
```bash
cd nero  # Entrar na pasta do app Flutter
flutter pub get
```

### 5. Rodar o App
```bash
flutter run
```

---

## 🔄 Atualizar Código (Toda Vez)

Sempre que quiser pegar as últimas mudanças:

```bash
cd C:\caminho\do\projeto\nero
git pull
```

**Pronto!** Código atualizado com todas as mudanças do outro computador.

---

## 📤 Enviar Mudanças do Outro Computador

Se fizer alterações no outro PC:

### Opção 1: Manualmente
```bash
git add .
git commit -m "Descrição das mudanças"
git push
```

### Opção 2: Usar o script (se copiar)
```bash
.\git-push.bat
```

---

## 🔄 Workflow Completo Entre Computadores

### No Computador Principal (onde usa Claude):
1. Claude modifica código ✏️
2. Claude cria commit 📝
3. Você roda `git-push.bat` 🖱️
4. Código vai pro GitHub ☁️

### No Outro Computador:
1. Você roda `git pull` 📥
2. Código atualizado! ✅
3. Trabalha normalmente 💻
4. Quando terminar, faz commit e push 📤

---

## 🆘 Resolução de Problemas

### Erro de autenticação:
```bash
git config --global credential.helper manager
git pull  # Vai abrir janela de login
```

### Conflitos ao fazer pull:
```bash
git stash          # Salva mudanças locais
git pull           # Puxa do GitHub
git stash pop      # Restaura mudanças locais
```

### Ver status:
```bash
git status
```

### Ver histórico:
```bash
git log --oneline -10
```

---

## 📝 Resumo Rápido

| Ação | Comando |
|------|---------|
| Clonar pela primeira vez | `git clone https://github.com/brunaoperes/nero.git` |
| Pegar atualizações | `git pull` |
| Ver o que mudou | `git status` |
| Enviar mudanças | `git add . && git commit -m "msg" && git push` |

---

## 🔐 Segurança

- ✅ Repositório é **PRIVADO**
- ✅ Apenas você tem acesso
- ✅ Credenciais salvas de forma segura no Windows
- ✅ Sem tokens expostos

---

**Pronto!** Agora você pode trabalhar de qualquer computador! 🎉
