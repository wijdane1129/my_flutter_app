import 'package:flutter/material.dart';

class CustomPageTransition extends PageRouteBuilder {
  final Widget page;

  CustomPageTransition({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          var offsetAnimation = animation.drive(tween);

          var fadeAnimation = animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
          );

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
}
