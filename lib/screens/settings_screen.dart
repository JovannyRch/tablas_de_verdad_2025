import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/const/routes.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<Settings>();
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          t.settingsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _SectionHeader(title: t.appearance),
          _SettingsCard(
            children: [
              _SettingTile(
                icon: Icons.dark_mode_outlined,
                title: t.darkMode,
                trailing: Switch.adaptive(
                  value: s.isDarkMode(context),
                  onChanged:
                      (val) => context.read<Settings>().update(
                        themeMode: val ? ThemeMode.dark : ThemeMode.light,
                      ),
                ),
              ),
              _SettingTile(
                icon: Icons.language_outlined,
                title: t.language,
                subtitle: _getLanguageName(s.locale.languageCode),
                onTap: () => _showLanguagePicker(context, s),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: t.preferences),
          _SettingsCard(
            children: [
              _PreferenceSection(
                title: t.settings_mode,
                child: SegmentedButton<KeypadMode>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    selectedBackgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    selectedForegroundColor:
                        Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  segments: [
                    ButtonSegment(
                      value: KeypadMode.simple,
                      label: Text(t.simple_mode),
                      icon: const Icon(Icons.dialpad),
                    ),
                    ButtonSegment(
                      value: KeypadMode.advanced,
                      label: Text(t.advanced_mode),
                      icon: const Icon(Icons.calculate),
                    ),
                  ],
                  selected: {s.keypadMode},
                  onSelectionChanged: (Set<KeypadMode> newSelection) {
                    context.read<Settings>().update(
                      keypadMode: newSelection.first,
                    );
                  },
                ),
              ),
              const Divider(indent: 16, endIndent: 16, height: 1),
              _PreferenceSection(
                title: t.truthValues,
                child: SegmentedButton<TruthFormat>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    selectedBackgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    selectedForegroundColor:
                        Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  segments: [
                    ButtonSegment(value: TruthFormat.vf, label: Text(t.t_f)),
                    ButtonSegment(
                      value: TruthFormat.binary,
                      label: const Text('1 / 0'),
                    ),
                  ],
                  selected: {s.truthFormat},
                  onSelectionChanged: (Set<TruthFormat> newSelection) {
                    context.read<Settings>().update(
                      truthFormat: newSelection.first,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: t.about),
          _SettingsCard(
            children: [
              _SettingTile(
                icon: Icons.privacy_tip_outlined,
                title: t.privacyPolicy,
                onTap: () => Navigator.pushNamed(context, Routes.privacy),
                showArrow: true,
              ),
              _SettingTile(
                icon: Icons.restore_outlined,
                title: t.resetDefaults,
                onTap: () => _showResetConfirmation(context, s, t),
                titleColor: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            '${t.appName} $_version',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  void _showResetConfirmation(
    BuildContext context,
    Settings s,
    AppLocalizations t,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(t.confirmReset),
            content: Text(t.confirmResetDesc),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t.cancel),
              ),
              FilledButton(
                onPressed: () {
                  s.reset();
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                child: Text(t.ok),
              ),
            ],
          ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'pt':
        return 'Português';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'hi':
        return 'हिन्दी';
      case 'ru':
        return 'Русский';
      case 'it':
        return 'Italiano';
      case 'zh':
        return '中文 (简体)';
      case 'ja':
        return '日本語';
      default:
        return code;
    }
  }

  void _showLanguagePicker(BuildContext context, Settings s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(context)!.language,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _LangOption(
                      code: 'es',
                      label: 'Español',
                      current: s.locale.languageCode,
                    ),
                    _LangOption(
                      code: 'en',
                      label: 'English',
                      current: s.locale.languageCode,
                    ),
                    _LangOption(
                      code: 'fr',
                      label: 'Français',
                      current: s.locale.languageCode,
                    ),
                    _LangOption(
                      code: 'de',
                      label: 'Deutsch',
                      current: s.locale.languageCode,
                    ),
                    _LangOption(
                      code: 'pt',
                      label: 'Português',
                      current: s.locale.languageCode,
                    ),
                    _LangOption(
                      code: 'it',
                      label: 'Italiano',
                      current: s.locale.languageCode,
                    ),
                    _LangOption(
                      code: 'ru',
                      label: 'Русский',
                      current: s.locale.languageCode,
                    ),
                    _LangOption(
                      code: 'hi',
                      label: 'हिन्दी',
                      current: s.locale.languageCode,
                    ),
                    _LangOption(
                      code: 'zh',
                      label: '中文 (简体)',
                      current: s.locale.languageCode,
                    ),
                    _LangOption(
                      code: 'ja',
                      label: '日本語',
                      current: s.locale.languageCode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showArrow;
  final Color? titleColor;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showArrow = false,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          titleColor ??
                          (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (showArrow)
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _PreferenceSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: child),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String code;
  final String label;
  final String current;

  const _LangOption({
    required this.code,
    required this.label,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = code == current;
    return ListTile(
      title: Text(label),
      trailing:
          isSelected
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
      onTap: () {
        context.read<Settings>().update(locale: Locale(code));
        Navigator.pop(context);
      },
    );
  }
}
