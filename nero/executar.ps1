# ========================================
# NERO - Script PowerShell de Execução
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  NERO - Executar Tudo Automaticamente" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Este script vai:" -ForegroundColor Yellow
Write-Host "  1. Instalar dependencias" -ForegroundColor White
Write-Host "  2. Gerar codigo necessario" -ForegroundColor White
Write-Host "  3. Executar o app no Chrome" -ForegroundColor White
Write-Host ""

Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""

# ========================================
# [1/3] Instalar Dependencias
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  [1/3] Instalando Dependencias" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Executando: flutter pub get" -ForegroundColor Yellow
Write-Host "Aguarde... (pode demorar 2-3 minutos)" -ForegroundColor Gray
Write-Host ""

try {
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw "Erro ao instalar dependencias"
    }
    Write-Host ""
    Write-Host "[OK] Dependencias instaladas com sucesso!" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host ""
    Write-Host "[ERRO] Falha ao instalar dependencias!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possiveis causas:" -ForegroundColor Yellow
    Write-Host "  - Flutter nao esta instalado" -ForegroundColor White
    Write-Host "  - Sem conexao com internet" -ForegroundColor White
    Write-Host "  - Problema no pubspec.yaml" -ForegroundColor White
    Write-Host ""
    Write-Host "Solucao:" -ForegroundColor Yellow
    Write-Host "  1. Verifique: flutter --version" -ForegroundColor White
    Write-Host "  2. Instale: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor White
    Write-Host ""
    pause
    exit 1
}

# ========================================
# [2/3] Gerar Codigo
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  [2/3] Gerando Codigo (Freezed + Riverpod)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Executando: flutter pub run build_runner build --delete-conflicting-outputs" -ForegroundColor Yellow
Write-Host "Aguarde... (pode demorar 1-2 minutos)" -ForegroundColor Gray
Write-Host ""

try {
    flutter pub run build_runner build --delete-conflicting-outputs
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "[AVISO] Erro ao gerar codigo!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Tentando limpar e gerar novamente..." -ForegroundColor Yellow
        Write-Host ""

        flutter clean
        flutter pub get
        flutter pub run build_runner build --delete-conflicting-outputs

        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "[AVISO] Ainda com erro, mas vamos continuar..." -ForegroundColor Yellow
            Write-Host ""
        }
    }
    Write-Host ""
    Write-Host "[OK] Codigo gerado!" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host ""
    Write-Host "[AVISO] Erro ao gerar codigo, mas vamos continuar..." -ForegroundColor Yellow
    Write-Host ""
}

# ========================================
# [3/3] Executar App
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  [3/3] Executando o App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Executando: flutter run -d chrome" -ForegroundColor Yellow
Write-Host ""
Write-Host "O Chrome vai abrir automaticamente com o app!" -ForegroundColor Green
Write-Host "Aguarde... (primeira execucao pode demorar 3-5 minutos)" -ForegroundColor Gray
Write-Host ""
Write-Host "DICA: Quando o app estiver rodando:" -ForegroundColor Yellow
Write-Host "  - Pressione 'r' para hot reload" -ForegroundColor White
Write-Host "  - Pressione 'R' para hot restart" -ForegroundColor White
Write-Host "  - Pressione 'q' para sair" -ForegroundColor White
Write-Host ""

flutter run -d chrome

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERRO] Falha ao executar o app!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possiveis causas:" -ForegroundColor Yellow
    Write-Host "  - Chrome nao encontrado" -ForegroundColor White
    Write-Host "  - Porta ja em uso" -ForegroundColor White
    Write-Host "  - Erro no codigo" -ForegroundColor White
    Write-Host ""
    Write-Host "Solucao:" -ForegroundColor Yellow
    Write-Host "  1. Execute: flutter devices" -ForegroundColor White
    Write-Host "  2. Execute: flutter doctor -v" -ForegroundColor White
    Write-Host "  3. Tente: flutter run" -ForegroundColor White
    Write-Host ""
    pause
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  SUCESSO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "O app Nero esta rodando!" -ForegroundColor Green
Write-Host ""
Write-Host "Agora voce pode:" -ForegroundColor Yellow
Write-Host "  1. Criar uma conta de teste" -ForegroundColor White
Write-Host "  2. Completar o onboarding" -ForegroundColor White
Write-Host "  3. Ver o dashboard funcionando" -ForegroundColor White
Write-Host ""
Write-Host "Leia NEXT_STEPS.md para saber o que implementar a seguir." -ForegroundColor Cyan
Write-Host ""
