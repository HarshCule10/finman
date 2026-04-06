import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable PIN input widget with animated dot indicators and a numeric keypad.
/// Used in both the onboarding security step and the lock screen.
class PinInput extends StatefulWidget {
  final int pinLength;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  const PinInput({
    super.key,
    this.pinLength = 4,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<PinInput> createState() => PinInputState();
}

class PinInputState extends State<PinInput> with TickerProviderStateMixin {
  String _pin = '';

  // Shake animation for wrong PIN feedback
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  /// Triggers the shake animation and clears the PIN (call on wrong input).
  void shakeAndClear() {
    _shakeController.forward(from: 0).then((_) {
      setState(() => _pin = '');
      widget.onChanged?.call('');
    });
  }

  /// Clears the current PIN input.
  void clear() => setState(() => _pin = '');

  void _onDigitPressed(int digit) {
    if (_pin.length >= widget.pinLength) return;
    HapticFeedback.lightImpact();
    setState(() => _pin += digit.toString());
    widget.onChanged?.call(_pin);

    if (_pin.length == widget.pinLength) {
      widget.onCompleted(_pin);
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
    widget.onChanged?.call(_pin);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dot indicators
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) => Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.pinLength, (i) {
              final isFilled = i < _pin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: isFilled ? 18 : 14,
                height: isFilled ? 18 : 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled
                      ? colorScheme.primary
                      : colorScheme.primary.withValues(alpha: 0.15),
                  border: isFilled
                      ? null
                      : Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 32),

        // Numeric keypad
        _buildKeypad(context),
      ],
    );
  }

  Widget _buildKeypad(BuildContext context) {
    final textColor = Theme.of(context).textTheme.headlineMedium?.color ??
        Colors.white;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        children: [
          for (int row = 0; row < 4; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildRow(row, textColor),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildRow(int row, Color textColor) {
    if (row < 3) {
      // Rows 0-2: digits 1-9
      return List.generate(3, (col) {
        final digit = row * 3 + col + 1;
        return _KeypadButton(
          label: digit.toString(),
          textColor: textColor,
          onTap: () => _onDigitPressed(digit),
        );
      });
    }

    // Row 3: empty | 0 | backspace
    return [
      const SizedBox(width: 68, height: 68),
      _KeypadButton(
        label: '0',
        textColor: textColor,
        onTap: () => _onDigitPressed(0),
      ),
      _KeypadButton(
        icon: Icons.backspace_outlined,
        textColor: textColor,
        onTap: _onBackspace,
      ),
    ];
  }
}

/// A single keypad button with a ripple effect.
class _KeypadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Color textColor;
  final VoidCallback onTap;

  const _KeypadButton({
    this.label,
    this.icon,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        child: SizedBox(
          width: 68,
          height: 68,
          child: Center(
            child: icon != null
                ? Icon(icon, color: textColor, size: 24)
                : Text(
                    label ?? '',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
