import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:provider/provider.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<Settings>();
    final t = AppLocalizations.of(context)!; // tu sistema de i18n

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        Text(t.settingsTitle, style: Theme.of(context).textTheme.titleLarge),
        const Divider(height: 30.0),

        DropdownMenu<Locale>(
          initialSelection: s.locale,
          width: double.infinity,
          label: Text(t.language),
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: Locale('es'), label: 'Español'),
            DropdownMenuEntry(value: Locale('en'), label: 'English'),
          ],
          onSelected: (loc) => context.read<Settings>().update(locale: loc),
        ),
        const SizedBox(height: 12),
        Text(t.settings_mode, style: Theme.of(context).textTheme.titleMedium),
        RadioListTile(
          title: Text('Modo simple'),
          value: KeypadMode.simple,
          groupValue: s.keypadMode,
          onChanged: (v) => context.read<Settings>().update(keypadMode: v),
        ),
        RadioListTile(
          title: Text('Modo avanzado'),
          value: KeypadMode.advanced,
          groupValue: s.keypadMode,
          onChanged: (v) => context.read<Settings>().update(keypadMode: v),
        ),
        const SizedBox(height: 12),
        // ─── Idioma ──────────────────────────────────────

        // ─── Tema ───────────────────────────────────────
        SwitchListTile.adaptive(
          title: Text(t.darkMode),
          value: s.themeMode == ThemeMode.dark,
          onChanged:
              (val) => context.read<Settings>().update(
                themeMode: val ? ThemeMode.dark : ThemeMode.light,
              ),
        ),
        const SizedBox(height: 12),

        // ─── Formato V/F  vs  1/0 ──────────────────────
        Text(t.truthValues, style: Theme.of(context).textTheme.titleMedium),
        RadioListTile(
          title: const Text('V / F'),
          value: TruthFormat.vf,
          groupValue: s.truthFormat,
          onChanged: (val) => context.read<Settings>().update(truthFormat: val),
        ),
        RadioListTile(
          title: const Text('1 / 0'),
          value: TruthFormat.binary,
          groupValue: s.truthFormat,
          onChanged: (val) => context.read<Settings>().update(truthFormat: val),
        ),
        const SizedBox(height: 12),

        // ─── Orden de minitérminos ─────────────────────
        Text(t.mintermOrder, style: Theme.of(context).textTheme.titleMedium),
        RadioListTile(
          title: Text(t.ascending), // p.ej. 000 → 001 → 010…
          value: MintermOrder.asc,
          groupValue: s.mintermOrder,
          onChanged:
              (val) => context.read<Settings>().update(mintermOrder: val),
        ),
        RadioListTile(
          title: Text(t.descending),
          value: MintermOrder.desc,
          groupValue: s.mintermOrder,
          onChanged:
              (val) => context.read<Settings>().update(mintermOrder: val),
        ),
        const SizedBox(height: 24),

        // ─── Reset ─────────────────────────────────────
        /*  OutlinedButton.icon(
          icon: const Icon(Icons.restore),
          label: Text(t.resetDefaults),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: Text(t.confirmReset),
                    content: Text(t.confirmResetDesc),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(t.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(t.ok),
                      ),
                    ],
                  ),
            );
            if (confirm ?? false) context.read<Settings>().reset();
          },
        ), */
      ],
    );
  }
}
