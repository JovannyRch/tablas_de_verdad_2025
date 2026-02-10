#!/usr/bin/env bash

# ==========================
# Flutter Flavor Runner Pro
# macOS + gum
# ==========================

# Verificar gum
if ! command -v gum &> /dev/null; then
  echo "❌ gum no está instalado."
  echo "👉 Instálalo desde: https://github.com/charmbracelet/gum"
  exit 1
fi

clear

gum style \
  --border normal \
  --margin "1 2" \
  --padding "1 2" \
  --border-foreground 212 \
  "🚀 Flutter Flavor Runner\nTablas de Verdad"

# Idioma
LANGUAGE=$(gum choose \
  "🇲🇽 Español (es)" \
  "🇺🇸 English (en)")

if [[ "$LANGUAGE" == *"es"* ]]; then
  FLAVOR="es"
  PACKAGE="com.jovannyrch.tablasdeverdad"
  OUTPUT_DIR="build/app/outputs/bundle/esRelease"
else
  FLAVOR="en"
  PACKAGE="com.jovannyrch.tablasdeverdad.en"
  OUTPUT_DIR="build/app/outputs/bundle/enRelease"
fi

# Acción
ACTION=$(gum choose \
  "▶️  Run app" \
  "📦 Build AppBundle (Play Console)")

echo ""
gum style --foreground 10 "✔ Flavor: $FLAVOR"
gum style --foreground 10 "✔ Package: $PACKAGE"
echo ""

if [[ "$ACTION" == *"Run"* ]]; then
  CMD="flutter run --flavor $FLAVOR"

  gum style --foreground 14 "🧾 Comando a ejecutar:"
  gum style --foreground 250 "$CMD"
  echo ""

  gum confirm "¿Ejecutar este comando?" || exit 0

  gum spin --spinner dot --title "Ejecutando app..." -- $CMD

else
  CMD="flutter build appbundle --flavor $FLAVOR --dart-define=FLAVOR=$FLAVOR"

  gum style --foreground 14 "🧾 Comando ejecutado:"
  gum style --foreground 250 "$CMD"
  echo ""

  gum confirm "¿Generar AppBundle?" || exit 0

  gum spin --spinner dot --title "Generando AppBundle..." -- $CMD

  echo ""
  gum style --foreground 10 "✅ AppBundle generado"

  # Abrir carpeta en Finder
  if [[ -d "$OUTPUT_DIR" ]]; then
    echo ""
    gum style --foreground 14 "📂 Carpeta de salida:"
    gum style --foreground 250 "$OUTPUT_DIR"

    if gum confirm "¿Abrir carpeta en Finder?"; then
      open "$OUTPUT_DIR"
    fi
  else
    gum style --foreground 1 "⚠️ No se encontró la carpeta de salida"
  fi
fi

echo ""
gum style --foreground 212 "🎉 Flujo de publicación listo"
