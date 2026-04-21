#!/usr/bin/env bash

# ==========================
# Flutter Device Launcher
# macOS + gum
# ==========================

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
  "📱 Flutter Device Launcher\nTablas de Verdad"

# Detectar dispositivos físicos conectados (excluye emuladores y la línea header)
PHYSICAL=$(adb devices 2>/dev/null \
  | grep -v "^List" \
  | grep "device$" \
  | grep -v "emulator" \
  | awk '{print $1}')

# Detectar AVDs disponibles
AVDS=$(emulator -list-avds 2>/dev/null)

# Construir lista de opciones
OPTIONS=()

while IFS= read -r serial; do
  [[ -z "$serial" ]] && continue
  MODEL=$(adb -s "$serial" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
  OPTIONS+=("📱 $MODEL ($serial)")
done <<< "$PHYSICAL"

while IFS= read -r avd; do
  [[ -z "$avd" ]] && continue
  OPTIONS+=("🤖 Emulador: $avd")
done <<< "$AVDS"

if [[ ${#OPTIONS[@]} -eq 0 ]]; then
  gum style --foreground 1 "❌ No hay dispositivos ni emuladores disponibles."
  gum style --foreground 250 "Conecta un dispositivo o crea un emulador en Android Studio."
  exit 1
fi

# Seleccionar dispositivo
SELECTED=$(printf '%s\n' "${OPTIONS[@]}" | gum choose --header "Selecciona el dispositivo:")

[[ -z "$SELECTED" ]] && exit 0

# Seleccionar flavor
LANGUAGE=$(gum choose \
  "🇲🇽 Español (es)" \
  "🇺🇸 English (en)" \
  --header "Selecciona el idioma:")

[[ -z "$LANGUAGE" ]] && exit 0

if [[ "$LANGUAGE" == *"es"* ]]; then
  FLAVOR="es"
else
  FLAVOR="en"
fi

echo ""
gum style --foreground 10 "✔ Dispositivo: $SELECTED"
gum style --foreground 10 "✔ Flavor:      $FLAVOR"
echo ""

# Determinar si es emulador o físico y actuar en consecuencia
if [[ "$SELECTED" == 🤖* ]]; then
  AVD=$(echo "$SELECTED" | sed 's/🤖 Emulador: //')

  gum confirm "¿Iniciar emulador y correr la app?" || exit 0

  RUNNING=$(adb devices | grep emulator | grep -v "offline")

  if [[ -z "$RUNNING" ]]; then
    gum style --foreground 14 "🚀 Iniciando emulador..."
    emulator -avd "$AVD" -no-snapshot-load &> /dev/null &

    gum spin --spinner dot --title "Esperando que el emulador arranque..." -- \
      adb wait-for-device

    gum spin --spinner dot --title "Esperando que el sistema esté listo..." -- \
      bash -c 'until [[ "$(adb shell getprop sys.boot_completed 2>/dev/null)" == "1" ]]; do sleep 2; done'

    gum style --foreground 10 "✅ Emulador listo"
  else
    gum style --foreground 10 "✅ Emulador ya estaba corriendo"
  fi

  DEVICE_FLAG=""
else
  # Extraer serial del dispositivo físico
  SERIAL=$(echo "$SELECTED" | sed 's/.*(\(.*\))/\1/')

  gum confirm "¿Correr la app en el dispositivo?" || exit 0

  DEVICE_FLAG="-d $SERIAL"
fi

echo ""

CMD="flutter run $DEVICE_FLAG --flavor $FLAVOR --dart-define=FLAVOR=$FLAVOR"
gum style --foreground 14 "🧾 Ejecutando:"
gum style --foreground 250 "$CMD"
echo ""

eval $CMD
