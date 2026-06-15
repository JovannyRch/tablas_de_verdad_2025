#!/usr/bin/env bash

# ==========================
# Flutter Runner
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
  "🚀 Flutter Runner\nTablas de Verdad"

PACKAGE="com.jovannyrch.tablasdeverdad"
OUTPUT_DIR="build/app/outputs/bundle/release"

# Acción
ACTION=$(gum choose \
  "▶️  Run app" \
  "📦 Build AppBundle (Play Console)")

echo ""
gum style --foreground 10 "✔ Package: $PACKAGE"
echo ""

if [[ "$ACTION" == *"Run"* ]]; then
  CMD="flutter run"

  gum style --foreground 14 "🧾 Comando a ejecutar:"
  gum style --foreground 250 "$CMD"
  echo ""

  gum confirm "¿Ejecutar este comando?" || exit 0

  gum spin --spinner dot --title "Ejecutando app..." -- $CMD

else
  # Leer versión actual del pubspec.yaml
  CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
  VERSION_NAME=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
  MAJOR=$(echo "$VERSION_NAME" | cut -d'.' -f1)
  MINOR=$(echo "$VERSION_NAME" | cut -d'.' -f2)
  PATCH=$(echo "$VERSION_NAME" | cut -d'.' -f3)

  echo ""
  gum style --foreground 14 "📦 Versión actual:"
  gum style --foreground 250 "  $CURRENT_VERSION"
  echo ""

  BUMP=$(gum choose \
    "patch  ($MAJOR.$MINOR.$PATCH → $MAJOR.$MINOR.$((PATCH + 1)))" \
    "minor  ($MAJOR.$MINOR.$PATCH → $MAJOR.$((MINOR + 1)).0)" \
    "major  ($MAJOR.$MINOR.$PATCH → $((MAJOR + 1)).0.0)" \
    "no incrementar" \
    --header "¿Incrementar versión?")

  [[ -z "$BUMP" ]] && exit 0

  if [[ "$BUMP" == no* ]]; then
    NEW_VERSION="$CURRENT_VERSION"
  else
    if [[ "$BUMP" == patch* ]]; then
      NEW_MAJOR=$MAJOR; NEW_MINOR=$MINOR; NEW_PATCH=$((PATCH + 1))
    elif [[ "$BUMP" == minor* ]]; then
      NEW_MAJOR=$MAJOR; NEW_MINOR=$((MINOR + 1)); NEW_PATCH=0
    else
      NEW_MAJOR=$((MAJOR + 1)); NEW_MINOR=0; NEW_PATCH=0
    fi

    NEW_BUILD=$((NEW_MAJOR * 10000 + NEW_MINOR * 1000 + NEW_PATCH))
    NEW_VERSION="$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH+$NEW_BUILD"

    gum style --foreground 10 "✔ Nueva versión: $NEW_VERSION"
    echo ""

    gum confirm "¿Actualizar pubspec.yaml a $NEW_VERSION?" || exit 0

    sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
    gum style --foreground 10 "✅ pubspec.yaml actualizado"
    echo ""
  fi

  CMD="flutter build appbundle"

  gum style --foreground 14 "🧾 Comando a ejecutar:"
  gum style --foreground 250 "$CMD"
  echo ""

  gum confirm "¿Generar AppBundle?" || exit 0

  gum spin --spinner dot --title "Generando AppBundle $NEW_VERSION..." -- $CMD

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
