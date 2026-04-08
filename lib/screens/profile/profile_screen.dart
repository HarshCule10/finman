import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/storage_service.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/section_header.dart';
import '../../widgets/settings_card.dart';
import '../../widgets/app_snackbar.dart';
import 'widgets/edit_profile_sheet.dart';
import 'verify_pin_screen.dart';
import 'set_pin_screen.dart';
import 'recurring_payments_screen.dart';
import 'vault_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profilePhotoPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    final storage = Provider.of<StorageService>(context, listen: false);
    final photoFile = await storage.getProfilePhotoFile();
    if (mounted) {
      setState(() {
        _profilePhotoPath = photoFile?.path;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Pick image from specified source
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        // User cancelled the picker
        return;
      }

      // Convert XFile to File
      final File imageFile = File(pickedFile.path);

      // Save using StorageService
      final storage = Provider.of<StorageService>(context, listen: false);
      final savedPath = await storage.saveProfilePhoto(imageFile);

      // Update UI with new photo
      if (mounted) {
        setState(() {
          _profilePhotoPath = savedPath;
        });

        // Show success message
        AppSnackBar.show(
          context,
          message: 'Profile photo updated successfully',
        );
      }
    } catch (e) {
      // Handle errors with user-friendly message
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Failed to update profile photo: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Profile Photo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_profilePhotoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _removePhoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removePhoto() async {
    try {
      final storage = Provider.of<StorageService>(context, listen: false);
      
      // Delete the photo file if it exists
      if (_profilePhotoPath != null) {
        final file = File(_profilePhotoPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Clear the path in storage
      await storage.setProfilePhotoPath(null);
      
      // Update UI
      if (mounted) {
        setState(() {
          _profilePhotoPath = null;
        });
        
        AppSnackBar.show(
          context,
          message: 'Profile photo removed',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Failed to remove photo: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  String _getInitials(String displayName) {
    if (displayName.isEmpty) {
      return 'U';
    }
    
    // Split by spaces and get first letter of each word
    final words = displayName.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      // Single word: return first letter
      return words[0][0].toUpperCase();
    } else {
      // Multiple words: return first letter of first two words
      return (words[0][0] + words[1][0]).toUpperCase();
    }
  }

  Future<void> _showEditProfileSheet() async {
    final storage = Provider.of<StorageService>(context, listen: false);
    
    // Show the edit profile sheet with current values
    final result = await EditProfileSheet.show(
      context,
      initialName: storage.displayName,
      initialUsername: storage.userName,
      initialCurrency: storage.currency,
    );
    
    // If user saved changes, update UI and show success feedback
    if (result != null && mounted) {
      setState(() {
        // UI will rebuild with new values from StorageService
      });
      
      AppSnackBar.show(
        context,
        message: 'Profile updated successfully',
      );
    }
  }

  Future<void> _navigateToChangePIN() async {
    final storage = Provider.of<StorageService>(context, listen: false);
    
    // Check if PIN exists
    final hasPIN = storage.securityType == 'pin';
    
    if (!mounted) return;
    
    // Navigate to appropriate screen
    if (hasPIN) {
      // PIN exists - verify current PIN first
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const VerifyPINScreen(),
        ),
      );
    } else {
      // No PIN - go directly to set PIN
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SetPINScreen(isChanging: false),
        ),
      );
    }
    
    // Update UI after returning from PIN screens
    if (mounted) {
      setState(() {
        // UI will rebuild with updated security type
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final displayName = storage.displayName;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Profile Header
              Center(
                child: Column(
                  children: [
                    // Profile photo with camera overlay
                    GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: _profilePhotoPath != null
                                  ? Image.file(
                                      File(_profilePhotoPath!),
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Theme.of(context).colorScheme.surface,
                                      child: Center(
                                        child: Text(
                                          _getInitials(displayName),
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName.isEmpty ? 'User' : displayName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${storage.userName.isEmpty ? 'username' : storage.userName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textGrey,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap photo to change',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
              ),
              
              // Profile Information Section
              const SectionHeader(title: 'Profile Information'),
              SettingsCard(
                icon: Icons.person,
                title: 'Full Name',
                subtitle: displayName.isEmpty ? 'Not set' : displayName,
                onTap: _showEditProfileSheet,
              ),
              SettingsCard(
                icon: Icons.alternate_email,
                title: 'Username',
                subtitle: storage.userName.isEmpty ? 'Not set' : storage.userName,
                onTap: _showEditProfileSheet,
              ),
              SettingsCard(
                icon: Icons.attach_money,
                title: 'Currency',
                subtitle: storage.currency,
                onTap: _showEditProfileSheet,
              ),

              // Recurring Section
              const SectionHeader(title: 'Subscriptions & Recurring'),
              SettingsCard(
                icon: Icons.autorenew,
                title: 'Recurring Payments',
                subtitle: 'Manage automated transactions',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RecurringPaymentsScreen(),
                    ),
                  );
                },
              ),
              
              // Security Section
              const SectionHeader(title: 'Security'),
              SettingsCard(
                icon: Icons.lock,
                iconColor: storage.securityType != null ? Colors.green : AppColors.textGrey,
                title: storage.securityType != null ? 'Change PIN' : 'Set Up PIN',
                subtitle: storage.securityType != null 
                    ? 'Security: ${storage.securityType!.toUpperCase()}'
                    : 'Security: None',
                onTap: _navigateToChangePIN,
              ),
              if (storage.securityType == 'pin')
                SettingsCard(
                  icon: Icons.visibility_off,
                  iconColor: Theme.of(context).colorScheme.primary,
                  title: 'Hidden Transactions',
                  subtitle: 'View your secure vault',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VerifyPINScreen(
                          onSuccess: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const VaultScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              
              // Appearance Section
              const SectionHeader(title: 'Appearance'),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return SettingsCard(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: themeProvider.isDark ? 'Enabled' : 'Disabled',
                    trailing: Switch(
                      value: themeProvider.isDark,
                      onChanged: (value) async {
                        await themeProvider.toggle();
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
