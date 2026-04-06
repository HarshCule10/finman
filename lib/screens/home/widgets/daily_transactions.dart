import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import 'transaction_tile.dart';

class DailyTransactions extends StatefulWidget {
  const DailyTransactions({super.key});

  @override
  State<DailyTransactions> createState() => _DailyTransactionsState();
}

class _DailyTransactionsState extends State<DailyTransactions> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(DateTime.now()) ? DateTime.now() : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_selectedDate.isBefore(today)) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      });
    }
  }

  String _formatDateLabel() {
    final now = DateTime.now();
    if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (_selectedDate.year == yesterday.year &&
        _selectedDate.month == yesterday.month &&
        _selectedDate.day == yesterday.day) {
      return 'Yesterday';
    }
    return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Selector header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousDay,
                  ),
                  InkWell(
                    onTap: _pickDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            _formatDateLabel(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.calendar_today, size: 14),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _selectedDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)) 
                        ? _nextDay 
                        : null,
                    color: _selectedDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
                        ? null
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Transactions List
        Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            final dailyTransactions = provider.allTransactions.where((t) {
              return t.date.year == _selectedDate.year &&
                  t.date.month == _selectedDate.month &&
                  t.date.day == _selectedDate.day;
            }).toList();

            if (dailyTransactions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No transactions for this day',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: dailyTransactions.length,
              itemBuilder: (context, index) {
                final transaction = dailyTransactions[index];
                return TransactionTile(transaction: transaction);
              },
            );
          },
        ),
      ],
    );
  }
}
