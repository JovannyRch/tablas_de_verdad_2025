// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get about => 'О программе';

  @override
  String get adNotAvailable =>
      'Видео недоступно. Попробуйте позже или перейдите на Pro.';

  @override
  String get addedToFavorites => 'Добавлено в избранное';

  @override
  String get advanced_mode => 'Расширенный режим';

  @override
  String get all => 'Все';

  @override
  String get appName => 'Таблицы Истинности';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get ascending => 'По возрастанию';

  @override
  String get becomePro => 'Станьте Pro!';

  @override
  String get bestStreak => 'Лучшая серия';

  @override
  String get buyPro => 'Купить';

  @override
  String get calculationHistory => 'История вычислений';

  @override
  String get cancel => 'Отмена';

  @override
  String get checkEquivalence => 'Проверить Эквивалентность';

  @override
  String get chooseDifficulty => 'Выберите сложность';

  @override
  String get clear_all => 'Очистить всё';

  @override
  String get close => 'Закрыть';

  @override
  String get cnfDescription =>
      'И макстермов: один ИЛИ-терм для каждой строки, где результат 0.';

  @override
  String get cnfTautology =>
      'КНФ не существует — выражение является тавтологией (всегда истинно).';

  @override
  String get cnfTitle => 'Конъюнктивная Нормальная Форма (КНФ)';

  @override
  String get comparisonTable => 'Сравнительная Таблица';

  @override
  String get confirmReset => 'Подтвердить сброс';

  @override
  String get confirmResetDesc =>
      'Вы уверены, что хотите сбросить все настройки до значений по умолчанию?';

  @override
  String get contingency => 'Случайность ⚠️';

  @override
  String get contingency_description =>
      'Случайность относится к утверждению или формуле, которая не является ни тавтологией, ни противоречием. Другими словами, это выражение, которое может быть истинным или ложным в зависимости от обстоятельств или значений истинности его компонентов.';

  @override
  String get contradiction => 'Противоречие ❌';

  @override
  String get contradiction_description =>
      'Противоречие - это утверждение или логическая формула, которая всегда ложна, независимо от значений истинности её компонентов. Другими словами, это выражение, которое не выполняется ни при какой интерпретации или присвоении значений истинности его переменным.';

  @override
  String get correctAnswer => 'Правильно! 🎉';

  @override
  String get correctAnswers => 'Правильных';

  @override
  String get darkMode => 'Тёмный режим';

  @override
  String get descending => 'По убыванию';

  @override
  String get dnfContradiction =>
      'ДНФ не существует — выражение является противоречием (всегда ложно).';

  @override
  String get dnfDescription =>
      'ИЛИ минтермов: один И-терм для каждой строки, где результат 1.';

  @override
  String get dnfTitle => 'Дизъюнктивная Нормальная Форма (ДНФ)';

  @override
  String get easy => 'Легко';

  @override
  String get easyDesc => 'Простые выражения с 1-2 переменными';

  @override
  String get emptyExpression => 'Пожалуйста, введите логическое выражение';

  @override
  String get equivalenceChecker => 'Проверка Эквивалентности';

  @override
  String get equivalenceError => 'Ошибка Вычисления';

  @override
  String get equivalentDescription =>
      'Оба выражения дают одинаковые значения истинности для всех возможных комбинаций входных данных.';

  @override
  String get expression => 'Выражение';

  @override
  String get expressionA => 'Выражение A';

  @override
  String get expressionB => 'Выражение B';

  @override
  String get expressionLibrary => 'Библиотека выражений';

  @override
  String get expressionsEquivalent => 'Эквивалентны ✅';

  @override
  String get expressionsNotEquivalent => 'Не Эквивалентны ❌';

  @override
  String expressionsRemaining(int count) {
    return '$count выражений осталось';
  }

  @override
  String get favorites => 'Избранное';

  @override
  String get fileOptions => 'Опции файла';

  @override
  String get fullFeatureAccess => 'Полный доступ ко всем функциям';

  @override
  String get fullLibraryAccess => 'Полный доступ к библиотеке выражений';

  @override
  String get fullTable => 'Полная таблица';

  @override
  String get getStarted => 'Начать!';

  @override
  String get hard => 'Сложно';

  @override
  String get hardDesc => 'Сложные выражения с 3-4 переменными';

  @override
  String get history => 'История';

  @override
  String get language => 'Язык';

  @override
  String get later => 'Позже';

  @override
  String get libraryUnlocked => '🎉 Полная библиотека разблокирована!';

  @override
  String get maxterms => 'макстермы';

  @override
  String get medium => 'Средне';

  @override
  String get mediumDesc => 'Составные выражения с 2-3 переменными';

  @override
  String get mintermOrder => 'Порядок минтермов';

  @override
  String get minterms => 'минтермы';

  @override
  String get moreExpressions => 'больше выражений';

  @override
  String get more_info => 'Дополнительная информация';

  @override
  String get next => 'Далее';

  @override
  String get noAds => 'Без рекламы';

  @override
  String get noFavorites => 'Нет избранного';

  @override
  String get noPurchasesFound => 'Предыдущие покупки не найдены';

  @override
  String get no_history => 'Нет истории';

  @override
  String get normalForms => 'Нормальные Формы';

  @override
  String get normalFormsAdGate =>
      'Посмотрите короткое видео, чтобы разблокировать Нормальные Формы для этого выражения.';

  @override
  String get normalFormsDescription =>
      'Преобразуйте выражение в Дизъюнктивную Нормальную Форму (ДНФ) и Конъюнктивную Нормальную Форму (КНФ) с помощью таблицы истинности.';

  @override
  String get normalFormsProHint =>
      'Обновитесь до Pro, чтобы видеть Нормальные Формы мгновенно без рекламы.';

  @override
  String get normalFormsTitle => 'Нормальные Формы';

  @override
  String normalFormsTooManyVars(Object max) {
    return 'Слишком много переменных (макс $max)';
  }

  @override
  String get normalFormsTooManyVarsDesc =>
      'Преобразование в нормальные формы ограничено выражениями до 5 переменных для удобочитаемости.';

  @override
  String notEquivalentDescription(Object differing, Object pct, Object total) {
    return 'Различаются в $differing из $total строк ($pct% совпадают).';
  }

  @override
  String get numberOfPropositions => 'Количество утверждений';

  @override
  String get numberOfRows => 'Количество строк';

  @override
  String get ok => 'ОК';

  @override
  String get onboardingDesc1 =>
      'Используйте клавиатуру для ввода логического выражения с переменными и операторами';

  @override
  String get onboardingDesc2 =>
      'Просматривайте каждый шаг решения и полную таблицу истинности';

  @override
  String get onboardingDesc3 =>
      'Создавайте профессиональные PDF и легко делитесь результатами';

  @override
  String get onboardingTitle1 => 'Напишите выражение';

  @override
  String get onboardingTitle2 => 'Пошаговое решение';

  @override
  String get onboardingTitle3 => 'Экспортируйте и делитесь';

  @override
  String get oneTimePurchase => 'Разовая покупка';

  @override
  String get only_tutorials => 'Показывать только учебники';

  @override
  String get openFile => 'Открыть файл';

  @override
  String get pdfFilename => 'tablica_istinnosti';

  @override
  String get playAgain => 'Играть снова';

  @override
  String get practiceMode => 'Режим практики';

  @override
  String get preferences => 'Предпочтения';

  @override
  String get premiumOperator => 'Премиум оператор';

  @override
  String get premiumOperatorMessage =>
      'Этот расширенный оператор требует просмотра видео или обновления до Pro для неограниченного доступа.';

  @override
  String get premiumOperatorsAccess => 'Доступ ко всем премиум операторам';

  @override
  String get premiumSupport => 'Премиум поддержка';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get proUpgradeHint =>
      'Перейдите на Pro для безлимитной практики со всеми операторами и без рекламы!';

  @override
  String get propositions => 'Утверждения';

  @override
  String get purchaseError => 'Ошибка покупки. Попробуйте ещё раз.';

  @override
  String get question => 'Вопрос';

  @override
  String get quizResults => 'Результаты теста';

  @override
  String get quizzesPlayed => 'Сыграно';

  @override
  String get rateTheApp => 'Оценить приложение';

  @override
  String get ratingDialogMessage =>
      'Ваше мнение очень важно для нас! Если вам понравились Таблицы Истинности, мы будем рады, если вы оставите нам 5-звёздочный рейтинг ⭐';

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
  String get removedFromFavorites => 'Удалено из избранного';

  @override
  String get resetDefaults => 'Сбросить настройки';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get result => 'Результат';

  @override
  String get searchHistory => 'Поиск в истории...';

  @override
  String get seeResults => 'Посмотреть результаты';

  @override
  String get settings => 'Настройки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settings_mode => 'Режим';

  @override
  String get shareFile => 'Поделиться файлом';

  @override
  String get shareFileMessage => 'Я делюсь этим файлом с вами.';

  @override
  String get simple_mode => 'Простой режим';

  @override
  String get skip => 'Пропустить';

  @override
  String get socialProof => 'Доверяют тысячи студентов';

  @override
  String get steps => 'Шаги решения';

  @override
  String get supportDeveloper => 'Поддержите разработчика';

  @override
  String get swapExpressions => 'Поменять выражения';

  @override
  String get t_f => 'И/Л';

  @override
  String get tautology => 'Тавтология ✅';

  @override
  String get tautology_description =>
      'Тавтология - это утверждение или логическая формула, которая всегда истинна, независимо от значений истинности её компонентов. Другими словами, это выражение, которое выполняется при любой интерпретации или присвоении значений истинности его переменным.';

  @override
  String get truthValues => 'Значения истинности';

  @override
  String get tutorials => 'Учебники';

  @override
  String get type => 'Тип';

  @override
  String get unlimitedPremiumOps => 'Безлимитные премиум-операторы';

  @override
  String get unlockFullLibrary => 'Разблокируйте полную библиотеку!';

  @override
  String get unlockLibraryTitle => '🎯 Разблокируйте полную библиотеку!';

  @override
  String get upgradePro => 'Обновить до Pro';

  @override
  String get validationMissingOperand => 'Отсутствует операнд';

  @override
  String get validationMissingOperator =>
      'Отсутствует оператор между переменными';

  @override
  String get validationTrailingOp => 'Выражение неполное';

  @override
  String get validationUnmatched => 'Незакрытые скобки';

  @override
  String get validationValid => 'Готово к вычислению';

  @override
  String get videoFABLabel => 'Смотреть видео';

  @override
  String get videoFABTooltip => 'Видео объяснение';

  @override
  String get videoScreenDescription =>
      'Это видео пошагово объясняет решение этого логического выражения.';

  @override
  String get videoScreenTitle => 'Видео объяснение';

  @override
  String get watchVideoFree => 'Смотреть видео (Бесплатно)';

  @override
  String get whatTypeIsThis => 'Какого типа это выражение?';

  @override
  String get wrongAnswer => 'Неправильно. Продолжайте!';

  @override
  String get yourStats => 'Ваша статистика';

  @override
  String get youtubeChannel => 'YouTube канал';

  @override
  String get shareExpression => 'Поделиться выражением';

  @override
  String get discordCommunity => 'Сообщество в Discord';

  @override
  String get argumentValidator => 'Валидатор Аргументов';

  @override
  String get premise => 'Посылка';

  @override
  String get addPremise => 'Добавить посылку';

  @override
  String get removePremise => 'Удалить';

  @override
  String get conclusionLabel => 'Заключение';

  @override
  String get validateArgument => 'Проверить аргумент';

  @override
  String get validArgument => 'Аргумент верный ✅';

  @override
  String get invalidArgument => 'Аргумент неверный ❌';

  @override
  String get validArgumentDesc =>
      'Во всех комбинациях, где посылки истинны, заключение также истинно. Аргумент логически верен.';

  @override
  String get invalidArgumentDesc =>
      'Существует хотя бы одна комбинация, где все посылки истинны, но заключение ложно.';

  @override
  String get counterexamples => 'Контрпримеры';

  @override
  String get argumentHint => 'Введите логическое выражение';
}
