import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../common/utils/extensions.dart';
import '../../../../core/utils/username_utils.dart';
import '../../../../common/widgets/error_message_widget.dart';
import '../../application/auth_bloc.dart';
import '../../application/auth_event.dart';
import '../../application/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  // UI Constants
  static const double _containerBorderRadius = 18.0;
  static const double _iconContainerSize = 8.0;
  static const double _iconSize = 20.0;
  static const double _buttonHeight = 60.0;
  static const double _loadingIndicatorSize = 22.0;

  // Animation Constants
  static const Duration _animationDuration = Duration(milliseconds: 1200);
  static const Duration _buttonAnimationDuration = Duration(milliseconds: 150);
  static const Duration _backgroundZoomDuration = Duration(milliseconds: 20000);

  // Validation Constants
  static const int _minNameLength = 2;
  static const int _minPasswordLength = 6;

  // Spacing Constants
  static const EdgeInsets _horizontalPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
  );
  static const EdgeInsets _containerPadding = EdgeInsets.symmetric(
    horizontal: 28, // Reduced from 32
    vertical: 24, // Reduced from 28
  );
  static const EdgeInsets _containerMargin = EdgeInsets.symmetric(
    horizontal: 12.0,
  );
  static const EdgeInsets _inputContentPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 12.0,
  );

  // Form controllers and focus nodes
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // State variables
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

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
  }

  /// Sets up all animations used in the register screen
  /// Includes fade-in, slide, button scale, and background zoom animations
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: _buttonAnimationDuration,
      vsync: this,
    );

    _backgroundZoomController = AnimationController(
      duration: _backgroundZoomDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          ),
        );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _backgroundZoomAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _backgroundZoomController, curve: Curves.linear),
    );

    _animationController.forward();
    _backgroundZoomController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _animationController.dispose();
    _buttonAnimationController.dispose();
    _backgroundZoomController.dispose();
    super.dispose();
  }

  // Helper method to create consistent input decoration
  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      hintText: hintText,
      hintStyle: TextStyle(
        color: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        fontSize: 15,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: _buildOutlineInputBorder(),
      enabledBorder: _buildOutlineInputBorder(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
      ),
      focusedBorder: _buildOutlineInputBorder(
        color: const Color(0xFF4CAF50), // Green theme color
        width: 2.5,
      ),
      errorBorder: _buildOutlineInputBorder(
        color: Theme.of(context).colorScheme.error,
        width: 2,
      ),
      focusedErrorBorder: _buildOutlineInputBorder(
        color: Theme.of(context).colorScheme.error,
        width: 2.5,
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.9),
      contentPadding: _inputContentPadding,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
  }

  // Helper method to create consistent outline input border
  OutlineInputBorder _buildOutlineInputBorder({
    Color? color,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        16,
      ), // Slightly smaller radius for modern look
      borderSide: BorderSide(
        color:
            color ??
            Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        width: width,
      ),
    );
  }

  // Helper method to create consistent prefix icon container
  Widget _buildPrefixIcon(IconData iconData) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(_iconContainerSize),
      decoration: BoxDecoration(
        color: const Color(
          0xFF4CAF50,
        ).withValues(alpha: 0.12), // Green theme with transparency
        borderRadius: BorderRadius.circular(12), // More modern radius
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
          width: 1,
        ),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: _handleAuthStateChange,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Animated background with zoom effect
                Positioned.fill(child: _buildAnimatedBackground()),
                // Gradient overlay for energy theme
                Positioned.fill(
                  child: Container(
                    decoration: _buildBackgroundDecoration(context),
                  ),
                ),
                // Main content with improved scrolling
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                constraints.maxHeight *
                                0.85, // Even more reduced for register
                            maxWidth: 400,
                          ),
                          child: Column(
                            children: [
                              // Flexible top spacer (smaller on small screens)
                              SizedBox(
                                height: constraints.maxHeight < 700
                                    ? 20
                                    : constraints.maxHeight *
                                          0.2, // Even smaller for register
                              ),

                              // Bottom content area
                              Padding(
                                padding: _horizontalPadding,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Main register form
                                    AnimatedBuilder(
                                      animation: _animationController,
                                      builder: (context, child) {
                                        return FadeTransition(
                                          opacity: _fadeAnimation,
                                          child: SlideTransition(
                                            position: _slideAnimation,
                                            child: _buildRegisterForm(context),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Small bottom padding
                              const SizedBox(height: 20),
                            ],
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
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10), // Reduced top spacing
          _buildHeader(context),
          const SizedBox(height: 20), // Reduced spacing before form
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 380,
              ), // Optimal form width
              child: Container(
                padding: _containerPadding,
                margin: _containerMargin,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(_containerBorderRadius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFFCDDC39).withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputFieldWrapper(child: _buildNameField()),
                    const SizedBox(height: 16), // Reduced spacing
                    _buildInputFieldWrapper(child: _buildEmailField()),
                    const SizedBox(height: 16), // Reduced spacing
                    _buildInputFieldWrapper(child: _buildPasswordField()),
                    const SizedBox(height: 16), // Reduced spacing
                    _buildInputFieldWrapper(
                      child: _buildConfirmPasswordField(),
                    ),
                    const SizedBox(height: 24), // Reduced space before button
                    _buildRegisterButton(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16), // Reduced spacing after form
          _buildLoginLink(),
          const SizedBox(height: 12), // Reduced bottom spacing
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'CREATE ACCOUNT',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
            height: 1.2,
            fontSize: 32, // Reduced from 40 for better space utilization
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 8,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8), // Reduced from 12
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Join the solar energy revolution',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
              fontSize: 14, // Reduced from 16
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                  color: Colors.black.withValues(alpha: 0.2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Builds the name input field with validation
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      enabled: !_isLoading,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.5,
      ),
      decoration: _buildInputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter your full name',
        prefixIcon: _buildPrefixIcon(Icons.person_rounded),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your full name';
        }
        if (value.trim().length < _minNameLength) {
          return 'Name must be at least $_minNameLength characters';
        }
        return null;
      },
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_emailFocusNode);
      },
    );
  }

  /// Builds the email input field with validation
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: !_isLoading,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.5,
      ),
      decoration: _buildInputDecoration(
        labelText: 'Email Address',
        hintText: 'Enter your email address',
        prefixIcon: _buildPrefixIcon(Icons.email_rounded),
      ),
      validator: (value) => value?.validateEmail(),
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
    );
  }

  /// Builds the password input field with visibility toggle and validation
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      enabled: !_isLoading,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.5,
      ),
      decoration: _buildInputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: _buildPrefixIcon(Icons.lock_rounded),
        suffixIcon: Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: const Color(0xFF4CAF50).withValues(alpha: 0.8),
              size: 22,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(40, 40),
              backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < _minPasswordLength) {
          return 'Password must be at least $_minPasswordLength characters';
        }
        return null;
      },
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
      },
    );
  }

  /// Builds the confirm password input field with validation
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocusNode,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      enabled: !_isLoading,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.5,
      ),
      decoration: _buildInputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Confirm your password',
        prefixIcon: _buildPrefixIcon(Icons.lock_outline_rounded),
        suffixIcon: Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: const Color(0xFF4CAF50).withValues(alpha: 0.8),
              size: 22,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(40, 40),
              backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleRegister(),
    );
  }

  Widget _buildRegisterButton() {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: Container(
            height: _buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF4CAF50), // Solid green color
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: _loadingIndicatorSize,
                          height: _loadingIndicatorSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Creating Account...',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 15,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 4,
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : () => context.go(AppRoutes.login),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white.withValues(alpha: 0.1),
          ),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                  color: Colors.black.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
        ),
      ],
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
    }
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    // Add button press animation
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    // Unfocus any focused fields
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();

    // Generate a valid username from email using utility function
    final username = UsernameUtils.generateUsernameFromEmail(email);

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        username: username,
        email: email,
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        roleId: 3, // Default role ID for user
      ),
    );
  }
}
