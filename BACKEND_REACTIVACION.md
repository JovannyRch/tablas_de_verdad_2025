# 🔌 Backend API - Guía de Reactivación

## 📊 Estado Actual: DESACTIVADO ⚠️

El backend API está temporalmente desactivado debido a que el servidor está caído. La aplicación funciona completamente sin el backend, pero algunas funcionalidades están limitadas.

---

## 🚫 Funcionalidades Desactivadas

### 1. **Videos Tutoriales Sugeridos**

- **Qué hace:** Después de calcular una expresión, muestra un FAB (botón flotante) con link a video de YouTube explicando esa expresión específica
- **Estado:** Desactivado (no hay botón de video en resultados)
- **Alternativa:** El usuario puede ir al canal de YouTube manualmente

### 2. **Biblioteca de Expresiones**

- **Qué hace:** Muestra lista de expresiones de ejemplo con paginación desde el servidor
- **Estado:** Comentado en el drawer (no accesible)
- **Alternativa:** Los usuarios pueden crear sus propias expresiones

### 3. **Registro de Expresiones**

- **Qué hace:** Envía cada expresión calculada al servidor para estadísticas
- **Estado:** Desactivado (no se envían datos)
- **Impacto:** No se recopilan estadísticas de uso

---

## ✅ Funcionalidades que SÍ Funcionan

Toda la funcionalidad principal de la app está operativa:

- ✅ Cálculo de tablas de verdad
- ✅ Todos los operadores lógicos
- ✅ Resolución paso a paso
- ✅ Exportación a PDF
- ✅ Compartir resultados
- ✅ Historial local (SQLite)
- ✅ Configuraciones
- ✅ Temas claro/oscuro
- ✅ Multiidioma (ES/EN)
- ✅ Anuncios (AdMob)
- ✅ Versión Pro (IAP)
- ✅ Canal de YouTube (link directo)

---

## 🔄 Cómo Reactivar el Backend

Cuando el servidor vuelva a estar disponible, sigue estos pasos:

### Paso 1: Activar el Flag Principal

**Archivo:** `lib/const/backend_config.dart`

```dart
// Cambiar esta línea:
const bool BACKEND_ENABLED = false; // De false...

// A:
const bool BACKEND_ENABLED = true; // ...a true ✅
```

### Paso 2: Descomentar Código en Truth Table Result Screen

**Archivo:** `lib/screens/truth_table_result_screen.dart`

#### 2.1 Imports (líneas 1-10):

```dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tablas_de_verdad_2025/api/api.dart'; // ✅ Descomentar
import 'package:tablas_de_verdad_2025/class/step_proccess.dart';
```

```dart
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';
import 'package:tablas_de_verdad_2025/model/post_expression_response.dart'; // ✅ Descomentar
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
```

#### 2.2 Variable response (línea ~63):

```dart
class _TruthTableResultScreenState extends State<TruthTableResultScreen> {
  late AppLocalizations _localization;
  PostExpressionResponse? response; // ✅ Descomentar
  late Settings _settings;
```

#### 2.3 initState (líneas ~68-80):

```dart
@override
void initState() {
  try {
    Api.postExpression(widget.truthTable.infix, widget.truthTable.tipo).then((
      value,
    ) {
      setState(() {
        response = value;
      });
    });
  } finally {}
  super.initState();
}
```

#### 2.4 FloatingActionButton (líneas ~88-101):

```dart
return Scaffold(
  floatingActionButton:
      (response != null &&
              response!.video_link != null &&
              response!.video_link!.isNotEmpty)
          ? FloatingActionButton.extended(
            onPressed: () {
              visit(response!.video_link!);
            },
            label: Text(_localization.videoFABTooltip),
            icon: FaIcon(FontAwesomeIcons.youtube, color: Colors.white),
            tooltip: _localization.videoFABTooltip,
            backgroundColor: Colors.red,
          )
          : null,
```

### Paso 3: Descomentar Código en Expression Library Screen

**Archivo:** `lib/screens/expression_library_screen.dart`

#### 3.1 Import (línea ~2):

```dart
import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/api/api.dart'; // ✅ Descomentar
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
```

#### 3.2 Método \_fetchExpressions (líneas ~48-68):

