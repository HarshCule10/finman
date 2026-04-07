import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/storage_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

/// Bottom sheet for editing profile information
/// Allows users to update name, username, and currency
class EditProfileSheet extends StatefulWidget {
  final String initialName;
  final String initialUsername;
  final String initialCurrency;

  const EditProfileSheet({
    super.key,
    required this.initialName,
    required this.initialUsername,
    required this.initialCurrency,
  });

  /// Shows the edit profile sheet and returns updated values
  /// Returns a Map with 'name', 'username', and 'currency' keys if saved
  /// Returns null if cancelled
  static Future<Map<String, String>?> show(
    BuildContext context, {
    required String initialName,
    required String initialUsername,
    required String initialCurrency,
  }) {
    return showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(
        initialName: initialName,
        initialUsername: initialUsername,
        initialCurrency: initialCurrency,
      ),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late String _currency;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  static const _currencies = ['₹', '\$', '€', '£', '¥'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _usernameController = TextEditingController(text: widget.initialUsername);
    _currency = widget.initialCurrency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final storage = context.read<StorageService>();
      
      // Save to storage
      await storage.setDisplayName(_nameController.text.trim());
      await storage.setUserName(_usernameController.text.trim());
      await storage.setCurrency(_currency);

      if (!mounted) return;

      // Return updated values
      Navigator.of(context).pop({
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'currency': _currency,
      });
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save changes: $e'),
          backgroundColor: AppColors.expense,
        ),
      );
      
      setState(() => _isSaving = false);
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Edit Profile',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name field
                    AppTextField(
                      label: 'Full Name',
                      hint: 'John Doe',
                      controller: _nameController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    
                    // Username field
                    AppTextField(
                      label: 'Username',
                      hint: 'johndoe',
                      controller: _usernameController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Username is required'
                          : null,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),
                    
                    // Currency picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferred Currency',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: _currencies.map((c) {
                            final isSelected = c == _currency;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () => setState(() => _currency = c),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: isSelected
                                        ? AppColors.accent.withValues(alpha: 0.15)
                                        : Theme.of(context).cardTheme.color,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.accent
                                          : Theme.of(context).dividerColor,
                                      width: isSelected ? 1.8 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      c,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? AppColors.accent
                                            : AppColors.textGrey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: GestureDetector(
                      onTap: _isSaving ? null : _handleCancel,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Save button
                  Expanded(
                    child: AppButton(
                      label: 'Save',
                      onPressed: _isSaving ? null : _handleSave,
                      isLoading: _isSaving,
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
