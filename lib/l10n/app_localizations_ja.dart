// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get adNotAvailable => 'ビデオは利用できません。後でもう一度試すか、プロ版にアップグレードしてください。';

  @override
  String get advanced_mode => '高度なモード';

  @override
  String get appName => '真理値表';

  @override
  String get ascending => '昇順';

  @override
  String get becomePro => 'プロになる！';

  @override
  String get buyPro => '購入';

  @override
  String get calculationHistory => '計算履歴';

  @override
  String get cancel => 'キャンセル';

  @override
  String get contingency => '偶発的 ⚠️';

  @override
  String get contingency_description => '偶発的とは、恒真式でも矛盾式でもない命題または式を指します。言い換えれば、状況またはその構成要素の真理値に応じて、真または偽になり得る表現です。';

  @override
  String get contradiction => '矛盾 ❌';

  @override
  String get contradiction_description => '矛盾とは、構成要素の真理値に関係なく常に偽である命題または論理式です。言い換えれば、変数への真理値の解釈または割り当てのいかなる場合でも成立しない表現です。';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get descending => '降順';

  @override
  String get emptyExpression => '論理式を入力してください';

  @override
  String get expression => '式';

  @override
  String get expressionLibrary => '式ライブラリ';

  @override
  String expressionsRemaining(int count) {
    return '残り$count個の式';
  }

  @override
  String get fullFeatureAccess => 'すべての機能への完全アクセス';

  @override
  String get fullLibraryAccess => '式ライブラリへの完全アクセス';

  @override
  String get history => '履歴';

  @override
  String get language => '言語';

  @override
  String get later => '後で';

  @override
  String get libraryUnlocked => '🎉 完全なライブラリがアンロックされました！';

  @override
  String get mintermOrder => '最小項の順序';

  @override
  String get moreExpressions => 'さらに式';

  @override
  String get noAds => '広告なし';

  @override
  String get no_history => '履歴なし';

  @override
  String get numberOfPropositions => '命題の数';

  @override
  String get numberOfRows => '行数';

  @override
  String get only_tutorials => 'チュートリアルのみ表示';

  @override
  String get pdfFilename => '真理値表';

  @override
  String get premiumOperator => 'プレミアム演算子';

  @override
  String get premiumOperatorMessage => 'この高度な演算子は、ビデオを視聴するか、無制限アクセスのためにプロ版にアップグレードする必要があります。';

  @override
  String get premiumOperatorsAccess => 'すべてのプレミアム演算子へのアクセス';

  @override
  String get premiumSupport => 'プレミアムサポート';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get propositions => '命題';

  @override
  String get rateTheApp => 'アプリを評価';

  @override
  String get ratingDialogMessage => 'あなたの意見は私たちにとって非常に重要です！真理値表を気に入っていただけた場合は、5つ星の評価を残していただければ幸いです ⭐';

  @override
  String get ratingDialogTitle => 'アプリを楽しんでいますか？';

  @override
  String get ratingLater => '後で';

  @override
  String get ratingNoThanks => 'いいえ、結構です';

  @override
  String get ratingRateNow => '今すぐ評価！';

  @override
  String get remainingExpressions => '残り';

  @override
  String get result => '結果';

  @override
  String get settings => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get settings_mode => 'モード';

  @override
  String get simple_mode => 'シンプルモード';

  @override
  String get t_f => '真/偽';

  @override
  String get tautology => '恒真式 ✅';

  @override
  String get tautology_description => '恒真式とは、構成要素の真理値に関係なく常に真である命題または論理式です。言い換えれば、変数への真理値の解釈または割り当てのいかなる場合でも成立する表現です。';

  @override
  String get truthValues => '真理値';

  @override
  String get tutorials => 'チュートリアル';

  @override
  String get type => 'タイプ';

  @override
  String get unlockFullLibrary => '完全なライブラリをアンロック！';

  @override
  String get unlockLibraryTitle => '🎯 完全なライブラリをアンロック！';

  @override
  String get upgradePro => 'プロ版にアップグレード';

  @override
  String get videoFABLabel => 'ビデオを見る';

  @override
  String get videoFABTooltip => 'ビデオ説明';

  @override
  String get videoScreenDescription => 'このビデオは、この論理式の段階的な解法を説明します。';

  @override
  String get videoScreenTitle => 'ビデオ説明';

  @override
  String get watchVideoFree => 'ビデオを見る（無料）';

  @override
  String get youtubeChannel => 'YouTubeチャンネル';
}
