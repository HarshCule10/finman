import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/services/secure_storage_service.dart';
import '../../data/services/storage_service.dart';
import '../../widgets/pin_input.dart';

/// Screen for setting or changing PIN with confirmation.
/// Displays a two-step flow: first entry and confirmation.
class SetPINScreen extends StatefulWidget {
  final bool isChanging; // true if changing existing PIN

  const SetPINScreen({
    super.key,
    this.isChanging = false,
  });

  @override
  State<SetPINScreen> createState() => _SetPINScreenState();
}

class _SetPINScreenState extends State<SetPINScreen> {
  String _pinValue = '';
  bool _isConfirmStep = false;
  String _firstEntry = '';
  String? _errorMessage;
  final _pinInputKey = GlobalKey<PinInputState>();

  void _onPINComplete(String pin) {
    setState(() {
      _pinValue = pin;
      _errorMessage = null;
    });

    // Automatically proceed when PIN is complete
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _handlePINSubmit();
    });
  }

  void _handlePINSubmit() {
    if (!_isConfirmStep) {
      // First entry — ask to confirm
      setState(() {
        _firstEntry = _pinValue;
        _pinValue = '';
        _isConfirmStep = true;
        _errorMessage = null;
      });
      _pinInputKey.currentState?.clear();
    } else {
      // Confirming — check match
      if (_pinValue == _firstEntry) {
        _savePIN();
      } else {
        setState(() => _errorMessage = 'PINs don\'t match. Try again.');
        _pinInputKey.currentState?.shakeAndClear();
        
        // Reset to first entry after a delay
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _isConfirmStep = false;
              _firstEntry = '';
              _pinValue = '';
              _errorMessage = null;
            });
          }
        });
      }
    }
  }

  Future<void> _savePIN() async {
    final secureStorage = context.read<SecureStorageService>();
    final storage = context.read<StorageService>();

    // Save PIN to SecureStorageService
    await secureStorage.saveCredential(_pinValue);

    // Update security type in StorageService
    await storage.setSecurityType('pin');

    if (!mounted) return;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isChanging ? 'PIN changed successfully!' : 'PIN set successfully!',
        ),
        backgroundColor: AppColors.income,
      ),
    );

    // Navigate back on success
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Determine title based on state
    String title;
    if (_isConfirmStep) {
      title = 'Confirm PIN';
    } else {
      title = widget.isChanging ? 'Change PIN' : 'Set Up PIN';
    }

    // Determine subtitle based on state
    String subtitle;
    if (_isConfirmStep) {
      subtitle = 'Enter your PIN again to confirm';
    } else {
      subtitle = 'Enter a 4-digit PIN to secure your app';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isChanging ? 'Change PIN' : 'Set Up PIN'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.2, end: 0),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textGrey,
                    ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: -0.2, end: 0),

              const SizedBox(height: 48),

              // PIN Input
              PinInput(
                key: _pinInputKey,
                onCompleted: _onPINComplete,
                onChanged: (v) => setState(() {
                  _pinValue = v;
                  _errorMessage = null;
                }),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: AppColors.expense,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .shake(hz: 4, curve: Curves.easeInOut),
            ],
          ),
        ),
      ),
    );
  }
}
