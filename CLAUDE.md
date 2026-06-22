# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Flutter (Dart 3.7) Android app that computes and visualizes truth tables for propositional logic expressions. Audience: logic / CS students. 10 languages. Free tier (ad-supported) + one-time Pro IAP.

**`CONTEXTO_APP.md` is the authoritative deep reference** — operator tables, every screen, monetization, Firebase event names, full test inventory. Read it before any substantial change; this file covers only commands and the load-bearing architecture. (Note: a few of its numbers, e.g. version and test counts, lag the code — trust `pubspec.yaml` and `flutter test` over the doc.)

## Commands

```bash
flutter run                 # Run on a connected device/emulator
flutter test                # Full suite (test/)
flutter test test/truth_table_test.dart        # Single file
flutter test --name "tautology"                 # Tests matching a name
flutter analyze             # Must stay at 0 warnings / 0 errors
./regenerate_l10n.sh        # Regenerate l10n after editing any lib/l10n/app_*.arb
flutter build appbundle     # Release bundle for Play Console
```

`commands.sh` and `run_emulator.sh` are interactive `gum`-based wrappers for run/build; `commands.sh` also bumps the version in `pubspec.yaml` (build number is derived as `major*10000 + minor*1000 + patch`).

### No build flavors
There is a single build — package `com.jovannyrch.tablasdeverdad`, no `productFlavors` in `android/app/build.gradle.kts`, and no `--flavor` / `--dart-define=FLAVOR` anywhere. Don't reintroduce flavor flags; the app is localized at runtime via the in-app locale picker, not by build variant.

## Localization workflow

- Template ARB is **`lib/l10n/app_es.arb`** (Spanish), not English — config in `l10n.yaml`.
- `lib/l10n/app_localizations*.dart` are **generated**. Never edit them by hand. Edit the `.arb` files, then run `./regenerate_l10n.sh`.
- Access strings via `AppLocalizations.of(context)`.
- Exception: the `TruthTable` parser's error messages are NOT in the ARB system. They live as private localized constants inside `lib/class/truth_table.dart` (all 10 languages + English fallback). Add new parser errors there, keyed by locale.

## Architecture

State management is **Provider** with a single `Settings extends ChangeNotifier` (`lib/model/settings_model.dart`), provided at the root in `main.dart` and read via `context.watch<Settings>()`. It holds locale, theme, `truthFormat`, `mintermOrder`, `keypadMode`, haptics, and `isProVersion`, persisted to `SharedPreferences`.

### Logic engines (`lib/class/` + `lib/utils/`) — the core of the app
These are pure Dart, heavily tested, and where correctness matters most:
- `truth_table.dart` — `TruthTable`: Shunting-Yard infix→postfix + stack evaluation over 18 operators; produces steps, columns, final table, and tautology/contradiction/contingency classification. Also holds the i18n parser-error constants.
- `karnaugh_map.dart` — `KarnaughSolver`: exact Quine–McCluskey for 2–4 vars, SOP & POS, wrap-around groups.
- `logic_simplifier.dart` — `LogicSimplifier`: AST-based algebraic simplification, 20 named laws, fixed-point to ≤100 steps, guaranteed to terminate (no expansive distribution).
- `utils/equivalence_checker.dart`, `utils/expression_validator.dart` (real-time validity without building the full table), `utils/fill_table_builder.dart` (the "complete the table" puzzle).

When changing any engine, run its test file and `truth_table_test.dart` — the suite is the spec.

### Result screen + Pro gating
`truth_table_result_screen.dart` has 5 tabs: Steps and Full Table are free; **Simplification, Normal Forms, and Karnaugh are Pro-gated**. For free users those three sit behind `_InterstitialAdGate` (watch an ad to unlock); when `isProVersion` is true the gate is bypassed entirely. Any new "premium" feature should follow this same gate pattern, keyed off `Settings.isProVersion`.

### Other structural notes
- **Routing**: named routes in `const/routes.dart`, declared in `main.dart`. Deep links (`app_links`) inject an `expression` query param into the calculator route and take priority over normal route args (see `_extractExpression` in `main.dart`).
- **Persistence**: SQLite (`db/database.dart`) for history + favorites (two trivial tables); `SharedPreferences` for everything else, including `stat_*` local analytics counters.
- **Ads / IAP**: `const/const.dart` holds AdMob unit IDs and the `IS_TESTING` flag (`false` = real production ads — be deliberate before flipping it). IAP product is `pro_version` via `service/purchase_service.dart`.
- **Firebase**: optional at runtime — `_initFirebase()` in `main.dart` swallows init failures so the app runs without `google-services.json`. Analytics is wrapped by `utils/analytics.dart`; emit events through it, not the SDK directly.

### Stray file
`lib/utils/minimizationComparator.ts` is a TypeScript file in a Dart tree (reference/scratch). It is not part of the build.
