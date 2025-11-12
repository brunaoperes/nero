@echo off
echo ========================================
echo  NERO - Setup Automatico
echo ========================================
echo.

echo [1/5] Verificando instalacao do Flutter...
flutter --version
if errorlevel 1 (
    echo ERRO: Flutter nao encontrado!
    echo Instale o Flutter em: https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
)
echo OK - Flutter encontrado!
echo.

echo [2/5] Instalando dependencias...
flutter pub get
if errorlevel 1 (
    echo ERRO ao instalar dependencias!
    pause
    exit /b 1
)
echo OK - Dependencias instaladas!
echo.

echo [3/5] Gerando codigo (Freezed + Riverpod)...
flutter pub run build_runner build --delete-conflicting-outputs
if errorlevel 1 (
    echo ERRO ao gerar codigo!
    echo Tentando limpar e gerar novamente...
    flutter clean
    flutter pub get
    flutter pub run build_runner build --delete-conflicting-outputs
    if errorlevel 1 (
        echo ERRO: Nao foi possivel gerar o codigo!
        pause
        exit /b 1
    )
)
echo OK - Codigo gerado!
echo.

echo [4/5] Verificando erros no codigo...
flutter analyze
echo.

echo [5/5] Criando arquivo .env...
if not exist .env (
    copy .env.example .env
    echo Arquivo .env criado! Configure suas credenciais antes de executar o app.
) else (
    echo Arquivo .env ja existe.
)
echo.

echo ========================================
echo  Setup Concluido!
echo ========================================
echo.
echo Proximos passos:
echo 1. Configure o arquivo .env com suas credenciais do Supabase
echo 2. Execute: flutter run -d chrome
echo.
echo Consulte SETUP.md para mais detalhes.
echo.
pause
