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

### 3. Actualizar el PDF con las features nuevas
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

### 9. Limpieza de legacy
- `lib/const/translations.dart`: mapa de traducciones legacy que convive con los `.arb`; los mensajes de error de `TruthTable` (`UNCOMPLETED_PARENTHESIS`, etc.) todavía dependen de él y solo cubren es/en — los otros 8 idiomas reciben errores en otro idioma.
  - **Acción**: mover los mensajes de error del parser a los `.arb` (el `language` ya llega a `TruthTable`).
- `CONTEXTO_APP.md` está desactualizado (dice 2 idiomas, versión 4.0.8, 3 pestañas). Actualizarlo o regenerarlo — es el documento que usa la IA/colaboradores para entender el proyecto.

---

## 🟡 P2 — Pulido de UX

### 10. Onboarding y descubrimiento de las pestañas nuevas
- Karnaugh y Simplificación son los diferenciadores y nadie las va a descubrir solas en la 5ª pestaña.
- **Acción**: badge "NUEVO" en las pestañas la primera semana; slide nuevo en el onboarding; un snackbar/coachmark tras el primer cálculo ("Desliza para ver el mapa de Karnaugh →").

### 11. Espaciado consistente en columnas intermedias
- Tras el fix de paréntesis, los encabezados compuestos quedan uniformes, pero conviene revisar visualmente expresiones muy largas (4+ variables con anidación): el header de la última columna puede desbordar. Considerar `Tooltip` con la expresión completa o fuente más chica a partir de N caracteres.

### 12. Teclado (keypad)
- Haptics al pulsar (la app RN de K-maps ya tiene `utils/haptics.ts` como referencia).
- Long-press en un operador → tooltip con nombre y tabla de verdad mini (ya existe `operator_theory.dart` con ese contenido).
- Paréntesis inteligentes: al pulsar `(` con texto seleccionado, envolver la selección.

### 13. Historial y favoritos
- Mostrar el **tipo** (tautología/contradicción/contingencia) como chip de color en cada item del historial (ya se calculó una vez; persistirlo en la tabla SQLite).
- Estado vacío con ilustración/CTA en historial y favoritos.
- Swipe para borrar items.

### 14. Accesibilidad
- `Semantics` en el teclado y el mapa de Karnaugh (hoy el CustomPaint es invisible para lectores de pantalla — describir grupos: "Grupo 1: A y no B, 4 celdas").
- Verificar contraste de `kLabelColor` sobre fondos claros y escalado de fuente del sistema (los headers de tabla con `fontSize` fijo).

### 15. Tablet / landscape
- En tablets la calculadora estira el keypad sin límite. `maxWidth` en el contenido + layout de dos paneles en landscape (entrada izquierda, resultado derecha) es factible con la estructura actual.

---

## 🟢 P3 — Features nuevas (orden de impacto sugerido)

### 16. Práctica: modo "Completar la tabla"
- Ya diseñado en `PROPUESTA_PRACTICA.md` (Opción 2). Pedagógicamente superior al quiz de clasificación: el alumno construye la tabla celda por celda con feedback inmediato.
- Reusa: motor `TruthTable`, framework del quiz, persistencia de stats existente.

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
- Pro ahora desbloquea mucho más que "sin anuncios" (K-maps, simplificación, formas normales sin gates). El paywall (`show_pro_version_dialog.dart`) debería listar estos beneficios explícitamente.
- Evaluar suscripción vs compra única cuando exista la versión web (sync multiplataforma como beneficio de suscripción).

### 27. Timing del in-app review
- Pedir review justo después de un momento de éxito (primera simplificación completada / primer K-map visto) en vez de por contador de operaciones.

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
