// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get about => 'À propos';

  @override
  String get adNotAvailable => 'Vidéo non disponible. Réessayez plus tard ou passez à Pro.';

  @override
  String get addedToFavorites => 'Ajouté aux favoris';

  @override
  String get advanced_mode => 'Mode avancé';

  @override
  String get all => 'Tous';

  @override
  String get appName => 'Tables de Vérité';

  @override
  String get appearance => 'Apparence';

  @override
  String get ascending => 'Ascendant';

  @override
  String get becomePro => 'Devenez Pro !';

  @override
  String get bestStreak => 'Meilleure série';

  @override
  String get buyPro => 'Acheter';

  @override
  String get calculationHistory => 'Historique des calculs';

  @override
  String get cancel => 'Annuler';

  @override
  String get checkEquivalence => 'Vérifier l\'Équivalence';

  @override
  String get chooseDifficulty => 'Choisissez la difficulté';

  @override
  String get clear_all => 'Tout effacer';

  @override
  String get close => 'Fermer';

  @override
  String get cnfDescription => 'ET des maxtermes : un terme OU pour chaque ligne où le résultat est 0.';

  @override
  String get cnfTautology => 'Pas de FNC — l\'expression est une tautologie (toujours vraie).';

  @override
  String get cnfTitle => 'Forme Normale Conjonctive (FNC)';

  @override
  String get comparisonTable => 'Tableau Comparatif';

  @override
  String get confirmReset => 'Confirmer la réinitialisation';

  @override
  String get confirmResetDesc => 'Êtes-vous sûr de vouloir réinitialiser tous les paramètres par défaut ?';

  @override
  String get contingency => 'Contingence ⚠️';

  @override
  String get contingency_description => 'Une contingence fait référence à une proposition ou formule qui n\'est ni une tautologie ni une contradiction. En d\'autres termes, c\'est une expression qui peut être vraie ou fausse, selon les circonstances ou les valeurs de vérité de ses composants.';

  @override
  String get contradiction => 'Contradiction ❌';

  @override
  String get contradiction_description => 'Une contradiction est une proposition ou formule logique qui est toujours fausse, indépendamment des valeurs de vérité de ses composants. En d\'autres termes, c\'est une expression qui ne tient sous aucune interprétation ou attribution de valeurs de vérité à ses variables.';

  @override
  String get correctAnswer => 'Correct ! 🎉';

  @override
  String get correctAnswers => 'Correctes';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get descending => 'Descendant';

  @override
  String get dnfContradiction => 'Pas de FND — l\'expression est une contradiction (toujours fausse).';

  @override
  String get dnfDescription => 'OU des mintermes : un terme ET pour chaque ligne où le résultat est 1.';

  @override
  String get dnfTitle => 'Forme Normale Disjonctive (FND)';

  @override
  String get easy => 'Facile';

  @override
  String get easyDesc => 'Expressions simples avec 1-2 variables';

  @override
  String get emptyExpression => 'Veuillez saisir une expression logique';

  @override
  String get equivalenceChecker => 'Vérificateur d\'Équivalence';

  @override
  String get equivalenceError => 'Erreur d\'Évaluation';

  @override
  String get equivalentDescription => 'Les deux expressions produisent les mêmes valeurs de vérité pour toutes les combinaisons possibles.';

  @override
  String get expression => 'Expression';

  @override
  String get expressionA => 'Expression A';

  @override
  String get expressionB => 'Expression B';

  @override
  String get expressionLibrary => 'Bibliothèque d\'expressions';

  @override
  String get expressionsEquivalent => 'Équivalentes ✅';

  @override
  String get expressionsNotEquivalent => 'Non Équivalentes ❌';

  @override
  String expressionsRemaining(int count) {
    return '$count expressions supplémentaires restantes';
  }

  @override
  String get favorites => 'Favoris';

  @override
  String get fileOptions => 'Options de fichier';

  @override
  String get fullFeatureAccess => 'Accès complet à toutes les fonctionnalités';

  @override
  String get fullLibraryAccess => 'Accès complet à la bibliothèque d\'expressions';

  @override
  String get fullTable => 'Table complète';

  @override
  String get getStarted => 'Commencer!';

  @override
  String get hard => 'Difficile';

  @override
  String get hardDesc => 'Expressions complexes avec 3-4 variables';

  @override
  String get history => 'Historique';

  @override
  String get language => 'Langue';

  @override
  String get later => 'Plus tard';

  @override
  String get libraryUnlocked => '🎉 Bibliothèque complète débloquée !';

  @override
  String get maxterms => 'maxtermes';

  @override
  String get medium => 'Moyen';

  @override
  String get mediumDesc => 'Expressions composées avec 2-3 variables';

  @override
  String get mintermOrder => 'Ordre des mintermes';

  @override
  String get minterms => 'mintermes';

  @override
  String get moreExpressions => 'expressions supplémentaires';

  @override
  String get more_info => 'Plus d\'informations';

  @override
  String get next => 'Suivant';

  @override
  String get noAds => 'Sans publicités';

  @override
  String get noFavorites => 'Pas de favoris';

  @override
  String get noPurchasesFound => 'Aucun achat précédent trouvé';

  @override
  String get no_history => 'Aucun historique';

  @override
  String get normalForms => 'Formes Normales';

  @override
  String get normalFormsAdGate => 'Regardez une courte vidéo pour débloquer les Formes Normales de cette expression.';

  @override
  String get normalFormsDescription => 'Convertissez l\'expression en Forme Normale Disjonctive (FND) et Forme Normale Conjonctive (FNC) à partir de la table de vérité.';

  @override
  String get normalFormsProHint => 'Passez à Pro pour voir les Formes Normales instantanément sans publicités.';

  @override
  String get normalFormsTitle => 'Formes Normales';

  @override
  String normalFormsTooManyVars(Object max) {
    return 'Trop de variables (max $max)';
  }

  @override
  String get normalFormsTooManyVarsDesc => 'La conversion en formes normales est limitée aux expressions avec jusqu\'à 5 variables pour garder la sortie lisible.';

  @override
  String notEquivalentDescription(Object differing, Object pct, Object total) {
    return 'Elles diffèrent dans $differing sur $total lignes ($pct% correspondent).';
  }

  @override
  String get numberOfPropositions => 'Nombre de propositions';

  @override
  String get numberOfRows => 'Nombre de lignes';

  @override
  String get ok => 'OK';

  @override
  String get onboardingDesc1 => 'Utilisez le clavier pour saisir toute expression logique avec des variables et des opérateurs';

  @override
  String get onboardingDesc2 => 'Visualisez chaque étape de la résolution et la table de vérité complète';

  @override
  String get onboardingDesc3 => 'Générez des PDF professionnels et partagez vos résultats facilement';

  @override
  String get onboardingTitle1 => 'Écrivez votre expression';

  @override
  String get onboardingTitle2 => 'Solution étape par étape';

  @override
  String get onboardingTitle3 => 'Exportez et partagez';

  @override
  String get oneTimePurchase => 'Achat unique';

  @override
  String get only_tutorials => 'Afficher uniquement les tutoriels';

  @override
  String get openFile => 'Ouvrir le fichier';

  @override
  String get pdfFilename => 'table_verite';

  @override
  String get playAgain => 'Rejouer';

  @override
  String get practiceMode => 'Mode Entraînement';

  @override
  String get preferences => 'Préférences';

  @override
  String get premiumOperator => 'Opérateur Premium';

  @override
  String get premiumOperatorMessage => 'Cet opérateur avancé nécessite de regarder une vidéo ou de passer à Pro pour un accès illimité.';

  @override
  String get premiumOperatorsAccess => 'Accès à tous les opérateurs premium';

  @override
  String get premiumSupport => 'Support Premium';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get proUpgradeHint => 'Passez à Pro pour une pratique illimitée avec tous les opérateurs et sans publicités !';

  @override
  String get propositions => 'Propositions';

  @override
  String get purchaseError => 'Échec de l\'achat. Veuillez réessayer.';

  @override
  String get question => 'Question';

  @override
  String get quizResults => 'Résultats du quiz';

  @override
  String get quizzesPlayed => 'Joués';

  @override
  String get rateTheApp => 'Noter l\'application';

  @override
  String get ratingDialogMessage => 'Votre avis est très important pour nous ! Si vous avez aimé Tables de Vérité, nous aimerions que vous nous laissiez une note de 5 étoiles ⭐';

  @override
  String get ratingDialogTitle => 'Vous aimez l\'application ?';

  @override
  String get ratingLater => 'Plus tard';

  @override
  String get ratingNoThanks => 'Non, merci';

  @override
  String get ratingRateNow => 'Noter maintenant !';

  @override
  String get remainingExpressions => 'Restant';

  @override
  String get removedFromFavorites => 'Retiré des favoris';

  @override
  String get resetDefaults => 'Réinitialiser aux paramètres par défaut';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get result => 'Résultat';

  @override
  String get searchHistory => 'Rechercher dans l\'historique...';

  @override
  String get seeResults => 'Voir les résultats';

  @override
  String get settings => 'Paramètres';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settings_mode => 'Mode';

  @override
  String get shareFile => 'Partager le fichier';

  @override
  String get shareFileMessage => 'Je partage ce fichier avec vous.';

  @override
  String get simple_mode => 'Mode simple';

  @override
  String get skip => 'Passer';

  @override
  String get socialProof => 'Utilisé par des milliers d\'étudiants';

  @override
  String get steps => 'Étapes de résolution';

  @override
  String get supportDeveloper => 'Soutenez le développeur';

  @override
  String get swapExpressions => 'Échanger les expressions';

  @override
  String get t_f => 'V/F';

  @override
  String get tautology => 'Tautologie ✅';

  @override
  String get tautology_description => 'Une tautologie est une proposition ou formule logique qui est toujours vraie, indépendamment des valeurs de vérité de ses composants. En d\'autres termes, c\'est une expression qui tient sous toute interprétation ou attribution de valeurs de vérité à ses variables.';

  @override
  String get truthValues => 'Valeurs de vérité';

  @override
  String get tutorials => 'Tutoriels';

  @override
  String get type => 'Type';

  @override
  String get unlimitedPremiumOps => 'Opérateurs premium illimités';

  @override
  String get unlockFullLibrary => 'Débloquez la bibliothèque complète !';

  @override
  String get unlockLibraryTitle => '🎯 Débloquez la bibliothèque complète !';

  @override
  String get upgradePro => 'Passer à Pro';

  @override
  String get validationMissingOperand => 'Opérande manquant';

  @override
  String get validationMissingOperator => 'Opérateur manquant entre les variables';

  @override
  String get validationTrailingOp => 'Expression incomplète';

  @override
  String get validationUnmatched => 'Parenthèses non fermées';

  @override
  String get validationValid => 'Prêt à évaluer';

  @override
  String get videoFABLabel => 'Voir la vidéo';

  @override
  String get videoFABTooltip => 'Explication vidéo';

  @override
  String get videoScreenDescription => 'Cette vidéo explique étape par étape la résolution de cette expression logique.';

  @override
  String get videoScreenTitle => 'Explication vidéo';

  @override
  String get watchVideoFree => 'Voir la vidéo (Gratuit)';

  @override
  String get whatTypeIsThis => 'Quel type est cette expression ?';

  @override
  String get wrongAnswer => 'Incorrect. Continuez !';

  @override
  String get yourStats => 'Vos statistiques';

  @override
  String get youtubeChannel => 'Chaîne YouTube';

  @override
  String get shareExpression => 'Partager l\'expression';
}
