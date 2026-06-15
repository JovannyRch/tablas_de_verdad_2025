# Contexto de la Aplicación — Tablas de Verdad 2025

## 📱 Descripción General

**Tablas de Verdad** es una aplicación Flutter para Android que permite calcular y visualizar tablas de verdad de expresiones lógicas proposicionales. Está dirigida a estudiantes de lógica matemática, informática y áreas relacionadas.

### Información Básica

- **Nombre**: Tablas de Verdad / Truth Tables
- **Versión**: 4.0.25 (Build 40025)
- **Plataformas**: Android (iOS e iOS/web preparados en roadmap)
- **Idiomas**: 10 — es, en, pt, fr, de, hi, ru, it, zh, ja
- **Framework**: Flutter 3.41.8 / Dart 3.7
- **Firebase**: `tablas-de-verdad-ed88b` (Analytics + Crashlytics activos)

---

## 🎯 Funcionalidad Principal — 5 Pestañas de Resultado

Tras calcular una expresión, el usuario ve `TruthTableResultScreen` con 5 tabs:

| Tab | Nombre | Acceso |
|-----|--------|--------|
| 1 | Pasos de resolución | Libre |
| 2 | Tabla completa | Libre |
| 3 | Simplificación | Pro (con ad gate) |
| 4 | Formas normales | Pro (con ad gate) |
| 5 | Mapa de Karnaugh | Pro (con ad gate) |

---

## 🔧 Motores de Lógica

### 1. `TruthTable` (`lib/class/truth_table.dart`)
- Algoritmo Shunting Yard (infijo → postfijo)
- Evaluación por pila con 18 operadores (ver tabla más abajo)
- Genera `steps`, `columns`, `finalTable`, clasificación (tautología / contradicción / contingencia)
- Mensajes de error localizados en los 10 idiomas (privados en el mismo archivo)

### 2. `KarnaughSolver` (`lib/class/karnaugh_map.dart`)
- Quine–McCluskey exacto para 2–4 variables
- Soporta SOP y POS
- Grupos con wrap-around; visualización con `KarnaughMapView` (`lib/widget/karnaugh_map_view.dart`)

### 3. `LogicSimplifier` (`lib/class/logic_simplifier.dart`)
- AST-based, 20 leyes nombradas (De Morgan, absorción, complemento, etc.)
- Simplificación hasta punto fijo (máx. 100 pasos)
- Garantiza terminación (sin distribución expansiva)

### 4. `EquivalenceChecker` (`lib/utils/equivalence_checker.dart`)
- Compara dos expresiones, normaliza variables, retorna `EquivalenceResult` con filas divergentes

### 5. `ExpressionValidator` (`lib/utils/expression_validator.dart`)
- Validación en tiempo real (sin construir tabla completa)
- Estados: `empty`, `valid`, `incomplete`, `error`

---

## ⚙️ Operadores Lógicos (18 total)

| Operador | Símbolos | Descripción |
|---|---|---|
| Negación | `¬` `~` `!` | NOT |
| Conjunción | `∧` `&` | AND |
| Disyunción | `∨` `\|` | OR |
| XOR | `⊕` `⊻` | OR exclusivo |
| NAND | `⊼` | NOT AND |
| NOR | `↓` | NOT OR |
| Condicional | `⇒` | Implicación |
| Bicondicional | `⇔` | Equivalencia |
| Anticondicional | `￩` | Condicional inverso |
| ¬Condicional | `⇏` | NOT implicación |
| ¬Condicional inv. | `⇍` | NOT condicional inverso |
| ¬Bicondicional | `⇎` | NOT equivalencia (≡ XOR) |
| Tautología | `┲` | Siempre 1 (binario) |
| Contradicción | `┹` | Siempre 0 (binario) |

---

## 🏗️ Arquitectura

### State Management
Provider (`Settings extends ChangeNotifier`)

### Estructura de directorios relevante

```
lib/
├── class/
│   ├── truth_table.dart       # Motor principal + mensajes de error i18n
│   ├── karnaugh_map.dart      # Quine–McCluskey
│   ├── logic_simplifier.dart  # Simplificador algebraico
│   ├── operator.dart          # Enum Operators con nombres localizados
│   ├── row_table.dart
│   └── step_proccess.dart     # wrapOperand / displayOperand
├── const/
│   ├── const.dart             # IDs AdMob, flags IS_TESTING, URLs
│   ├── colors.dart            # kSeedColor, temas light/dark
│   ├── routes.dart
│   └── calculator.dart        # Config del teclado
├── db/database.dart           # SQLite: historial + favoritos
├── l10n/                      # ARB × 10 idiomas; template: app_es.arb
│   └── app_*.arb
├── model/
│   ├── settings_model.dart    # Locale, TruthFormat, MintermOrder, KeypadMode, isPro
│   ├── list_response.dart     # Expression (biblioteca)
│   └── operator_theory.dart   # Contenido teórico de cada operador
├── screens/
│   ├── calculator_screen.dart
│   ├── truth_table_result_screen.dart   # 5 tabs
│   ├── equivalence_screen.dart
│   ├── argument_validator_screen.dart
│   ├── quiz_screen.dart            # Práctica: clasificar (tautología/…)
│   ├── practice_mode_screen.dart   # Landing: selector de modo + stats
│   ├── fill_table_screen.dart      # Práctica: completar la tabla
│   ├── expression_library_screen.dart
│   ├── settings_screen.dart
│   ├── onboarding_screen.dart
│   └── privacy_policy_screen.dart
├── service/purchase_service.dart        # IAP Pro
├── utils/
│   ├── analytics.dart         # Firebase Analytics + contadores locales
│   ├── equivalence_checker.dart
│   ├── expression_validator.dart
│   ├── fill_table_builder.dart # Puzzle "completar la tabla" (puro)
│   ├── keypad_input.dart       # Inserción de teclado + paréntesis inteligentes
│   ├── generate_pdf.dart      # PDF: tabla + metadatos
│   ├── go_to_solution.dart    # Construye TruthTableResultScreen
│   └── show_pro_version_dialog.dart
└── widget/
    ├── keypad.dart
    ├── karnaugh_map_view.dart  # CustomPaint con grupos coloreados
    ├── drawer.dart
    ├── expression_card.dart
    └── banner_ad_widget.dart
```

