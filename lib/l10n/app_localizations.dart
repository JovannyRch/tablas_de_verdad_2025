import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// No description provided for @adNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'Video no disponible. Intenta más tarde o actualiza a Pro.'**
  String get adNotAvailable;

  /// No description provided for @addedToFavorites.
  ///
  /// In es, this message translates to:
  /// **'Agregado a favoritos'**
  String get addedToFavorites;

  /// No description provided for @advanced_mode.
  ///
  /// In es, this message translates to:
  /// **'Modo avanzado'**
  String get advanced_mode;

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get all;

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Tablas de Verdad'**
  String get appName;

  /// No description provided for @appearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// No description provided for @ascending.
  ///
  /// In es, this message translates to:
  /// **'Ascendente'**
  String get ascending;

  /// No description provided for @becomePro.
  ///
  /// In es, this message translates to:
  /// **'¡Conviértete en Pro!'**
  String get becomePro;

  /// No description provided for @bestStreak.
  ///
  /// In es, this message translates to:
  /// **'Mejor racha'**
  String get bestStreak;

  /// No description provided for @buyPro.
  ///
  /// In es, this message translates to:
  /// **'Adquirir'**
  String get buyPro;

  /// No description provided for @calculationHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de cálculos'**
  String get calculationHistory;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @checkEquivalence.
  ///
  /// In es, this message translates to:
  /// **'Verificar Equivalencia'**
  String get checkEquivalence;

  /// No description provided for @chooseDifficulty.
  ///
  /// In es, this message translates to:
  /// **'Elige la dificultad'**
  String get chooseDifficulty;

  /// No description provided for @clear_all.
  ///
  /// In es, this message translates to:
  /// **'Borrar todo'**
  String get clear_all;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @cnfDescription.
  ///
  /// In es, this message translates to:
  /// **'AND de maxtérminos: un término OR por cada fila donde el resultado es 0.'**
  String get cnfDescription;

  /// No description provided for @cnfTautology.
  ///
  /// In es, this message translates to:
  /// **'No existe FNC — la expresión es una tautología (siempre verdadera).'**
  String get cnfTautology;

  /// No description provided for @cnfTitle.
  ///
  /// In es, this message translates to:
  /// **'Forma Normal Conjuntiva (FNC)'**
  String get cnfTitle;

  /// No description provided for @comparisonTable.
  ///
  /// In es, this message translates to:
  /// **'Tabla Comparativa'**
  String get comparisonTable;

  /// No description provided for @confirmReset.
  ///
  /// In es, this message translates to:
  /// **'Confirmar restablecimiento'**
  String get confirmReset;

  /// No description provided for @confirmResetDesc.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres restablecer todos los ajustes a sus valores predeterminados?'**
  String get confirmResetDesc;

  /// No description provided for @contingency.
  ///
  /// In es, this message translates to:
  /// **'Contingencia ⚠️'**
  String get contingency;

  /// No description provided for @contingency_description.
  ///
  /// In es, this message translates to:
  /// **'Una contingencia se refiere a una proposición o fórmula que no es ni una tautología ni una contradicción. En otras palabras, es una expresión que puede ser verdadera o falsa, dependiendo de las circunstancias o de los valores de verdad de sus componentes.'**
  String get contingency_description;

  /// No description provided for @contradiction.
  ///
  /// In es, this message translates to:
  /// **'Contradicción ❌'**
  String get contradiction;

  /// No description provided for @contradiction_description.
  ///
  /// In es, this message translates to:
  /// **'Una contradicción es una proposición o fórmula lógica que siempre es falsa, independientemente de los valores de verdad de sus componentes. En otras palabras, es una expresión que no se cumple bajo ninguna interpretación o asignación de valores de verdad a sus variables.'**
  String get contradiction_description;

  /// No description provided for @correctAnswer.
  ///
  /// In es, this message translates to:
  /// **'¡Correcto! 🎉'**
  String get correctAnswer;

  /// No description provided for @correctAnswers.
  ///
  /// In es, this message translates to:
  /// **'Correctas'**
  String get correctAnswers;

  /// No description provided for @darkMode.
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro'**
  String get darkMode;

  /// No description provided for @descending.
  ///
  /// In es, this message translates to:
  /// **'Descendente'**
  String get descending;

  /// No description provided for @dnfContradiction.
  ///
  /// In es, this message translates to:
  /// **'No existe FND — la expresión es una contradicción (siempre falsa).'**
  String get dnfContradiction;

  /// No description provided for @dnfDescription.
  ///
  /// In es, this message translates to:
  /// **'OR de mintérminos: un término AND por cada fila donde el resultado es 1.'**
  String get dnfDescription;

  /// No description provided for @dnfTitle.
  ///
  /// In es, this message translates to:
  /// **'Forma Normal Disyuntiva (FND)'**
  String get dnfTitle;

  /// No description provided for @easy.
  ///
  /// In es, this message translates to:
  /// **'Fácil'**
  String get easy;

  /// No description provided for @easyDesc.
  ///
  /// In es, this message translates to:
  /// **'Expresiones simples con 1-2 variables'**
  String get easyDesc;

  /// No description provided for @emptyExpression.
  ///
  /// In es, this message translates to:
  /// **'Por favor, ingresa una expresión lógica'**
  String get emptyExpression;

  /// No description provided for @equivalenceChecker.
  ///
  /// In es, this message translates to:
  /// **'Verificador de Equivalencia'**
  String get equivalenceChecker;

  /// No description provided for @equivalenceError.
  ///
  /// In es, this message translates to:
  /// **'Error de Evaluación'**
  String get equivalenceError;

  /// No description provided for @equivalentDescription.
  ///
  /// In es, this message translates to:
  /// **'Ambas expresiones producen los mismos valores de verdad para todas las combinaciones posibles.'**
  String get equivalentDescription;

  /// No description provided for @expression.
  ///
  /// In es, this message translates to:
  /// **'Expresión'**
  String get expression;

  /// No description provided for @expressionA.
  ///
  /// In es, this message translates to:
  /// **'Expresión A'**
  String get expressionA;

  /// No description provided for @expressionB.
  ///
  /// In es, this message translates to:
  /// **'Expresión B'**
  String get expressionB;

  /// No description provided for @expressionLibrary.
  ///
  /// In es, this message translates to:
  /// **'Biblioteca de expresiones'**
  String get expressionLibrary;

  /// No description provided for @expressionsEquivalent.
  ///
  /// In es, this message translates to:
  /// **'Equivalentes ✅'**
  String get expressionsEquivalent;

  /// No description provided for @expressionsNotEquivalent.
  ///
  /// In es, this message translates to:
  /// **'No Equivalentes ❌'**
  String get expressionsNotEquivalent;

  /// No description provided for @expressionsRemaining.
  ///
  /// In es, this message translates to:
  /// **'Quedan {count} expresiones más'**
  String expressionsRemaining(int count);

  /// No description provided for @favorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get favorites;

  /// No description provided for @fileOptions.
  ///
  /// In es, this message translates to:
  /// **'Opciones de archivo'**
  String get fileOptions;

  /// No description provided for @fullFeatureAccess.
  ///
  /// In es, this message translates to:
  /// **'Acceso completo a todas las funciones'**
  String get fullFeatureAccess;

  /// No description provided for @fullLibraryAccess.
  ///
  /// In es, this message translates to:
  /// **'Acceso completo a la biblioteca de expresiones'**
  String get fullLibraryAccess;

  /// No description provided for @fullTable.
  ///
  /// In es, this message translates to:
  /// **'Tabla completa'**
  String get fullTable;

  /// No description provided for @getStarted.
  ///
  /// In es, this message translates to:
  /// **'¡Empezar!'**
  String get getStarted;

  /// No description provided for @hard.
  ///
  /// In es, this message translates to:
  /// **'Difícil'**
  String get hard;

  /// No description provided for @hardDesc.
  ///
  /// In es, this message translates to:
  /// **'Expresiones complejas con 3-4 variables'**
  String get hardDesc;

  /// No description provided for @history.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get history;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @later.
  ///
  /// In es, this message translates to:
  /// **'Más tarde'**
  String get later;

  /// No description provided for @libraryUnlocked.
  ///
  /// In es, this message translates to:
  /// **'🎉 ¡Biblioteca completa desbloqueada!'**
  String get libraryUnlocked;

  /// No description provided for @maxterms.
  ///
  /// In es, this message translates to:
  /// **'maxtérminos'**
  String get maxterms;

  /// No description provided for @medium.
  ///
  /// In es, this message translates to:
  /// **'Medio'**
  String get medium;

  /// No description provided for @mediumDesc.
  ///
  /// In es, this message translates to:
  /// **'Expresiones compuestas con 2-3 variables'**
  String get mediumDesc;

  /// No description provided for @mintermOrder.
  ///
  /// In es, this message translates to:
  /// **'Orden de minterms'**
  String get mintermOrder;

  /// No description provided for @minterms.
  ///
  /// In es, this message translates to:
  /// **'mintérminos'**
  String get minterms;

  /// No description provided for @moreExpressions.
  ///
  /// In es, this message translates to:
  /// **'expresiones más'**
  String get moreExpressions;

  /// No description provided for @more_info.
  ///
  /// In es, this message translates to:
  /// **'Más información'**
  String get more_info;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @noAds.
  ///
  /// In es, this message translates to:
  /// **'Sin anuncios'**
  String get noAds;

  /// No description provided for @noFavorites.
  ///
  /// In es, this message translates to:
  /// **'Sin favoritos'**
  String get noFavorites;

  /// No description provided for @noPurchasesFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron compras previas'**
  String get noPurchasesFound;

  /// No description provided for @no_history.
  ///
  /// In es, this message translates to:
  /// **'No hay historial'**
  String get no_history;

  /// No description provided for @normalForms.
  ///
  /// In es, this message translates to:
  /// **'Formas Normales'**
  String get normalForms;

  /// No description provided for @normalFormsAdGate.
  ///
  /// In es, this message translates to:
  /// **'Mira un breve video para desbloquear las Formas Normales de esta expresión.'**
  String get normalFormsAdGate;

  /// No description provided for @normalFormsDescription.
  ///
  /// In es, this message translates to:
  /// **'Convierte la expresión a su Forma Normal Disyuntiva (FND) y Forma Normal Conjuntiva (FNC) usando la tabla de verdad.'**
  String get normalFormsDescription;

  /// No description provided for @normalFormsProHint.
  ///
  /// In es, this message translates to:
  /// **'Actualiza a Pro para ver las Formas Normales al instante sin anuncios.'**
  String get normalFormsProHint;

  /// No description provided for @normalFormsTitle.
  ///
  /// In es, this message translates to:
  /// **'Formas Normales'**
  String get normalFormsTitle;

  /// No description provided for @normalFormsTooManyVars.
  ///
  /// In es, this message translates to:
  /// **'Demasiadas variables (máx {max})'**
  String normalFormsTooManyVars(Object max);

  /// No description provided for @normalFormsTooManyVarsDesc.
  ///
  /// In es, this message translates to:
  /// **'La conversión a formas normales está limitada a expresiones con hasta 5 variables para mantener la salida legible.'**
  String get normalFormsTooManyVarsDesc;

  /// No description provided for @notEquivalentDescription.
  ///
  /// In es, this message translates to:
  /// **'Difieren en {differing} de {total} filas ({pct}% coinciden).'**
  String notEquivalentDescription(Object differing, Object pct, Object total);

  /// No description provided for @numberOfPropositions.
  ///
  /// In es, this message translates to:
  /// **'Cantidad de proposiciones'**
  String get numberOfPropositions;

  /// No description provided for @numberOfRows.
  ///
  /// In es, this message translates to:
  /// **'Cantidad de filas'**
  String get numberOfRows;

  /// No description provided for @ok.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get ok;

  /// No description provided for @onboardingDesc1.
  ///
  /// In es, this message translates to:
  /// **'Usa el teclado para ingresar cualquier expresión lógica con variables y operadores'**
  String get onboardingDesc1;

  /// No description provided for @onboardingDesc2.
  ///
  /// In es, this message translates to:
  /// **'Visualiza cada paso de la resolución y la tabla de verdad completa'**
  String get onboardingDesc2;

  /// No description provided for @onboardingDesc3.
  ///
  /// In es, this message translates to:
  /// **'Genera PDFs profesionales y comparte tus resultados fácilmente'**
  String get onboardingDesc3;

  /// No description provided for @onboardingTitle1.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu expresión'**
  String get onboardingTitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In es, this message translates to:
  /// **'Solución paso a paso'**
  String get onboardingTitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In es, this message translates to:
  /// **'Exporta y comparte'**
  String get onboardingTitle3;

  /// No description provided for @oneTimePurchase.
  ///
  /// In es, this message translates to:
  /// **'Compra única'**
  String get oneTimePurchase;

  /// No description provided for @only_tutorials.
  ///
  /// In es, this message translates to:
  /// **'Solo mostrar tutoriales'**
  String get only_tutorials;

  /// No description provided for @openFile.
  ///
  /// In es, this message translates to:
  /// **'Abrir archivo'**
  String get openFile;

  /// No description provided for @pdfFilename.
  ///
  /// In es, this message translates to:
  /// **'tabla_de_verdad'**
  String get pdfFilename;

  /// No description provided for @playAgain.
  ///
  /// In es, this message translates to:
  /// **'Jugar de nuevo'**
  String get playAgain;

  /// No description provided for @practiceMode.
  ///
  /// In es, this message translates to:
  /// **'Modo Práctica'**
  String get practiceMode;

  /// No description provided for @preferences.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get preferences;

  /// No description provided for @premiumOperator.
  ///
  /// In es, this message translates to:
  /// **'Operador Premium'**
  String get premiumOperator;

  /// No description provided for @premiumOperatorMessage.
  ///
  /// In es, this message translates to:
  /// **'Este operador avanzado requiere ver un video o actualizar a Pro para acceso ilimitado.'**
  String get premiumOperatorMessage;

  /// No description provided for @premiumOperatorsAccess.
  ///
  /// In es, this message translates to:
  /// **'Acceso a todos los operadores premium'**
  String get premiumOperatorsAccess;

  /// No description provided for @premiumSupport.
  ///
  /// In es, this message translates to:
  /// **'Soporte Premium'**
  String get premiumSupport;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get privacyPolicy;

  /// No description provided for @proUpgradeHint.
  ///
  /// In es, this message translates to:
  /// **'¡Mejora a Pro para práctica ilimitada con todos los operadores y sin anuncios!'**
  String get proUpgradeHint;

  /// No description provided for @propositions.
  ///
  /// In es, this message translates to:
  /// **'Proposiciones'**
  String get propositions;

  /// No description provided for @purchaseError.
  ///
  /// In es, this message translates to:
  /// **'Error en la compra. Intenta de nuevo.'**
  String get purchaseError;

  /// No description provided for @question.
  ///
  /// In es, this message translates to:
  /// **'Pregunta'**
  String get question;

  /// No description provided for @quizResults.
  ///
  /// In es, this message translates to:
  /// **'Resultados del quiz'**
  String get quizResults;

  /// No description provided for @quizzesPlayed.
  ///
  /// In es, this message translates to:
  /// **'Jugados'**
  String get quizzesPlayed;

  /// No description provided for @rateTheApp.
  ///
  /// In es, this message translates to:
  /// **'Calificar la app'**
  String get rateTheApp;

  /// No description provided for @ratingDialogMessage.
  ///
  /// In es, this message translates to:
  /// **'¡Tu opinión es muy importante para nosotros! Si te ha gustado Tablas de Verdad, nos encantaría que nos dejaras una calificación de 5 estrellas ⭐'**
  String get ratingDialogMessage;

  /// No description provided for @ratingDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Te gusta la app?'**
  String get ratingDialogTitle;

  /// No description provided for @ratingLater.
  ///
  /// In es, this message translates to:
  /// **'Más tarde'**
  String get ratingLater;

  /// No description provided for @ratingNoThanks.
  ///
  /// In es, this message translates to:
  /// **'No, gracias'**
  String get ratingNoThanks;

  /// No description provided for @ratingRateNow.
  ///
  /// In es, this message translates to:
  /// **'¡Calificar ahora!'**
  String get ratingRateNow;

  /// No description provided for @remainingExpressions.
  ///
  /// In es, this message translates to:
  /// **'Quedan'**
  String get remainingExpressions;

  /// No description provided for @removedFromFavorites.
  ///
  /// In es, this message translates to:
  /// **'Eliminado de favoritos'**
  String get removedFromFavorites;

  /// No description provided for @resetDefaults.
  ///
  /// In es, this message translates to:
  /// **'Restablecer valores predeterminados'**
  String get resetDefaults;

  /// No description provided for @restorePurchases.
  ///
  /// In es, this message translates to:
  /// **'Restaurar compras'**
  String get restorePurchases;

  /// No description provided for @result.
  ///
  /// In es, this message translates to:
  /// **'Resultado'**
  String get result;

  /// No description provided for @searchHistory.
  ///
  /// In es, this message translates to:
  /// **'Buscar en historial...'**
  String get searchHistory;

  /// No description provided for @seeResults.
  ///
  /// In es, this message translates to:
  /// **'Ver resultados'**
  String get seeResults;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuraciones'**
  String get settings;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuraciones'**
  String get settingsTitle;

  /// No description provided for @settings_mode.
  ///
  /// In es, this message translates to:
  /// **'Modo'**
  String get settings_mode;

  /// No description provided for @shareFile.
  ///
  /// In es, this message translates to:
  /// **'Compartir archivo'**
  String get shareFile;

  /// No description provided for @shareFileMessage.
  ///
  /// In es, this message translates to:
  /// **'Te comparto este archivo.'**
  String get shareFileMessage;

  /// No description provided for @simple_mode.
  ///
  /// In es, this message translates to:
  /// **'Modo simple'**
  String get simple_mode;

  /// No description provided for @skip.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get skip;

  /// No description provided for @socialProof.
  ///
  /// In es, this message translates to:
  /// **'Confiado por miles de estudiantes'**
  String get socialProof;

  /// No description provided for @steps.
  ///
  /// In es, this message translates to:
  /// **'Pasos de resolución'**
  String get steps;

  /// No description provided for @supportDeveloper.
  ///
  /// In es, this message translates to:
  /// **'Apoya al desarrollador'**
  String get supportDeveloper;

  /// No description provided for @swapExpressions.
  ///
  /// In es, this message translates to:
  /// **'Intercambiar expresiones'**
  String get swapExpressions;

  /// No description provided for @t_f.
  ///
  /// In es, this message translates to:
  /// **'V/F'**
  String get t_f;

  /// No description provided for @tautology.
  ///
  /// In es, this message translates to:
  /// **'Tautología ✅'**
  String get tautology;

  /// No description provided for @tautology_description.
  ///
  /// In es, this message translates to:
  /// **'Una tautología es una proposición o fórmula lógica que siempre es verdadera, independientemente de los valores de verdad de sus componentes. En otras palabras, es una expresión que se cumple bajo cualquier interpretación o asignación de valores de verdad a sus variables.'**
  String get tautology_description;

  /// No description provided for @truthValues.
  ///
  /// In es, this message translates to:
  /// **'Valores de verdad'**
  String get truthValues;

  /// No description provided for @tutorials.
  ///
  /// In es, this message translates to:
  /// **'Tutoriales'**
  String get tutorials;

  /// No description provided for @type.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get type;

  /// No description provided for @unlimitedPremiumOps.
  ///
  /// In es, this message translates to:
  /// **'Operadores premium ilimitados'**
  String get unlimitedPremiumOps;

  /// No description provided for @unlockFullLibrary.
  ///
  /// In es, this message translates to:
  /// **'¡Desbloquea la biblioteca completa!'**
  String get unlockFullLibrary;

  /// No description provided for @unlockLibraryTitle.
  ///
  /// In es, this message translates to:
  /// **'🎯 ¡Desbloquea la biblioteca completa!'**
  String get unlockLibraryTitle;

  /// No description provided for @upgradePro.
  ///
  /// In es, this message translates to:
  /// **'Actualizar a Pro'**
  String get upgradePro;

  /// No description provided for @validationMissingOperand.
  ///
  /// In es, this message translates to:
  /// **'Falta un operando'**
  String get validationMissingOperand;

  /// No description provided for @validationMissingOperator.
  ///
  /// In es, this message translates to:
  /// **'Falta un operador entre variables'**
  String get validationMissingOperator;

  /// No description provided for @validationTrailingOp.
  ///
  /// In es, this message translates to:
  /// **'Expresión incompleta'**
  String get validationTrailingOp;

  /// No description provided for @validationUnmatched.
  ///
  /// In es, this message translates to:
  /// **'Paréntesis sin cerrar'**
  String get validationUnmatched;

  /// No description provided for @validationValid.
  ///
  /// In es, this message translates to:
  /// **'Lista para evaluar'**
  String get validationValid;

  /// No description provided for @videoFABLabel.
  ///
  /// In es, this message translates to:
  /// **'Ver video'**
  String get videoFABLabel;

  /// No description provided for @videoFABTooltip.
  ///
  /// In es, this message translates to:
  /// **'Explicación en video'**
  String get videoFABTooltip;

  /// No description provided for @videoScreenDescription.
  ///
  /// In es, this message translates to:
  /// **'Este video explica paso a paso la resolución de esta expresión lógica.'**
  String get videoScreenDescription;

  /// No description provided for @videoScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Explicación en video'**
  String get videoScreenTitle;

  /// No description provided for @watchVideoFree.
  ///
  /// In es, this message translates to:
  /// **'Ver Video (Gratis)'**
  String get watchVideoFree;

  /// No description provided for @whatTypeIsThis.
  ///
  /// In es, this message translates to:
  /// **'¿Qué tipo de expresión es?'**
  String get whatTypeIsThis;

  /// No description provided for @wrongAnswer.
  ///
  /// In es, this message translates to:
  /// **'Incorrecto. ¡Sigue intentando!'**
  String get wrongAnswer;

  /// No description provided for @yourStats.
  ///
  /// In es, this message translates to:
  /// **'Tus estadísticas'**
  String get yourStats;

  /// No description provided for @youtubeChannel.
  ///
  /// In es, this message translates to:
  /// **'Canal de YouTube'**
  String get youtubeChannel;

  /// No description provided for @shareExpression.
  ///
  /// In es, this message translates to:
  /// **'Compartir expresión'**
  String get shareExpression;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'hi', 'it', 'ja', 'pt', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'hi': return AppLocalizationsHi();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
