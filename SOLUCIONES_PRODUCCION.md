# 🔧 Soluciones a Problemas en Producción

## 1. 🇮🇳 Caracteres Hindi no se muestran en PDF

**Problema**: DejaVuSans.ttf no tiene soporte completo para caracteres Devanagari (hindi).

**Solución**: Usar fuente Noto Sans que incluye soporte completo para hindi.

### Pasos:

1. **Descargar Noto Sans con soporte Devanagari**:
   - Ir a https://fonts.google.com/noto/specimen/Noto+Sans+Devanagari
   - O usar: https://github.com/notofonts/devanagari/releases

2. **Agregar la fuente al proyecto**:

   ```bash
   # Descargar NotoSans-Regular.ttf a assets/fonts/
   curl -L -o assets/fonts/NotoSans-Regular.ttf https://github.com/notofonts/noto-fonts/raw/main/hinted/ttf/NotoSans/NotoSans-Regular.ttf
   ```

3. **Actualizar pubspec.yaml**:

   ```yaml
   fonts:
     - family: NotoSans
       fonts:
         - asset: assets/fonts/NotoSans-Regular.ttf
   ```

4. **Actualizar generate_pdf.dart**:
   ```dart
   Future<Uint8List> loadFont() async {
     final data = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
     return data.buffer.asUint8List();
   }
   ```

**Alternativa rápida**: Si ya tienes la app publicada, puedes crear un conditional que use diferentes fuentes según el idioma.

---

## 2. 📚 Lista no se muestra completa después del Rewarded Ad

**Problema**: Después de ver el anuncio rewarded, `_hasUnlockedFullList = true` pero la lista no se actualiza visualmente.

**Causa**: El `setState()` se está llamando, pero puede haber un problema con el rebuild o con el timing del callback.

**Solución**: Asegurar que el rebuild ocurra correctamente después del ad:

### Actualizar expression_library_screen.dart:

```dart
Future<void> _unlockWithAd() async {
  // Mostrar loading mientras se carga el ad
  if (mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  final success = await _rewardedAdHelper.showRewardedAd();

  // Cerrar el loading
  if (mounted) {
    Navigator.of(context).pop();
  }

  if (success) {
    // Dar un pequeño delay para asegurar que el ad se cerró completamente
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _hasUnlockedFullList = true;
      });
      showSnackBarMessage(context, t.libraryUnlocked);

      // Scroll hacia abajo para mostrar las nuevas expresiones
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  } else {
    if (mounted) {
      showSnackBarMessage(context, t.adNotAvailable);
    }
  }
}
```

**Debug**: Agregar prints para verificar:

```dart
print('🎯 Rewarded ad success: $success');
print('🔓 _hasUnlockedFullList: $_hasUnlockedFullList');
print('📊 Total expressions: ${_filteredExpressions.length}');
print('✅ Should show: ${_settings.isProVersion ? "all" : _hasUnlockedFullList ? "all" : "limited"}');
```

---

## 3. 💳 IAP Mostrando "Pedido de Prueba" en Producción

**Problema**: Las compras in-app muestran tarjetas de prueba y "Este es un pedido de prueba".

**Causas posibles**:

1. **La app está firmada con debug keystore** (no release)
2. **El producto no está configurado correctamente en Google Play Console**
3. **La cuenta de prueba está activa** en Google Play Console
4. **La app no está en producción** o en testing cerrado/abierto

### ✅ Solución:

#### A. Verificar que la app está firmada correctamente:

1. **Revisar build.gradle.kts**:

