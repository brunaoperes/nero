@echo off
echo ========================================
echo  NERO - Verificacao de Setup
echo ========================================
echo.

echo [1/6] Verificando Flutter...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [X] ERRO: Flutter nao encontrado!
    echo     Instale: https://flutter.dev/docs/get-started/install/windows
    echo.
) else (
    echo [OK] Flutter encontrado!
    flutter --version
    echo.
)

echo [2/6] Verificando arquivo .env...
if exist .env (
    echo [OK] Arquivo .env existe!
    findstr /C:"SUPABASE_URL" .env >nul
    if errorlevel 1 (
        echo [X] ERRO: SUPABASE_URL nao encontrada no .env!
    ) else (
        echo [OK] Credenciais do Supabase configuradas!
    )
    echo.
) else (
    echo [X] ERRO: Arquivo .env nao encontrado!
    echo.
)

echo [3/6] Verificando pubspec.yaml...
if exist pubspec.yaml (
    echo [OK] pubspec.yaml encontrado!
    echo.
) else (
    echo [X] ERRO: pubspec.yaml nao encontrado!
    echo.
)

echo [4/6] Verificando estrutura de pastas...
if exist lib (
    echo [OK] Pasta lib/ existe
) else (
    echo [X] ERRO: Pasta lib/ nao existe
)
if exist assets (
    echo [OK] Pasta assets/ existe
) else (
    echo [X] ERRO: Pasta assets/ nao existe
)
echo.

echo [5/6] Verificando SQL Schema...
if exist SUPABASE_SCHEMA.sql (
    echo [OK] SUPABASE_SCHEMA.sql encontrado!
    echo     IMPORTANTE: Voce JA executou este SQL no Supabase?
    echo     Se NAO, abra: https://supabase.com/dashboard/project/yyxrgfwezgffncxuhkvo/sql
    echo.
) else (
    echo [X] ERRO: SUPABASE_SCHEMA.sql nao encontrado!
    echo.
)

echo [6/6] Verificando dependencias...
if exist pubspec.lock (
    echo [OK] Dependencias ja foram instaladas antes!
    echo.
) else (
    echo [!] Dependencias nao instaladas ainda.
    echo     Execute: flutter pub get
    echo.
)

echo ========================================
echo  Resumo
echo ========================================
echo.

flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ ] Flutter instalado
) else (
    echo [X] Flutter instalado
)

if exist .env (
    echo [X] Arquivo .env configurado
) else (
    echo [ ] Arquivo .env configurado
)

if exist pubspec.lock (
    echo [X] Dependencias instaladas
) else (
    echo [ ] Dependencias instaladas
)

echo [ ] SQL executado no Supabase (verifique manualmente!)
echo [ ] App rodando com sucesso

echo.
echo ========================================
echo  Proximos Passos
echo ========================================
echo.
echo 1. Se o Flutter nao estiver instalado, instale primeiro
echo 2. Execute: flutter pub get
echo 3. Execute o SQL no Supabase (copie SUPABASE_SCHEMA.sql)
echo 4. Execute: flutter pub run build_runner build --delete-conflicting-outputs
echo 5. Execute: flutter run -d chrome
echo.
pause
