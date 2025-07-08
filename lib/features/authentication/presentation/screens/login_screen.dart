import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../common/widgets/error_message_widget.dart';
import '../../application/auth_cubit.dart';
import '../../application/auth_state.dart';
import '../../domain/entities/user.dart';
import '../widgets/login_header.dart';
import '../widgets/username_field.dart';
import '../widgets/password_field.dart';
import '../widgets/remember_me_checkbox.dart';
import '../widgets/forgot_password_button.dart';
import '../widgets/sign_in_button.dart';
import '../widgets/sign_out_header.dart';
import '../widgets/login_form_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // UI Constants (More Compact)
  static const double _containerBorderRadius = 16.0;
  static const double _iconContainerSize = 6.0;
  static const double _iconSize = 18.0;
  static const double _buttonHeight = 48.0;

  // Animation Constants
  static const Duration _animationDuration = Duration(milliseconds: 800);
  static const Duration _buttonAnimationDuration = Duration(milliseconds: 120);
  static const Duration _backgroundZoomDuration = Duration(milliseconds: 15000);

  // Validation Constants
  static const int _minUsernameLength = 3;
  static const int _minPasswordLength = 6;

  // Responsive Breakpoints (More Compact)
  static const double _smallScreenHeight = 650;
  static const double _mediumScreenHeight = 750;
  static const double _smallScreenWidth = 380;
  static const double _mediumScreenWidth = 420;

  // Spacing Constants (Reduced for compact design)
  static const EdgeInsets _containerPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 20);
  static const EdgeInsets _containerMargin = EdgeInsets.symmetric(horizontal: 8.0);

  // Form controllers and focus nodes
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // State variables
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  // Animation controllers and animations
  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _backgroundZoomController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _backgroundZoomAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSavedPreferences();
  }

  /// Load saved username and remember me preference from storage
  Future<void> _loadSavedPreferences() async {
    try {
      final preferences = await context.read<AuthCubit>().loadSavedPreferences();
      final savedUsername = preferences['username'] as String?;
      final rememberMe = preferences['rememberMe'] as bool? ?? false;

      if (mounted && savedUsername != null && savedUsername.isNotEmpty) {
        setState(() {
          _usernameController.text = savedUsername;
          _rememberMe = rememberMe;
          // Clear password field when username is auto-filled for security
          _passwordController.clear();
        });
      }
    } catch (e) {
      // Handle error silently, no need to show error for preference loading
      debugPrint('Error loading saved preferences: $e');
    }
  }

  /// Clear saved login preferences
  Future<void> _clearSavedPreferences() async {
    try {
      final authCubit = context.read<AuthCubit>();
      await authCubit.clearSavedPreferences();

      if (mounted) {
        setState(() {
          _usernameController.clear();
          _passwordController.clear();
          _rememberMe = false;
        });

        // Show a brief confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved login cleared'),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error clearing saved preferences: $e');
    }
  }

  /// Sets up all animations used in the login screen
  /// Includes fade-in, slide, button scale, and background zoom animations
  void _setupAnimations() {
    _animationController = AnimationController(duration: _animationDuration, vsync: this);

    _buttonAnimationController = AnimationController(duration: _buttonAnimationDuration, vsync: this);

    _backgroundZoomController = AnimationController(duration: _backgroundZoomDuration, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _buttonAnimationController, curve: Curves.easeInOut));

    _backgroundZoomAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _backgroundZoomController, curve: Curves.linear));

    _animationController.forward();
    _backgroundZoomController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    _buttonAnimationController.dispose();
    _backgroundZoomController.dispose();
    super.dispose();
  }

  // Helper method to create consistent input decoration with responsive sizing
  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    final isSmallScreen = _isSmallScreen(context);
    final labelFontSize = isSmallScreen ? 12.0 : 13.0; // Increased for better readability
    final hintFontSize = isSmallScreen ? 14.0 : 15.0; // Increased for better UX

    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
        fontWeight: FontWeight.w500,
        fontSize: labelFontSize,
      ),
      hintText: hintText,
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        fontSize: hintFontSize,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: _buildOutlineInputBorder(),
      enabledBorder: _buildOutlineInputBorder(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
      focusedBorder: _buildOutlineInputBorder(
        color: const Color(0xFF4CAF50), // Green theme color
        width: 2.5,
      ),
      errorBorder: _buildOutlineInputBorder(color: Theme.of(context).colorScheme.error, width: 2),
      focusedErrorBorder: _buildOutlineInputBorder(color: Theme.of(context).colorScheme.error, width: 2.5),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.9),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10.0 : 12.0, // Increased for better spacing
        vertical: isSmallScreen ? 12.0 : 14.0, // Increased for better UX
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
  }

  // Helper method to create consistent outline input border
  OutlineInputBorder _buildOutlineInputBorder({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14), // Smaller radius for compact look
      borderSide: BorderSide(
        color: color ?? Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        width: width,
      ),
    );
  }

  // Helper method to create consistent prefix icon container
  Widget _buildPrefixIcon(IconData iconData) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(_iconContainerSize),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.12), // Green theme with transparency
        borderRadius: BorderRadius.circular(10), // Smaller radius for compact design
        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.2), width: 1),
      ),
      child: Icon(
        iconData,
        color: const Color(0xFF4CAF50), // Consistent green theme
        size: _iconSize,
      ),
    );
  }

  // Helper method to wrap input fields with subtle shadow effect
  Widget _buildInputFieldWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 1)),
          BoxShadow(color: const Color(0xFF4CAF50).withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: _handleAuthStateChange,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Animated background with zoom effect
                Positioned.fill(child: _buildAnimatedBackground()),
                // Gradient overlay for energy theme
                Positioned.fill(child: Container(decoration: _buildBackgroundDecoration(context))),
                // Main content with perfect centering
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = _isSmallScreen(context);
                      final screenHeight = constraints.maxHeight;
                      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                      final isKeyboardOpen = keyboardHeight > 0;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: screenHeight, maxWidth: double.infinity),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Responsive top spacer
                                SizedBox(height: _getTopSpacing(screenHeight, isKeyboardOpen, isSmallScreen)),

                                // Sign out option for already authenticated users
                                if (state is AuthAuthenticated) ...[
                                  _buildSignOutHeader(context, state.user),
                                  SizedBox(height: isSmallScreen ? 12 : 16),
                                ],

                                // Main login form - perfectly centered
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: SlideTransition(
                                        position: _slideAnimation,
                                        child: Center(child: _buildLoginForm(context)),
                                      ),
                                    );
                                  },
                                ),

                                // Responsive bottom spacer
                                SizedBox(height: _getBottomSpacing(screenHeight, isKeyboardOpen, isSmallScreen)),

                                // Bottom safe area padding
                                SizedBox(height: isKeyboardOpen ? 0 : (isSmallScreen ? 12 : 16)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Creates the solar energy themed gradient background decoration
  BoxDecoration _buildBackgroundDecoration(BuildContext context) {
    return BoxDecoration(
      // Solar energy gradient overlay
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1B5E20).withValues(alpha: 0.8), // Dark green
          const Color(0xFF2E7D32).withValues(alpha: 0.6), // Medium green
          const Color(0xFF4CAF50).withValues(alpha: 0.4), // Light green
          const Color(0xFF8BC34A).withValues(alpha: 0.2), // Energy green
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),
    );
  }

  /// Builds the animated background with solar panel image and zoom effect
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundZoomAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _backgroundZoomAnimation.value,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/bg.jpg'), fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final isSmallScreen = _isSmallScreen(context);
    final responsivePadding = _getResponsivePadding(context);
    final responsiveMargin = _getResponsiveMargin(context);
    final responsiveMaxWidth = _getResponsiveMaxWidth(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: responsiveMaxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header section
          LoginHeader(isSmallScreen: isSmallScreen, screenWidth: MediaQuery.of(context).size.width),
          SizedBox(height: isSmallScreen ? 16 : 24),

          // Login form container
          LoginFormContainer(
            formKey: _formKey,
            isSmallScreen: isSmallScreen,
            responsivePadding: responsivePadding,
            responsiveMargin: responsiveMargin,
            containerBorderRadius: _containerBorderRadius,
            usernameField: _buildInputFieldWrapper(
              child: UsernameField(
                controller: _usernameController,
                focusNode: _usernameFocusNode,
                passwordFocusNode: _passwordFocusNode,
                isLoading: _isLoading,
                buildInputDecoration: _buildInputDecoration,
                buildPrefixIcon: _buildPrefixIcon,
                minUsernameLength: _minUsernameLength,
              ),
            ),
            passwordField: _buildInputFieldWrapper(
              child: PasswordField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                isLoading: _isLoading,
                obscurePassword: _obscurePassword,
                onTogglePasswordVisibility: () {
                  // Add haptic feedback for better user experience
                  HapticFeedback.lightImpact();
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                onFieldSubmitted: _handleSignIn,
                buildInputDecoration: _buildInputDecoration,
                buildPrefixIcon: _buildPrefixIcon,
                minPasswordLength: _minPasswordLength,
              ),
            ),
            optionsRow: _buildOptionsRow(),
            signInButton: _buildSignInButton(),
          ),
        ],
      ),
    );
  }

  /// Builds the options row with remember me checkbox and forgot password button
  Widget _buildOptionsRow() {
    final isSmallScreen = _isSmallScreen(context);

    return Row(
      children: [
        // Enhanced Remember me section with modern UI
        RememberMeCheckbox(
          rememberMe: _rememberMe,
          onToggle: () {
            setState(() {
              _rememberMe = !_rememberMe;
            });
          },
          onLongPress: _clearSavedPreferences,
          isLoading: _isLoading,
          isSmallScreen: isSmallScreen,
        ),
        // Enhanced Forgot password button (responsive)
        ForgotPasswordButton(isLoading: _isLoading, isSmallScreen: isSmallScreen),
      ],
    );
  }

  /// Builds the sign in button with loading indicator
  Widget _buildSignInButton() {
    final isSmallScreen = _isSmallScreen(context);
    final buttonHeight = isSmallScreen ? 44.0 : _buttonHeight;

    return SignInButton(
      isLoading: _isLoading,
      isSmallScreen: isSmallScreen,
      onPressed: _handleSignIn,
      buttonScaleAnimation: _buttonScaleAnimation,
      buttonHeight: buttonHeight,
    );
  }

  Widget _buildSignOutHeader(BuildContext context, User user) {
    return SignOutHeader(user: user, onSignOut: () => _showSignOutDialog(context));
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Sign Out',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to sign out? You can sign in again with a different account.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthCubit>().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  void _handleAuthStateChange(BuildContext context, AuthState state) {
    setState(() {
      _isLoading = state is AuthLoading;
    });

    if (state is AuthAuthenticated) {
      context.go(AppRoutes.home);
    } else if (state is AuthFailure) {
      ApiErrorSnackBar.show(context, state.message);
    } else if (state is AuthPasswordResetSent) {
      ApiErrorSnackBar.showSuccess(context, 'Password reset email sent!');
    }
  }

  void _handleSignIn() {
    if (!_formKey.currentState!.validate()) return;

    // Add button press animation
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    // Unfocus any focused fields
    FocusScope.of(context).unfocus();

    context.read<AuthCubit>().signIn(
      email: _usernameController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );
  }

  // Helper methods for responsive design
  bool _isSmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.height < _smallScreenHeight || size.width < _smallScreenWidth;
  }

  bool _isMediumScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.height < _mediumScreenHeight || size.width < _mediumScreenWidth;
  }

  /// Calculate responsive top spacing for proper centering
  double _getTopSpacing(double screenHeight, bool isKeyboardOpen, bool isSmallScreen) {
    if (isKeyboardOpen) {
      return isSmallScreen ? 16.0 : 24.0;
    }

    // Calculate spacing based on screen size for perfect centering
    final baseSpacing = screenHeight * 0.12;

    if (isSmallScreen) {
      return baseSpacing.clamp(16.0, 60.0);
    }

    return baseSpacing.clamp(32.0, 80.0);
  }

  /// Calculate responsive bottom spacing for proper centering
  double _getBottomSpacing(double screenHeight, bool isKeyboardOpen, bool isSmallScreen) {
    if (isKeyboardOpen) {
      return isSmallScreen ? 16.0 : 24.0;
    }

    // Calculate spacing based on screen size for perfect centering
    final baseSpacing = screenHeight * 0.12;

    if (isSmallScreen) {
      return baseSpacing.clamp(16.0, 60.0);
    }

    return baseSpacing.clamp(32.0, 80.0);
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    if (_isSmallScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0);
    } else if (_isMediumScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0);
    }
    return _containerPadding;
  }

  EdgeInsets _getResponsiveMargin(BuildContext context) {
    if (_isSmallScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 2.0);
    }
    return _containerMargin;
  }

  double _getResponsiveMaxWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (_isSmallScreen(context)) {
      return screenWidth * 0.95; // 95% of screen width for small screens
    } else if (_isMediumScreen(context)) {
      return 380; // Smaller fixed width for medium screens
    }
    return 400; // Smaller fixed width for large screens
  }
}
