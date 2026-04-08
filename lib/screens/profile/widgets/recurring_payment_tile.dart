import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/models/transaction.dart';
import '../../../data/services/storage_service.dart';
import '../../../providers/transaction_provider.dart';
import '../../../core/constants/categories.dart';
import '../../../widgets/app_snackbar.dart';
import '../../add_transaction/add_transaction_sheet.dart';

class RecurringPaymentTile extends StatelessWidget {
  final Map<String, dynamic> groupData;

  const RecurringPaymentTile({super.key, required this.groupData});

  @override
  Widget build(BuildContext context) {
    final transaction = groupData['nextTransaction'] as Transaction;
    final recurringId = groupData['recurringId'] as String;
    final remainingCount = groupData['remainingCount'] as int;
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final storage = Provider.of<StorageService>(context, listen: false);
    final currency = storage.currency;

    final category = AppCategories.fromKey(transaction.category) ??
        AppCategories.all.firstWhere(
          (c) => c.label.toLowerCase() == transaction.category.toLowerCase(),
          orElse: () => AppCategories.all.first,
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Slidable(
        key: ValueKey(recurringId),
        groupTag: 'recurring_payments',
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.7,
          children: [
            SlidableAction(
              onPressed: (context) {
                AddTransactionSheet.show(
                  context,
                  transaction: transaction,
                  isEditingRecurring: true,
                  recurringId: recurringId,
                );
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (context) async {
                final success = await provider.cancelNextPayment(recurringId);
                if (success && context.mounted) {
                  AppSnackBar.show(context, message: 'Next payment skipped.');
                }
              },
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: Icons.skip_next,
              label: 'Skip Next',
            ),
            SlidableAction(
              onPressed: (context) async {
                final success = await provider.cancelEntireSubscription(recurringId);
                if (success && context.mounted) {
                  AppSnackBar.show(context, message: 'Subscription cancelled.');
                }
              },
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              icon: Icons.cancel,
              label: 'Cancel All',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, color: category.color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.label,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (transaction.note.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            transaction.note,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${transaction.isIncome ? '+' : '-'}$currency${transaction.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: transaction.isIncome ? Colors.green : null,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.frequency ?? 'Unknown',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Next Date',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Remaining',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(transaction.date),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '$remainingCount payments',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
