import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/transaction_provider.dart';

/// Full-screen transaction list with Weekly / Monthly tab switcher.
class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTransactionList(List transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'No transactions for this period',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: t.isIncome
                  ? [
                      Theme.of(context).colorScheme.surface,
                      Colors.green.withValues(alpha: 0.1),
                    ]
                  : [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                    ],
            ),
            border: Border.all(
              color: (t.isIncome ? Colors.green : Theme.of(context).colorScheme.error)
                  .withValues(alpha: 0.2),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (t.isIncome
                        ? Colors.green
                        : Theme.of(context).colorScheme.error)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                t.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: t.isIncome ? Colors.green : Theme.of(context).colorScheme.error,
                size: 18,
              ),
            ),
            title: Text(t.category,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(
              t.note.isNotEmpty ? t.note : '${t.date.day}/${t.date.month}/${t.date.year}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            trailing: Text(
              Formatters.formatCurrency('₹', t.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: t.isIncome
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        )
            .animate(delay: (index * 40).ms)
            .slideX(begin: 0.15, end: 0, duration: 350.ms, curve: Curves.easeOut)
            .fadeIn(duration: 300.ms);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final now = DateTime.now();

    // Monthly: current month
    final monthTx = provider.allTransactions
        .where((t) =>
            t.date.year == now.year && t.date.month == now.month)
        .toList();

    // Weekly: current week (Mon–Sun)
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final weekTx = provider.allTransactions
        .where((t) => !t.date.isBefore(weekStart) && t.date.isBefore(weekEnd))
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'All Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(weekTx),
          _buildTransactionList(monthTx),
        ],
      ),
    );
  }
}