```dart
Future<void> _fetchExpressions({bool reset = false}) async {
  if (_isLoading) return;

  setState(() {
    _isLoading = true;
    if (reset) {
      _currentPage = 1;
      _expressions.clear();
      _hasMore = true;
    }
  });

  final ListResponse response = await Api.getListExpressions(
    _currentPage,
    type,
    videos: _onlyVideos,
  );

  setState(() {
    _expressions.addAll(response.data ?? []);
    _hasMore = response.nextPageUrl != null;
    _isLoading = false;
  });
}
```

### Paso 4: Reactivar Biblioteca en Drawer

**Archivo:** `lib/widget/drawer.dart`

Buscar las líneas comentadas (~115-120):

```dart
buildTile(
  Icons.folder_outlined,
  t.expressionLibrary,
  Routes.library,
), // ✅ Descomentar
```

### Paso 5: Verificar y Probar

1. **Guardar todos los archivos**
2. **Hot reload o reiniciar la app**
3. **Probar funcionalidades:**
   - Calcular una expresión → Verificar si aparece FAB de video
   - Ir a biblioteca → Ver si carga expresiones
   - Verificar consola (no debe haber errores HTTP)

---

## 🧪 Verificar Estado del Backend

Antes de reactivar, verifica que el servidor esté funcionando:

### Método 1: Curl (Terminal)

```bash
curl https://jovannyrch-1dfc553c9cbb.herokuapp.com/api/expressions?page=1
```

### Método 2: Browser

Abrir en navegador:

```
https://jovannyrch-1dfc553c9cbb.herokuapp.com/api/expressions?page=1
```

### Respuesta Esperada:

```json
{
  "data": [...],
  "nextPageUrl": "...",
  "prevPageUrl": null
}
```

---

## 🔍 Debugging

### Si la app crashea después de reactivar:

1. **Revisar logs:**

   ```bash
   flutter logs
   ```

2. **Problemas comunes:**
   - ❌ Backend sigue caído → Volver a desactivar
   - ❌ Timeout muy corto → Aumentar en `backend_config.dart`
   - ❌ Formato de respuesta cambió → Actualizar modelos

3. **Rollback rápido:**
   ```dart
   // En backend_config.dart
   const bool BACKEND_ENABLED = false;
   ```

---

## 📝 Checklist de Reactivación

- [ ] Verificar que backend esté operativo (curl/browser)
- [ ] Cambiar `BACKEND_ENABLED = true`
- [ ] Descomentar imports en `truth_table_result_screen.dart`
- [ ] Descomentar variable `response`
- [ ] Descomentar `initState()`
- [ ] Descomentar `floatingActionButton`
- [ ] Descomentar import en `expression_library_screen.dart`
- [ ] Descomentar `_fetchExpressions()` completo
- [ ] Descomentar biblioteca en drawer
- [ ] Hot restart la app
- [ ] Probar cálculo de expresión
- [ ] Probar biblioteca de expresiones
- [ ] Verificar consola (sin errores)
- [ ] Testing con varios usuarios

---

## 📊 Monitoreo Post-Reactivación

Después de reactivar, monitorear:

1. **Crashlytics** - Errores de red
2. **Analytics** - Uso de biblioteca
3. **Play Console** - Reviews mencionando errores
4. **Logs del servidor** - Tráfico API

---

## 💡 Mejoras Futuras

Para evitar problemas futuros con el backend:

### 1. Modo Fallback Automático

```dart
try {
  final response = await Api.postExpression(...).timeout(Duration(seconds: 5));
  // Usar respuesta
} catch (e) {
  // Modo offline automático
  // Mostrar mensaje opcional al usuario
}
```

### 2. Cache Local

- Guardar últimas expresiones de la biblioteca en SQLite
- Usar cache cuando backend no responde

### 3. Indicador de Estado

- Mostrar badge en drawer: "Biblioteca (Offline)"
- Toast al detectar backend caído

### 4. Retry Inteligente

- Intentar reconectar cada X minutos
- Notificar cuando vuelva a estar disponible

---

**Última actualización:** Enero 26, 2026  
**Mantenedor:** Jovanny Ramirez  
**Backend URL:** https://jovannyrch-1dfc553c9cbb.herokuapp.com
