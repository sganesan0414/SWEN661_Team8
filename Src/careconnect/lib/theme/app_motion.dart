import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Motion design tokens.
///
/// Every animated surface in the app pulls its timing from here so that
/// transitions feel like one system rather than a per-screen decision.
class AppDurations {
  /// State flips that must feel immediate (colour, border, opacity).
  static const Duration fast = Duration(milliseconds: 150);

  /// The default: content swaps, expanding sections, button state changes.
  static const Duration normal = Duration(milliseconds: 250);

  /// Entrances and larger layout shifts.
  static const Duration slow = Duration(milliseconds: 350);

  /// Screen-to-screen navigation.
  static const Duration page = Duration(milliseconds: 300);

  /// Delay added per item when a list staggers itself in.
  static const Duration stagger = Duration(milliseconds: 45);

  /// Longest an entrance stagger may run before every remaining item is
  /// revealed together — keeps long lists from crawling in.
  static const Duration maxStagger = Duration(milliseconds: 360);
}

/// Easing tokens. Decelerating curves on entry, accelerating on exit.
class AppCurves {
  static const Curve standard = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  /// A slight overshoot, reserved for celebratory confirmations.
  static const Curve emphasized = Curves.easeOutBack;
}

/// Reduced-motion support.
///
/// WCAG 2.1 SC 2.3.3 (Animation from Interactions) asks that motion triggered
/// by interaction can be disabled. The platform "reduce motion" setting is
/// surfaced by Flutter as [MediaQueryData.disableAnimations]; honouring it here
/// means a single check collapses every duration in the app to zero, so
/// animated widgets snap to their end state instead of moving.
extension MotionQuery on BuildContext {
  bool get reduceMotion => MediaQuery.maybeOf(this)?.disableAnimations ?? false;

  /// [d], or [Duration.zero] when the user has asked for reduced motion.
  Duration motion(Duration d) => reduceMotion ? Duration.zero : d;
}

/// A single page transition used on every platform.
///
/// Flutter's per-platform defaults mean the same push looks different on
/// Android and iOS. CareConnect's navigation is shallow and label-driven, so a
/// gentle fade with a short upward slide reads as "new content" everywhere
/// without the directional baggage of a platform slide.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (context.reduceMotion) return child;

    final fade = CurvedAnimation(parent: animation, curve: AppCurves.enter);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(fade);

    // The outgoing page fades back slightly so the two never fight for
    // attention mid-transition.
    final fadeOut = Tween<double>(begin: 1, end: 0.85).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: AppCurves.exit),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fadeOut, child: child),
      ),
    );
  }
}

/// Lifts its child into place once, on first build.
///
/// [index] staggers siblings in a list; the delay is capped by
/// [AppDurations.maxStagger] so a twenty-item list does not take a second to
/// finish arriving.
///
/// Deliberately translation-only, with no accompanying fade. Text rendered at
/// partial opacity blends toward the background, dropping below the 4.5:1
/// contrast ratio WCAG 2.1 SC 1.4.3 requires — for the whole length of the
/// entrance, on content that is on screen at first paint. Moving the child
/// without fading it keeps every label legible from the first frame while
/// still giving the list a sense of arrival.
class EntranceSlide extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;

  /// Distance in logical pixels the child travels upward into place.
  final double offset;

  const EntranceSlide({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = AppDurations.slow,
    this.offset = 12,
  });

  @override
  State<EntranceSlide> createState() => _EntranceSlideState();
}

class _EntranceSlideState extends State<EntranceSlide>
    with SingleTickerProviderStateMixin {
  /// Stagger is folded into the controller as a leading [Interval] rather than
  /// scheduled with a `Future.delayed`. A pending timer would otherwise outlive
  /// the frame and fail any widget test that pumps without settling.
  late final int _delayMs = (AppDurations.stagger.inMilliseconds * widget.index)
      .clamp(0, AppDurations.maxStagger.inMilliseconds);

  late final int _totalMs = widget.duration.inMilliseconds + _delayMs;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _totalMs),
  );

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Interval(_delayMs / _totalMs, 1, curve: AppCurves.enter),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (context.reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, widget.offset * (1 - _curve.value)),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Shakes its child horizontally whenever [trigger] changes to a new value.
///
/// Used to give an error an immediate physical read (the PIN pad) alongside the
/// text and haptic feedback, never as the only signal — colour and copy carry
/// the meaning for anyone with motion disabled.
class ShakeOnChange extends StatefulWidget {
  final Widget child;

  /// Any value; a change from the previous build starts a shake.
  final Object? trigger;

  const ShakeOnChange({super.key, required this.child, required this.trigger});

  @override
  State<ShakeOnChange> createState() => _ShakeOnChangeState();
}

class _ShakeOnChangeState extends State<ShakeOnChange>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void didUpdateWidget(covariant ShakeOnChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && !context.reduceMotion) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Three decaying oscillations.
        final t = _controller.value;
        final decay = (1 - t);
        final dx = decay * 10 * math.sin(t * math.pi * 6);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
