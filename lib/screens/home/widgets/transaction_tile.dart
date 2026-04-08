import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/transaction_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/categories.dart';
import '../../add_transaction/add_transaction_sheet.dart';
import '../../../widgets/app_snackbar.dart';

class TransactionTile extends StatefulWidget {
  final Transaction transaction;
  final bool isVaultMode;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.isVaultMode = false,
  });

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.975,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  bool get _isIncome => widget.transaction.isIncome;

  Color get _accentColor =>
      _isIncome ? const Color(0xFF00C853) : const Color(0xFFFF3B30);

  Color get _accentSubtle =>
      _isIncome
          ? const Color(0xFF00C853).withValues(alpha: 0.08)
          : const Color(0xFFFF3B30).withValues(alpha: 0.08);

  IconData get _categoryIcon {
    final cat = widget.transaction.category.toLowerCase();
    if (cat.contains('food') ||
        cat.contains('restaurant') ||
        cat.contains('dining')) {
      return Icons.restaurant_rounded;
    } else if (cat.contains('transport') ||
        cat.contains('fuel') ||
        cat.contains('travel')) {
      return Icons.directions_car_rounded;
    } else if (cat.contains('salary') ||
        cat.contains('income') ||
        cat.contains('freelance')) {
      return Icons.account_balance_wallet_rounded;
    } else if (cat.contains('shopping') || cat.contains('clothes')) {
      return Icons.shopping_bag_rounded;
    } else if (cat.contains('health') ||
        cat.contains('medical') ||
        cat.contains('pharmacy')) {
      return Icons.favorite_rounded;
    } else if (cat.contains('entertainment') ||
        cat.contains('movie') ||
        cat.contains('game')) {
      return Icons.movie_filter_rounded;
    } else if (cat.contains('utilities') ||
        cat.contains('bill') ||
        cat.contains('electricity')) {
      return Icons.bolt_rounded;
    } else if (cat.contains('rent') ||
        cat.contains('home') ||
        cat.contains('house')) {
      return Icons.home_rounded;
    } else if (cat.contains('invest') ||
        cat.contains('stock') ||
        cat.contains('mutual')) {
      return Icons.trending_up_rounded;
    }
    return _isIncome ? Icons.south_west_rounded : Icons.north_east_rounded;
  }

  Future<bool> _showConfirmation(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    bool isDestructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Slidable(
          key: ValueKey(widget.transaction.id),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.65,
            children: [
              // Edit action — custom pill shape
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    AddTransactionSheet.show(
                      context,
                      transaction: widget.transaction,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A84FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Hide/Unhide action
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    HapticFeedback.mediumImpact();

                    final confirmed = await _showConfirmation(
                      context,
                      title: widget.isVaultMode ? 'Unhide Transaction' : 'Hide Transaction',
                      content: widget.isVaultMode
                          ? 'Are you sure you want to remove this transaction from the hidden vault?'
                          : 'Are you sure you want to move this transaction to the hidden vault?',
                      confirmText: widget.isVaultMode ? 'Unhide' : 'Hide',
                    );
                    if (!confirmed) return;
                    if (!context.mounted) return;

                    final provider = Provider.of<TransactionProvider>(
                      context,
                      listen: false,
                    );
                    await provider.toggleHide(widget.transaction.id);
                    if (context.mounted) {
                      AppSnackBar.show(
                        context,
                        message: widget.isVaultMode
                            ? 'Transaction unhidden'
                            : 'Transaction hidden',
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9500),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.isVaultMode
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.isVaultMode ? 'Unhide' : 'Hide',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Delete action
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    HapticFeedback.mediumImpact();

                    final confirmed = await _showConfirmation(
                      context,
                      title: 'Delete Transaction',
                      content: 'Are you sure you want to delete this transaction?\n\nThis action cannot be undone.',
                      confirmText: 'Delete',
                      isDestructive: true,
                    );
                    if (!confirmed) return;
                    if (!context.mounted) return;

                    final provider = Provider.of<TransactionProvider>(
                      context,
                      listen: false,
                    );
                    await provider.delete(widget.transaction.id);
                    if (context.mounted) {
                      AppSnackBar.show(
                        context,
                        message: 'Transaction deleted',
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 6,
                      right: 4,
                      top: 4,
                      bottom: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          child: GestureDetector(
            onTapDown: (_) => _pressController.forward(),
            onTapUp: (_) => _pressController.reverse(),
            onTapCancel: () => _pressController.reverse(),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark
                            ? Colors.black.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color:
                        isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Subtle left accent stripe
                    Positioned(
                      left: 0,
                      top: 12,
                      bottom: 12,
                      child: Container(
                        width: 3,
                        decoration: BoxDecoration(
                          color: _accentColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
                      child: Row(
                        children: [
                          // Icon container
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: _accentSubtle,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              _categoryIcon,
                              color: _accentColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppCategories.fromKey(widget.transaction.category)?.label ?? 
                                  Formatters.capitalize(widget.transaction.category),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: onSurface,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                if (widget.transaction.note.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.transaction.note,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: onSurface.withValues(alpha: 0.45),
                                      fontWeight: FontWeight.w400,
                                      height: 1.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Amount
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_isIncome ? '+' : '−'} ${Formatters.formatCurrency('₹', widget.transaction.amount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: _isIncome ? _accentColor : onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _accentSubtle,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _isIncome ? 'Credit' : 'Debit',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _accentColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
