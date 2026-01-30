# 📚 Guía para Agregar un Nuevo Idioma

Esta guía documenta el proceso completo para agregar soporte de un nuevo idioma a la aplicación Tablas de Verdad.

## 🎯 Pasos Generales

### 1. Crear el archivo de traducciones ARB

**Ubicación:** `lib/l10n/app_[codigo].arb`

Ejemplo para italiano: `lib/l10n/app_it.arb`

```json
{
  "@@locale": "it",
  "appTitle": "Traduzione del título",
  "truthTable": "Traduzione"
  // ... copiar todas las claves del archivo app_es.arb o app_en.arb
}
```

**Claves importantes a traducir:**

- `appTitle`, `truthTable`, `expression`, `result`
- `tautology`, `contradiction`, `contingency`
- `negation`, `conjunction`, `disjunction`, `conditional`, `biconditional`
- `xor`, `nand`, `nor`, `anticonditional`
- Todos los mensajes de la UI (premium, settings, library, etc.)

### 2. Crear el recurso Android strings.xml

**Ubicación:** `android/app/src/main/res/values-[codigo]/strings.xml`

Ejemplo para italiano: `android/app/src/main/res/values-it/strings.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Nome App Tradotto</string>
</resources>
```

### 3. Actualizar operator.dart

**Archivo:** `lib/class/operator.dart`

**Agregar método privado para el nuevo idioma:**

```dart
String _get[Idioma]Name(AppLocalizations localizations) {
  switch (value) {
    case OperatorType.negation:
      return localizations.negation;
    case OperatorType.conjunction:
      return localizations.conjunction;
    // ... etc para todos los operadores
    case OperatorType.tautology:
      return localizations.tautology;
    case OperatorType.contradiction:
      return localizations.contradiction;
    default:
      return 'Unknown';
  }
}
```

**Actualizar el switch en getLocalizedName():**

```dart
String getLocalizedName(Locale locale, AppLocalizations localizations) {
  switch (locale.languageCode) {
    case 'es':
      return _getSpanishName(localizations);
    case '[codigo]':  // Agregar nuevo caso
      return _get[Idioma]Name(localizations);
    // ... otros casos
    default:
      return _getEnglishName(localizations);
  }
}
```

### 4. Actualizar generate_pdf.dart

**Archivo:** `lib/utils/generate_pdf.dart`

**Actualizar función getType():**

```dart
String getType(String locale, String type) {
  switch (locale) {
    case 'es':
      // ... casos existentes
    case '[codigo]':
      switch (type) {
        case 'tautology': return 'Traducción';
        case 'contradiction': return 'Traducción';
        case 'contingency': return 'Traducción';
        default: return 'Unknown';
      }
    // ... otros casos
    default:
      // English
  }
}
```

### 5. Actualizar main.dart

**Archivo:** `lib/main.dart`

**Agregar el nuevo Locale a supportedLocales:**

```dart
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: const [
  Locale('es'),
  Locale('en'),
  Locale('pt'),
  Locale('fr'),
  Locale('de'),
  Locale('hi'),
  Locale('ru'),
  Locale('[codigo]'), // Nuevo idioma
],
```

### 6. Actualizar settings_screen.dart

**Archivo:** `lib/screens/settings_screen.dart`

**Agregar entrada en el DropdownMenu:**

```dart
DropdownMenuEntry(
  value: const Locale('[codigo]'),
  label: 'Nombre Nativo del Idioma',
),
```

**Orden alfabético recomendado por nombre nativo.**

### 7. Regenerar archivos de localización

Ejecutar el script de regeneración:

```bash
./regenerate_l10n.sh
```

Esto generará automáticamente `lib/l10n/app_localizations_[codigo].dart` y actualizará el archivo principal `app_localizations.dart`.

## 🔤 Consideraciones por Tipo de Escritura

### Idiomas con alfabeto latino (Italiano, Francés, Español, etc.)

