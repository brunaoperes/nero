@echo off
echo ========================================
echo   Enviando alteracoes para o GitHub
echo ========================================
echo.

cd /d "%~dp0"

git push

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   SUCESSO! Codigo enviado para GitHub
    echo ========================================
    echo.
    echo Acesse: https://github.com/brunaoperes/nero
    echo.
) else (
    echo.
    echo ========================================
    echo   ERRO ao enviar para o GitHub
    echo ========================================
    echo.
)

pause
