import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/api/api.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/model/list_response.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/widget/expression_card.dart';

class ExpressionLibraryScreen extends StatefulWidget {
  const ExpressionLibraryScreen({Key? key}) : super(key: key);

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
  List<Expression> _expressions = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  TruthTableType? _selectedType;
  bool _onlyVideos = false;
  late AppLocalizations t;

  @override
  void initState() {
    super.initState();
    _fetchExpressions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchExpressions({bool reset = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (reset) {
        _currentPage = 1;
        _expressions.clear();
        _hasMore = true;
      }
    });

    final ListResponse response = await Api.getListExpressions(
      _currentPage,
      type,
      videos: _onlyVideos,
    );

    setState(() {
      _expressions.addAll(response.data ?? []);
      _hasMore = response.nextPageUrl != null;
      _isLoading = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        _hasMore &&
        !_isLoading) {
      _currentPage++;
      _fetchExpressions();
    }
  }

  void _onFilterSelected(TruthTableType selectedType) {
    setState(() {
      if (_selectedType == selectedType) {
        _selectedType = null;
      } else {
        _selectedType = selectedType;
      }
    });
    _fetchExpressions(reset: true);
  }

  void _onVideosToggled() {
    setState(() {
      _onlyVideos = !_onlyVideos;
    });
    _fetchExpressions(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    t = AppLocalizations.of(context)!;
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
    if (_isLoading && _expressions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_expressions.isEmpty) {
      return const Center(child: Text('No se encontraron expresiones.'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _expressions.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _expressions.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final expression = _expressions[index];
        return _buildExpressionTile(expression, index);
      },
    );
  }

  Widget _buildExpressionTile(Expression expression, int index) {
    return ExpressionCard(
      expression: expression,
      showAds: (index % 7 == 0 && index != 0),
    );
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
