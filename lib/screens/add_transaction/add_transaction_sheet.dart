import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/card_provider.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_button.dart';
import '../../../core/utils/formatters.dart';
import 'widgets/card_selector_sheet.dart';
import '../../../core/constants/categories.dart';

import '../../../data/models/transaction.dart';
import '../../../data/models/card_model.dart';

class AddTransactionSheet extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionSheet({super.key, this.transaction});

  static Future<void> show(BuildContext context, {Transaction? transaction}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionSheet(transaction: transaction),
    );
  }

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _selectedCategory;
  
  // Card selection state
  String? _selectedCardId;
  CardModel? _selectedCard;
  List<CardModel> _availableCards = [];
  
  // Category keys stored in Transaction.category; labels resolved via AppCategories
  static const List<String> _expenseCategoryKeys = [
    'food', 'transport', 'shopping', 'entertainment',
    'bills', 'health', 'education', 'other',
  ];

  static const List<String> _incomeCategoryKeys = [
    'salary', 'freelance', 'investment', 'gift', 'other_income',
  ];

  /// Display label for a stored category key (graceful fallback for old data).
  String _labelFor(String key) => AppCategories.fromKey(key)?.label ?? Formatters.capitalize(key);

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amountController.text = (widget.transaction!.amount == widget.transaction!.amount.toInt())
          ? widget.transaction!.amount.toInt().toString()
          : widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.note;
      _isIncome = widget.transaction!.isIncome;
      _selectedDate = widget.transaction!.date;
      _selectedCategory = widget.transaction!.category;
      _selectedCardId = widget.transaction!.cardId;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCards();
  }

  void _loadCards() {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    final cards = cardProvider.cards;
    debugPrint('Loaded ${cards.length} cards from CardProvider');
    
    setState(() {
      _availableCards = cards;
      // Initialize selected card from cardId when editing
      if (_selectedCardId != null && cards.isNotEmpty) {
        try {
          _selectedCard = cards.firstWhere(
            (card) => card.id == _selectedCardId,
          );
        } catch (e) {
          debugPrint('Card with id $_selectedCardId not found');
          _selectedCard = null;
          _selectedCardId = null;
        }
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    bool success;
    if (widget.transaction != null) {
      success = await provider.update(
        id: widget.transaction!.id,
        amount: amount,
        category: _selectedCategory!,
        date: _selectedDate,
        isIncome: _isIncome,
        note: _descriptionController.text.trim(),
        cardId: _selectedCardId,
      );
    } else {
      success = await provider.add(
        amount: amount,
        category: _selectedCategory!,
        date: _selectedDate,
        isIncome: _isIncome,
        note: _descriptionController.text.trim(),
        cardId: _selectedCardId,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Failed to add transaction')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      margin: const EdgeInsets.only(top: kToolbarHeight),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.transaction != null ? 'Edit Transaction' : 'Add Transaction',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Type Toggle
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isIncome = false;
                        _selectedCategory = null; // Reset category when switching type
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isIncome ? Theme.of(context).colorScheme.error.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: !_isIncome ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Expense',
                          style: TextStyle(
                            color: !_isIncome ? Theme.of(context).colorScheme.error : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isIncome = true;
                        _selectedCategory = null; // Reset category when switching type
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isIncome ? Colors.green.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isIncome ? Colors.green : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Income',
                          style: TextStyle(
                            color: _isIncome ? Colors.green : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Amount',
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _amountController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Category Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      hintText: _isIncome ? 'Select income category' : 'Select expense category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: {
                      ...(_isIncome ? _incomeCategoryKeys : _expenseCategoryKeys),
                      if (_selectedCategory != null) _selectedCategory!,
                    }.map((key) => DropdownMenuItem(
                              value: key,
                              child: Text(_labelFor(key)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                    validator: (val) => val == null ? 'Please select a category' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Card selection field
              GestureDetector(
                onTap: () async {
                  final selected = await CardSelectorSheet.show(
                    context,
                    cards: _availableCards,
                    selectedCardId: _selectedCardId,
                  );
                  // Handle both explicit selection and "No Card" option
                  setState(() {
                    _selectedCard = selected;
                    _selectedCardId = selected?.id;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Card (Optional)',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedCard != null
                                  ? _selectedCard!.nickname ?? _selectedCard!.bankName
                                  : 'No card selected',
                              style: TextStyle(
                                color: _selectedCard != null
                                    ? Theme.of(context).textTheme.bodyLarge?.color
                                    : Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                hint: 'Add a description',
                controller: _descriptionController,
              ),
              const SizedBox(height: 32),
              AppButton(
                label: widget.transaction != null ? 'Update Transaction' : 'Save Transaction',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
