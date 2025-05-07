import 'package:flutter/material.dart';

// Define slide directions for our custom page route
enum SlideDirection {
  left,
  right,
  up,
  down,
}

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final SlideDirection direction;
  
  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset.zero;
      
      // Set the starting position based on direction
      switch (direction) {
        case SlideDirection.left:
          begin = const Offset(-1.0, 0.0);
          break;
        case SlideDirection.right:
          begin = const Offset(1.0, 0.0);
          break;
        case SlideDirection.up:
          begin = const Offset(0.0, -1.0);
          break;
        case SlideDirection.down:
          begin = const Offset(0.0, 1.0);
          break;
      }
      
      const end = Offset.zero;
      const curve = Curves.easeInOutCubic;
      
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}
