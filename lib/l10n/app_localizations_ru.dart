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
  String rowCountTitle(int rows) {
    return 'Почему $rows строк?';
  }

  @override
  String rowCountExplanation(int vars) {
    return 'Каждое высказывание имеет 2 возможных значения (И или Л). При $vars высказываниях получается 2 в степени $vars комбинаций: по одной на каждую строку.';
  }

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
  String get instagramFollow => 'Подписаться на разработчика';

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

  @override
  String get karnaughTab => 'Карно';

  @override
  String get karnaughTitle => 'Карта Карно';

  @override
  String get karnaughDescription =>
      'Группируйте соседние ячейки по степеням двойки, чтобы получить минимальное булево выражение функции.';

  @override
  String get karnaughUnsupportedVars => 'Доступно для 2–4 переменных';

  @override
  String get karnaughUnsupportedVarsDesc =>
      'Карта Карно отображается для выражений с 2, 3 или 4 переменными (без констант).';

  @override
  String get karnaughAdGate =>
      'Посмотрите короткое видео, чтобы разблокировать карту Карно для этого выражения.';

  @override
  String get karnaughSopDescription =>
      'SOP: группирует единицы (сумма произведений)';

  @override
  String get karnaughPosDescription =>
      'POS: группирует нули (произведение сумм)';

  @override
  String get karnaughMinimizedExpression => 'Минимизированное выражение';

  @override
  String get karnaughGroupsTitle => 'Группы';

  @override
  String karnaughGroupCells(int count) {
    return '$count ячеек';
  }

  @override
  String get karnaughConstant =>
      'Функция константна: группы формировать не нужно.';

  @override
  String get simplificationTab => 'Упростить';

  @override
  String get simplificationTitle => 'Пошаговое упрощение';

  @override
  String get simplificationDescription =>
      'Применяет законы алгебры высказываний, чтобы привести выражение к более простой форме. Коммутативность и ассоциативность применяются неявно.';

  @override
  String get simplificationAdGate =>
      'Посмотрите короткое видео, чтобы разблокировать пошаговое упрощение этого выражения.';

  @override
  String get simplificationOriginal => 'Исходное выражение';

  @override
  String get simplificationResult => 'Результат';

  @override
  String get simplificationAlreadySimple =>
      'Выражение уже находится в простейшей форме.';

  @override
  String simplificationStepCount(int count) {
    return '$count шагов';
  }

  @override
  String get lawConditional => 'Закон импликации';

  @override
  String get lawBiconditional => 'Закон эквиваленции';

  @override
  String get lawConverse => 'Обратная импликация';

  @override
  String get lawXorDefinition => 'Определение XOR';

  @override
  String get lawNandDefinition => 'Определение NAND';

  @override
  String get lawNorDefinition => 'Определение NOR';

  @override
  String get lawNegatedConditional => 'Отрицание импликации';

  @override
  String get lawNegatedConverse => 'Отрицание обратной импликации';

  @override
  String get lawNegatedBiconditional => 'Отрицание эквиваленции';

  @override
  String get lawTautologyOperator => 'Оператор тавтологии';

  @override
  String get lawContradictionOperator => 'Оператор противоречия';

  @override
  String get lawDoubleNegation => 'Двойное отрицание';

  @override
  String get lawDeMorgan => 'Закон де Моргана';

  @override
  String get lawNegationOfConstant => 'Отрицание константы';

  @override
  String get lawIdempotence => 'Идемпотентность';

  @override
  String get lawIdentity => 'Тождество';

  @override
  String get lawDomination => 'Доминирование';

  @override
  String get lawComplement => 'Дополнение';

  @override
  String get lawAbsorption => 'Поглощение';

  @override
  String get lawFactorization => 'Дистрибутивность (вынесение за скобки)';

  @override
  String get instagramPromoTitle => 'Подпишитесь в Instagram!';

  @override
  String get instagramPromoButton => 'Подписаться в Instagram';

  @override
  String get instagramPromoLater => 'Может быть позже';

  @override
  String get a11yBackspace => 'Удалить';

  @override
  String get a11yToggleCase => 'Регистр букв';

  @override
  String get a11yEvaluate => 'Вычислить';

  @override
  String a11yKarnaughMap(int count) {
    return 'Карта Карно с $count группами';
  }

  @override
  String a11yKarnaughGroup(int number, String term, int count) {
    return 'Группа $number: $term, $count ячеек';
  }

  @override
  String get example => 'Пример';

  @override
  String get hapticFeedback => 'Виброотклик';

  @override
  String get classifyMode => 'Классифицировать';

  @override
  String get fillTableMode => 'Заполнить таблицу';

  @override
  String get practiceType => 'Тип практики';

  @override
  String get fillTableInstruction =>
      'Выберите истинностное значение последнего столбца в каждой строке.';

  @override
  String get verifyAnswers => 'Проверить';

  @override
  String get tablesCompleted => 'Таблицы';

  @override
  String get accuracy => 'Точность';

  @override
  String cellsCorrectOfTotal(int correct, int total) {
    return '$correct/$total ячеек верно';
  }

  @override
  String get proKarnaughBenefit => 'Карты Карно без рекламы';

  @override
  String get proSimplificationBenefit => 'Пошаговое упрощение мгновенно';

  @override
  String get proNormalFormsBenefit => 'Нормальные формы (ДНФ/КНФ) мгновенно';
}
