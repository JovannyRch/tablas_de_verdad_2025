# 🛠️ Mejoras y Polishments Pendientes

> Actualizado: junio 2026. Documento de trabajo con todo lo identificado en la auditoría del proyecto, priorizado por impacto/esfuerzo. Marcar con ✅ al completar.

## ✅ Completado recientemente (referencia)

- ✅ Pestaña **Mapa de Karnaugh** con Quine–McCluskey exacto (`lib/class/karnaugh_map.dart`, `lib/widget/karnaugh_map_view.dart`)
- ✅ Pestaña **Simplificación paso a paso** con 20 leyes citadas (`lib/class/logic_simplifier.dart`)
- ✅ Fix de **paréntesis perdidos** en pasos, tabla completa y PDF (`StepProcess.wrapOperand/displayOperand`)
- ✅ 53 tests unitarios y de widget (antes: solo el boilerplate roto, ya eliminado)
- ✅ Eliminado el algoritmo K-maps greedy viejo (`lib/utils/kMaps.dart`, `lib/model/types.dart`)

---

## 🔴 P0 — Arreglar antes del próximo release

### 1. IDs de AdMob con TODO en producción
- `lib/const/const.dart:21,23` y `lib/const/translations.dart:144,146`: `"STEP_BY_STEP"` reutiliza el ID de `VIDEO_ID` con `//TODO: Set a new id`.
- **Acción**: crear los ad units en AdMob console (uno por flavor es/en) y reemplazar. Reutilizar el mismo ID en dos placements distorsiona las métricas de eCPM por placement.

### 2. Verificación visual de las pestañas nuevas en dispositivo
- Karnaugh y Simplificación están cubiertas por tests, pero falta validación visual en emulador/dispositivo real (grupos con wrap, dark mode, expresiones de 4 variables, pantallas pequeñas).
- **Acción**: `flutter run --flavor es`, probar `(p⇒q)∧(q⇒p)`, `(A∧B)∨(A∧¬B)∨(¬A∧C)`, una tautología y una contradicción, en claro y oscuro.

### 3. ✅ Actualizar el PDF con las features nuevas
- El PDF (`lib/utils/generate_pdf.dart`) solo exporta la tabla. El estudiante quiere entregar la tarea completa.
- **Acción**: secciones opcionales en el PDF: formas normales, expresión minimizada (K-map) y pasos de simplificación con sus leyes. Es contenido premium natural (gate Pro para el PDF extendido).

---

## 🟠 P1 — Deuda técnica (rápida y de alto retorno)

### 4. ✅ Migración `withOpacity` → `withValues`
- 156 reemplazos en 20 archivos. `flutter analyze` sin warnings de deprecación.

### 5. ✅ Limpieza de warnings reales
- Eliminados todos los `unused_import` (`history_dialog`, `video_screen`, `expression_card`, `go_to_solution`, `settings_model`).
- Corregidos ambos `must_be_immutable`: `PrivacyPolicyScreen.controller` → `final`; `ExpressionCard.t/_settings` → variables locales en `build()`.
- `flutter analyze` sale con **0 warnings, 0 errors** (solo `info` de naming conventions legacy y prints de debug).

### 6. ✅ Tests del motor principal (`TruthTable`)
- `test/truth_table_test.dart`: 68 tests, 11 grupos. Cubren clasificación, variables y filas, los 3 aliases de NOT, los 16 operadores binarios (cada uno con counter1s verificado), constantes 0/1, 4 errores de sintaxis, consistencia de columnas, precedencia de operadores, `EquivalenceChecker` (7 casos incluyendo cross-variable y error) y `ExpressionValidator` (13 casos). Total suite: **121 tests**.

### 7. ✅ CI con GitHub Actions
- `.github/workflows/ci.yml`: `flutter analyze --no-fatal-infos` + `flutter test` en cada push/PR a `main`. Flutter 3.41.8 pinned, caché de pub habilitado.

### 8. ✅ Crashlytics + Firebase Analytics reales
- `firebase_core ^3.6.0`, `firebase_analytics ^11.3.0`, `firebase_crashlytics ^4.1.0` añadidos.
- `main.dart`: `Firebase.initializeApp()` + `FlutterError.onError` + `PlatformDispatcher.instance.onError` → Crashlytics; envuelto en try-catch (la app funciona aunque Firebase no esté configurado).
- `analytics.dart`: implementación reemplazada con Firebase Analytics (fire-and-forget, nunca crashea). `getStats()` sigue retornando contadores locales para la pantalla de ajustes. Cero cambios en call-sites.

