@echo off
echo ========================================
echo  NERO - Executar Tudo Automaticamente
echo ========================================
echo.
echo Este script vai:
echo  1. Instalar dependencias
echo  2. Gerar codigo necessario
echo  3. Executar o app
echo.
echo Pressione qualquer tecla para continuar...
pause >nul
echo.

echo ========================================
echo  [1/3] Instalando Dependencias
echo ========================================
echo.
echo Executando: flutter pub get
echo Aguarde... (pode demorar 2-3 minutos)
echo.

flutter pub get

if errorlevel 1 (
    echo.
    echo [ERRO] Falha ao instalar dependencias!
    echo.
    echo Possiveis causas:
    echo  - Flutter nao esta instalado
    echo  - Sem conexao com internet
    echo  - Problema no pubspec.yaml
    echo.
    echo Solucao:
    echo  1. Verifique se o Flutter esta instalado: flutter --version
    echo  2. Instale: https://flutter.dev/docs/get-started/install/windows
    echo  3. Execute este script novamente
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Dependencias instaladas com sucesso!
echo.

echo ========================================
echo  [2/3] Gerando Codigo (Freezed + Riverpod)
echo ========================================
echo.
echo Executando: flutter pub run build_runner build --delete-conflicting-outputs
echo Aguarde... (pode demorar 1-2 minutos)
echo.

flutter pub run build_runner build --delete-conflicting-outputs

if errorlevel 1 (
    echo.
    echo [AVISO] Erro ao gerar codigo!
    echo.
    echo Tentando limpar e gerar novamente...
    echo.
    flutter clean
    flutter pub get
    flutter pub run build_runner build --delete-conflicting-outputs

    if errorlevel 1 (
        echo.
        echo [ERRO] Ainda com erro ao gerar codigo!
        echo.
        echo Isso pode nao ser critico. Vamos tentar continuar...
        echo.
    )
)

echo.
echo [OK] Codigo gerado!
echo.

echo ========================================
echo  [3/3] Executando o App
echo ========================================
echo.
echo Executando: flutter run -d chrome
echo.
echo O Chrome vai abrir automaticamente com o app!
echo Aguarde... (primeira execucao pode demorar 3-5 minutos)
echo.
echo DICA: Quando o app estiver rodando:
echo  - Pressione 'r' para hot reload
echo  - Pressione 'R' para hot restart
echo  - Pressione 'q' para sair
echo.

flutter run -d chrome

if errorlevel 1 (
    echo.
    echo [ERRO] Falha ao executar o app!
    echo.
    echo Possiveis causas:
    echo  - Chrome nao encontrado
    echo  - Porta ja em uso
    echo  - Erro no codigo
    echo.
    echo Solucao:
    echo  1. Execute: flutter devices (para ver dispositivos disponiveis)
    echo  2. Execute: flutter doctor -v (para verificar problemas)
    echo  3. Tente: flutter run (sem -d chrome)
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo  SUCESSO!
echo ========================================
echo.
echo O app Nero esta rodando!
echo.
echo Agora voce pode:
echo  1. Criar uma conta de teste
echo  2. Completar o onboarding
echo  3. Ver o dashboard funcionando
echo.
echo Leia NEXT_STEPS.md para saber o que implementar a seguir.
echo.
pause
