import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../data/services/storage_service.dart';
import '../../providers/card_provider.dart';
import 'widgets/card_carousel.dart';
import 'widgets/add_card_sheet.dart';
import 'widgets/daily_transactions.dart';
import '../add_transaction/add_transaction_sheet.dart';

/// The main home screen of the FinMan app.
///
/// Displays:
/// - User greeting with display name
/// - Card carousel showing all financial cards
/// - Daily transactions with full calendar picker option
/// - A gradient button linking to the Statistics tab
/// - Floating action button for adding transactions
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Builds the app bar with logo, search icon, and notification icon with badge
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      title: Row(
        children: [
          // Logo/App name
          Text(
            'FinMan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
      actions: [
        // Search icon
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implement search functionality
          },
        ),
        // Notification icon with badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: Implement notifications
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Builds the greeting section with display name from StorageService
  Widget _buildGreeting(BuildContext context) {
    final storageService = Provider.of<StorageService>(context);
    final displayName = storageService.displayName;
    
    // Use "Hey, there" as fallback when display name is empty
    final greetingName = displayName.isEmpty ? 'there' : displayName;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hey, $greetingName',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  /// Builds the card carousel section
  Widget _buildCardCarousel(BuildContext context) {
    final cardProvider = Provider.of<CardProvider>(context);
    
    return CardCarousel(
      cards: cardProvider.cards,
      onAddCard: () {
        AddCardSheet.show(context);
      },
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2, end: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Greeting section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildGreeting(context),
              ),
              
              const SizedBox(height: 24),
              
              // Card carousel
              _buildCardCarousel(context),
              
              const SizedBox(height: 24),
              
              // Daily Transactions List
              const DailyTransactions()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 100), // Extra space for FAB
            ],
          ),
        ),
      ),
      // Floating action button for adding transactions
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AddTransactionSheet.show(context);
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 4,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 400.ms)
          .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
