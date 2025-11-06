import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powerhouse/services/user_service.dart';
import 'package:powerhouse/models/user_model.dart';
import 'package:powerhouse/core/constants/goals.dart'; // ← Add this import
import 'dart:io';

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
  String? _selectedGoal; // This will store the goal ID
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

          // 🐛 DEBUG: Print values from database
          print('📊 Database Values:');
          print('Gender: "${user.gender}"');
          print('Activity Level: "${user.activityLevel}"');
          print('Fitness Goal: "${user.fitnessGoal}"');

          // ✅ Set gender
          _selectedGender = _findMatchingValue(user.gender, _genders);

          // ✅ Set activity level
          _selectedActivityLevel = _findMatchingValue(
            user.activityLevel,
            _activityLevels,
          );

          // ✅ Set fitness goal - check if it's already an ID or display name
          if (user.fitnessGoal != null) {
            if (GoalConstants.allGoalIds.contains(user.fitnessGoal)) {
              // It's already an ID
              _selectedGoal = user.fitnessGoal;
            } else {
              // Try to find ID from display name
              _selectedGoal = GoalConstants.getIdFromDisplayName(
                user.fitnessGoal,
              );
            }
          }

          // 🐛 DEBUG: Print selected values
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
  
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera, color: Color(0xFF1DAB87)),
            title: const Text('Take Photo'),
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
            leading: const Icon(Icons.photo_library, color: Color(0xFF1DAB87)),
            title: const Text('Choose from Gallery'),
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
          if (_profileImage != null || _currentUser?.profilePictureUrl != null)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Photo'),
              onTap: () async {
                Navigator.pop(context);
                
                // Show confirmation dialog
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('Remove Photo'),
                    content: const Text('Are you sure you want to remove your profile picture?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
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
                  
                  // Delete from database
                  try {
                    await _userService.deleteProfilePicture(_currentUser?.profilePictureUrl);
                    await _userService.updateUserProfile({
                      'profile_picture_url': null,
                    });
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile picture removed'),
                          backgroundColor: Color(0xFF1DAB87),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to remove picture: $e'),
                          backgroundColor: Colors.red,
                        ),
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

      // ✅ Upload profile picture if a new one was selected
      if (_profileImage != null) {
        try {
          // Delete old profile picture if exists
          if (_currentUser?.profilePictureUrl != null) {
            await _userService.deleteProfilePicture(_currentUser!.profilePictureUrl);
          }

          // Upload new profile picture
          uploadedImageUrl = await _userService.uploadProfilePicture(_profileImage!);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Profile picture uploaded!'),
                backgroundColor: Color(0xFF1DAB87),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          print('Error uploading profile picture: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload picture: ${e.toString()}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          // Continue with other updates even if image upload fails
        }
      }

      // Prepare update data
      final Map<String, dynamic> updates = {
        'username': _nameController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add profile picture URL if uploaded
      if (uploadedImageUrl != null) {
        updates['profile_picture_url'] = uploadedImageUrl;
      }

      // Add optional fields
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

      // Update user profile
      await _userService.updateUserProfile(updates);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated successfully!'),
            backgroundColor: Color(0xFF1DAB87),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      print('❌ Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
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

                      // ✅ Updated Goal Dropdown with custom widget
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
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DAB87)),
              ),
            ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DAB87)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== GOAL DROPDOWN (Simplified) ====================
  Widget _buildGoalDropdown() {
    // Map of goal IDs to display names
    final Map<String, String> goalOptions = {
      'lose_weight': 'Lose Weight',
      'gain_muscle': 'Build Muscle',
      'gain_endurance': 'Gain Endurance',
      'try_app': 'Try App',
    };

    return DropdownButtonFormField<String>(
      initialValue: _selectedGoal,
      decoration: InputDecoration(
        labelText: 'Primary Goal',
        labelStyle: const TextStyle(color: Color(0xFF7E7E7E)),
        prefixIcon: const Icon(Icons.flag_outlined, color: Color(0xFF1DAB87)),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
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
          borderSide: const BorderSide(color: Color(0xFF1DAB87), width: 2),
        ),
      ),
      items: goalOptions.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
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
              border: Border.all(color: const Color(0xFF1DAB87), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DAB87).withOpacity(0.3),
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
                  color: const Color(0xFF1DAB87),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
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
      color: const Color(0xFF1DAB87),
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black,
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? const Color(0xFF7E7E7E) : Colors.grey,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? const Color(0xFF1DAB87) : Colors.grey,
        ),
        filled: true,
        fillColor: enabled ? const Color(0xFFF5F5F5) : Colors.grey.shade200,
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
          borderSide: const BorderSide(color: Color(0xFF1DAB87), width: 2),
        ),
        errorBorder: OutlineInputBorder(
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
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF7E7E7E)),
        prefixIcon: Icon(icon, color: const Color(0xFF1DAB87)),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
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
          borderSide: const BorderSide(color: Color(0xFF1DAB87), width: 2),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
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
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1DAB87),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '⚠️ Delete Account',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
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
