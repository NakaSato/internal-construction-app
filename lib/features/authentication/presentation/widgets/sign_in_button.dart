import 'package:flutter/material.dart';

/// Custom sign-in button widget with loading states and animations
class SignInButton extends StatelessWidget {
  const SignInButton({
    super.key,
    required this.isLoading,
    required this.isSmallScreen,
    required this.onPressed,
    required this.buttonScaleAnimation,
    required this.buttonHeight,
  });

  final bool isLoading;
  final bool isSmallScreen;
  final VoidCallback onPressed;
  final Animation<double> buttonScaleAnimation;
  final double buttonHeight;

  @override
  Widget build(BuildContext context) {
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final loadingSize = isSmallScreen ? 16.0 : 20.0;

    return AnimatedBuilder(
      animation: buttonScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: buttonScaleAnimation.value,
          child: Container(
            height: buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF4CAF50),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: loadingSize,
                          height: loadingSize,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Signing In...',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: fontSize,
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
}
