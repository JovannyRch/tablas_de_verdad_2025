// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get adNotAvailable => 'Видео недоступно. Попробуйте позже или перейдите на Pro.';

  @override
  String get advanced_mode => 'Расширенный режим';

  @override
  String get appName => 'Таблицы Истинности';

  @override
  String get ascending => 'По возрастанию';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get about => 'О программе';

  @override
  String get becomePro => 'Станьте Pro!';

  @override
  String get clear_all => 'Очистить всё';

  @override
  String get close => 'Закрыть';

  @override
  String get buyPro => 'Купить';

  @override
  String get calculationHistory => 'История вычислений';

  @override
  String get cancel => 'Отмена';

  @override
  String get contingency => 'Случайность ⚠️';

  @override
  String get contingency_description => 'Случайность относится к утверждению или формуле, которая не является ни тавтологией, ни противоречием. Другими словами, это выражение, которое может быть истинным или ложным в зависимости от обстоятельств или значений истинности его компонентов.';

  @override
  String get contradiction => 'Противоречие ❌';

  @override
  String get contradiction_description => 'Противоречие - это утверждение или логическая формула, которая всегда ложна, независимо от значений истинности её компонентов. Другими словами, это выражение, которое не выполняется ни при какой интерпретации или присвоении значений истинности его переменным.';

  @override
  String get darkMode => 'Тёмный режим';

  @override
  String get descending => 'По убыванию';

  @override
  String get emptyExpression => 'Пожалуйста, введите логическое выражение';

  @override
  String get expression => 'Выражение';

  @override
  String get fileOptions => 'Опции файла';

  @override
  String get openFile => 'Открыть файл';

  @override
  String get shareFile => 'Поделиться файлом';

  @override
  String get shareFileMessage => 'Я делюсь этим файлом с вами.';

  @override
  String get expressionLibrary => 'Библиотека выражений';

  @override
  String expressionsRemaining(int count) {
    return '$count выражений осталось';
  }

  @override
  String get fullFeatureAccess => 'Полный доступ ко всем функциям';

  @override
  String get fullLibraryAccess => 'Полный доступ к библиотеке выражений';

  @override
  String get history => 'История';

  @override
  String get language => 'Язык';

  @override
  String get later => 'Позже';

  @override
  String get libraryUnlocked => '🎉 Полная библиотека разблокирована!';

  @override
  String get mintermOrder => 'Порядок минтермов';

  @override
  String get moreExpressions => 'больше выражений';

  @override
  String get noAds => 'Без рекламы';

  @override
  String get no_history => 'Нет истории';

  @override
  String get numberOfPropositions => 'Количество утверждений';

  @override
  String get numberOfRows => 'Количество строк';

  @override
  String get only_tutorials => 'Показывать только учебники';

  @override
  String get pdfFilename => 'tablica_istinnosti';

  @override
  String get premiumOperator => 'Премиум оператор';

  @override
  String get premiumOperatorMessage => 'Этот расширенный оператор требует просмотра видео или обновления до Pro для неограниченного доступа.';

  @override
  String get premiumOperatorsAccess => 'Доступ ко всем премиум операторам';

  @override
  String get preferences => 'Предпочтения';

  @override
  String get premiumSupport => 'Премиум поддержка';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get propositions => 'Утверждения';

  @override
  String get rateTheApp => 'Оценить приложение';

  @override
  String get ratingDialogMessage => 'Ваше мнение очень важно для нас! Если вам понравились Таблицы Истинности, мы будем рады, если вы оставите нам 5-звёздочный рейтинг ⭐';

  @override
  String get ratingDialogTitle => 'Нравится приложение?';

  @override
  String get ratingLater => 'Позже';

  @override
  String get ratingNoThanks => 'Нет, спасибо';

  @override
  String get ratingRateNow => 'Оценить сейчас!';

  @override
  String get remainingExpressions => 'Осталось';

  @override
  String get resetDefaults => 'Сбросить настройки';

  @override
  String get confirmReset => 'Подтвердить сброс';

  @override
  String get confirmResetDesc => 'Вы уверены, что хотите сбросить все настройки до значений по умолчанию?';

  @override
  String get ok => 'ОК';

  @override
  String get result => 'Результат';

  @override
  String get settings => 'Настройки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settings_mode => 'Режим';

  @override
  String get simple_mode => 'Простой режим';

  @override
  String get steps => 'Шаги решения';

  @override
  String get more_info => 'Дополнительная информация';

  @override
  String get t_f => 'И/Л';

  @override
  String get tautology => 'Тавтология ✅';

  @override
  String get tautology_description => 'Тавтология - это утверждение или логическая формула, которая всегда истинна, независимо от значений истинности её компонентов. Другими словами, это выражение, которое выполняется при любой интерпретации или присвоении значений истинности его переменным.';

  @override
  String get truthValues => 'Значения истинности';

  @override
  String get tutorials => 'Учебники';

  @override
  String get type => 'Тип';

  @override
  String get unlockFullLibrary => 'Разблокируйте полную библиотеку!';

  @override
  String get unlockLibraryTitle => '🎯 Разблокируйте полную библиотеку!';

  @override
  String get upgradePro => 'Обновить до Pro';

  @override
  String get videoFABLabel => 'Смотреть видео';

  @override
  String get videoFABTooltip => 'Видео объяснение';

  @override
  String get videoScreenDescription => 'Это видео пошагово объясняет решение этого логического выражения.';

  @override
  String get videoScreenTitle => 'Видео объяснение';

  @override
  String get watchVideoFree => 'Смотреть видео (Бесплатно)';

  @override
  String get youtubeChannel => 'YouTube канал';

  @override
  String get fullTable => 'Полная таблица';
}
