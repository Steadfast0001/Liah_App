import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';

/// Monitors user touch/pointer interaction and forces a logout after [timeoutDuration] of inactivity.
class SessionTimeoutListener extends ConsumerStatefulWidget {
  const SessionTimeoutListener({
    super.key,
    required this.child,
    this.timeoutDuration = const Duration(minutes: 15),
    this.onTimeout,
  });

  final Widget child;
  final Duration timeoutDuration;
  final VoidCallback? onTimeout;

  @override
  ConsumerState<SessionTimeoutListener> createState() =>
      _SessionTimeoutListenerState();
}

class _SessionTimeoutListenerState
    extends ConsumerState<SessionTimeoutListener> {
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(widget.timeoutDuration, _handleTimeout);
  }

  Future<void> _handleTimeout() async {
    final currentSession =
        await ref.read(authRepositoryProvider).currentSession();
    if (currentSession != null) {
      await ref.read(authRepositoryProvider).signOut();
      if (widget.onTimeout != null) {
        widget.onTimeout!();
      }
    }
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
