import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powerhouse/core/config/supabase_config.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
  String? get currentUserId => currentUser?.id;
  bool get isAuthenticated => currentUser != null;

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // ========== SIGN UP WITH EMAIL (SENDS OTP) ==========
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      print('Sign up response: ${response.user?.id}');
      print('User email confirmed: ${response.user?.emailConfirmedAt}');

      return response;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  // ========== VERIFY OTP (EMAIL VERIFICATION) ==========
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) async {
    try {
      print('Verifying OTP for email: $email, token: $token');

      final response = await _supabase.auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: token,
      );

      print('OTP verification response: ${response.user?.id}');

      // Create user profile AFTER successful verification
      if (response.user != null && response.session != null) {
        print('Creating user profile...');

        await Future.delayed(const Duration(milliseconds: 500));

        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          username: response.user!.userMetadata?['username'] ?? 'User',
        );

        print('User profile created successfully');
      }

      return response;
    } catch (e) {
      print('OTP verification error: $e');
      rethrow;
    }
  }

  // ========== RESEND OTP (FIXED) ==========
  Future<ResendResponse> resendOTP(String email) async {
    try {
      print('🔄 Attempting to resend OTP to: $email');

      // IMPORTANT: Use resend method with proper parameters
      final response = await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      print('✅ OTP resend response received');
      return response;
    } on AuthException catch (e) {
      print('❌ Resend OTP AuthException: ${e.message}');

      // Handle specific error cases
      if (e.message.contains('email_rate_limit_exceeded')) {
        throw Exception('Please wait 60 seconds before requesting a new code.');
      } else if (e.message.contains('already_confirmed')) {
        throw Exception('This email is already verified. Please sign in.');
      } else if (e.message.contains('not_found')) {
        throw Exception('User not found. Please sign up first.');
      }

      rethrow;
    } catch (e) {
      print('❌ Resend OTP error: $e');
      rethrow;
    }
  }

  // ========== ALTERNATIVE: SIGN UP AGAIN (IF USER EXISTS BUT NOT CONFIRMED) ==========
  Future<void> resendSignupEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 Attempting signup again to trigger email...');

      // This will fail if user exists BUT will send email if not confirmed
      await _supabase.auth.signUp(email: email, password: password);

      print('✅ Email sent');
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        // User exists, try resend instead
        await resendOTP(email);
      } else {
        rethrow;
      }
    }
  }

  // ========== SIGN IN WITH EMAIL ==========
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting sign in for: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('Sign in successful: ${response.user?.id}');
      return response;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // ========== CHECK IF USER PROFILE EXISTS ==========
  Future<bool> doesProfileExist() async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final response = await _supabase
          .from('users')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking profile: $e');
      return false;
    }
  }

  // ========== CHECK IF EMAIL IS ALREADY REGISTERED ==========
  Future<bool> isEmailRegistered(String email) async {
    try {
      // Try to sign in with a dummy password to check if email exists
      // This is a workaround since Supabase doesn't have a direct email check
      await _supabase.auth.signInWithPassword(
        email: email,
        password: 'dummy_password_for_check_12345',
      );
      return true; // If no error, email exists
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        return true; // Email exists but wrong password
      } else if (e.message.contains('Email not confirmed')) {
        return true; // Email exists but not confirmed
      }
      return false; // Email doesn't exist
    } catch (e) {
      return false;
    }
  }

  // ========== GOOGLE SIGN IN ==========
  Future<bool> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.powerhouse://login-callback/',
      );
      return true;
    } catch (e) {
      print('Google sign in error: $e');
      return false;
    }
  }

  // ========== APPLE SIGN IN ==========
  Future<bool> signInWithApple() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.powerhouse://login-callback/',
      );
      return true;
    } catch (e) {
      print('Apple sign in error: $e');
      return false;
    }
  }

  // ========== RESET PASSWORD ==========
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      print('Password reset email sent to: $email');
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  // ========== SIGN OUT ==========
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      print('User signed out');
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // ========== CREATE USER PROFILE ==========
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String username,
  }) async {
    try {
      print('Creating profile for user: $userId');

      final existing = await _supabase
          .from('users')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        print('Profile already exists for user: $userId');
        return;
      }

      await _supabase.from('users').insert({
        'user_id': userId,
        'email': email,
        'username': username,
        'xp_points': 0,
        'level': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('Profile created successfully for: $email');
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  // ========== UPDATE USER PROFILE DATA (COMPLETE PROFILE SETUP) ==========
  Future<void> completeProfileSetup({
    required String gender,
    required int age,
    required double weight,
    required double height,
    required String goal,
    String? weightUnit,
    String? heightUnit,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('No user logged in');

      print('🔄 Completing profile setup for user: $userId');

      // Convert units to metric if needed
      final weightInKg = weightUnit == 'lbs' ? weight / 2.20462 : weight;
      final heightInCm = heightUnit == 'ft' ? height * 30.48 : height;

      // Calculate activity level based on goal
      String activityLevel = _calculateActivityLevel(age, goal);

      // Update user profile with all data
      await _supabase
          .from('users')
          .update({
            'gender': gender,
            'age': age,
            'current_weight': weightInKg.toDouble(),
            'height': heightInCm.toDouble(),
            'fitness_goal': goal,
            'activity_level': activityLevel,
            'xp_points': 0,
            'level': 1,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      print('✅ Profile setup completed successfully');
      print(
        '📊 Gender: $gender, Age: $age, Weight: ${weightInKg.toInt()}kg, Height: ${heightInCm.toInt()}cm, Goal: $goal',
      );
    } catch (e) {
      print('❌ Complete profile error: $e');
      rethrow;
    }
  }

  // Helper: Calculate activity level based on age and goal
  String _calculateActivityLevel(int age, String goal) {
    // Simple logic - you can make this more sophisticated
    if (goal == 'lose_weight') {
      return 'Light';
    } else if (goal == 'gain_muscle') {
      return 'Very Active';
    } else if (goal == 'gain_endurance') {
      return 'Active';
    } else {
      return 'Moderate';
    }
  }

  // ========== GET USER PROFILE DATA ==========
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final response = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // ========== CHECK IF PROFILE IS COMPLETE ==========
  Future<bool> isProfileComplete() async {
    try {
      final profile = await getUserProfile();

      if (profile == null) return false;

      // Check if all required fields are filled
      return profile['gender'] != null &&
          profile['age'] != null &&
          profile['current_weight'] != null &&
          profile['height'] != null &&
          profile['fitness_goal'] != null;
    } catch (e) {
      print('Error checking profile completion: $e');
      return false;
    }
  }

  // ========== DELETE UNCONFIRMED USER (FOR TESTING) ==========
  Future<void> deleteUnconfirmedUser(String email) async {
    try {
      // This is a development helper
      // In production, use Supabase Dashboard or admin API
      print('⚠️ This requires admin privileges');
      print('Go to Supabase Dashboard → Authentication → Users');
      print('Find user with email: $email');
      print('Delete manually if email is not confirmed');
    } catch (e) {
      print('Error: $e');
    }
  }
}