- ✅ **Fuente:** DejaVuSans (ya incluida) es suficiente
- ✅ **Dificultad:** Baja
- ✅ **Requiere cambios en pubspec.yaml:** No

### Idiomas con escritura cirílica (Ruso, Ucraniano, etc.)

- ✅ **Fuente:** DejaVuSans (ya incluida) tiene soporte cirílico
- ✅ **Dificultad:** Baja
- ✅ **Requiere cambios en pubspec.yaml:** No

### Idiomas con escritura devanagari (Hindi, Nepalí, etc.)

- ⚠️ **Fuente:** NotoSans o NotoSansDevanagari
- ⚠️ **Dificultad:** Media
- ⚠️ **Compromiso:** Los símbolos lógicos (∧,∨,⇒) se ven mejor con DejaVuSans
- ⚠️ **Requiere cambios en pubspec.yaml:** Sí, si se usa fuente especial

### Idiomas CJK (Chino, Japonés, Coreano)

- ⚠️ **Fuente:** Noto Sans CJK (debe descargarse)
- ⚠️ **Dificultad:** Media-Alta
- ⚠️ **Requiere cambios en pubspec.yaml:** Sí
- ⚠️ **Tamaño:** Las fuentes CJK son grandes (~10-20 MB)

**Agregar fuente CJK al pubspec.yaml:**

```yaml
fonts:
  - family: NotoSansCJK
    fonts:
      - asset: assets/fonts/NotoSansSC-Regular.ttf # Simplified Chinese
      - asset: assets/fonts/NotoSansJP-Regular.ttf # Japanese
      - asset: assets/fonts/NotoSansKR-Regular.ttf # Korean
```

**Actualizar generate_pdf.dart para cargar la fuente:**

```dart
Future<pw.Font> loadCJKFont() async {
  final fontData = await rootBundle.load('assets/fonts/NotoSansSC-Regular.ttf');
  return pw.Font.ttf(fontData);
}
```

### Idiomas RTL (Árabe, Hebreo, Persa)

- ⚠️ **Fuente:** Noto Sans Arabic / Hebrew
- ⚠️⚠️ **Dificultad:** Alta
- ⚠️⚠️ **Consideraciones especiales:** Layout RTL (Right-to-Left)
- ⚠️⚠️ **Requiere cambios en pubspec.yaml:** Sí
- ⚠️⚠️ **Requiere ajustes de UI:** Sí (TextDirection.rtl en widgets)

## 📊 Checklist de Verificación

Antes de considerar completa la implementación de un nuevo idioma:

- [ ] ✅ Archivo ARB creado con todas las claves traducidas
- [ ] ✅ Archivo strings.xml creado para Android
- [ ] ✅ Método agregado en operator.dart
- [ ] ✅ Caso agregado en getLocalizedName() de operator.dart
- [ ] ✅ Caso agregado en getType() de generate_pdf.dart
- [ ] ✅ Locale agregado en main.dart supportedLocales
- [ ] ✅ Entrada agregada en settings_screen.dart dropdown
- [ ] ✅ Script regenerate_l10n.sh ejecutado exitosamente
- [ ] ✅ Fuente necesaria agregada a pubspec.yaml (si aplica)
- [ ] ✅ Función de carga de fuente agregada a generate_pdf.dart (si aplica)
- [ ] 🧪 Probado cambio de idioma en settings
- [ ] 🧪 Probado generación de PDF en el nuevo idioma
- [ ] 🧪 Probado nombres de operadores en pantalla de resultado
- [ ] 🧪 Probado todos los flujos principales de la app

## 🌍 Idiomas Actualmente Soportados

1. **Español (es)** - Idioma principal
2. **English (en)** - Inglés
3. **Português (pt)** - Portugués
4. **Français (fr)** - Francés
5. **Deutsch (de)** - Alemán
6. **हिन्दी (hi)** - Hindi
7. **Русский (ru)** - Ruso
8. **Italiano (it)** - Italiano
9. **中文 (zh)** - Chino Simplificado
10. **日本語 (ja)** - Japonés

