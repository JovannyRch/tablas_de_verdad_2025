#!/bin/bash

# Script para regenerar archivos de localización de Flutter
# Uso: ./regenerate_l10n.sh

echo "🧹 Eliminando archivos de localización antiguos..."
rm -f lib/l10n/app_localizations*.dart

echo "🔨 Generando nuevos archivos de localización..."
flutter gen-l10n

if [ $? -eq 0 ]; then
    echo "✅ Archivos de localización regenerados exitosamente"
    echo ""
    echo "📄 Archivos generados:"
    ls -1 lib/l10n/app_localizations*.dart
else
    echo "❌ Error al generar archivos de localización"
    exit 1
fi