### 9. ✅ Limpieza de legacy
- `lib/const/translations.dart` eliminado. Los 5 mapas de mensajes de error del parser migrados a constantes privadas en `truth_table.dart` cubriendo los 10 idiomas con fallback a inglés.
- `CONTEXTO_APP.md` actualizado: v4.0.25, 10 idiomas, 5 pestañas, Firebase, CI, 121 tests, estructura real de directorios.

---

## 🟡 P2 — Pulido de UX

### 10. Onboarding y descubrimiento de las pestañas nuevas
- Karnaugh y Simplificación son los diferenciadores y nadie las va a descubrir solas en la 5ª pestaña.
- **Acción**: badge "NUEVO" en las pestañas la primera semana; slide nuevo en el onboarding; un snackbar/coachmark tras el primer cálculo ("Desliza para ver el mapa de Karnaugh →").

### 11. Espaciado consistente en columnas intermedias
- Tras el fix de paréntesis, los encabezados compuestos quedan uniformes, pero conviene revisar visualmente expresiones muy largas (4+ variables con anidación): el header de la última columna puede desbordar. Considerar `Tooltip` con la expresión completa o fuente más chica a partir de N caracteres.

### 12. ✅ Teclado (keypad)
- Haptics diferenciados por tipo de tecla: `selectionClick` para entrada (operandos/operadores), `lightImpact` para acciones (AC/⌫/Aa), `mediumImpact` para evaluar (=). Toggle en Ajustes (`hapticsEnabled`, persistido; default on) — clave l10n `hapticFeedback` ×10.
- Long-press en un operador → diálogo con `TheoryCard` (nombre localizado + mini tabla de verdad + ejemplo), reutilizando `OperatorTheory`. Paréntesis/llaves sin teoría no hacen nada. Se localizó "Example" (clave `example` ×10).
- Paréntesis inteligentes: pulsar `(` con texto seleccionado envuelve la selección (`p∧q` → `(p∧q)`), cursor tras `)`. Lógica extraída a `lib/utils/keypad_input.dart` (puro) con 7 tests.

### 13. Historial y favoritos
- Mostrar el **tipo** (tautología/contradicción/contingencia) como chip de color en cada item del historial (ya se calculó una vez; persistirlo en la tabla SQLite).
- Estado vacío con ilustración/CTA en historial y favoritos.
- Swipe para borrar items.

### 14. ✅ Accesibilidad
- `Semantics` en el teclado: cada tecla anuncia una etiqueta hablada (operadores → nombre localizado + "premium" si está gateado; acciones AC/⌫/Aa/= con claves `a11y*`). Vía `Text(semanticsLabel:)` para no perder la acción de tap del `InkWell`.
- `Semantics` en el mapa de Karnaugh: el overlay `CustomPaint` (antes invisible) ahora describe la cobertura mínima — "Karnaugh map with N groups. Group 1: ¬A ∧ C, 4 cells" (`a11yKarnaughMap`/`a11yKarnaughGroup`, 10 idiomas); funciones constantes usan `karnaughConstant`. +2 tests de semántica.
- Contraste: `kLabelColor` subido de `black54` a `0xA6000000` (~65%) para pasar AA sobre las superficies crema.
- Escalado de fuente: el `DataTable` denso (alturas fijas 40/44) ahora acota el `textScaler` a 1.5× con `MediaQuery.withClampedTextScaling` para evitar recortes.

### 15. Tablet / landscape
- En tablets la calculadora estira el keypad sin límite. `maxWidth` en el contenido + layout de dos paneles en landscape (entrada izquierda, resultado derecha) es factible con la estructura actual.

---

## 🟢 P3 — Features nuevas (orden de impacto sugerido)

### 16. ✅ Práctica: modo "Completar la tabla"
- Implementada la Opción 2 (variante "solo columna final" como MVP): el alumno marca el valor de verdad de la última columna en cada fila, con verificación y feedback verde/rojo por celda.
- `lib/screens/practice_mode_screen.dart`: selector de modo (`SegmentedButton`: Clasificar / Completar la tabla) y stats card consciente del modo. `lib/screens/fill_table_screen.dart`: sesión de 5 expresiones, progreso, verificación y pantalla de resultados (% de celdas correctas).
- Reusa: motor `TruthTable`, banco de expresiones `QuizBank`, niveles `QuizDifficulty`, formato V/F (`getCellValue`), Analytics. Stats propios en SharedPreferences (`fill_tables_completed`, `fill_cells_correct`, `fill_cells_total`).
- Lógica de construcción del puzzle extraída a `lib/utils/fill_table_builder.dart` (puro) con 5 tests. Nota: se detectó que `TruthTable` requiere input sin espacios (el quiz lo enmascaraba con su try/catch + fallback); fill-table sanea espacios antes de evaluar.
- 8 claves l10n nuevas ×10 idiomas.

