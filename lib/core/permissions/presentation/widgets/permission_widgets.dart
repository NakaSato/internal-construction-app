import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/authentication/application/auth_bloc.dart';
import '../../../../features/authentication/application/auth_state.dart';
import '../../domain/services/permission_service.dart';
import '../../../di/injection.dart';

/// Widget that conditionally renders content based on user permissions
class PermissionBuilder extends StatelessWidget {
  const PermissionBuilder({
    super.key,
    required this.resource,
    required this.action,
    required this.builder,
    this.fallback,
    this.loading,
  });

  final String resource;
  final String action;
  final Widget Function(BuildContext context, bool hasPermission) builder;
  final Widget? fallback;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return fallback ?? const SizedBox.shrink();
        }

        return FutureBuilder<bool>(
          future: getIt<PermissionService>().hasPermission(
            authState.user.id,
            resource,
            action,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return loading ?? const SizedBox.shrink();
            }

            final hasPermission = snapshot.data ?? false;

            if (hasPermission) {
              return builder(context, true);
            } else {
              return fallback ?? const SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}

/// Widget that shows content only if user has permission
class PermissionWidget extends StatelessWidget {
  const PermissionWidget({
    super.key,
    required this.resource,
    required this.action,
    required this.child,
    this.fallback,
    this.loading,
  });

  final String resource;
  final String action;
  final Widget child;
  final Widget? fallback;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return PermissionBuilder(
      resource: resource,
      action: action,
      fallback: fallback,
      loading: loading,
      builder: (context, hasPermission) {
        return hasPermission ? child : (fallback ?? const SizedBox.shrink());
      },
    );
  }
}

/// Button that is enabled/disabled based on user permissions
class PermissionButton extends StatelessWidget {
  const PermissionButton({
    super.key,
    required this.resource,
    required this.action,
    required this.onPressed,
    required this.child,
    this.style,
    this.disabledStyle,
    this.tooltip,
  });

  final String resource;
  final String action;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final ButtonStyle? disabledStyle;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return PermissionBuilder(
      resource: resource,
      action: action,
      builder: (context, hasPermission) {
        final button = ElevatedButton(
          onPressed: hasPermission ? onPressed : null,
          style: hasPermission ? style : (disabledStyle ?? style),
          child: child,
        );

        if (tooltip != null && !hasPermission) {
          return Tooltip(message: tooltip!, child: button);
        }

        return button;
      },
    );
  }
}

/// FloatingActionButton that shows only if user has permission
class PermissionFloatingActionButton extends StatelessWidget {
  const PermissionFloatingActionButton({
    super.key,
    required this.resource,
    required this.action,
    required this.onPressed,
    this.child,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.heroTag,
  });

  final String resource;
  final String action;
  final VoidCallback? onPressed;
  final Widget? child;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return PermissionWidget(
      resource: resource,
      action: action,
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation,
        heroTag: heroTag,
        child: child,
      ),
    );
  }
}

/// AppBar actions that show only if user has permission
class PermissionAppBarAction extends StatelessWidget {
  const PermissionAppBarAction({
    super.key,
    required this.resource,
    required this.action,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final String resource;
  final String action;
  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return PermissionWidget(
      resource: resource,
      action: action,
      child: IconButton(icon: icon, onPressed: onPressed, tooltip: tooltip),
    );
  }
}

/// ListTile that shows only if user has permission
class PermissionListTile extends StatelessWidget {
  const PermissionListTile({
    super.key,
    required this.resource,
    required this.action,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.fallback,
  });

  final String resource;
  final String action;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return PermissionWidget(
      resource: resource,
      action: action,
      fallback: fallback,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

/// Tab that shows only if user has permission
class PermissionTab extends StatelessWidget {
  const PermissionTab({
    super.key,
    required this.resource,
    required this.action,
    this.text,
    this.icon,
    this.child,
  });

  final String resource;
  final String action;
  final String? text;
  final Widget? icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        return FutureBuilder<bool>(
          future: getIt<PermissionService>().hasPermission(
            authState.user.id,
            resource,
            action,
          ),
          builder: (context, snapshot) {
            final hasPermission = snapshot.data ?? false;

            if (!hasPermission) {
              return const SizedBox.shrink();
            }

            return Tab(text: text, icon: icon, child: child);
          },
        );
      },
    );
  }
}
