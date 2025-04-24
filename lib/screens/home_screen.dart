// truth_table_home.dart
import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/model/purchase_model.dart';
import 'package:tablas_de_verdad_2025/screens/calculator_screen.dart';
import 'package:tablas_de_verdad_2025/sheets/settings_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

//RepositoryPagePlaceholder
class RepositoryPage extends StatelessWidget {
  const RepositoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Repositorio'));
  }
}

//TutorialsPagePlaceholder
class TutorialsPage extends StatelessWidget {
  const TutorialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Tutoriales'));
  }
}

class TruthTableHome extends StatefulWidget {
  const TruthTableHome({super.key});

  @override
  State<TruthTableHome> createState() => _TruthTableHomeState();
}

class _TruthTableHomeState extends State<TruthTableHome> {
  int _selected = 0;

  final _pages = const [CalculatorScreen(), RepositoryPage(), TutorialsPage()];

  void _onSelect(int index) => setState(() => _selected = index);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    final t = AppLocalizations.of(context)!;

    Widget nav;
    if (isWide) {
      nav = NavigationRail(
        selectedIndex: _selected,
        onDestinationSelected: _onSelect,
        labelType: NavigationRailLabelType.all,
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.functions_outlined),
            selectedIcon: Icon(Icons.functions),
            label: Text('Calculadora'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: Text('Repositorio'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: Text('Tutoriales'),
          ),
        ],
      );
    } else {
      nav = NavigationBar(
        selectedIndex: _selected,
        onDestinationSelected: _onSelect,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.functions_outlined),
            selectedIcon: Icon(Icons.functions),
            label: 'Calculadora',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Repositorio',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Tutoriales',
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed:
                () => showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  builder: (_) => const SettingsBottomSheet(),
                ),
          ),
          ElevatedButton(
            onPressed: () => context.read<PurchaseModel>().buyPro(),
            child: Text('Pro ·'),
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWide) nav as NavigationRail,
          Expanded(child: IndexedStack(index: _selected, children: _pages)),
        ],
      ),
      bottomNavigationBar: isWide ? null : nav as NavigationBar,
    );
  }
}
