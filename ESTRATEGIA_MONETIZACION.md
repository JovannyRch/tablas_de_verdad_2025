# 💰 Estrategia de Monetización Mejorada

## 📊 Cambios Implementados

### 1. ✅ Anuncios Intersticiales Menos Invasivos

**Antes:**

- Se mostraba un anuncio intersticial en **cada** cálculo
- Experiencia de usuario muy invasiva
- Alta probabilidad de abandono

**Ahora:**

- Anuncios cada **3 cálculos** (configurable en `Settings.adFrequency`)
- Experiencia mucho más fluida
- El usuario puede resolver 2 expresiones sin interrupciones
- Aumenta la retención y satisfacción del usuario

**Código:**

```dart
// En Settings:
int adFrequency = 3; // Mostrar ad cada N operaciones

bool shouldShowInterstitialAd() {
  return !isProVersion && operationsCount % adFrequency == 0;
}

// En Calculator Screen:
if (_settings.shouldShowInterstitialAd()) {
  ads.showInterstitialAd();
}
```

---

### 2. 🎯 Rewarded Ads para Operadores Premium

**Concepto:**
Los operadores avanzados/poco comunes ahora requieren que el usuario:

1. Vea un **Rewarded Ad** (video con recompensa), O
2. Actualice a **versión Pro**

**Operadores Premium** (requieren rewarded ad):

- `⇏` - NOT Condicional
- `⊻` - XOR
- `￩` - Anticondicional
- `⇎` - NOT Bicondicional
- `⊕` - XOR2
- `⊼` - NAND
- `⇍` - NOT Condicional Inverso
- `↓` - NOR
- `┹` - Operador especial 1
- `┲` - Operador especial 2

**Flujo de Usuario:**

1. Usuario ingresa expresión con operador premium (ej: `A ⊼ B`)
2. Sistema detecta el operador premium
3. Muestra diálogo: "🎯 Operador Premium"
4. Opciones:
   - **Cancelar**: Vuelve a editar la expresión
   - **Ver Video (Gratis)**: Muestra rewarded ad → Permite calcular
   - **Actualizar a Pro**: Lleva a pantalla de compra

**Ventajas:**

- ✅ Monetiza funcionalidad avanzada sin bloquearla completamente
- ✅ Los usuarios básicos no se ven afectados (solo usan operadores simples)
- ✅ Incentiva actualización a Pro
- ✅ Mayor eCPM que intersticiales (rewarded ads pagan más)
- ✅ Usuario tiene control (puede elegir ver video o no usar el operador)

---

## 📱 Experiencia de Usuario Mejorada

### Para Usuarios Gratuitos:

**Operadores Básicos** (Uso Ilimitado Sin Ads):

- Variables: `p, q, r, s, a, b, c...z, 0, 1`
- Operadores: `∧ (AND)`, `∨ (OR)`, `⇒ (Implicación)`, `¬ (Negación)`, `⇔ (Bicondicional)`, `()` Paréntesis

**Operadores Premium** (Requieren Rewarded Ad):

- Solo se activa cuando específicamente los usan
- Pueden ver un video de 15-30 segundos
- Acceso temporal al operador (por sesión o por cálculo)

**Anuncios Intersticiales:**

- Cada 3 cálculos exitosos
- Solo en usuarios no Pro
- No invasivo

### Para Usuarios Pro:

- ✅ Sin anuncios de ningún tipo
- ✅ Acceso ilimitado a todos los operadores
- ✅ Experiencia premium sin interrupciones
- ✅ Soporte prioritario

---

## 🔧 Configuración en AdMob

### IDs Necesarios:

1. **Interstitial Ad** (ya configurado):
   - ES: `ca-app-pub-4665787383933447/1003394249`
   - EN: `ca-app-pub-4665787383933447/2599030026`

2. **Rewarded Ad** (NUEVO - debes crear):
   - Ir a AdMob Console
   - Crear nueva unidad de anuncio tipo "Rewarded"
   - Copiar ID y actualizar en `const.dart`:
   ```dart
   String REWARDED_AD_ID = "ca-app-pub-XXXXXXX/XXXXXXX";
   ```

   - Actualizar en `rewarded_ad_helper.dart`

### Test IDs (ya configurados en desarrollo):

```dart
Android: 'ca-app-pub-3940256099942544/5224354917'
iOS: 'ca-app-pub-3940256099942544/1712485313'
```

---

## 📈 Proyección de Ingresos

