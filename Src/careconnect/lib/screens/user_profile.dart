import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../components/widgets.dart';
import '../providers/account_provider.dart';
import '../utils/formatting.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();
  final _careNotesController = TextEditingController();

  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final account = ref.read(accountProvider);
    _fullNameController = TextEditingController(text: account.displayName);
    _emailController = TextEditingController(text: account.email);
  }

  Future<void> _pickImage() async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 512,
        maxWidth: 512,
      );

      if (!mounted) return;
      if (pickedFile != null) {
        setState(() => _profileImage = File(pickedFile.path));
      } else {
        showAppSnackBar(context, 'No image selected');
      }
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, 'Error picking image: $e');
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    ref.read(accountProvider.notifier).updateDisplayName(_fullNameController.text.trim());
    ref.read(accountProvider.notifier).updateEmail(_emailController.text.trim());
    setState(() => _isLoading = false);
    showAppSnackBar(context, 'Profile updated successfully', duration: const Duration(seconds: 2));
  }

  void _cancelChanges() {
    final account = ref.read(accountProvider);
    setState(() {
      _fullNameController.text = account.displayName;
      _emailController.text = account.email;
      _phoneController.clear();
      _roleController.clear();
      _careNotesController.clear();
      _profileImage = null;
    });
  }

  Future<void> _changePassword() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final currentPasswordController = TextEditingController();
        final newPasswordController = TextEditingController();
        final confirmPasswordController = TextEditingController();
        bool obscureCurrent = true;
        bool obscureNew = true;
        bool obscureConfirm = true;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label: 'Current password input',
                      child: TextField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrent,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          suffixIcon: IconButton(
                            icon: Icon(obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => obscureCurrent = !obscureCurrent),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      label: 'New password input',
                      child: TextField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          suffixIcon: IconButton(
                            icon: Icon(obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => obscureNew = !obscureNew),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      label: 'Confirm new password input',
                      child: TextField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          suffixIcon: IconButton(
                            icon: Icon(obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (newPasswordController.text != confirmPasswordController.text) {
                      showAppSnackBar(context, 'Passwords do not match');
                      return;
                    }
                    if (newPasswordController.text.length < 8) {
                      showAppSnackBar(context, 'Password must be at least 8 characters');
                      return;
                    }
                    ref.read(accountProvider.notifier).updatePassword(newPasswordController.text);
                    Navigator.pop(context);
                    showAppSnackBar(context, 'Password changed successfully');
                  },
                  child: const Text('Change Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    _careNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountProvider);
    final initials = initialsOf(account.displayName);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: LabeledBackButton(
          label: 'Home',
          onPressed: () => Navigator.of(context).pop(),
        ),
        leadingWidth: AppSizing.backButtonWidth,
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Manage your account information',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personal Information', style: AppTextStyles.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Update your profile details',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        height: 120,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _profileImage != null && _profileImage!.existsSync()
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        _profileImage!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Center(
                                          child: Text(initials, style: AppTextStyles.displayLarge.copyWith(color: AppColors.primary)),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(initials, style: AppTextStyles.displayLarge.copyWith(color: AppColors.primary)),
                                    ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.camera_alt_outlined),
                                    label: const Text('Change Photo'),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'JPG, PNG or GIF. Max 2MB.',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 20),

                      Text('Full Name', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter full name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text('Email Address', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text('Phone Number', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter phone',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text('Role', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _roleController,
                        decoration: InputDecoration(
                          hintText: 'Enter role',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text('Care Notes', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _careNotesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter care notes',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _isLoading ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              minimumSize: const Size(120, 48),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Save Changes'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: _cancelChanges,
                            style: OutlinedButton.styleFrom(minimumSize: const Size(120, 48)),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account Security', style: AppTextStyles.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Manage your password',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _changePassword,
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('Change Password'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
