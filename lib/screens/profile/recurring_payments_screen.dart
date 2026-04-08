import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/empty_state.dart';
import 'widgets/recurring_payment_tile.dart';

class RecurringPaymentsScreen extends StatelessWidget {
  const RecurringPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Recurring Payments'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final groups = provider.getRecurringGroups();
          
          if (groups.isEmpty) {
            return const EmptyState(
              icon: Icons.autorenew,
              title: 'No Recurring Payments',
              subtitle: 'Set up recurring payments when adding a transaction.',
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return RecurringPaymentTile(
                groupData: group,
              );
            },
          );
        },
      ),
    );
  }
}
