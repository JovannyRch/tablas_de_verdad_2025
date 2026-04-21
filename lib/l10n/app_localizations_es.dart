// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get about => 'Acerca de';

  @override
  String get adNotAvailable =>
      'Video no disponible. Intenta más tarde o actualiza a Pro.';

  @override
  String get addedToFavorites => 'Agregado a favoritos';

  @override
  String get advanced_mode => 'Modo avanzado';

  @override
  String get all => 'Todos';

  @override
  String get appName => 'Tablas de Verdad';

  @override
  String get appearance => 'Apariencia';

  @override
  String get ascending => 'Ascendente';

  @override
  String get becomePro => '¡Conviértete en Pro!';

  @override
  String get bestStreak => 'Mejor racha';

  @override
  String get buyPro => 'Adquirir';

  @override
  String get calculationHistory => 'Historial de cálculos';

  @override
  String get cancel => 'Cancelar';

  @override
  String get checkEquivalence => 'Verificar Equivalencia';

  @override
  String get chooseDifficulty => 'Elige la dificultad';

  @override
  String get clear_all => 'Borrar todo';

  @override
  String get close => 'Cerrar';

  @override
  String get cnfDescription =>
      'AND de maxtérminos: un término OR por cada fila donde el resultado es 0.';

  @override
  String get cnfTautology =>
      'No existe FNC — la expresión es una tautología (siempre verdadera).';

  @override
  String get cnfTitle => 'Forma Normal Conjuntiva (FNC)';

  @override
  String get comparisonTable => 'Tabla Comparativa';

  @override
  String get confirmReset => 'Confirmar restablecimiento';

  @override
  String get confirmResetDesc =>
      '¿Estás seguro de que quieres restablecer todos los ajustes a sus valores predeterminados?';

  @override
  String get contingency => 'Contingencia ⚠️';

  @override
  String get contingency_description =>
      'Una contingencia se refiere a una proposición o fórmula que no es ni una tautología ni una contradicción. En otras palabras, es una expresión que puede ser verdadera o falsa, dependiendo de las circunstancias o de los valores de verdad de sus componentes.';

  @override
  String get contradiction => 'Contradicción ❌';

  @override
  String get contradiction_description =>
      'Una contradicción es una proposición o fórmula lógica que siempre es falsa, independientemente de los valores de verdad de sus componentes. En otras palabras, es una expresión que no se cumple bajo ninguna interpretación o asignación de valores de verdad a sus variables.';

  @override
  String get correctAnswer => '¡Correcto! 🎉';

  @override
  String get correctAnswers => 'Correctas';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get descending => 'Descendente';

  @override
  String get dnfContradiction =>
      'No existe FND — la expresión es una contradicción (siempre falsa).';

  @override
  String get dnfDescription =>
      'OR de mintérminos: un término AND por cada fila donde el resultado es 1.';

  @override
  String get dnfTitle => 'Forma Normal Disyuntiva (FND)';

  @override
  String get easy => 'Fácil';

  @override
  String get easyDesc => 'Expresiones simples con 1-2 variables';

  @override
  String get emptyExpression => 'Por favor, ingresa una expresión lógica';

  @override
  String get equivalenceChecker => 'Verificador de Equivalencia';

  @override
  String get equivalenceError => 'Error de Evaluación';

  @override
  String get equivalentDescription =>
      'Ambas expresiones producen los mismos valores de verdad para todas las combinaciones posibles.';

  @override
  String get expression => 'Expresión';

  @override
  String get expressionA => 'Expresión A';

  @override
  String get expressionB => 'Expresión B';

  @override
  String get expressionLibrary => 'Biblioteca de expresiones';

  @override
  String get expressionsEquivalent => 'Equivalentes ✅';

  @override
  String get expressionsNotEquivalent => 'No Equivalentes ❌';

  @override
  String expressionsRemaining(int count) {
    return 'Quedan $count expresiones más';
  }

  @override
  String get favorites => 'Favoritos';

  @override
  String get fileOptions => 'Opciones de archivo';

  @override
  String get fullFeatureAccess => 'Acceso completo a todas las funciones';

  @override
  String get fullLibraryAccess =>
      'Acceso completo a la biblioteca de expresiones';

  @override
  String get fullTable => 'Tabla completa';

  @override
  String get getStarted => '¡Empezar!';

  @override
  String get hard => 'Difícil';

  @override
  String get hardDesc => 'Expresiones complejas con 3-4 variables';

  @override
  String get history => 'Historial';

  @override
  String get language => 'Idioma';

  @override
  String get later => 'Más tarde';

  @override
  String get libraryUnlocked => '🎉 ¡Biblioteca completa desbloqueada!';

  @override
  String get maxterms => 'maxtérminos';

  @override
  String get medium => 'Medio';

  @override
  String get mediumDesc => 'Expresiones compuestas con 2-3 variables';

  @override
  String get mintermOrder => 'Orden de minterms';

  @override
  String get minterms => 'mintérminos';

  @override
  String get moreExpressions => 'expresiones más';

  @override
  String get more_info => 'Más información';

  @override
  String get next => 'Siguiente';

  @override
  String get noAds => 'Sin anuncios';

  @override
  String get noFavorites => 'Sin favoritos';

  @override
  String get noPurchasesFound => 'No se encontraron compras previas';

  @override
  String get no_history => 'No hay historial';

  @override
  String get normalForms => 'Formas Normales';

  @override
  String get normalFormsAdGate =>
      'Mira un breve video para desbloquear las Formas Normales de esta expresión.';

  @override
  String get normalFormsDescription =>
      'Convierte la expresión a su Forma Normal Disyuntiva (FND) y Forma Normal Conjuntiva (FNC) usando la tabla de verdad.';

  @override
  String get normalFormsProHint =>
      'Actualiza a Pro para ver las Formas Normales al instante sin anuncios.';

  @override
  String get normalFormsTitle => 'Formas Normales';

  @override
  String normalFormsTooManyVars(Object max) {
    return 'Demasiadas variables (máx $max)';
  }

  @override
  String get normalFormsTooManyVarsDesc =>
      'La conversión a formas normales está limitada a expresiones con hasta 5 variables para mantener la salida legible.';

  @override
  String notEquivalentDescription(Object differing, Object pct, Object total) {
    return 'Difieren en $differing de $total filas ($pct% coinciden).';
  }

  @override
  String get numberOfPropositions => 'Cantidad de proposiciones';

  @override
  String get numberOfRows => 'Cantidad de filas';

  @override
  String get ok => 'Aceptar';

  @override
  String get onboardingDesc1 =>
      'Usa el teclado para ingresar cualquier expresión lógica con variables y operadores';

  @override
  String get onboardingDesc2 =>
      'Visualiza cada paso de la resolución y la tabla de verdad completa';

  @override
  String get onboardingDesc3 =>
      'Genera PDFs profesionales y comparte tus resultados fácilmente';

  @override
  String get onboardingTitle1 => 'Escribe tu expresión';

  @override
  String get onboardingTitle2 => 'Solución paso a paso';

  @override
  String get onboardingTitle3 => 'Exporta y comparte';

  @override
  String get oneTimePurchase => 'Compra única';

  @override
  String get only_tutorials => 'Solo mostrar tutoriales';

  @override
  String get openFile => 'Abrir archivo';

  @override
  String get pdfFilename => 'tabla_de_verdad';

  @override
  String get playAgain => 'Jugar de nuevo';

  @override
  String get practiceMode => 'Modo Práctica';

  @override
  String get preferences => 'Preferencias';

  @override
  String get premiumOperator => 'Operador Premium';

  @override
  String get premiumOperatorMessage =>
      'Este operador avanzado requiere ver un video o actualizar a Pro para acceso ilimitado.';

  @override
  String get premiumOperatorsAccess => 'Acceso a todos los operadores premium';

  @override
  String get premiumSupport => 'Soporte Premium';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get proUpgradeHint =>
      '¡Mejora a Pro para práctica ilimitada con todos los operadores y sin anuncios!';

  @override
  String get propositions => 'Proposiciones';

  @override
  String get purchaseError => 'Error en la compra. Intenta de nuevo.';

  @override
  String get question => 'Pregunta';

  @override
  String get quizResults => 'Resultados del quiz';

  @override
  String get quizzesPlayed => 'Jugados';

  @override
  String get rateTheApp => 'Calificar la app';

  @override
  String get ratingDialogMessage =>
      '¡Tu opinión es muy importante para nosotros! Si te ha gustado Tablas de Verdad, nos encantaría que nos dejaras una calificación de 5 estrellas ⭐';

  @override
  String get ratingDialogTitle => '¿Te gusta la app?';

  @override
  String get ratingLater => 'Más tarde';

  @override
  String get ratingNoThanks => 'No, gracias';

  @override
  String get ratingRateNow => '¡Calificar ahora!';

  @override
  String get remainingExpressions => 'Quedan';

  @override
  String get removedFromFavorites => 'Eliminado de favoritos';

  @override
  String get resetDefaults => 'Restablecer valores predeterminados';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get result => 'Resultado';

  @override
  String get searchHistory => 'Buscar en historial...';

  @override
  String get seeResults => 'Ver resultados';

  @override
  String get settings => 'Configuraciones';

  @override
  String get settingsTitle => 'Configuraciones';

  @override
  String get settings_mode => 'Modo';

  @override
  String get shareFile => 'Compartir archivo';

  @override
  String get shareFileMessage => 'Te comparto este archivo.';

  @override
  String get simple_mode => 'Modo simple';

  @override
  String get skip => 'Omitir';

  @override
  String get socialProof => 'Confiado por miles de estudiantes';

  @override
  String get steps => 'Pasos de resolución';

  @override
  String get supportDeveloper => 'Apoya al desarrollador';

  @override
  String get swapExpressions => 'Intercambiar expresiones';

  @override
  String get t_f => 'V/F';

  @override
  String get tautology => 'Tautología ✅';

  @override
  String get tautology_description =>
      'Una tautología es una proposición o fórmula lógica que siempre es verdadera, independientemente de los valores de verdad de sus componentes. En otras palabras, es una expresión que se cumple bajo cualquier interpretación o asignación de valores de verdad a sus variables.';

  @override
  String get truthValues => 'Valores de verdad';

  @override
  String get tutorials => 'Tutoriales';

  @override
  String get type => 'Tipo';

  @override
  String get unlimitedPremiumOps => 'Operadores premium ilimitados';

  @override
  String get unlockFullLibrary => '¡Desbloquea la biblioteca completa!';

  @override
  String get unlockLibraryTitle => '🎯 ¡Desbloquea la biblioteca completa!';

  @override
  String get upgradePro => 'Actualizar a Pro';

  @override
  String get validationMissingOperand => 'Falta un operando';

  @override
  String get validationMissingOperator => 'Falta un operador entre variables';

  @override
  String get validationTrailingOp => 'Expresión incompleta';

  @override
  String get validationUnmatched => 'Paréntesis sin cerrar';

  @override
  String get validationValid => 'Lista para evaluar';

  @override
  String get videoFABLabel => 'Ver video';

  @override
  String get videoFABTooltip => 'Explicación en video';

  @override
  String get videoScreenDescription =>
      'Este video explica paso a paso la resolución de esta expresión lógica.';

  @override
  String get videoScreenTitle => 'Explicación en video';

  @override
  String get watchVideoFree => 'Ver Video (Gratis)';

  @override
  String get whatTypeIsThis => '¿Qué tipo de expresión es?';

  @override
  String get wrongAnswer => 'Incorrecto. ¡Sigue intentando!';

  @override
  String get yourStats => 'Tus estadísticas';

  @override
  String get youtubeChannel => 'Canal de YouTube';

  @override
  String get shareExpression => 'Compartir expresión';

  @override
  String get discordCommunity => 'Comunidad en Discord';

  @override
  String get argumentValidator => 'Validador de Argumentos';

  @override
  String get premise => 'Premisa';

  @override
  String get addPremise => 'Agregar premisa';

  @override
  String get removePremise => 'Eliminar';

  @override
  String get conclusionLabel => 'Conclusión';

  @override
  String get validateArgument => 'Validar argumento';

  @override
  String get validArgument => 'Argumento válido ✅';

  @override
  String get invalidArgument => 'Argumento inválido ❌';

  @override
  String get validArgumentDesc =>
      'En todas las combinaciones donde las premisas son verdaderas, la conclusión también lo es. El argumento es lógicamente válido.';

  @override
  String get invalidArgumentDesc =>
      'Existe al menos una combinación donde todas las premisas son verdaderas pero la conclusión es falsa.';

  @override
  String get counterexamples => 'Contraejemplos';

  @override
  String get argumentHint => 'Ingresa una expresión lógica';
}