### Estimación Conservadora:

**Escenario Actual (antes):**

- 1000 usuarios/día
- 100% ven intersticial cada cálculo
- 3 cálculos promedio = 3000 impresiones/día
- eCPM $2 = $6/día = $180/mes

**Escenario Mejorado (ahora):**

**Intersticiales (menos frecuentes):**

- 1000 usuarios/día
- 3 cálculos promedio = 1000 impresiones/día (cada 3 cálculos)
- eCPM $2 = $2/día = $60/mes

**Rewarded Ads (premium operators):**

- 10% usuarios usan operadores premium = 100 usuarios/día
- 80% ven el video = 80 impresiones/día
- eCPM $8 (rewarded paga más) = $0.64/día = $19.2/mes

**Conversiones a Pro:**

- Mejor experiencia = +20% conversión
- 1% de 1000 usuarios = 10 conversiones/mes
- $4.99 cada uno = $49.90/mes

**Total estimado:** $60 + $19.2 + $49.9 = **$129.1/mes**

Aunque es menor en ads, la mejor UX aumentará:

- ✅ Retención de usuarios
- ✅ Valoración en Play Store
- ✅ Conversiones a Pro
- ✅ Recomendaciones orgánicas

---

## 🎛️ Ajustes Disponibles

### Cambiar Frecuencia de Intersticiales:

```dart
// En settings_model.dart
int adFrequency = 3; // Cambiar a 2, 4, 5, etc.
```

### Agregar/Quitar Operadores Premium:

```dart
// En const/calculator.dart
const kPremiumOperators = [
  '⇏',  // Agregar o quitar según estrategia
  '⊻',
  // ...
];
```

### Deshabilitar Rewarded Ads (temporalmente):

```dart
// En calculator_screen.dart, comentar:
if (!_settings.isProVersion && _containsPremiumOperators(expression)) {
  // ...
}
```

---

## 🧪 Testing

### Probar Intersticiales:

1. Asegúrate que `IS_TESTING = true` en `const.dart`
2. Realiza 3 cálculos consecutivos
3. En el 3º cálculo debe aparecer test ad

### Probar Rewarded Ads:

1. Usa un operador premium: `A ⊼ B`
2. Debe aparecer diálogo "Operador Premium"
3. Click en "Ver Video (Gratis)"
4. Debe aparecer test ad
5. Completa el video
6. Continúa con el cálculo

### Verificar que Pro funciona:

1. Activa versión Pro (en settings o mediante compra)
2. No deben aparecer anuncios de ningún tipo
3. Operadores premium sin restricción

---

## 📋 Checklist Pre-Lanzamiento

- [ ] Crear unidad Rewarded Ad en AdMob Console
- [ ] Actualizar `REWARDED_AD_ID` en código
- [ ] Cambiar `IS_TESTING = false` en producción
- [ ] Probar flujo completo (gratuito y Pro)
- [ ] Verificar traducciones (ES/EN)
- [ ] Documentar cambios en notas de versión
- [ ] A/B testing de frecuencia de ads (3 vs 4 vs 5)

---

## 🔮 Futuras Mejoras

1. **Límite de Rewarded Ads:**
   - Después de ver 5 videos en un día, bloquear operadores premium
   - Incentiva más la conversión a Pro

2. **Sistema de Créditos:**
   - Cada rewarded ad da 3 créditos
   - Cada operador premium cuesta 1 crédito
   - Pro = créditos ilimitados

3. **Operadores Progresivos:**
   - Primeros 10 usos de operador premium: gratis
   - Después: rewarded ad
   - Crea "adicción" antes de monetizar

4. **Analytics:**
   - Trackear qué operadores premium son más usados
   - Ajustar lista según demanda real

---

## 💡 Recomendaciones

### Para Maximizar Ingresos:

1. **Mantén `adFrequency = 3`** - Buen balance UX/monetización
2. **Promueve operadores premium** - Agrega tooltips educativos
3. **Optimiza conversión a Pro** - Muestra beneficios constantemente
4. **Analiza métricas** - Ajusta según datos reales

### Para Maximizar Retención:

1. **Nunca bloquees funcionalidad básica**
2. **Opciones siempre disponibles** (ver video o actualizar)
3. **Feedback positivo** después de ver ads
4. **Transparencia** sobre qué es premium y por qué

---

**Última actualización:** Enero 26, 2026
**Autor:** Jovanny Ramirez