```kotlin
// android/app/build.gradle.kts
android {
    signingConfigs {
        create("release") {
            storeFile = file("../key.properties").let { keyProps ->
                if (keyProps.exists()) {
                    val props = Properties().apply {
                        load(keyProps.inputStream())
                    }
                    file(props["storeFile"] ?: "")
                } else {
                    null
                }
            }
            // Asegurarse de que storePassword, keyAlias, keyPassword están configurados
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

2. **Verificar key.properties existe y está correcto**:

```properties
storePassword=tu_password
keyPassword=tu_password
keyAlias=tu_alias
storeFile=/ruta/a/tu/keystore.jks
```

3. **Construir release bundle**:

```bash
flutter build appbundle --release
```

#### B. Configurar producto en Google Play Console:

1. Ir a **Google Play Console** → Tu App → **Monetización** → **Productos y suscripciones**

2. Crear producto in-app:
   - **ID del producto**: `pro_version` (debe coincidir con PurchaseService)
   - **Nombre**: "Versión Pro"
   - **Descripción**: Descripción del beneficio
   - **Precio**: Configurar precio en cada país
   - **Estado**: Activar

3. **Guardar y activar** el producto

#### C. Configurar testing:

1. En Google Play Console → **Configuración** → **Licencias**:
   - Agregar cuentas de prueba si es necesario
   - **Importante**: La cuenta que estás usando para probar NO debe estar en la lista de probadores internos/cerrados si quieres probar compras reales

2. Crear un **track de testing cerrado o abierto**:
   - Subir el AAB firmado con release keystore
   - Esperar aprobación (puede tomar horas o días)

#### D. Verificar en el código:

En `purchase_service.dart`, el ID debe coincidir:

```dart
static const String _proProductId = 'pro_version'; // ✅ Debe coincidir con Google Play Console
```

### 🧪 Testing de IAP:

**Para probar compras reales sin pagar**:

1. Usa una cuenta de prueba configurada en Google Play Console
2. La primera vez la compra será real pero Google la reembolsará automáticamente
3. Las siguientes compras con esa cuenta serán gratuitas

**Para producción**:

- Asegúrate de que la app está en un track de producción o testing cerrado/abierto
- La app debe estar firmada con el keystore de release
- El producto debe estar activo en Play Console

---

## 4. ⭐ Review In-App no funciona

**Problema**: No aparece nada al intentar calificar la app.

**Causas**:

1. **in_app_review tiene limitaciones** de frecuencia por dispositivo
2. **Requiere que la app esté publicada** en Play Store
3. **Android limita las solicitudes** a 1 vez cada 3 meses por usuario
4. **iOS limita** a 3 veces al año por usuario

### ✅ Solución:

#### A. Verificar implementación actual:

El código actual en `show_rating_dialog.dart` es correcto:

```dart
if (await inAppReview.isAvailable()) {
  await inAppReview.requestReview();
} else {
  visit(storeUrl);
}
```

#### B. Limitaciones de la API:

**Android (Google Play)**:

- ✅ Funciona solo si la app está publicada en Play Store
- ✅ Máximo 1 solicitud cada 3 meses por usuario
- ✅ Google decide si mostrar o no el diálogo (no es garantizado)
- ✅ En desarrollo, `isAvailable()` retorna `false`

**iOS (App Store)**:

- ✅ Máximo 3 solicitudes por año
- ✅ Apple decide si mostrar el diálogo

#### C. Mejorar el manejo:

```dart
Future<void> showRatingDialog(BuildContext context) async {
  if (!context.mounted) return;

  final t = AppLocalizations.of(context)!;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      // ... (mantener el diálogo actual)
      actions: [
        TextButton(
          onPressed: () async {
            await RatingHelper.markAsNeverAskAgain();
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          },
          child: Text(t.ratingNoThanks),
        ),
        TextButton(
          onPressed: () async {
            await RatingHelper.markAsPostponed();
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          },
          child: Text(t.ratingLater),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            await RatingHelper.markAsRated();

            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }

            // Intentar mostrar review in-app
            final InAppReview inAppReview = InAppReview.instance;

            try {
              if (await inAppReview.isAvailable()) {
                print('✅ In-app review disponible, mostrando...');
                await inAppReview.requestReview();

                // Esperar un poco y si no funcionó, abrir la tienda
                await Future.delayed(const Duration(seconds: 2));

                // Mostrar mensaje de respaldo
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Si no apareció el diálogo, puedes calificarnos en la tienda'),
                      action: SnackBarAction(
                        label: 'Ir a la tienda',
                        onPressed: () => _openStore(),
                      ),
                    ),
                  );
                }
              } else {
                print('❌ In-app review NO disponible, abriendo tienda...');
                _openStore();
              }
            } catch (e) {
              print('❌ Error en in-app review: $e');
              _openStore();
            }
          },
          icon: const Icon(Icons.star),
          label: Text(t.ratingRateNow),
        ),
      ],
    ),
  );
}

void _openStore() {
  final String storeUrl = Platform.isAndroid
      ? 'https://play.google.com/store/apps/details?id=com.jovannyrch.tablasdeverdad'
      : 'https://apps.apple.com/app/id1234567890';
  visit(storeUrl);
}
```

#### D. Testing del review:

**Durante desarrollo**:

```dart
// Para testing, puedes forzar abrir la tienda:
if (kDebugMode) {
  print('🧪 DEBUG MODE: Abriendo tienda directamente');
  _openStore();
} else {
  // Lógica normal de in-app review
}
```

**En producción**:

- El diálogo in-app solo aparecerá si Google/Apple lo permite
- **No hay garantía** de que se muestre cada vez
- Es normal que no aparezca si ya se pidió recientemente
- Siempre proveer fallback a la tienda

---

## 🚀 Checklist Final Pre-Producción

### PDF:

- [ ] Descargar e integrar NotoSans-Regular.ttf
- [ ] Probar PDF con texto en hindi
- [ ] Verificar que todos los idiomas se ven correctamente

### IAP:

- [ ] Verificar que key.properties existe y es correcto
- [ ] Construir con `flutter build appbundle --release`
- [ ] Verificar firma: `jarsigner -verify -verbose build/app/outputs/bundle/release/app-release.aab`
- [ ] Configurar producto `pro_version` en Google Play Console
- [ ] Activar producto en Play Console
- [ ] Subir AAB a track de testing cerrado/abierto
- [ ] Probar compra con cuenta de prueba

### Rewarded Ads:

- [ ] Agregar debug prints en `_unlockWithAd()`
- [ ] Probar desbloqueo en dispositivo real
- [ ] Verificar scroll automático después de desbloquear

### Review:

- [ ] Agregar logging en `showRatingDialog`
- [ ] Agregar fallback a tienda siempre
- [ ] Probar en app publicada (no funcionará en debug)
- [ ] Documentar que el diálogo puede no aparecer (limitaciones de la plataforma)

---

## 📞 Soporte

Si después de implementar estas soluciones persisten los problemas:

1. **PDF Hindi**: Verificar que NotoSans se cargó correctamente con `print(fontData.length)`
2. **IAP**: Revisar logs de `adb logcat | grep InAppPurchase` para ver errores específicos
3. **Rewarded**: Verificar que los IDs de AdMob son correctos y los anuncios están aprobados
4. **Review**: Es normal que no aparezca siempre, es controlado por la plataforma
