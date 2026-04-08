import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../home/widgets/transaction_tile.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hidden Transactions'),
        centerTitle: true,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final transactions = provider.vaultTransactions;
          
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hidden transactions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return TransactionTile(
                transaction: transactions[index],
                isVaultMode: true,
              );
            },
          );
        },
      ),
    );
  }
}
