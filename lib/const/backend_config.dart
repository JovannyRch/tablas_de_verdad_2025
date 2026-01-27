// Configuración de Backend API
// Cambiar estos valores según el estado del servidor

/// Flag para habilitar/deshabilitar el backend completamente
const bool BACKEND_ENABLED = false; // TODO: Cambiar a true cuando el backend esté disponible

/// URLs del backend
const String BACKEND_URL = 'https://jovannyrch-1dfc553c9cbb.herokuapp.com';
const String API_BASE_URL = '$BACKEND_URL/api';

/// Endpoints específicos
class ApiEndpoints {
  static const String expressions = '$API_BASE_URL/expressions';
  static const String expressionsList = '$API_BASE_URL/expressions';
}

/// Configuración de timeouts
const Duration API_TIMEOUT = Duration(seconds: 10);
const Duration CONNECT_TIMEOUT = Duration(seconds: 5);

/// Mensajes de error
class ApiErrorMessages {
  static const String serverDown = 'Servidor temporalmente no disponible';
  static const String noConnection = 'Sin conexión a internet';
  static const String timeout = 'Tiempo de espera agotado';
  static const String unknown = 'Error desconocido';
}

/// Clase para verificar disponibilidad del backend
class BackendStatus {
  static bool get isAvailable => BACKEND_ENABLED;
  
  static String get statusMessage {
    if (BACKEND_ENABLED) {
      return 'Backend: Activo ✅';
    } else {
      return 'Backend: Desactivado ⚠️ (Modo offline)';
    }
  }
}
