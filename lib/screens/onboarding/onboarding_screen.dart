import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/services/secure_storage_service.dart';
import '../../data/services/storage_service.dart';
import '../../screens/shell/app_shell.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/pin_input.dart';
import 'widgets/onboarding_page.dart';
import 'widgets/security_option_card.dart';

/// Three-step onboarding flow:
///   1. Welcome — brand introduction
///   2. Profile — name, username, currency
///   3. Security — optional PIN / password setup
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step 2 — Profile
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  String _currency = '₹';
  final _profileFormKey = GlobalKey<FormState>();

  // Step 3 — Security
  String? _securityType; // 'pin' or null
  String _pinValue = '';
  final _pinInputKey = GlobalKey<PinInputState>();
  bool _showPinEntryView = false;

  // Confirm step for PIN
  bool _isConfirmStep = false;
  String _firstEntry = '';
  String? _confirmError;

  static const _currencies = ['₹', '\$', '€', '£', '¥'];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // --- Navigation ---

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onNextPressed() {
    if (_currentPage == 0) {
      _goToPage(1);
    } else if (_currentPage == 1) {
      if (_profileFormKey.currentState?.validate() ?? false) {
        _goToPage(2);
      }
    } else {
      _handleSecuritySubmit();
    }
  }

  // --- Security flow ---

  void _handleSecuritySubmit() {
    if (_securityType == null) {
      // Skip security
      _completeOnboarding();
      return;
    }

    if (_securityType == 'pin') {
      _handlePinSubmit();
    }
  }

  void _handlePinSubmit() {
    if (!_isConfirmStep) {
      // First entry — ask to confirm
      setState(() {
        _firstEntry = _pinValue;
        _pinValue = '';
        _isConfirmStep = true;
        _confirmError = null;
      });
      _pinInputKey.currentState?.clear();
    } else {
      // Confirming — check match
      if (_pinValue == _firstEntry) {
        _completeOnboarding(credential: _pinValue);
      } else {
        setState(() => _confirmError = 'PINs don\'t match. Try again.');
        _pinInputKey.currentState?.shakeAndClear();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _isConfirmStep = false;
              _firstEntry = '';
              _pinValue = '';
              _confirmError = null;
            });
          }
        });
      }
    }
  }

  // --- Complete onboarding ---

  Future<void> _completeOnboarding({String? credential}) async {
    final storage = context.read<StorageService>();
    final secureStorage = context.read<SecureStorageService>();

    // Save profile
    await storage.setDisplayName(_nameController.text.trim());
    await storage.setUserName(_usernameController.text.trim());
    await storage.setCurrency(_currency);

    // Save security preference
    await storage.setSecurityType(_securityType);
    if (_securityType != null && credential != null) {
      await secureStorage.saveCredential(credential);
    }

    // Mark onboarding complete
    await storage.setOnboarded(true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() {
                  _currentPage = i;
                  // Reset confirm state when navigating away
                  _isConfirmStep = false;
                  _firstEntry = '';
                  _confirmError = null;
                  _showPinEntryView = false;
                }),
                children: [
                  _buildWelcomePage(),
                  _buildProfilePage(),
                  _buildSecurityPage(),
                ],
              ),
            ),

            // Bottom section: dots + button
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  // --- Page 1: Welcome ---

  Widget _buildWelcomePage() {
    return OnboardingPage(
      imageWidget: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/welcome.png',
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      )
          .animate()
          .fadeIn(duration: 800.ms)
          .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
      title: 'Welcome to FinMan',
      subtitle:
          'Take control of your finances with a simple, beautiful tracker that stays on your device.',
      content: const SizedBox.shrink(),
    );
  }

  // --- Page 2: Profile ---

  Widget _buildProfilePage() {
    return OnboardingPage(
      icon: Icons.person_outline_rounded,
      title: 'Set Up Your Profile',
      subtitle: 'Tell us a bit about yourself to personalise your experience.',
      content: Form(
        key: _profileFormKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppTextField(
                label: 'Full Name',
                hint: 'John Doe',
                controller: _nameController,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
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
      ),
    );
  }

  // --- Page 3: Security ---

  Widget _buildSecurityPage() {
    // Determine title based on view state
    String title;
    if (_showPinEntryView) {
      title = 'Set Up PIN';
    } else if (_isConfirmStep) {
      title = 'Confirm PIN';
    } else {
      title = 'Secure Your App';
    }

    // Determine subtitle based on view state
    String subtitle;
    if (_showPinEntryView) {
      subtitle = 'Enter a 4-digit PIN to secure your app.';
    } else if (_isConfirmStep) {
      subtitle = 'Enter your PIN again to confirm.';
    } else {
      subtitle = 'Add an extra layer of privacy. You can always change this later.';
    }

    // Determine content based on view state
    Widget content;
    if (_showPinEntryView) {
      content = _buildPinEntryView();
    } else if (_isConfirmStep) {
      content = _buildConfirmInput();
    } else {
      content = _buildSecuritySelection();
    }

    return OnboardingPage(
      icon: Icons.lock_outline_rounded,
      title: title,
      subtitle: subtitle,
      content: content,
    );
  }

  Widget _buildSecuritySelection() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SecurityOptionCard(
            icon: Icons.pin_outlined,
            title: '4-Digit PIN',
            description: 'Quick and easy to enter',
            isSelected: _securityType == 'pin',
            onTap: () => setState(() {
              _securityType = 'pin';
              _showPinEntryView = true;
              _pinValue = '';
            }),
          ),
          const SizedBox(height: 12),
          SecurityOptionCard(
            icon: Icons.lock_open_rounded,
            title: 'Skip for Now',
            description: 'No lock screen on launch',
            isSelected: _securityType == null,
            onTap: () => setState(() => _securityType = null),
          ),

          if (_confirmError != null) ...[
            const SizedBox(height: 12),
            Text(
              _confirmError!,
              style: TextStyle(color: AppColors.expense, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPinEntryView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isConfirmStep ? 'Enter again for confirmation' : 'Enter a 4-digit PIN',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGrey,
                ),
          ),
          const SizedBox(height: 12),
          PinInput(
            key: _pinInputKey,
            onCompleted: (pin) {
              setState(() => _pinValue = pin);
              // Automatically submit when PIN is complete
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) _handlePinSubmit();
              });
            },
            onChanged: (v) => setState(() => _pinValue = v),
          ),
          if (_confirmError != null) ...[
            const SizedBox(height: 12),
            Text(
              _confirmError!,
              style: TextStyle(color: AppColors.expense, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmInput() {
    return Column(
      children: [
        PinInput(
          key: _pinInputKey,
          onCompleted: (pin) {
            setState(() => _pinValue = pin);
            _handlePinSubmit();
          },
          onChanged: (v) => setState(() => _pinValue = v),
        ),
        if (_confirmError != null) ...[
          const SizedBox(height: 16),
          Text(
            _confirmError!,
            style: TextStyle(color: AppColors.expense, fontSize: 13),
          ),
        ],
      ],
    );
  }

  // --- Bottom: Dots + Button ---

  Widget _buildBottomSection() {
    final isLastPage = _currentPage == 2;
    final canProceed = _canProceed();

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? AppColors.accent
                      : AppColors.accent.withValues(alpha: 0.2),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Action button
          AppButton(
            label: isLastPage
                ? (_securityType == null ? 'Get Started' : 'Set Up & Continue')
                : 'Next',
            onPressed: canProceed ? _onNextPressed : null,
          ),

          // Back button (pages 1 & 2, or PIN entry view)
          if (_currentPage > 0 || _showPinEntryView) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                if (_showPinEntryView) {
                  setState(() {
                    _showPinEntryView = false;
                    _securityType = null;
                    _pinValue = '';
                    _pinInputKey.currentState?.clear();
                  });
                } else if (_isConfirmStep) {
                  setState(() {
                    _isConfirmStep = false;
                    _confirmError = null;
                    _firstEntry = '';
                    _pinInputKey.currentState?.clear();
                  });
                } else {
                  _goToPage(_currentPage - 1);
                }
              },
              child: Text(
                _isConfirmStep ? 'Go Back' : 'Back',
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Determines whether the "Next" button should be enabled.
  bool _canProceed() {
    if (_currentPage == 0) return true;
    if (_currentPage == 1) return true; // validation happens on press
    // Security page
    if (_securityType == null) return true; // skip
    if (_securityType == 'pin') return _pinValue.length == 4;
    return true;
  }
}
