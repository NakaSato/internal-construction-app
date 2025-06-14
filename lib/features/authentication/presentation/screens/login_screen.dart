import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/error_message_widget.dart';
import '../../application/auth_bloc.dart';
import '../../application/auth_event.dart';
import '../../application/auth_state.dart';
import '../../domain/entities/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
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
  static const int _minUsernameLength = 3;
  static const int _minPasswordLength = 6;

  // Spacing Constants
  static const EdgeInsets _horizontalPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
  );
  static const EdgeInsets _containerPadding = EdgeInsets.symmetric(
    horizontal: 32,
    vertical: 28,
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
  }

  /// Sets up all animations used in the login screen
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
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
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
      padding: EdgeInsets.all(_iconContainerSize),
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
                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      // Top spacer to push content to bottom
                      const Expanded(flex: 1, child: SizedBox()),

                      // Bottom content area
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth:
                              400, // Max width for better desktop experience
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: _horizontalPadding,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Sign out option for already authenticated users
                              if (state is AuthAuthenticated) ...[
                                _buildSignOutHeader(context, state.user),
                                const SizedBox(height: 20),
                              ],

                              // Main login form
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: SlideTransition(
                                      position: _slideAnimation,
                                      child: _buildLoginForm(context),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Small bottom padding
                      const SizedBox(height: 20),
                    ],
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

  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16), // Reduced top spacing
          _buildHeader(context),
          const SizedBox(height: 24), // Reduced spacing before form
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
                    _buildInputFieldWrapper(child: _buildUsernameField()),
                    const SizedBox(
                      height: 24,
                    ), // Optimized space between credentials
                    _buildInputFieldWrapper(child: _buildPasswordField()),
                    const SizedBox(height: 28), // Space after credentials
                    _buildOptionsRow(),
                    const SizedBox(height: 28), // Optimal space before button
                    _buildSignInButton(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20), // Reduced spacing after form
          _buildSignUpSection(),
          const SizedBox(height: 16), // Minimal bottom spacing
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'CONSTRUCTION INTERNAL',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
            height: 1.2,
            fontSize: 40,
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
        const SizedBox(
          height: 12,
        ), // Optimized spacing between title and description
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ), // Consistent with main padding
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
                fontSize: 16,
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
        ),
      ],
    );
  }

  /// Builds the username input field with validation
  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      focusNode: _usernameFocusNode,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      enabled: !_isLoading,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.5,
      ),
      decoration: _buildInputDecoration(
        labelText: 'Username',
        hintText: 'Enter your username',
        prefixIcon: _buildPrefixIcon(Icons.person_rounded),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your username';
        }
        if (value.length < _minUsernameLength) {
          return 'Username must be at least $_minUsernameLength characters';
        }
        return null;
      },
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
      textInputAction: TextInputAction.done,
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
              color: const Color(
                0xFF4CAF50,
              ).withValues(alpha: 0.8), // Match theme
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
          return 'Please enter your password';
        }
        if (value.length < _minPasswordLength) {
          return 'Password must be at least $_minPasswordLength characters';
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleSignIn(),
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      children: [
        // Enhanced Remember me section with modern UI
        Expanded(
          child: InkWell(
            onTap: _isLoading
                ? null
                : () {
                    setState(() {
                      _rememberMe = !_rememberMe;
                    });
                  },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Custom animated checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _rememberMe
                            ? const Color(0xFF4CAF50)
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.6),
                        width: _rememberMe ? 2 : 1.5,
                      ),
                      color: _rememberMe
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                      boxShadow: _rememberMe
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF4CAF50,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: _rememberMe
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Enhanced text with better typography
                  Flexible(
                    child: Text(
                      'Remember me',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _rememberMe
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: _rememberMe
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Enhanced Forgot password button (no border)
        TextButton(
          onPressed: _isLoading
              ? null
              : () => context.go(AppRoutes.forgotPassword),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.04),
          ),
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
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
              onPressed: _isLoading ? null : _handleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: _loadingIndicatorSize,
                          height: _loadingIndicatorSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        const SizedBox(width: 16),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 500),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              'Signing In...',
                              key: ValueKey(_isLoading),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Sign In',
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

  Widget _buildSignUpSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : () => context.go(AppRoutes.register),
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignOutHeader(BuildContext context, User user) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? Text(
                    _getInitials(user),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signed in as',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  user.name.isNotEmpty ? user.name : user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _showSignOutDialog(context),
            icon: Icon(
              Icons.logout,
              size: 18,
              color: Theme.of(context).colorScheme.error,
            ),
            label: Text(
              'Sign Out',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(User user) {
    if (user.name.isNotEmpty) {
      final nameParts = user.name.split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      }
      return user.name[0].toUpperCase();
    }
    return user.email[0].toUpperCase();
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Sign Out',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out? You can sign in again with a different account.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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

    context.read<AuthBloc>().add(
      AuthSignInRequested(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }
}
