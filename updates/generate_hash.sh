#!/bin/bash
# Script para gerar o hash SHA-256 do APK

if [ -z "$1" ]; then
    echo "Uso: ./generate_hash.sh caminho/para/app.apk"
    exit 1
fi

APK_FILE="$1"

if [ ! -f "$APK_FILE" ]; then
    echo "Erro: Arquivo '$APK_FILE' não encontrado!"
    exit 1
fi

echo "Gerando hash SHA-256 para: $APK_FILE"
echo ""

# Linux/Mac
if command -v sha256sum &> /dev/null; then
    sha256sum "$APK_FILE" | awk '{print $1}'
# Mac alternativo
elif command -v shasum &> /dev/null; then
    shasum -a 256 "$APK_FILE" | awk '{print $1}'
else
    echo "Erro: Comando sha256sum ou shasum não encontrado!"
    exit 1
fi