## 🔄 Detección Automática de Idioma

La aplicación detecta automáticamente el idioma del dispositivo al iniciar por primera vez:

- Lee el idioma del sistema operativo usando `PlatformDispatcher.instance.locale`
- Si el idioma está en la lista de soportados, lo usa automáticamente
- Si no está soportado, usa el idioma por defecto (español o inglés según APP_ID)
- El usuario puede cambiar manualmente el idioma en cualquier momento desde Settings
- La preferencia manual se guarda en SharedPreferences y tiene prioridad sobre la detección automática

Esta detección solo ocurre la primera vez. Una vez que el usuario abre la app, si no ha seleccionado manualmente un idioma, usará el del sistema.

## 💡 Recomendaciones de Prioridad

### Alta prioridad (fácil + alto impacto):

- 🇮🇹 **Italiano** - Fácil (alfabeto latino), mercado europeo
- 🇨🇳 **Chino Simplificado** - Gran mercado, requiere fuente CJK
- 🇯🇵 **Japonés** - Gran mercado, requiere fuente CJK

### Media prioridad:

- 🇰🇷 **Coreano** - Buen mercado, requiere fuente CJK
- 🇹🇷 **Turco** - Fácil (alfabeto latino extendido)
- 🇸🇦 **Árabe** - Gran mercado, pero complejidad RTL

### Consideraciones de mercado:

- Play Store permite hasta 50 idiomas
- Cada idioma aumenta la visibilidad en su región
- Los idiomas CJK abren mercados asiáticos enormes
- Priorizar idiomas según analytics de descargas por región

## 🔧 Resolución de Problemas

### Error: "The getter '[key]' isn't defined"

- **Causa:** Falta agregar la clave en el archivo ARB
- **Solución:** Copiar todas las claves de app_es.arb o app_en.arb

### Error al ejecutar regenerate_l10n.sh

- **Causa:** Formato JSON inválido en archivo ARB
- **Solución:** Verificar sintaxis JSON con validador online

### Los símbolos lógicos no se ven en PDF

- **Causa:** La fuente no incluye caracteres ∧,∨,⇒,⇔,⊻,⊼,↓
- **Solución:** Usar DejaVuSans o verificar que la fuente tenga estos glyphs

### El idioma no aparece en el dropdown

- **Causa:** Falta agregar DropdownMenuEntry en settings_screen.dart
- **Solución:** Agregar entrada con nombre nativo del idioma

### Caracteres se ven como cuadros en la app

- **Causa:** Falta configurar la fuente en pubspec.yaml
- **Solución:** Agregar fuente con soporte para ese sistema de escritura

## 📝 Notas Técnicas

- **Flutter l10n:** El sistema genera automáticamente métodos type-safe en AppLocalizations
- **Fallback:** Si un idioma no está disponible, se usa inglés por defecto
- **Formato de fecha/número:** AppLocalizations maneja automáticamente según locale
- **Fuentes en PDF:** La fuente para PDF se carga independientemente de la fuente de la UI
- **Tamaño del APK/AAB:** Cada fuente adicional aumenta el tamaño, considerar fuentes variables o subsets

## 📚 Recursos Útiles

- [Google Translate](https://translate.google.com/) - Para traducciones iniciales
- [DeepL](https://www.deepl.com/) - Traducciones de mayor calidad
- [Google Noto Fonts](https://fonts.google.com/noto) - Fuentes para todos los idiomas
- [Unicode Character Table](https://unicode-table.com/) - Verificar soporte de caracteres
- [Flutter Internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization) - Documentación oficial

---

**Última actualización:** Enero 2026
**Idiomas soportados:** 7 (es, en, pt, fr, de, hi, ru)