### 17. Visualizador de circuitos lógicos
- La app RN hermana ya lo tiene resuelto (`components/circuit/`: gates SVG, layout, `sceneToSvg.ts`) — portar a Flutter con CustomPaint.
- Encaja como 6ª pestaña o como botón desde el resultado del K-map (el `KarnaughResult` ya da los términos SOP/POS listos para dibujar como AND-OR de dos niveles).

### 18. Mejoras al simplificador
- Resaltar en color la subexpresión reescrita dentro de la expresión completa de cada paso (hoy se muestra `local → local` aparte; el `LogicSimplifier` tendría que reportar el span).
- Ley de consenso y distribución selectiva (con poda por tamaño) para alcanzar más tautologías → `1`.
- Botón "usar resultado" que mande la expresión simplificada de vuelta a la calculadora (ya es sintaxis válida de la app).

### 19. Mejoras al Karnaugh
- Soporte de **don't cares**: el solver ya está preparado conceptualmente (el de RN los soporta); requeriría un editor de mapa interactivo (tocar celda para ciclar 0/1/X) — eso es casi una mini-app de K-maps dentro de la app, como la de RN.
- Exportar el mapa como imagen para compartir (RepaintBoundary → PNG).
- 5 variables (dos mapas de 4×4 lado a lado), si hay demanda.

### 20. Lógica de predicados / deducción natural
- Siguiente tema del temario después de proposicional. El validador de argumentos existente es la base; agregar reglas de inferencia nombradas (modus ponens, tollens, silogismo) como "demostración paso a paso" reutilizaría el patrón visual del simplificador.

---

## 🔵 P4 — Expansión (plataformas y rubros)

### 21. Versión web (Flutter web) — la de mayor retorno
- "truth table generator" tiene volumen de búsqueda alto en desktop; los estudiantes hacen la tarea en laptop.
- Plan mínimo: build web del flujo calculadora→resultado (sin IAP/AdMob; AdSense o gratis como embudo), deploy en `tablasdeverdad.app` (el dominio ya existe y ya maneja los deep links `/calculadora?expression=`).
- Cuidado: `google_mobile_ads`, `in_app_purchase` y `sqflite` no compilan a web → aislar tras interfaces o `kIsWeb`.

### 22. iOS
- `flutter_launcher_icons` tiene `ios: false` y no hay flavor configurado en Xcode. Es el mercado obvio sin atender; el código es portable salvo configuración de AdMob/IAP.

### 23. Nuevas secciones dentro de la app (misma audiencia)
- **Conversor de bases numéricas** (binario/octal/hex, complemento a 2): esfuerzo bajísimo, búsqueda alta, mismo usuario de primer semestre.
- **Teoría de conjuntos / diagramas de Venn**: isomorfo al motor actual (∧=∩, ∨=∪, ¬=complemento); solo falta la visualización.
- Con 2-3 secciones, evaluar rebranding suave: "la app de matemáticas discretas".

