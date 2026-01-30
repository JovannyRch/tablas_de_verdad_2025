import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:tablas_de_verdad_2025/api/api.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/model/list_response.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/utils/rewarded_ad_helper.dart';
import 'package:tablas_de_verdad_2025/utils/show_pro_version_dialog.dart';
import 'package:tablas_de_verdad_2025/utils/show_snackbar.dart';
import 'package:tablas_de_verdad_2025/widget/expression_card.dart';

class ExpressionLibraryScreen extends StatefulWidget {
  const ExpressionLibraryScreen({super.key});

  @override
  State<ExpressionLibraryScreen> createState() =>
      _ExpressionLibraryScreenState();
}

class Filter {
  final String label;
  final TruthTableType value;

  Filter(this.label, this.value);
}

class _ExpressionLibraryScreenState extends State<ExpressionLibraryScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Expression> _allExpressions = []; // Todas las expresiones del JSON
  final List<Expression> _filteredExpressions = []; // Expresiones filtradas
  bool _isLoading = false;
  TruthTableType? _selectedType;
  bool _onlyVideos = false;
  bool _hasUnlockedFullList = false; // Si el usuario desbloqueó viendo un ad
  late AppLocalizations t;
  late Settings _settings;
  late RewardedAdHelper _rewardedAdHelper;

  static const int FREE_EXPRESSIONS_LIMIT =
      10; // Límite para usuarios gratuitos

  @override
  void initState() {
    super.initState();
    _rewardedAdHelper = RewardedAdHelper();
    _fetchExpressions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _rewardedAdHelper.dispose();
    super.dispose();
  }

  Future<void> _fetchExpressions() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener todas las expresiones del JSON estático
      final ListResponse response = await Api.getListExpressions(1, '');

      setState(() {
        if (response.data != null) {
          _allExpressions.clear();
          _allExpressions.addAll(response.data!);
          _applyFilters();
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching expressions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredExpressions.clear();

    List<Expression> filtered = List.from(_allExpressions);

    // Filtrar por tipo si está seleccionado
    if (_selectedType != null) {
      String typeStr = type;
      filtered = filtered.where((expr) => expr.type == typeStr).toList();
    }

    // Filtrar por videos si está activado
    if (_onlyVideos) {
      filtered =
          filtered
              .where(
                (expr) =>
                    expr.youtubeUrl != null && expr.youtubeUrl!.isNotEmpty,
              )
              .toList();
    }

    _filteredExpressions.addAll(filtered);
  }

  void _onFilterSelected(TruthTableType selectedType) {
    setState(() {
      if (_selectedType == selectedType) {
        _selectedType = null;
      } else {
        _selectedType = selectedType;
      }
      _applyFilters();
    });
  }

  void _onVideosToggled() {
    setState(() {
      _onlyVideos = !_onlyVideos;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    t = AppLocalizations.of(context)!;
    _settings = context.watch<Settings>();
    return Scaffold(
      appBar: AppBar(title: Text(t.expressionLibrary)),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [_buildFilters()]),
          ),
          _buildVideoToggle(),
          Expanded(child: _buildExpressionList()),
        ],
      ),
    );
  }

  Widget _buildVideoToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Checkbox(value: _onlyVideos, onChanged: (_) => _onVideosToggled()),
          Text(t.only_tutorials),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterButton(Filter(t.contingency, TruthTableType.contingency)),
          SizedBox(width: 4),
          _buildFilterButton(Filter(t.tautology, TruthTableType.tautology)),
          SizedBox(width: 4),

          _buildFilterButton(
            Filter(t.contradiction, TruthTableType.contradiction),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(Filter filter) {
    final bool isSelected = _selectedType == filter.value;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: () => _onFilterSelected(filter.value),
      child: Text(filter.label),
    );
  }

  Widget _buildExpressionList() {
    if (_isLoading && _filteredExpressions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredExpressions.isEmpty) {
      return const Center(child: Text('No se encontraron expresiones.'));
    }

    // Determinar cuántas expresiones mostrar
    final bool shouldLimit = !_settings.isProVersion && !_hasUnlockedFullList;
    final int itemCount =
        shouldLimit
            ? FREE_EXPRESSIONS_LIMIT.clamp(0, _filteredExpressions.length)
            : _filteredExpressions.length;

    // Si hay más expresiones disponibles, mostrar botón de desbloqueo
    final bool hasMoreExpressions =
        _filteredExpressions.length > FREE_EXPRESSIONS_LIMIT;
    final bool showUnlockButton = shouldLimit && hasMoreExpressions;

    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount + (showUnlockButton ? 1 : 0),
      itemBuilder: (context, index) {
        // Si es el último item y debemos mostrar el botón de desbloqueo
        if (showUnlockButton && index == itemCount) {
          return _buildUnlockCard();
        }

        final expression = _filteredExpressions[index];
        return _buildExpressionTile(expression, index);
      },
    );
  }

  Widget _buildExpressionTile(Expression expression, int index) {
    return ExpressionCard(
      expression: expression,
      showAds: (index % 5 == 0 && index != 0),
    );
  }

  Widget _buildUnlockCard() {
    final remainingCount = _filteredExpressions.length - FREE_EXPRESSIONS_LIMIT;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.lock, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              t.unlockLibraryTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              t.expressionsRemaining(remainingCount),
              style: const TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Botón para ver video
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _unlockWithAd,
                icon: const Icon(Icons.play_circle_filled),
                label: Text(t.watchVideoFree),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Botón para actualizar a Pro
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showProDialog,
                icon: const Icon(Icons.diamond),
                label: Text(t.upgradePro),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _unlockWithAd() async {
    if (kDebugMode) {
      print('🔓 Iniciando proceso de desbloqueo con ad...');
    }

    final success = await _rewardedAdHelper.showRewardedAd();

    if (kDebugMode) {
      print('🎯 Resultado del rewarded ad: $success');
    }

    if (success) {
      // Dar un pequeño delay para asegurar que el ad se cerró completamente
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _hasUnlockedFullList = true;
        });

        if (kDebugMode) {
          print(
            '✅ Lista desbloqueada. Total expresiones: ${_filteredExpressions.length}',
          );
        }

        showSnackBarMessage(context, t.libraryUnlocked);

        // Scroll hacia abajo para mostrar las nuevas expresiones
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    } else {
      if (kDebugMode) {
        print('❌ No se pudo mostrar el rewarded ad');
      }
      if (mounted) {
        showSnackBarMessage(context, t.adNotAvailable);
      }
    }
  }

  Future<void> _showProDialog() async {
    await showProVersionDialog(context, _settings, t);
  }

  String get type {
    switch (_selectedType) {
      case TruthTableType.contingency:
        return "CONTINGENCY";
      case TruthTableType.tautology:
        return "TAUTOLOGY";
      case TruthTableType.contradiction:
        return "CONTRADICTION";
      default:
        return '';
    }
  }
}
