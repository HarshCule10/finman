import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../home/widgets/transaction_tile.dart';
import 'widgets/active_filters_row.dart';
import 'widgets/search_filter_bar.dart';

/// Full-featured search and filter screen with live text search,
/// date range, category, and income/expense filters.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  String _query = '';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;
  bool? _isIncome; // null = all

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _query = '';
      _searchController.clear();
      _startDate = null;
      _endDate = null;
      _selectedCategory = null;
      _isIncome = null;
    });
  }

  bool get _hasAnyFilter =>
      _query.isNotEmpty ||
      _startDate != null ||
      _selectedCategory != null ||
      _isIncome != null;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final results = provider.searchTransactions(
      query: _query.isNotEmpty ? _query : null,
      startDate: _startDate,
      endDate: _endDate,
      categoryKey: _selectedCategory,
      isIncome: _isIncome,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Search',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search by note or category...',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                    size: 22,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4),
                          ),
                          onPressed: () {
                            setState(() {
                              _query = '';
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),

          // ── Filter chips ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SearchFilterBar(
              startDate: _startDate,
              endDate: _endDate,
              selectedCategory: _selectedCategory,
              isIncome: _isIncome,
              onDateRangeSelected: (range) {
                setState(() {
                  _startDate = range.start;
                  _endDate = range.end;
                });
              },
              onCategorySelected: (cat) =>
                  setState(() => _selectedCategory = cat),
              onTypeChanged: (type) => setState(() => _isIncome = type),
            ),
          ),

          const SizedBox(height: 10),

          // ── Active filters row ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ActiveFiltersRow(
              startDate: _startDate,
              endDate: _endDate,
              selectedCategory: _selectedCategory,
              isIncome: _isIncome,
              onClearDates: () =>
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  }),
              onClearCategory: () =>
                  setState(() => _selectedCategory = null),
              onClearType: () => setState(() => _isIncome = null),
              onClearAll: _clearAll,
            ),
          ),

          const SizedBox(height: 10),

          // ── Results header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _hasAnyFilter
                      ? '${results.length} result${results.length == 1 ? '' : 's'}'
                      : 'All Transactions',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
                if (_hasAnyFilter)
                  GestureDetector(
                    onTap: _clearAll,
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Results list ────────────────────────────────────────────
          Expanded(
            child: results.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return TransactionTile(
                              transaction: results[index])
                          .animate(delay: (index * 30).ms)
                          .fadeIn(duration: 250.ms)
                          .slideY(
                            begin: 0.08,
                            end: 0,
                            duration: 250.ms,
                          );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _hasAnyFilter
                ? Icons.search_off_rounded
                : Icons.receipt_long_rounded,
            size: 56,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Text(
            _hasAnyFilter
                ? 'No transactions match your filters'
                : 'No transactions yet',
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),
          ),
          if (_hasAnyFilter) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _clearAll,
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}