---

## 💰 Monetización

### Versión gratuita
- Anuncios banner + intersticiales + recompensados
- Tabs 3–5 protegidos por `_InterstitialAdGate` (se desbloquean viendo un anuncio)
- Historial y favoritos completos

### Versión Pro (`isProVersion = true`)
- Sin anuncios
- Acceso libre a simplificación, formas normales y Karnaugh sin ad gate
- Activación: compra única (`pro_version`) vía `in_app_purchase`

### Flavors Android
| Flavor | Package | AdMob App ID |
|--------|---------|--------------|
| `es` | `com.jovannyrch.tablasdeverdad` | `ca-app-pub-4665787383933447~4689744776` |
| `en` | `com.jovannyrch.tablasdeverdad.en` | `ca-app-pub-4665787383933447~1652617896` |

### IDs AdMob activos (`lib/const/const.dart`)
```dart
VIDEO_ID         = "ca-app-pub-4665787383933447/1003394249"
STEP_BY_STEP_ID  = "ca-app-pub-4665787383933447/9789289099"
SHARE_AND_SAVE_ID= "ca-app-pub-4665787383933447/8643480964"
BANNER_ID        = "ca-app-pub-4665787383933447/9637438366"
```

---

## 🌍 Internacionalización

- 10 idiomas: `es`, `en`, `pt`, `fr`, `de`, `hi`, `ru`, `it`, `zh`, `ja`
- ARB files en `lib/l10n/`; template: `app_es.arb`
- Regenerar con: `./regenerate_l10n.sh`
- Los mensajes de error del parser de `TruthTable` están en `truth_table.dart` como constantes privadas (cubren los 10 idiomas + fallback a inglés)

---

## 🔥 Firebase

- Proyecto: `tablas-de-verdad-ed88b`
- Config: `android/app/google-services.json` (3 package names registrados)
- **Analytics**: `firebase_analytics ^11.3.0` — eventos: `expression_calculated`, `pdf_exported`, `pro_conversion`, `favorite_added`, `expression_shared`, `onboarding_completed`, `karnaugh_map_viewed`, `simplification_viewed`, `paywall_*`, `quiz_*`
- **Crashlytics**: `firebase_crashlytics ^4.1.0` — captura `FlutterError` + errores async no capturados

---

## 💾 Persistencia

### SQLite (`db/database.dart`)
```sql
CREATE TABLE expressions (id INTEGER PRIMARY KEY, expression TEXT);
CREATE TABLE favorites (id INTEGER PRIMARY KEY, expression TEXT);
```

### SharedPreferences
- `locale`, `themeMode`, `truthFormat`, `mintermOrder`, `keypadMode`, `hapticsEnabled`, `isProVersion`
- `stat_*`: contadores locales de Analytics

---

## 🧪 Tests (`test/`)

| Archivo | Tests | Qué cubre |
|---|---|---|
| `truth_table_test.dart` | 68 | Motor TruthTable, EquivalenceChecker, ExpressionValidator |
| `karnaugh_map_test.dart` | 17 | Quine–McCluskey, layout, grupos |
| `karnaugh_map_view_test.dart` | 5 | Renderizado del mapa + semántica a11y |
| `logic_simplifier_test.dart` | 24 | 20 leyes + soundness |
| `step_parenthesization_test.dart` | 8 | wrapOperand / displayOperand |
| `keypad_input_test.dart` | 7 | Paréntesis inteligentes + inserción |
| `fill_table_builder_test.dart` | 5 | Puzzle "completar la tabla" |

**Total: 135 tests** — ejecutar con `flutter test`

---

## 🔗 Referencias

- **Backend API**: `https://jovannyrch-1dfc553c9cbb.herokuapp.com/api`
  - `GET /expressions?page=&type=&videos=` — biblioteca
  - `POST /expressions` — registro anónimo
- **YouTube**: `https://www.youtube.com/@tablasdeverdades`
- **Discord**: `https://discord.gg/ZUSfz8aZXP`
- **Play Store ES**: `com.jovannyrch.tablasdeverdad`
- **Play Store EN**: `com.jovannyrch.tablasdeverdad.en`

---

## 🛠️ Comandos

```bash
flutter run --flavor es          # Ejecutar flavor español
flutter run --flavor en          # Ejecutar flavor inglés
flutter test                     # Suite completa (121 tests)
flutter analyze                  # 0 warnings, 0 errors
./regenerate_l10n.sh             # Regenerar localizaciones ARB
flutter build apk --release --flavor es
flutter build appbundle --release --flavor es
```

---

*Actualizado: junio 2026. Desarrollador: Jovanny Ramirez — `com.jovannyrch.tablasdeverdad`*
