import 'package:flutter/material.dart';
import '../data/models/card_model.dart';

/// A premium financial card widget with layered gradients, glassmorphism
/// elements, holographic chip, and subtle motion-ready layout.
class FinancialCard extends StatelessWidget {
  final CardModel card;

  const FinancialCard({super.key, required this.card});

  String get _maskedNumber => card.maskedCardNumber;

  /// Returns styled card-network label instead of a generic icon.
  Widget _buildNetworkBadge() {
    final label = switch (card.cardType) {
      CardType.visa => _VisaBadge(),
      CardType.mastercard => _MastercardBadge(),
      CardType.amex => _TextBadge(text: 'AMEX'),
      CardType.discover => _TextBadge(text: 'DISCOVER'),
      CardType.other => const Icon(
        Icons.credit_card_outlined,
        color: Colors.white70,
        size: 28,
      ),
    };
    return label;
  }

  /// Splits the masked number into 4 groups for spaced rendering.
  List<String> get _numberGroups => _maskedNumber.split(' ');

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0.0, 0.45, 1.0],
      colors:
          card.gradientColors.length >= 2
              ? [
                Color(card.gradientColors[0]),
                Color(
                  card.gradientColors[0],
                ).lerp(Color(card.gradientColors[1]), 0.5),
                Color(card.gradientColors[1]),
              ]
              : [
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
                const Color(0xFF0F3460),
              ],
    );

    return SizedBox(
      height: 210,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Base card container ──────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(
                    card.gradientColors.first,
                  ).withValues(alpha: 0.45),
                  blurRadius: 28,
                  spreadRadius: -4,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),

          // ── Large blurred arc — top-right atmosphere ─────────────────
          Positioned(
            top: -60,
            right: -60,
            child: _GlowOrb(
              size: 220,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),

          // ── Smaller accent orb — bottom-left ────────────────────────
          Positioned(
            bottom: -30,
            left: 20,
            child: _GlowOrb(
              size: 130,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),

          // ── Glossy sheen stripe ──────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.13),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Diagonal mesh lines for texture ─────────────────────────
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(painter: _MeshPainter()),
            ),
          ),

          // ── Card content ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Bank name + network badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      card.bankName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                      ),
                    ),
                    _buildNetworkBadge(),
                  ],
                ),

                const Spacer(),

                // Row 2: EMV chip
                _ChipWidget(),

                const SizedBox(height: 12),

                // Row 3: Card number groups
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      _numberGroups.asMap().entries.map((e) {
                        final isMasked = e.key < 3;
                        return Text(
                          e.value,
                          style: TextStyle(
                            color:
                                isMasked
                                    ? Colors.white.withValues(alpha: 0.65)
                                    : Colors.white,
                            fontSize: isMasked ? 17 : 19,
                            fontWeight:
                                isMasked ? FontWeight.w400 : FontWeight.w700,
                            letterSpacing: isMasked ? 3 : 2,
                            height: 1,
                          ),
                        );
                      }).toList(),
                ),

                const Spacer(),

                // Row 4: Cardholder + expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARDHOLDER',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          card.cardholderName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'EXPIRES',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          card.expiryDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Edge border highlight ────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Extension helper ──────────────────────────────────────────────────────────

extension _ColorLerp on Color {
  Color lerp(Color other, double t) => Color.lerp(this, other, t)!;
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

/// Soft blurred circular glow orb.
class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

/// Realistic EMV chip with golden gradient and grid lines.
class _ChipWidget extends StatelessWidget {
  const _ChipWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4A843), Color(0xFFF5D78E), Color(0xFFBF9020)],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(painter: _ChipPainter()),
    );
  }
}

/// Draws chip contact lines.
class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFBF9020).withValues(alpha: 0.6)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke;

    // Vertical center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    // Horizontal center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    // Inner rectangle
    final rect = Rect.fromLTRB(
      size.width * 0.18,
      size.height * 0.22,
      size.width * 0.82,
      size.height * 0.78,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ChipPainter old) => false;
}

/// Subtle diagonal mesh lines for card texture.
class _MeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.04)
          ..strokeWidth = 0.5;

    const spacing = 22.0;
    final count = (size.width + size.height) ~/ spacing + 2;

    for (int i = 0; i < count; i++) {
      final offset = i * spacing;
      canvas.drawLine(Offset(offset, 0), Offset(0, offset), paint);
    }
  }

  @override
  bool shouldRepaint(_MeshPainter old) => false;
}

// ── Network badges ────────────────────────────────────────────────────────────

class _VisaBadge extends StatelessWidget {
  const _VisaBadge();

  @override
  Widget build(BuildContext context) {
    return Text(
      'VISA',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
        shadows: [
          Shadow(color: Colors.white.withValues(alpha: 0.4), blurRadius: 8),
        ],
      ),
    );
  }
}

class _MastercardBadge extends StatelessWidget {
  const _MastercardBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEB001B).withValues(alpha: 0.85),
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF79E1B).withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextBadge extends StatelessWidget {
  final String text;
  const _TextBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
