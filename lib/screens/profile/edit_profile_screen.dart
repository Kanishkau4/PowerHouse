import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powerhouse/services/user_service.dart';
import 'package:powerhouse/models/user_model.dart';
import 'package:powerhouse/core/constants/goals.dart';
import 'dart:io';

import 'package:powerhouse/widgets/animated_message.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart'; // ✅ ADD THIS

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String? _selectedGender;
  String? _selectedActivityLevel;
  String? _selectedGoal;
  File? _profileImage;
  bool _isLoading = false;
  UserModel? _currentUser;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  final List<String> _activityLevels = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _userService.getCurrentUserProfile();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.username;
          _emailController.text = user.email;
          _ageController.text = user.age?.toString() ?? '';
          _weightController.text = user.currentWeight?.toString() ?? '';
          _heightController.text = user.height?.toString() ?? '';

          print('📊 Database Values:');
          print('Gender: "${user.gender}"');
          print('Activity Level: "${user.activityLevel}"');
          print('Fitness Goal: "${user.fitnessGoal}"');

          _selectedGender = _findMatchingValue(user.gender, _genders);
          _selectedActivityLevel = _findMatchingValue(
            user.activityLevel,
            _activityLevels,
          );

          if (user.fitnessGoal != null) {
            if (GoalConstants.allGoalIds.contains(user.fitnessGoal)) {
              _selectedGoal = user.fitnessGoal;
            } else {
              _selectedGoal = GoalConstants.getIdFromDisplayName(
                user.fitnessGoal,
              );
            }
          }

          print('🎯 Selected Values:');
          print('Gender: $_selectedGender');
          print('Activity Level: $_selectedActivityLevel');
          print('Fitness Goal ID: $_selectedGoal');
          print(
            'Fitness Goal Display: ${GoalConstants.getSimpleName(_selectedGoal)}',
          );
        });
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
      if (mounted) {
        AnimatedMessage.show(
          context,
          message: 'Failed to load profile: ${e.toString()}',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _findMatchingValue(String? dbValue, List<String> options) {
    if (dbValue == null || dbValue.isEmpty) return null;

    final cleanDbValue = dbValue.trim().toLowerCase();

    for (var option in options) {
      if (option.trim().toLowerCase() == cleanDbValue) {
        return option;
      }
    }

    print('⚠️ No match found for: "$dbValue" in options: $options');
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground, // ✅ DARK MODE
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_camera,
                color: context.primaryColor, // ✅ DARK MODE
              ),
              title: Text(
                'Take Photo',
                style: TextStyle(color: context.primaryText), // ✅ DARK MODE
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                  maxWidth: 1024,
                  maxHeight: 1024,
                );
                if (photo != null) {
                  setState(() {
                    _profileImage = File(photo.path);
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: context.primaryColor, // ✅ DARK MODE
              ),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(color: context.primaryText), // ✅ DARK MODE
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                  maxWidth: 1024,
                  maxHeight: 1024,
                );
                if (image != null) {
                  setState(() {
                    _profileImage = File(image.path);
                  });
                }
              },
            ),
            if (_profileImage != null ||
                _currentUser?.profilePictureUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Remove Photo',
                  style: TextStyle(color: context.primaryText), // ✅ DARK MODE
                ),
                onTap: () async {
                  Navigator.pop(context);

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: context.cardBackground, // ✅ DARK MODE
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                        'Remove Photo',
                        style: TextStyle(
                          color: context.primaryText, // ✅ DARK MODE
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to remove your profile picture?',
                        style: TextStyle(
                          color: context.secondaryText, // ✅ DARK MODE
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: context.secondaryText, // ✅ DARK MODE
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Remove',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    setState(() {
                      _profileImage = null;
                    });

                    try {
                      await _userService.deleteProfilePicture(
                        _currentUser?.profilePictureUrl,
                      );
                      await _userService.updateUserProfile({
                        'profile_picture_url': null,
                      });

                      if (mounted) {
                        AnimatedMessage.show(
                          context,
                          message: 'Profile picture removed',
                          backgroundColor: const Color(0xFF1DAB87),
                          icon: Icons.check_circle_rounded,
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        AnimatedMessage.show(
                          context,
                          message: 'Failed to remove picture: $e',
                          backgroundColor: Colors.red,
                          icon: Icons.error,
                        );
                      }
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? uploadedImageUrl;

        if (_profileImage != null) {
          try {
            if (_currentUser?.profilePictureUrl != null) {
              await _userService.deleteProfilePicture(
                _currentUser!.profilePictureUrl,
              );
            }

            uploadedImageUrl = await _userService.uploadProfilePicture(
              _profileImage!,
            );

            if (mounted) {
              AnimatedMessage.show(
                context,
                message: '✅ Profile picture uploaded!',
                backgroundColor: const Color(0xFF1DAB87),
                icon: Icons.check_circle_rounded,
                duration: const Duration(seconds: 2),
              );
            }
          } catch (e) {
            print('Error uploading profile picture: $e');
            if (mounted) {
              AnimatedMessage.show(
                context,
                message: 'Failed to upload picture: ${e.toString()}',
                backgroundColor: Colors.orange,
                icon: Icons.error,
                duration: const Duration(seconds: 3),
              );
            }
          }
        }

        final Map<String, dynamic> updates = {
          'username': _nameController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (uploadedImageUrl != null) {
          updates['profile_picture_url'] = uploadedImageUrl;
        }

        if (_selectedGender != null) {
          updates['gender'] = _selectedGender;
        }

        if (_selectedActivityLevel != null) {
          updates['activity_level'] = _selectedActivityLevel;
        }

        if (_selectedGoal != null) {
          updates['fitness_goal'] = _selectedGoal;
        }

        final age = int.tryParse(_ageController.text);
        if (age != null) updates['age'] = age;

        final weight = double.tryParse(_weightController.text);
        if (weight != null) updates['current_weight'] = weight;

        final height = double.tryParse(_heightController.text);
        if (height != null) updates['height'] = height;

        print('📤 Updating profile with: $updates');

        await _userService.updateUserProfile(updates);

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          AnimatedMessage.show(
            context,
            message: 'Profile updated successfully!',
            backgroundColor: const Color(0xFF1DAB87),
            icon: Icons.check_circle_rounded,
            duration: const Duration(seconds: 2),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        print('❌ Error saving profile: $e');
        if (mounted) {
          AnimatedMessage.show(
            context,
            message: 'Failed to update profile: ${e.toString()}',
            backgroundColor: Colors.red,
            icon: Icons.error,
            duration: const Duration(seconds: 3),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.surfaceColor, // ✅ DARK MODE
      appBar: AppBar(
        backgroundColor: context.surfaceColor, // ✅ DARK MODE
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: context.primaryText, // ✅ DARK MODE
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: context.primaryText, // ✅ DARK MODE
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_currentUser != null)
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildProfilePicture(),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Personal Information'),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.trim().toLowerCase() == 'admin') {
                            return 'This username is reserved. Please choose another name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: false,
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _ageController,
                              label: 'Age',
                              icon: Icons.cake_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final age = int.tryParse(value);
                                if (age == null || age < 13 || age > 100) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Gender',
                              icon: Icons.wc_outlined,
                              value: _selectedGender,
                              items: _genders,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildDropdownField(
                        label: 'Activity Level',
                        icon: Icons.speed_outlined,
                        value: _selectedActivityLevel,
                        items: _activityLevels,
                        onChanged: (value) {
                          setState(() {
                            _selectedActivityLevel = value;
                          });
                        },
                      ),

                      const SizedBox(height: 32),

                      _buildSectionTitle('Physical Stats'),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _weightController,
                              label: 'Weight (kg)',
                              icon: Icons.monitor_weight_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final weight = double.tryParse(value);
                                if (weight == null ||
                                    weight < 20 ||
                                    weight > 300) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _heightController,
                              label: 'Height (cm)',
                              icon: Icons.height_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final height = double.tryParse(value);
                                if (height == null ||
                                    height < 100 ||
                                    height > 250) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      _buildSectionTitle('Fitness Goal'),
                      const SizedBox(height: 16),

                      _buildGoalDropdown(),

                      const SizedBox(height: 32),

                      _buildSaveButton(),
                      const SizedBox(height: 16),
                      _buildDeleteAccountButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            )
          else
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.primaryColor, // ✅ DARK MODE
                ),
              ),
            ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.primaryColor, // ✅ DARK MODE
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== GOAL DROPDOWN ====================
  Widget _buildGoalDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Map<String, String> goalOptions = {
      'lose_weight': 'Lose Weight',
      'gain_muscle': 'Build Muscle',
      'gain_endurance': 'Gain Endurance',
      'try_app': 'Try App',
    };

    return DropdownButtonFormField<String>(
      initialValue: _selectedGoal,
      dropdownColor: context.cardBackground, // ✅ DARK MODE
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: context.primaryText, // ✅ DARK MODE
      ),
      decoration: InputDecoration(
        labelText: 'Primary Goal',
        labelStyle: TextStyle(
          color: context.secondaryText, // ✅ DARK MODE
        ),
        prefixIcon: Icon(
          Icons.flag_outlined,
          color: context.primaryColor, // ✅ DARK MODE
        ),
        filled: true,
        fillColor: context.inputBackground, // ✅ DARK MODE
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context.primaryColor, // ✅ DARK MODE
            width: 2,
          ),
        ),
      ),
      items: goalOptions.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(
            entry.value,
            style: TextStyle(
              color: context.primaryText, // ✅ DARK MODE
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGoal = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a goal';
        }
        return null;
      },
    );
  }

  // ==================== PROFILE PICTURE ====================
  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.primaryColor, // ✅ DARK MODE
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withOpacity(0.3), // ✅ DARK MODE
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: _profileImage != null
                  ? Image.file(_profileImage!, fit: BoxFit.cover)
                  : (_currentUser?.profilePictureUrl != null
                        ? Image.network(
                            _currentUser!.profilePictureUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderAvatar();
                            },
                          )
                        : _buildPlaceholderAvatar()),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.primaryColor, // ✅ DARK MODE
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.surfaceColor, // ✅ DARK MODE
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: context.primaryColor, // ✅ DARK MODE
      child: Center(
        child: Text(
          _currentUser?.username.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: context.primaryText, // ✅ DARK MODE
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Disabled colors
    final disabledFillColor = isDark
        ? Colors.grey.shade800
        : Colors.grey.shade200;
    final disabledTextColor = isDark ? Colors.grey.shade500 : Colors.grey;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: enabled ? context.primaryText : disabledTextColor, // ✅ DARK MODE
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled
              ? context
                    .secondaryText // ✅ DARK MODE
              : disabledTextColor,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled
              ? context
                    .primaryColor // ✅ DARK MODE
              : disabledTextColor,
        ),
        filled: true,
        fillColor: enabled
            ? context
                  .inputBackground // ✅ DARK MODE
            : disabledFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context.primaryColor, // ✅ DARK MODE
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: context.cardBackground, // ✅ DARK MODE
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: context.primaryText, // ✅ DARK MODE
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: context.secondaryText, // ✅ DARK MODE
        ),
        prefixIcon: Icon(
          icon,
          color: context.primaryColor, // ✅ DARK MODE
        ),
        filled: true,
        fillColor: context.inputBackground, // ✅ DARK MODE
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context.primaryColor, // ✅ DARK MODE
            width: 2,
          ),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              color: context.primaryText, // ✅ DARK MODE
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primaryColor, // ✅ DARK MODE
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark
              ? Colors
                    .grey
                    .shade700 // ✅ DARK MODE
              : Colors.grey.shade300,
          disabledForegroundColor: isDark
              ? Colors.grey.shade500
              : Colors.grey.shade500,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return TextButton(
      onPressed: () => _showDeleteAccountDialog(),
      child: const Text(
        'Delete Account',
        style: TextStyle(
          color: Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.cardBackground, // ✅ DARK MODE
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '⚠️ Delete Account',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: context.primaryText, // ✅ DARK MODE
          ),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
          style: TextStyle(
            color: context.secondaryText, // ✅ DARK MODE
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: context.secondaryText, // ✅ DARK MODE
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion requested'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