### 24. App hermana de circuitos
- Cuando exista el visualizador (#17), el rubro de electrónica digital (compuertas, álgebra booleana, K-maps con don't cares) da para una segunda app reutilizando los motores, como ya hiciste con rn-karnough-maps-2026.

---

## 💰 Monetización y growth

### 25. Actualizar el listing de Play Store
- "Mapa de Karnaugh" y "simplificación con leyes lógicas" son **keywords de búsqueda** que ahora la app realmente tiene. Actualizar título corto/descripción/screenshots en ambos flavors (`PLAY_STORE_DESCRIPTIONS.md`).

### 26. Revisar la propuesta Pro
- ✅ **Paywall actualizado** (`show_pro_version_dialog.dart`): ahora lidera con los 3 diferenciadores reales —Mapas de Karnaugh, Simplificación paso a paso y Formas normales sin anuncios/al instante— resaltados (naranja de marca, negrita) vía `BenefitItem(highlight: true)`, seguidos de operadores premium ilimitados, sin anuncios, biblioteca completa y apoyo al desarrollador. Se quitó "Soporte Premium" del paywall (claim vago; la clave sigue en el drawer). 3 claves l10n nuevas ×10.
- ⏳ **Suscripción vs compra única**: pendiente, atarlo a la versión web (#21). Recomendación: mantener la **compra única** en móvil (es lo que ya funciona y conversiona bien para una utilidad), e introducir una suscripción **solo si** la web añade valor recurrente real (sync multiplataforma, historial en la nube). No migrar el modelo móvil actual.

### 27. ✅ Timing del in-app review
- El review ya **no se pide por contador de cálculos**. Se quitaron los prompts de `_evaluate`/`_evaluateAfterReward` en `calculator_screen.dart`.
- Ahora se pide en un **momento de éxito** dentro de `TruthTableResultScreen`: al ver el **Mapa de Karnaugh** o al obtener una **simplificación con reducción real** (`result.steps.isNotEmpty`). Helper `scheduleMilestoneRating()` con delay de 1.2s (post-frame, `context.mounted`) para separarlo del intersticial que un usuario free acaba de cerrar.
- `RatingHelper.shouldShowOnMilestone()`: misma lógica de cooldown/ya-calificó/nunca-preguntar pero **sin** el requisito de N cálculos. 6 tests en `rating_helper_test.dart`.
- Nota: los métodos por contador (`shouldShowRatingDialog`/`incrementCalculationCount`) quedan en `RatingHelper` sin uso por si se quieren como fallback; el botón manual "Calificar la app" del drawer sigue igual.

---

## 🔧 Motor de tablas de verdad (auditoría pre-web)

### 28. Robustez y deuda técnica del motor (`truth_table.dart`)
- ✅ **P0 — Robustez** (blindaje para input arbitrario de web):
  - `formatInput()` ahora **elimina todo whitespace** (antes `"p ∧ q"` lanzaba excepción en el parser; el calculador lo enmascaraba quitando espacios y el quiz con try/catch).
  - **Caracteres inválidos** (dígitos 2-9, puntuación, emojis) → error amigable `_kInvalidCharacter` en vez de *null-check crash* en `infixToPostfix`.
  - **Tope de variables** `kMaxTruthTableVariables = 10` (≤1024 filas) → error `_kTooManyVariables` en vez de congelar/OOM con 2^n.
  - `convertInfixToPostix()` devuelve `errorMessage.isEmpty` → los errores específicos de parseo ya **no los pisa** el chequeo estructural genérico.
  - +7 tests de robustez (75 en `truth_table_test.dart`). 2 claves de error nuevas ×10 (privadas en el motor).
- ✅ **P1 — Deuda técnica:**
  - **Estado estático eliminado**: `StepProcess` ya no tiene `currentIndex`/`labelIndex`/`backStep`/`index` — es un objeto de valor inmutable de comportamiento. Sin estado compartido entre instancias.
  - **Evaluación de una sola pasada**: se eliminó el acoplamiento por `statesSteps`/`varSubstitutions`. `_evaluateRow` evalúa los `steps` (ya deduplicados, en orden de dependencia) sobre un mapa `clave→valor`; cada subexpresión escribe su columna una vez. **Bonus**: corrige un bug latente de **doble escritura** cuando una subexpresión idéntica se repetía (`(p∧q)∨(p∧q)`) — test nuevo que lo fija. También elimina el `replaceAll`+re-split del postfix por fila (P2 resuelto de paso).
  - **Código muerto** eliminado: `tautologia()`, `contradiccion()`, `xnor()`, y el campo `format` (quitado del constructor; cascada limpiada en equivalence_checker, go_to_solution, argument_validator, quiz, fill_table, generate_pdf —que ahora recibe `format` del viewer—).
  - **API**: `makeAll()` ahora devuelve `bool` + getters `hasError`/`isValid`. `goToResult` se enrutó por `makeAll()`, así que **la ruta principal del calculador ya respeta el tope de variables** (antes lo saltaba con la secuencia manual).
- 🟡 **P2 — Rendimiento:** el `replaceAll`/re-split por fila ya se eliminó con el refactor de una pasada. Queda menor: el motor reconstruía `columns.keys.toList().sublist(...)` por fila — ya no aplica (se eliminó esa ruta).

---

## 📋 Orden sugerido de ejecución

| # | Item | Esfuerzo | Impacto |
|---|------|----------|---------|
| 1 | IDs AdMob (#1) | Minutos | Revenue |
| 2 | Verificación en device (#2) | 1 hora | Calidad release |
| 3 | Listing Play Store (#25) | 1 hora | Descargas |
| 4 | withOpacity + warnings (#4, #5) | 1-2 horas | Higiene |
| 5 | CI (#7) | 1 hora | Protege todo lo demás |
| 6 | Tests TruthTable (#6) | Medio día | Confianza |
| 7 | PDF extendido (#3) | 1 día | Valor Pro |
| 8 | Crashlytics/Analytics (#8) | Medio día | Visibilidad |
| 9 | Descubrimiento pestañas (#10) | Medio día | Adopción features |
| 10 | Completar tabla (#16) | 2-3 días | Retención |
| 11 | Web (#21) | 1 semana | Crecimiento |
| 12 | Circuitos (#17) | 1 semana | Diferenciador |
