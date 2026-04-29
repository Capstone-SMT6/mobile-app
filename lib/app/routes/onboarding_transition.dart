import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A carousel-style horizontal slide transition where BOTH the outgoing
/// and incoming pages move together on the same horizontal axis —
/// exactly like swiping between cards in a carousel.
class OnboardingCarouselTransition extends CustomTransition {
  OnboardingCarouselTransition();

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.horizontal,
      // Disable the default fade so the slide feels clean and opaque
      fillColor: const Color(0xFF101216),
      child: child,
    );
  }
}
